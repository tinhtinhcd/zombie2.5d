extends Node
class_name GameManager

# Central game state manager for session-level values.

const GameDataScript := preload("res://scripts/data/GameData.gd")
const UpgradeManagerScript := preload("res://scripts/systems/upgrade_manager.gd")
const DailyRewardsScript := preload("res://scripts/systems/daily_rewards.gd")
const PROGRESSION_SAVE_INTERVAL := 2.0
const WAVE_CLEAR_CURRENCY_REWARD := 2
const LEVEL_CLEAR_CURRENCY_REWARD := 10
const BOSS_CLEAR_CURRENCY_REWARD := 15
const ENERGY_MAX := 5
const ENERGY_REGEN_SECONDS := 600
const DEBUG_GAMEPLAY_TRACE := false
const TEST_UNLOCK_ALL_FEATURES := false

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
signal wallet_changed(gold: int, gems: int, shards: Dictionary)
signal energy_changed(energy: int, seconds_to_next: int)
signal inventory_changed(inventory: Dictionary)
signal mission_progress_changed(summary: String)
signal player_level_changed(level: int, current_xp: int, required_xp: int)
signal boss_health_changed(current_hp: int, max_hp: int, visible: bool)
signal guard_hire_requested(guard_id: StringName)

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
var run_xp_gain_multiplier: float = 1.0
var run_gold_bonus_multiplier: float = 1.0

var current_level_data: LevelData
var _levels: Array[LevelData] = []
var highest_unlocked_level: int = 1
var permanent_upgrades: Dictionary = {}
var soft_currency: int = 0
var gold: int = 0
var gems: int = 0
var shards: Dictionary = {}
var energy: int = ENERGY_MAX
var last_energy_time: int = 0
var daily_reward_day: String = ""
var last_login_date: String = ""
var claimed_daily_reward_date: String = ""
var login_streak: int = 0
var daily_quests: Array = []
var daily_quest_progress: Dictionary = {}
var selected_hero_id: String = "hero_knight"
var selected_weapon_id: String = "weapon_basic"
var selected_pet_id: String = "pet_drone"
var selected_guard_id: String = "guard_shooter"
var unlocked_heroes: Array = ["hero_knight"]
var unlocked_weapons: Array = ["weapon_basic"]
var weapon_levels: Dictionary = {}
var unlocked_pets: Array = ["pet_drone"]
var unlocked_guards: Array = ["guard_shooter"]
var pet_evolution_stages: Dictionary = {}
var pet_evolution_shards: int = 0
var pet_accessories: Dictionary = {}
var inventory: Dictionary = {}
var mission_stats: Dictionary = {"kills": 0, "xp": 0, "wave": 0}
var _progression_loaded: bool = false
var _progression_save_dirty: bool = false
var _progression_save_timer: float = 0.0
var _game_data: RefCounted = GameDataScript.new()
var _upgrade_manager: RefCounted = UpgradeManagerScript.new()
var _daily_rewards: RefCounted = DailyRewardsScript.new()
var audio_manager: AudioManager

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Only load data here. reset_game() is called by game.gd when
	# the gameplay scene starts, so we avoid duplicate signal emissions.
	_ensure_levels_loaded()
	_ensure_progression_loaded()
	_upgrade_manager.setup(self)
	_daily_rewards.setup(self)
	audio_manager = get_node_or_null("/root/AudioManager") as AudioManager

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
	run_xp_gain_multiplier = 1.0
	run_gold_bonus_multiplier = 1.0
	_upgrade_manager.reset_run()
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
		add_run_gold_reward(amount)
		if score % 3 == 0:
			grant_item("scrap", 1)
		record_daily_quest_progress("kills", amount)
		_emit_mission_progress()

