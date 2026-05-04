extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game_manager := root.get_node_or_null("/root/GameManager") as GameManager
	var save_manager := root.get_node_or_null("/root/SaveManager") as SaveManager
	if game_manager == null or save_manager == null:
		push_error("Economy test failed: required autoloads missing.")
		quit(1)
		return

	game_manager.gold = 0
	game_manager.soft_currency = 0
	game_manager.xp = 0
	game_manager.current_level_xp = 0
	game_manager.xp_to_next_level = 999
	game_manager.run_xp_gain_multiplier = 1.0
	game_manager.run_gold_bonus_multiplier = 1.0
	game_manager.mission_stats = {"kills": 0, "xp": 0, "wave": 0}
	game_manager.gems = 0
	game_manager.shards = {}
	game_manager.energy = GameManager.ENERGY_MAX
	game_manager.last_energy_time = int(Time.get_unix_time_from_system())

	game_manager.add_currency("gold", 12)
	game_manager.add_currency("gems", 2)
	game_manager.add_currency("shard:pet_drone", 3)
	if game_manager.gold != 12 or game_manager.soft_currency != 12 or game_manager.gems != 2 or int(game_manager.shards.get("pet_drone", 0)) != 3:
		push_error("Economy test failed: currency additions did not update wallet.")
		quit(1)
		return
	game_manager.is_gameplay_active = true
	game_manager.set_run_reward_multiplier("gold_bonus_multiplier", 1.5)
	game_manager.add_run_gold_reward(10)
	if game_manager.gold != 27:
		push_error("Economy test failed: run gold multiplier did not apply.")
		quit(1)
		return
	game_manager.add_currency("gold", 10)
	if game_manager.gold != 37:
		push_error("Economy test failed: normal gold grant should not use run multiplier.")
		quit(1)
		return
	game_manager.set_run_reward_multiplier("xp_gain_multiplier", 1.5)
	game_manager.add_xp(4)
	if game_manager.xp != 6 or int(game_manager.mission_stats.get("xp", 0)) != 6:
		push_error("Economy test failed: run XP multiplier did not apply.")
		quit(1)
		return
	if game_manager.spend_currency("gems", 3):
		push_error("Economy test failed: overspending gems succeeded.")
		quit(1)
		return
	if not game_manager.spend_currency("gems", 1) or game_manager.gems != 1:
		push_error("Economy test failed: valid gem spend failed.")
		quit(1)
		return
	if not game_manager.try_start_run() or game_manager.energy != GameManager.ENERGY_MAX - 1:
		push_error("Economy test failed: starting run did not consume energy.")
		quit(1)
		return
	game_manager.energy = 0
	game_manager.last_energy_time = int(Time.get_unix_time_from_system()) - GameManager.ENERGY_REGEN_SECONDS
	game_manager.get_seconds_to_next_energy()
	if game_manager.energy < 1:
		push_error("Economy test failed: energy did not regenerate.")
		quit(1)
		return

	game_manager.flush_progression_save()
	if int(save_manager.last_saved_snapshot.get("gold", 0)) != game_manager.gold:
		push_error("Economy test failed: gold did not persist.")
		quit(1)
		return
	if int(save_manager.last_saved_snapshot.get("energy", 0)) != game_manager.energy:
		push_error("Economy test failed: energy did not persist.")
		quit(1)
		return
	game_manager.claimed_daily_reward_date = ""
	game_manager.daily_reward_day = ""
	if not game_manager.claim_daily_reward():
		push_error("Economy test failed: daily reward did not claim.")
		quit(1)
		return
	game_manager.record_daily_quest_progress("kills", 5)
	if not game_manager.get_daily_quest_summary().contains("5/50"):
		push_error("Economy test failed: daily quest progress did not update.")
		quit(1)
		return

	print("Economy test passed: wallet, spend guard, energy, regen, daily rewards, quests, and persistence work.")
	quit(0)
