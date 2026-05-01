extends Node
class_name GameManager

# Central game state manager for session-level values.

const GameDataScript := preload("res://scripts/data/GameData.gd")
const PROGRESSION_SAVE_INTERVAL := 2.0
const WAVE_CLEAR_CURRENCY_REWARD := 2
const LEVEL_CLEAR_CURRENCY_REWARD := 10
const BOSS_CLEAR_CURRENCY_REWARD := 15
const DEBUG_GAMEPLAY_TRACE := false

signal score_changed(new_score: int)
signal xp_changed(new_xp: int)
signal level_changed(level_index: int, level_id: StringName, display_name: String)
signal wave_changed(new_wave: int)
signal boss_wave_changed(is_boss_wave_now: bool)
signal game_over_changed(is_game_over_now: bool)
signal victory_changed(is_victory_now: bool)
signal upgrade_options_requested(options: Array)
signal upgrade_selection_closed
signal upgrade_selected(upgrade_id: StringName)
signal permanent_upgrades_changed(upgrades: Dictionary)
signal highest_unlocked_level_changed(new_highest_unlocked_level: int)
signal loadout_changed
signal currency_changed(new_amount: int)
signal inventory_changed(inventory: Dictionary)
signal mission_progress_changed(summary: String)
signal player_level_changed(level: int, current_xp: int, required_xp: int)
signal boss_health_changed(current_hp: int, max_hp: int, visible: bool)

var score: int = 0
var xp: int = 0
var run_level: int = 1
var current_level_xp: int = 0
var xp_to_next_level: int = 5
var xp_drop_bonus_per_level: int = 1
var current_level: int = 1
var current_level_id: StringName = &""
var current_level_display_name: String = ""
var current_wave: int = 0
var is_boss_wave: bool = false
var is_paused: bool = false
var is_game_over: bool = false
var is_victory: bool = false
var is_upgrade_selection_active: bool = false
var is_gameplay_active: bool = true

var current_level_data: LevelData
var _levels: Array[LevelData] = []
var highest_unlocked_level: int = 1
var permanent_upgrades: Dictionary = {}
var soft_currency: int = 0
var selected_hero_id: String = "hero_knight"
var selected_weapon_id: String = "weapon_basic"
var selected_pet_id: String = "pet_drone"
var unlocked_heroes: Array = ["hero_knight"]
var unlocked_weapons: Array = ["weapon_basic"]
var unlocked_pets: Array = ["pet_drone"]
var inventory: Dictionary = {}
var mission_stats: Dictionary = {"kills": 0, "xp": 0, "wave": 0}
var _progression_loaded: bool = false
var _progression_save_dirty: bool = false
var _progression_save_timer: float = 0.0
var _game_data: RefCounted = GameDataScript.new()

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    # Only load data here. reset_game() is called by game.gd when
    # the gameplay scene starts, so we avoid duplicate signal emissions.
    _ensure_levels_loaded()
    _ensure_progression_loaded()

func _process(delta: float) -> void:
    if not _progression_save_dirty:
        return

    _progression_save_timer = maxf(_progression_save_timer - delta, 0.0)
    if _progression_save_timer <= 0.0:
        flush_progression_save()

func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_APPLICATION_PAUSED:
        flush_progression_save()

func reset_game() -> void:
    # Restore default session state for a fresh run.
    get_tree().paused = false
    _ensure_levels_loaded()
    _ensure_progression_loaded()
    score = 0
    xp = 0
    run_level = 1
    current_level_xp = 0
    xp_to_next_level = 5
    current_wave = 0
    is_boss_wave = false
    is_paused = false
    is_game_over = false
    is_victory = false
    is_upgrade_selection_active = false
    load_level_by_index(1)
    _update_gameplay_active()
    score_changed.emit(score)
    xp_changed.emit(xp)
    player_level_changed.emit(run_level, current_level_xp, xp_to_next_level)
    boss_wave_changed.emit(is_boss_wave)
    game_over_changed.emit(is_game_over)
    victory_changed.emit(is_victory)
    boss_health_changed.emit(0, 0, false)
    _reset_missions()
    upgrade_selection_closed.emit()