func add_xp(amount: int) -> void:
	var resolved_amount: int = maxi(roundi(float(max(amount, 0)) * maxf(run_xp_gain_multiplier, 0.0)), 0)
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
	if audio_manager != null:
		audio_manager.play_sfx_event(&"game_over")
	add_currency("shard:%s" % selected_pet_id, 1)
	record_daily_quest_progress("runs", 1)
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
	if audio_manager != null:
		audio_manager.play_sfx_event(&"victory")
	add_currency("shard:%s" % selected_pet_id, 2)
	record_daily_quest_progress("runs", 1)
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
	if _game_data.has_hero(hero_id) and is_hero_unlocked(hero_id):
		selected_hero_id = hero_id
	if _game_data.has_weapon(weapon_id) and is_weapon_unlocked(weapon_id):
		selected_weapon_id = weapon_id
	if _game_data.has_pet(pet_id) and is_pet_unlocked(pet_id):
		selected_pet_id = pet_id
	_save_progression()
	loadout_changed.emit()

func set_selected_guard(guard_id: String) -> bool:
	_ensure_progression_loaded()
	if not _game_data.has_guardian(guard_id) or not is_guardian_unlocked(guard_id):
		return false
	selected_guard_id = guard_id
	_save_progression()
	loadout_changed.emit()
	return true

func is_hero_unlocked(hero_id: String) -> bool:
	if TEST_UNLOCK_ALL_FEATURES and _game_data.has_hero(hero_id):
		return true
	return unlocked_heroes.has(hero_id)

func is_weapon_unlocked(weapon_id: String) -> bool:
	if TEST_UNLOCK_ALL_FEATURES and _game_data.has_weapon(weapon_id):
		return true
	return unlocked_weapons.has(weapon_id)

func is_pet_unlocked(pet_id: String) -> bool:
	if TEST_UNLOCK_ALL_FEATURES and _game_data.has_pet(pet_id):
		return true
	return unlocked_pets.has(pet_id)

func is_guardian_unlocked(guardian_id: String) -> bool:
	if TEST_UNLOCK_ALL_FEATURES and _game_data.has_guardian(guardian_id):
		return true
	if unlocked_guards.has(guardian_id):
		return true
	var guardian := get_guardian(guardian_id)
	var unlock_condition := str(guardian.get("unlock_condition", ""))
	match unlock_condition:
		"", "starter_guard_unlock", "hire_upgrade":
			return true
		"level_2_clear":
			return highest_unlocked_level >= 3
		"collect_50_scrap":
			return int(inventory.get("scrap", 0)) >= 50
		"defeat_first_boss":
			return highest_unlocked_level >= 2
	return false

func get_selected_hero_definition() -> Dictionary:
	return get_hero_definition(selected_hero_id)

func get_selected_weapon_definition() -> Dictionary:
	return get_weapon_definition(selected_weapon_id)

func get_selected_pet_definition() -> Dictionary:
	return get_pet_definition(selected_pet_id)

func get_selected_guardian() -> Dictionary:
	return get_guardian(selected_guard_id)

func get_hero_definition(hero_id: String) -> Dictionary:
	return _game_data.get_hero_definition(hero_id)

func get_weapon_definition(weapon_id: String) -> Dictionary:
	var weapon: Dictionary = _game_data.get_weapon_definition(weapon_id)
	return _apply_weapon_level_to_definition(weapon)

func get_pet_definition(pet_id: String) -> Dictionary:
	return _game_data.get_pet_definition(pet_id)

func get_skill(skill_id: String) -> Dictionary:
	return _game_data.get_skill(skill_id)

func get_skills_for_hero(hero_id: String) -> Array:
	return _game_data.get_skills_for_hero(hero_id)

func get_guardian(guardian_id: String) -> Dictionary:
	return _game_data.get_guardian(guardian_id)

func get_guardian_ids() -> Array:
	return _game_data.get_guardian_ids()

func get_pet_evolution(pet_id: String) -> Dictionary:
	return _game_data.get_pet_evolution(pet_id)

func get_pet_accessory(accessory_id: String) -> Dictionary:
	return _game_data.get_pet_accessory(accessory_id)

func get_upgrade_definition(upgrade_id: String) -> Dictionary:
	return _game_data.get_upgrade(upgrade_id)

func get_upgrade_options_raw() -> Array:
	return _game_data.get_upgrade_options()

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

func get_weapon_level(weapon_id: String) -> int:
	_ensure_progression_loaded()
	return clampi(int(weapon_levels.get(weapon_id, 1)), 1, 10)

func get_pet_evolution_stage(pet_id: String) -> int:
	_ensure_progression_loaded()
	return clampi(int(pet_evolution_stages.get(pet_id, 1)), 1, 3)

