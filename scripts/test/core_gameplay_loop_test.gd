extends SceneTree

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var game_manager := root.get_node_or_null("/root/GameManager") as GameManager
    var save_manager := root.get_node_or_null("/root/SaveManager") as SaveManager
    if game_manager == null or save_manager == null:
        push_error("Core loop test failed: required autoloads are missing.")
        quit(1)
        return

    var preserved_settings := {"music": 0.75, "sfx": 0.5}
    save_manager.last_saved_snapshot["settings"] = preserved_settings.duplicate(true)
    save_manager.last_saved_snapshot["version"] = SaveManager.SAVE_VERSION

    game_manager.reset_game()
    var currency_before := game_manager.soft_currency
    game_manager.grant_wave_clear_reward(2)
    game_manager.flush_progression_save()
    if int(save_manager.last_saved_snapshot.get("soft_currency", 0)) <= currency_before:
        push_error("Core loop test failed: wave clear reward did not persist.")
        quit(1)
        return
    if save_manager.last_saved_snapshot.get("settings", {}) != preserved_settings:
        push_error("Core loop test failed: progression flush dropped saved settings.")
        quit(1)
        return

    game_manager.load_level_by_index(1)
    game_manager.set_boss_wave(false)
    game_manager.complete_current_level()
    await process_frame
    if game_manager.current_level != 2 or game_manager.is_victory:
        push_error("Core loop test failed: non-final level clear did not advance to the next level.")
        quit(1)
        return

    game_manager.set_boss_wave(true)
    var before_victory_currency := game_manager.soft_currency
    game_manager.complete_current_level()
    await process_frame
    await process_frame

    if not game_manager.is_victory:
        push_error("Core loop test failed: final level clear did not trigger victory.")
        quit(1)
        return
    if game_manager.is_gameplay_active:
        push_error("Core loop test failed: gameplay stayed active after victory.")
        quit(1)
        return
    if int(save_manager.last_saved_snapshot.get("soft_currency", 0)) <= before_victory_currency:
        push_error("Core loop test failed: victory rewards were not persisted.")
        quit(1)
        return
    if int(save_manager.last_saved_snapshot.get("highest_unlocked_level", 1)) < 2:
        push_error("Core loop test failed: level unlock was not persisted.")
        quit(1)
        return
    if save_manager.last_saved_snapshot.get("settings", {}) != preserved_settings:
        push_error("Core loop test failed: victory flush dropped saved settings.")
        quit(1)
        return

    print("Core loop test passed: wave reward, victory reward, unlock, and save preservation.")
    quit(0)