func pause_game() -> void:
    if is_game_over:
        return
    is_paused = true
    get_tree().paused = true
    _update_gameplay_active()

func resume_game() -> void:
    if is_game_over:
        return
    is_paused = false
    get_tree().paused = false
    _update_gameplay_active()

func add_score(amount: int) -> void:
    # Keep score changes centralized for future UI and progression hooks.
    score += max(amount, 0)
    score_changed.emit(score)
    if amount > 0:
        mission_stats["kills"] = int(mission_stats.get("kills", 0)) + amount
        add_currency(amount)
        if score % 3 == 0:
            grant_item("scrap", 1)
        _emit_mission_progress()

func add_xp(amount: int) -> void:
    var resolved_amount: int = max(amount, 0)
    xp += resolved_amount
    current_level_xp += resolved_amount
    mission_stats["xp"] = int(mission_stats.get("xp", 0)) + resolved_amount
    xp_changed.emit(xp)
    _emit_mission_progress()
    while current_level_xp >= xp_to_next_level:
        current_level_xp -= xp_to_next_level
        run_level += 1
        xp_to_next_level += 3
        player_level_changed.emit(run_level, current_level_xp, xp_to_next_level)
        begin_upgrade_selection()
        if is_upgrade_selection_active:
            return
    player_level_changed.emit(run_level, current_level_xp, xp_to_next_level)

func get_scaled_xp_drop(base_amount: int) -> int:
    var resolved_base: int = max(base_amount, 1)
    var level_bonus: int = max(current_level - 1, 0) * max(xp_drop_bonus_per_level, 0)
    return resolved_base + level_bonus

func set_wave(wave: int) -> void:
    current_wave = max(wave, 0)
    wave_changed.emit(current_wave)
    mission_stats["wave"] = max(int(mission_stats.get("wave", 0)), current_wave)
    _emit_mission_progress()

func set_boss_wave(is_boss_wave_now: bool) -> void:
    is_boss_wave = is_boss_wave_now
    boss_wave_changed.emit(is_boss_wave)

func trigger_game_over() -> void:
    if is_game_over or is_victory:
        return
    get_tree().paused = false
    is_paused = false
    is_game_over = true
    _update_gameplay_active()
    game_over_changed.emit(is_game_over)
    flush_progression_save()

func trigger_victory() -> void:
    if is_game_over or is_victory:
        return
    get_tree().paused = false
    is_paused = false
    is_upgrade_selection_active = false
    is_victory = true
    _update_gameplay_active()
    victory_changed.emit(is_victory)
    flush_progression_save()

    var scene_router := get_node_or_null("/root/SceneRouter") as SceneRouter
    if scene_router != null:
        scene_router.call_deferred("go_to_home")

func restart_game() -> void:
    # Intentional roguelike loop: restart always begins a fresh run from
    # level 1 with default session stats. Permanent upgrades are preserved
    # across runs via SaveManager.
    reset_game()
    var scene_router := get_node_or_null("/root/SceneRouter") as SceneRouter
    if scene_router != null:
        scene_router.go_to_game()

func unlock_permanent_upgrade(upgrade_id: StringName) -> bool:
    _ensure_progression_loaded()

    var definition: Dictionary = _game_data.get_permanent_upgrade_definition(String(upgrade_id))
    if definition.is_empty():
        return false

    var upgrade_key := String(upgrade_id)
    var current_rank := get_permanent_upgrade_rank(upgrade_id)
    var max_rank := int(definition.get("max_rank", 1))
    if current_rank >= max_rank:
        return false

    permanent_upgrades[upgrade_key] = current_rank + 1
    _save_progression()
    permanent_upgrades_changed.emit(permanent_upgrades.duplicate(true))
    return true

func get_permanent_upgrade_rank(upgrade_id: StringName) -> int:
    _ensure_progression_loaded()
    return int(permanent_upgrades.get(String(upgrade_id), 0))