func get_pet_accessory_bonus(pet_id: String) -> float:
	_ensure_progression_loaded()
	var accessory_id := str(pet_accessories.get(pet_id, ""))
	if accessory_id.is_empty():
		return 0.0
	var accessory := get_pet_accessory(accessory_id)
	var accessory_pet_id := str(accessory.get("pet_id", "any"))
	if accessory_pet_id != "any" and accessory_pet_id != pet_id:
		return 0.0
	if str(accessory.get("modifier_type", "")) != "buff_multiplier_bonus":
		return 0.0
	return maxf(float(accessory.get("modifier_value", 0.0)), 0.0)

func get_pet_next_evolution_cost(pet_id: String) -> int:
	var evolution := get_pet_evolution(pet_id)
	var next_stage := get_pet_evolution_stage(pet_id) + 1
	var stages_value: Variant = evolution.get("stages", [])
	if typeof(stages_value) != TYPE_ARRAY:
		return 0
	for entry in stages_value:
		if typeof(entry) == TYPE_DICTIONARY and int((entry as Dictionary).get("stage", 0)) == next_stage:
			return int((entry as Dictionary).get("shard_cost", 0))
	return 0

func evolve_pet(pet_id: String) -> bool:
	_ensure_progression_loaded()
	if not is_pet_unlocked(pet_id):
		return false
	var current_stage := get_pet_evolution_stage(pet_id)
	if current_stage >= 3:
		return false
	var cost := get_pet_next_evolution_cost(pet_id)
	var available_shards := int(shards.get(pet_id, pet_evolution_shards))
	if available_shards < cost:
		return false
	available_shards -= cost
	shards[pet_id] = available_shards
	if pet_id == selected_pet_id:
		pet_evolution_shards = available_shards
	pet_evolution_stages[pet_id] = current_stage + 1
	_save_progression()
	loadout_changed.emit()
	return true

func get_weapon_upgrade_cost(weapon_id: String) -> int:
	var weapon: Dictionary = _game_data.get_weapon_definition(weapon_id)
	var level: int = get_weapon_level(weapon_id)
	var base_cost: int = max(int(weapon.get("upgrade_base_cost", 20)), 1)
	return max(roundi(float(base_cost) * pow(float(level), 1.5)), 1)

func can_upgrade_weapon(weapon_id: String) -> bool:
	return is_weapon_unlocked(weapon_id) and get_weapon_level(weapon_id) < 10 and soft_currency >= get_weapon_upgrade_cost(weapon_id)

func upgrade_weapon(weapon_id: String) -> bool:
	_ensure_progression_loaded()
	if not is_weapon_unlocked(weapon_id):
		return false
	var level := get_weapon_level(weapon_id)
	if level >= 10:
		return false
	var cost := get_weapon_upgrade_cost(weapon_id)
	if soft_currency < cost:
		return false
	soft_currency -= cost
	weapon_levels[weapon_id] = level + 1
	currency_changed.emit(soft_currency)
	_save_progression()
	loadout_changed.emit()
	return true

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

	player.move_speed = max(player.move_speed + float(hero_definition.get("move_speed_bonus", 0.0)), 1.0)
	player.projectile_damage += int(hero_definition.get("projectile_damage_bonus", 0))
	player.hp_changed.emit(player.current_hp)

func try_start_run() -> bool:
	_ensure_progression_loaded()
	_regenerate_energy()
	if energy <= 0:
		return false
	energy -= 1
	last_energy_time = _now()
	_save_progression()
	energy_changed.emit(energy, get_seconds_to_next_energy())
	return true

func add_currency(currency_type: Variant, amount: int = 0) -> void:
	_ensure_progression_loaded()
	if typeof(currency_type) == TYPE_STRING:
		_add_currency_by_type(str(currency_type), amount)
	else:
		_add_currency_by_type("gold", int(currency_type))
	currency_changed.emit(soft_currency)
	wallet_changed.emit(gold, gems, shards.duplicate(true))
	_save_progression()

func add_run_gold_reward(amount: int) -> void:
	_ensure_progression_loaded()
	_add_currency_by_type("gold", amount, true)
	currency_changed.emit(soft_currency)
	wallet_changed.emit(gold, gems, shards.duplicate(true))
	_save_progression()

func set_run_reward_multiplier(multiplier_type: String, multiplier: float) -> void:
	var resolved_multiplier := maxf(multiplier, 0.0)
	match multiplier_type:
		"xp_gain_multiplier":
			run_xp_gain_multiplier = maxf(run_xp_gain_multiplier, resolved_multiplier)
		"gold_bonus_multiplier":
			run_gold_bonus_multiplier = maxf(run_gold_bonus_multiplier, resolved_multiplier)

func spend_currency(currency_type: String, amount: int) -> bool:
	_ensure_progression_loaded()
	var spend_amount: int = max(amount, 0)
	match currency_type:
		"gold":
			if gold < spend_amount:
				return false
			gold -= spend_amount
			soft_currency = gold
		"gems":
			if gems < spend_amount:
				return false
			gems -= spend_amount
		_:
			if currency_type.begins_with("shard:"):
				var pet_id := currency_type.get_slice(":", 1)
				var current := int(shards.get(pet_id, 0))
				if current < spend_amount:
					return false
				shards[pet_id] = current - spend_amount
				if pet_id == selected_pet_id:
					pet_evolution_shards = int(shards.get(pet_id, 0))
			else:
				return false
	_save_progression()
	currency_changed.emit(soft_currency)
	wallet_changed.emit(gold, gems, shards.duplicate(true))
	return true

func claim_daily_reward() -> bool:
	_ensure_progression_loaded()
	var reward: Dictionary = _daily_rewards.claim_login_reward()
	if reward.is_empty():
		return false
	daily_reward_day = claimed_daily_reward_date
	_save_progression()
	return true

func get_daily_quest_summary() -> String:
	_ensure_progression_loaded()
	return _daily_rewards.get_summary()

func record_daily_quest_progress(stat: String, amount: int = 1) -> void:
	if _daily_rewards != null:
		_daily_rewards.record_progress(stat, amount)
		_save_progression()