func apply_permanent_upgrades(player: Player) -> void:
    _ensure_progression_loaded()
    if player == null:
        return

    var max_hp_rank := get_permanent_upgrade_rank(&"perm_max_hp")
    if max_hp_rank > 0:
        player.increase_max_hp(max_hp_rank * 2)

    var fire_rate_rank := get_permanent_upgrade_rank(&"perm_fire_rate")
    if fire_rate_rank > 0:
        player.reduce_fire_interval(0.04 * fire_rate_rank)

    var projectile_damage_rank := get_permanent_upgrade_rank(&"perm_projectile_damage")
    if projectile_damage_rank > 0:
        player.increase_projectile_damage(projectile_damage_rank)

func set_selected_loadout(hero_id: String, weapon_id: String, pet_id: String) -> void:
    _ensure_progression_loaded()
    if _game_data.has_hero(hero_id) and unlocked_heroes.has(hero_id):
        selected_hero_id = hero_id
    if _game_data.has_weapon(weapon_id) and unlocked_weapons.has(weapon_id):
        selected_weapon_id = weapon_id
    if _game_data.has_pet(pet_id) and unlocked_pets.has(pet_id):
        selected_pet_id = pet_id
    _save_progression()
    loadout_changed.emit()

func is_hero_unlocked(hero_id: String) -> bool:
    return unlocked_heroes.has(hero_id)

func is_weapon_unlocked(weapon_id: String) -> bool:
    return unlocked_weapons.has(weapon_id)

func is_pet_unlocked(pet_id: String) -> bool:
    return unlocked_pets.has(pet_id)

func get_selected_hero_definition() -> Dictionary:
    return get_hero_definition(selected_hero_id)

func get_selected_weapon_definition() -> Dictionary:
    return get_weapon_definition(selected_weapon_id)

func get_selected_pet_definition() -> Dictionary:
    return get_pet_definition(selected_pet_id)

func get_hero_definition(hero_id: String) -> Dictionary:
    return _game_data.get_hero_definition(hero_id)

func get_weapon_definition(weapon_id: String) -> Dictionary:
    return _game_data.get_weapon_definition(weapon_id)

func get_pet_definition(pet_id: String) -> Dictionary:
    return _game_data.get_pet_definition(pet_id)

func get_weapon_ids() -> Array:
    return _game_data.get_weapon_ids()

func get_hero_ids() -> Array:
    return _game_data.get_hero_ids()

func get_pet_ids() -> Array:
    return _game_data.get_pet_ids()

func get_display_name(definition: Dictionary, fallback: String) -> String:
    return str(definition.get("display_name", fallback))

func resolve_hero_model_scene(hero_id: String) -> PackedScene:
    return _game_data.resolve_hero_model_scene(hero_id)

func resolve_pet_model_scene(pet_id: String) -> PackedScene:
    return _game_data.resolve_pet_model_scene(pet_id)

func resolve_weapon_model_scene(weapon_id: String) -> PackedScene:
    return _game_data.resolve_weapon_model_scene(weapon_id)

func resolve_weapon_scene(weapon_id: String) -> PackedScene:
    return _game_data.resolve_weapon_scene(weapon_id)

func resolve_hero_model_path(hero_id: String) -> String:
    return _game_data.resolve_hero_model_path(hero_id)

func resolve_pet_model_path(pet_id: String) -> String:
    return _game_data.resolve_pet_model_path(pet_id)

func resolve_weapon_model_path(weapon_id: String) -> String:
    return _game_data.resolve_weapon_model_path(weapon_id)