func get_seconds_to_next_energy() -> int:
	_regenerate_energy()
	if energy >= ENERGY_MAX:
		return 0
	return max(ENERGY_REGEN_SECONDS - (_now() - last_energy_time), 0)

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
	add_run_gold_reward(reward)

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
		gold = max(int(save_data.get("gold", soft_currency)), 0)
		soft_currency = max(soft_currency, gold)
		gems = max(int(save_data.get("gems", 0)), 0)
		var shards_value: Variant = save_data.get("shards", {})
		if typeof(shards_value) == TYPE_DICTIONARY:
			shards = shards_value
		energy = clampi(int(save_data.get("energy", ENERGY_MAX)), 0, ENERGY_MAX)
		last_energy_time = int(save_data.get("last_energy_time", _now()))
		daily_reward_day = str(save_data.get("daily_reward_day", ""))
		last_login_date = str(save_data.get("last_login_date", ""))
		claimed_daily_reward_date = str(save_data.get("claimed_daily_reward_date", daily_reward_day))
		login_streak = clampi(int(save_data.get("login_streak", 0)), 0, 7)
		var daily_quests_value: Variant = save_data.get("daily_quests", [])
		if typeof(daily_quests_value) == TYPE_ARRAY:
			daily_quests = daily_quests_value
		var daily_quest_progress_value: Variant = save_data.get("daily_quest_progress", {})
		if typeof(daily_quest_progress_value) == TYPE_DICTIONARY:
			daily_quest_progress = daily_quest_progress_value
		_regenerate_energy()
		selected_hero_id = str(save_data.get("selected_hero_id", selected_hero_id))
		selected_weapon_id = str(save_data.get("selected_weapon_id", selected_weapon_id))
		selected_pet_id = str(save_data.get("selected_pet_id", selected_pet_id))
		selected_guard_id = str(save_data.get("selected_guard_id", selected_guard_id))
		var permanent_upgrades_value: Variant = save_data.get("permanent_upgrades", {})
		if typeof(permanent_upgrades_value) == TYPE_DICTIONARY:
			permanent_upgrades = permanent_upgrades_value
		var unlocked_heroes_value: Variant = save_data.get("unlocked_heroes", unlocked_heroes)
		if typeof(unlocked_heroes_value) == TYPE_ARRAY:
			unlocked_heroes = unlocked_heroes_value
		var unlocked_weapons_value: Variant = save_data.get("unlocked_weapons", unlocked_weapons)
		if typeof(unlocked_weapons_value) == TYPE_ARRAY:
			unlocked_weapons = unlocked_weapons_value
		var weapon_levels_value: Variant = save_data.get("weapon_levels", {})
		if typeof(weapon_levels_value) == TYPE_DICTIONARY:
			weapon_levels = weapon_levels_value
		var unlocked_pets_value: Variant = save_data.get("unlocked_pets", unlocked_pets)
		if typeof(unlocked_pets_value) == TYPE_ARRAY:
			unlocked_pets = unlocked_pets_value
		var unlocked_guards_value: Variant = save_data.get("unlocked_guards", unlocked_guards)
		if typeof(unlocked_guards_value) == TYPE_ARRAY:
			unlocked_guards = unlocked_guards_value
		var pet_evolution_stages_value: Variant = save_data.get("pet_evolution_stages", {})
		if typeof(pet_evolution_stages_value) == TYPE_DICTIONARY:
			pet_evolution_stages = pet_evolution_stages_value
		pet_evolution_shards = max(int(save_data.get("pet_evolution_shards", 0)), 0)
		var pet_accessories_value: Variant = save_data.get("pet_accessories", {})
		if typeof(pet_accessories_value) == TYPE_DICTIONARY:
			pet_accessories = pet_accessories_value
		if shards.has(selected_pet_id):
			pet_evolution_shards = int(shards.get(selected_pet_id, pet_evolution_shards))
		var inventory_value: Variant = save_data.get("inventory", {})
		if typeof(inventory_value) == TYPE_DICTIONARY:
			inventory = inventory_value
	if TEST_UNLOCK_ALL_FEATURES:
		_apply_testing_unlocks()
	_validate_selected_loadout()
	_progression_loaded = true
	highest_unlocked_level_changed.emit(highest_unlocked_level)
	permanent_upgrades_changed.emit(permanent_upgrades.duplicate(true))
	currency_changed.emit(soft_currency)
	wallet_changed.emit(gold, gems, shards.duplicate(true))
	energy_changed.emit(energy, get_seconds_to_next_energy())
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
		"gold": gold,
		"gems": gems,
		"shards": shards,
		"energy": energy,
		"last_energy_time": last_energy_time,
		"daily_reward_day": daily_reward_day,
		"last_login_date": last_login_date,
		"claimed_daily_reward_date": claimed_daily_reward_date,
		"login_streak": login_streak,
		"daily_quests": daily_quests,
		"daily_quest_progress": daily_quest_progress,
		"selected_hero_id": selected_hero_id,
		"selected_weapon_id": selected_weapon_id,
		"selected_pet_id": selected_pet_id,
		"selected_guard_id": selected_guard_id,
		"unlocked_heroes": unlocked_heroes,
		"unlocked_weapons": unlocked_weapons,
		"weapon_levels": weapon_levels,
		"unlocked_pets": unlocked_pets,
		"unlocked_guards": unlocked_guards,
		"pet_evolution_stages": pet_evolution_stages,
		"pet_evolution_shards": pet_evolution_shards,
		"pet_accessories": pet_accessories,
		"inventory": inventory,
		"settings": settings,
	}

func _grant_level_clear_rewards() -> void:
	add_run_gold_reward(max(LEVEL_CLEAR_CURRENCY_REWARD + current_level - 1, 1))
	if is_boss_wave:
		add_run_gold_reward(BOSS_CLEAR_CURRENCY_REWARD)

func _is_final_level(level_index: int) -> bool:
	if _levels.is_empty():
		return true
	return level_index >= _levels.size()