func apply_selected_loadout(player: Player) -> void:
    if player == null:
        push_warning("Gameplay start trace: player spawn result=false; selected loadout was not applied.")
        return

    _validate_selected_loadout()
    if DEBUG_GAMEPLAY_TRACE:
        print("Gameplay start trace: selected_level_id=%s selected_hero_id=%s selected_weapon_id=%s" % [
            String(current_level_id),
            selected_hero_id,
            selected_weapon_id,
        ])
    var hero_definition := get_selected_hero_definition()
    var raw_model_path := str(hero_definition.get("model_scene_path", "")).strip_edges()
    hero_definition["model_scene_path"] = resolve_hero_model_path(selected_hero_id)
    hero_definition["model_fallback_used"] = raw_model_path != str(hero_definition["model_scene_path"])
    if DEBUG_GAMEPLAY_TRACE:
        print("Gameplay start trace: resolved_hero_scene_path=%s hero_fallback_used=%s" % [
            str(hero_definition.get("model_scene_path", "")),
            str(bool(hero_definition.get("model_fallback_used", false))),
        ])
    player.apply_hero_definition(hero_definition)
    var weapon_definition := get_selected_weapon_definition()
    var raw_weapon_model_path := str(weapon_definition.get("model_scene_path", "")).strip_edges()
    weapon_definition["model_scene_path"] = resolve_weapon_model_path(selected_weapon_id)
    weapon_definition["model_fallback_used"] = raw_weapon_model_path != str(weapon_definition["model_scene_path"])
    if DEBUG_GAMEPLAY_TRACE:
        print("Gameplay start trace: resolved_weapon_scene_path=%s weapon_fallback_used=%s" % [
            str(weapon_definition.get("model_scene_path", "")),
            str(bool(weapon_definition.get("model_fallback_used", false))),
        ])
    player.apply_weapon_definition(weapon_definition, false, false)
    var weapon_attached := player.attach_gameplay_weapon_visual(weapon_definition)
    if DEBUG_GAMEPLAY_TRACE:
        print("Gameplay start trace: player_spawn_result=true weapon_attach_result=%s player_path=%s" % [
            str(weapon_attached),
            str(player.get_path()),
        ])

    var hp_bonus := int(hero_definition.get("max_hp_bonus", 0))
    if hp_bonus != 0:
        player.increase_max_hp(hp_bonus)
    player.move_speed = max(player.move_speed + float(hero_definition.get("move_speed_bonus", 0.0)), 1.0)
    player.projectile_damage += int(hero_definition.get("projectile_damage_bonus", 0))
    player.hp_changed.emit(player.current_hp)

func add_currency(amount: int) -> void:
    _ensure_progression_loaded()
    soft_currency = max(soft_currency + max(amount, 0), 0)
    currency_changed.emit(soft_currency)
    _save_progression()

func grant_item(item_id: String, amount: int = 1) -> void:
    _ensure_progression_loaded()
    if item_id.is_empty() or amount <= 0:
        return
    inventory[item_id] = int(inventory.get(item_id, 0)) + amount
    inventory_changed.emit(inventory.duplicate(true))
    _save_progression()

func get_mission_summary() -> String:
    var lines := PackedStringArray()
    for mission in _game_data.get_missions():
        var stat := str(mission.get("stat", ""))
        var target := int(mission.get("target", 1))
        var value := clampi(int(mission_stats.get(stat, 0)), 0, target)
        lines.append("%s: %d/%d" % [mission.get("label", ""), value, target])
    return "\n".join(lines)

func update_boss_health(current_hp: int, max_hp: int, visible: bool = true) -> void:
    boss_health_changed.emit(max(current_hp, 0), max(max_hp, 1), visible)

func load_level_by_index(level_index: int) -> void:
    _ensure_levels_loaded()
    if _levels.is_empty():
        current_level = 1
        current_level_id = &"level_001"
        current_level_display_name = "Level 1"
        current_level_data = null
        level_changed.emit(current_level, current_level_id, current_level_display_name)
        wave_changed.emit(current_wave)
        return

    var resolved_index := clampi(level_index, 1, _levels.size())
    current_level = resolved_index
    current_level_data = _levels[resolved_index - 1]
    current_level_id = current_level_data.level_id
    current_level_display_name = current_level_data.display_name if not current_level_data.display_name.is_empty() else "Level %d" % current_level
    current_wave = 0
    is_boss_wave = false
    level_changed.emit(current_level, current_level_id, current_level_display_name)
    wave_changed.emit(current_wave)
    boss_wave_changed.emit(is_boss_wave)

func load_level_by_id(level_id: StringName) -> void:
    _ensure_levels_loaded()
    for index in range(_levels.size()):
        var level_data := _levels[index]
        if level_data.level_id == level_id:
            load_level_by_index(index + 1)
            return