func _validate_selected_loadout() -> void:
	_ensure_unlocked_contains(unlocked_heroes, "hero_knight")
	_ensure_unlocked_contains(unlocked_weapons, "weapon_basic")
	_ensure_unlocked_contains(unlocked_pets, "pet_drone")
	_ensure_unlocked_contains(unlocked_guards, "guard_shooter")

	if not _game_data.has_hero(selected_hero_id) or not is_hero_unlocked(selected_hero_id):
		selected_hero_id = "hero_knight"
	if not _game_data.has_weapon(selected_weapon_id) or not is_weapon_unlocked(selected_weapon_id):
		selected_weapon_id = "weapon_basic"
	if not _game_data.has_pet(selected_pet_id) or not is_pet_unlocked(selected_pet_id):
		selected_pet_id = "pet_drone"
	if not _game_data.has_guardian(selected_guard_id) or not is_guardian_unlocked(selected_guard_id):
		selected_guard_id = "guard_shooter"

func _ensure_unlocked_contains(items: Array, item_id: String) -> void:
	if not items.has(item_id):
		items.append(item_id)

func _apply_testing_unlocks() -> void:
	_ensure_levels_loaded()
	if not _levels.is_empty():
		highest_unlocked_level = _levels.size()
	_append_missing_ids(unlocked_heroes, _game_data.get_hero_ids())
	_append_missing_ids(unlocked_weapons, _game_data.get_weapon_ids())
	_append_missing_ids(unlocked_pets, _game_data.get_pet_ids())
	_append_missing_ids(unlocked_guards, _game_data.get_guardian_ids())

func _append_missing_ids(items: Array, ids: Array) -> void:
	for id_value in ids:
		var item_id := str(id_value)
		if not items.has(item_id):
			items.append(item_id)

func _get_upgrade_options() -> Array:
	return _upgrade_manager.roll_upgrades(3)

func _apply_upgrade(player: Player, upgrade_id: StringName) -> void:
	if player == null:
		return

	_upgrade_manager.apply_upgrade(player, String(upgrade_id))

func _apply_weapon_level_to_definition(weapon: Dictionary) -> Dictionary:
	if weapon.is_empty():
		return weapon
	var weapon_id := str(weapon.get("id", ""))
	var level := get_weapon_level(weapon_id)
	var multiplier := 1.0 + float(level - 1) * 0.08
	weapon["level"] = level
	weapon["upgrade_multiplier"] = multiplier
	weapon["damage"] = maxi(roundi(float(weapon.get("damage", weapon.get("base_damage", 1))) * multiplier), 1)
	weapon["upgrade_cost"] = get_weapon_upgrade_cost(weapon_id) if level < 10 else 0
	return weapon

func _add_currency_by_type(currency_type: String, amount: int, apply_run_bonus: bool = false) -> void:
	var gain: int = max(amount, 0)
	if apply_run_bonus and currency_type == "gold":
		gain = maxi(roundi(float(gain) * maxf(run_gold_bonus_multiplier, 0.0)), 0)
	if gain <= 0:
		return
	match currency_type:
		"gold":
			gold += gain
			soft_currency = gold
		"gems":
			gems += gain
		_:
			if currency_type.begins_with("shard:"):
				var pet_id := currency_type.get_slice(":", 1)
				shards[pet_id] = int(shards.get(pet_id, 0)) + gain
				if pet_id == selected_pet_id:
					pet_evolution_shards = int(shards.get(pet_id, 0))

func _regenerate_energy() -> void:
	if energy >= ENERGY_MAX:
		last_energy_time = _now()
		return
	var now := _now()
	if last_energy_time <= 0:
		last_energy_time = now
		return
	var elapsed: int = max(now - last_energy_time, 0)
	var gained := int(elapsed / ENERGY_REGEN_SECONDS)
	if gained <= 0:
		return
	energy = mini(energy + gained, ENERGY_MAX)
	last_energy_time += gained * ENERGY_REGEN_SECONDS
	if energy >= ENERGY_MAX:
		last_energy_time = now

func _now() -> int:
	return int(Time.get_unix_time_from_system())

func request_hire_guard(guard_id: StringName) -> void:
	guard_hire_requested.emit(guard_id)

func hire_guard_after_ad_success(guard_id: StringName) -> void:
	# TODO: Replace this placeholder with rewarded ad completion callback integration.
	request_hire_guard(guard_id)

func _reset_missions() -> void:
	mission_stats = {"kills": 0, "xp": 0, "wave": 0}
	_emit_mission_progress()

func _emit_mission_progress() -> void:
	mission_progress_changed.emit(get_mission_summary())