func advance_to_next_level() -> void:
    _ensure_levels_loaded()
    if _levels.is_empty():
        load_level_by_index(1)
        return

    unlock_level(current_level + 1)

    var next_level := current_level + 1
    if next_level > _levels.size():
        next_level = 1
    load_level_by_index(next_level)

func complete_current_level() -> void:
    if is_game_over or is_victory:
        return

    _ensure_levels_loaded()
    var completed_level := current_level
    _grant_level_clear_rewards()
    unlock_level(completed_level + 1)
    flush_progression_save()

    if _is_final_level(completed_level):
        trigger_victory()
        return

    load_level_by_index(completed_level + 1)

func grant_wave_clear_reward(wave: int) -> void:
    if is_game_over or is_victory:
        return
    var reward: int = max(WAVE_CLEAR_CURRENCY_REWARD + max(wave - 1, 0), 1)
    add_currency(reward)

func unlock_level(level_index: int) -> void:
    _ensure_levels_loaded()
    _ensure_progression_loaded()

    var resolved_level: int = max(level_index, 1)
    if not _levels.is_empty():
        resolved_level = clampi(resolved_level, 1, _levels.size())

    if resolved_level <= highest_unlocked_level:
        return

    highest_unlocked_level = resolved_level
    _save_progression()
    highest_unlocked_level_changed.emit(highest_unlocked_level)

func begin_upgrade_selection() -> void:
    if is_game_over or is_victory:
        return
    if is_upgrade_selection_active:
        return

    is_upgrade_selection_active = true
    _update_gameplay_active()
    upgrade_options_requested.emit(_get_upgrade_options())

func select_upgrade(player: Player, upgrade_id: StringName) -> void:
    if not is_upgrade_selection_active:
        return

    _apply_upgrade(player, upgrade_id)
    is_upgrade_selection_active = false
    _update_gameplay_active()
    upgrade_selection_closed.emit()
    upgrade_selected.emit(upgrade_id)

func _update_gameplay_active() -> void:
    is_gameplay_active = not is_paused and not is_game_over and not is_victory and not is_upgrade_selection_active

func _ensure_levels_loaded() -> void:
    if not _levels.is_empty():
        return
    _levels = LevelLibrary.load_all_levels()

func _ensure_progression_loaded() -> void:
    if _progression_loaded:
        return

    var save_manager := get_node_or_null("/root/SaveManager") as SaveManager
    if save_manager != null:
        var save_data: Dictionary = save_manager.load_game()
        highest_unlocked_level = max(int(save_data.get("highest_unlocked_level", 1)), 1)
        soft_currency = max(int(save_data.get("soft_currency", 0)), 0)
        selected_hero_id = str(save_data.get("selected_hero_id", selected_hero_id))
        selected_weapon_id = str(save_data.get("selected_weapon_id", selected_weapon_id))
        selected_pet_id = str(save_data.get("selected_pet_id", selected_pet_id))
        var permanent_upgrades_value: Variant = save_data.get("permanent_upgrades", {})
        if typeof(permanent_upgrades_value) == TYPE_DICTIONARY:
            permanent_upgrades = permanent_upgrades_value
        var unlocked_heroes_value: Variant = save_data.get("unlocked_heroes", unlocked_heroes)
        if typeof(unlocked_heroes_value) == TYPE_ARRAY:
            unlocked_heroes = unlocked_heroes_value
        var unlocked_weapons_value: Variant = save_data.get("unlocked_weapons", unlocked_weapons)
        if typeof(unlocked_weapons_value) == TYPE_ARRAY:
            unlocked_weapons = unlocked_weapons_value
        var unlocked_pets_value: Variant = save_data.get("unlocked_pets", unlocked_pets)
        if typeof(unlocked_pets_value) == TYPE_ARRAY:
            unlocked_pets = unlocked_pets_value
        var inventory_value: Variant = save_data.get("inventory", {})
        if typeof(inventory_value) == TYPE_DICTIONARY:
            inventory = inventory_value
    _validate_selected_loadout()
    _progression_loaded = true
    highest_unlocked_level_changed.emit(highest_unlocked_level)
    permanent_upgrades_changed.emit(permanent_upgrades.duplicate(true))
    currency_changed.emit(soft_currency)
    inventory_changed.emit(inventory.duplicate(true))
    loadout_changed.emit()

func _save_progression() -> void:
    if not _progression_save_dirty:
        _progression_save_timer = PROGRESSION_SAVE_INTERVAL
    _progression_save_dirty = true

func flush_progression_save() -> void:
    if not _progression_save_dirty:
        return

    var save_manager := get_node_or_null("/root/SaveManager") as SaveManager
    if save_manager != null:
        save_manager.save_game(_get_progression_save_data())
    _progression_save_dirty = false
    _progression_save_timer = 0.0

func _get_progression_save_data() -> Dictionary:
    var save_version := SaveManager.SAVE_VERSION
    var settings: Dictionary = {}
    var save_manager := get_node_or_null("/root/SaveManager") as SaveManager
    if save_manager != null:
        save_version = int(save_manager.last_saved_snapshot.get("version", save_version))
        var settings_value: Variant = save_manager.last_saved_snapshot.get("settings", {})
        if typeof(settings_value) == TYPE_DICTIONARY:
            settings = (settings_value as Dictionary).duplicate(true)

    return {
        "version": save_version,
        "highest_unlocked_level": highest_unlocked_level,
        "permanent_upgrades": permanent_upgrades,
        "soft_currency": soft_currency,
        "selected_hero_id": selected_hero_id,
        "selected_weapon_id": selected_weapon_id,
        "selected_pet_id": selected_pet_id,
        "unlocked_heroes": unlocked_heroes,
        "unlocked_weapons": unlocked_weapons,
        "unlocked_pets": unlocked_pets,
        "inventory": inventory,
        "settings": settings,
    }

func _grant_level_clear_rewards() -> void:
    add_currency(max(LEVEL_CLEAR_CURRENCY_REWARD + current_level - 1, 1))
    if is_boss_wave:
        add_currency(BOSS_CLEAR_CURRENCY_REWARD)

func _is_final_level(level_index: int) -> bool:
    if _levels.is_empty():
        return true
    return level_index >= _levels.size()

func _validate_selected_loadout() -> void:
    _ensure_unlocked_contains(unlocked_heroes, "hero_knight")
    _ensure_unlocked_contains(unlocked_weapons, "weapon_basic")
    _ensure_unlocked_contains(unlocked_pets, "pet_drone")

    if not _game_data.has_hero(selected_hero_id) or not unlocked_heroes.has(selected_hero_id):
        selected_hero_id = "hero_knight"
    if not _game_data.has_weapon(selected_weapon_id) or not unlocked_weapons.has(selected_weapon_id):
        selected_weapon_id = "weapon_basic"
    if not _game_data.has_pet(selected_pet_id) or not unlocked_pets.has(selected_pet_id):
        selected_pet_id = "pet_drone"

func _ensure_unlocked_contains(items: Array, item_id: String) -> void:
    if not items.has(item_id):
        items.append(item_id)

func _get_upgrade_options() -> Array:
    var options: Array = _game_data.get_upgrade_options()
    options.shuffle()
    return options.slice(0, 3)

func _apply_upgrade(player: Player, upgrade_id: StringName) -> void:
    if player == null:
        return

    match upgrade_id:
        &"projectile_damage":
            player.increase_projectile_damage(1)
        &"fire_rate":
            player.reduce_fire_interval(0.08)
        &"max_hp":
            player.increase_max_hp(2)
        &"restore_hp":
            player.restore_hp(4)
        &"move_speed":
            player.move_speed += 0.5
        &"projectile_speed":
            player.projectile_speed += 3.0
        &"weapon_range":
            player.increase_weapon_range(4.0)
        &"projectile_count":
            player.increase_projectile_count(1)

func _reset_missions() -> void:
    mission_stats = {"kills": 0, "xp": 0, "wave": 0}
    _emit_mission_progress()

func _emit_mission_progress() -> void:
    mission_progress_changed.emit(get_mission_summary())
