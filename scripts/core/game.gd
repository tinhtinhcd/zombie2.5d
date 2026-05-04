extends Node3D

const DEBUG_GAMEPLAY_TRACE := false

@onready var player: Player = $Player
@onready var pet_companion = $PetCompanion
@onready var hud: HUD = $HUD
@onready var pause_menu: PauseMenuUI = $GameOverlayLayer/PauseMenu
@onready var settings_screen: SettingsScreen = $GameOverlayLayer/SettingsScreen
@onready var game_manager: GameManager = get_node("/root/GameManager") as GameManager
@onready var scene_router: SceneRouter = get_node("/root/SceneRouter") as SceneRouter
@onready var guard_container: Node3D = $GuardContainer

const SHOOTER_GUARD_SCENE := preload("res://scenes/entities/shooter_guard.tscn")
const BRUISER_GUARD_SCENE := preload("res://scenes/entities/guardians/bruiser_guard.tscn")
const SKILL_MANAGER_SCRIPT := preload("res://scripts/components/skill_manager.gd")
const MODEL_NORMALIZER := preload("res://scripts/utils/model_normalizer.gd")
const GUARD_SHOOTER_ID := &"guard_shooter"
const GUARD_BRUISER_ID := &"guard_bruiser"
const MAX_GUARDS := 1
var _active_guards: Dictionary = {}
var _skill_manager: Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hud.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	settings_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	# This scene is the single entry point for a fresh gameplay run.
	# reset_game() clears session state; apply_permanent_upgrades() layers
	# in any persistent progression the player has earned across runs.
	game_manager.reset_game()
	_trace_gameplay_scene_state("after_reset_before_loadout")
	game_manager.apply_selected_loadout(player)
	game_manager.apply_permanent_upgrades(player)
	_setup_skill_manager()
	_spawn_selected_pet_companion()
	call_deferred("spawn_guard", StringName(game_manager.selected_guard_id))
	_apply_map_radius_from_player()
	_trace_gameplay_scene_state("after_loadout")
	if pet_companion != null:
		pet_companion.apply_pet_definition(game_manager.get_selected_pet_definition())
		_apply_pet_buffs_to_player()
	pause_menu.visible = false
	hud.pause_requested.connect(_toggle_pause_menu)
	hud.restart_requested.connect(_restart_game)
	hud.main_menu_requested.connect(_go_home)
	hud.upgrade_selected.connect(_on_upgrade_selected)
	pause_menu.resume_requested.connect(_hide_pause_menu)
	pause_menu.settings_requested.connect(_show_settings_menu)
	pause_menu.home_requested.connect(_go_home)
	settings_screen.back_requested.connect(_hide_settings_menu)
	player.hp_changed.connect(hud.set_hp)
	player.died.connect(_on_player_died)
	game_manager.guard_hire_requested.connect(_on_guard_hire_requested)
	hud.set_hp(player.current_hp)

func _setup_skill_manager() -> void:
	if player == null or game_manager == null:
		return
	_skill_manager = player.get_node_or_null("SkillManager")
	if _skill_manager == null:
		_skill_manager = Node.new()
		_skill_manager.set_script(SKILL_MANAGER_SCRIPT)
		_skill_manager.name = "SkillManager"
		player.add_child(_skill_manager)
	player.skill_manager = _skill_manager
	_skill_manager.call("setup", player, game_manager)
	_skill_manager.call("load_skills", game_manager.selected_hero_id)
	if hud != null and hud.has_method("setup_skill_manager"):
		hud.call("setup_skill_manager", _skill_manager)

func _unhandled_input(event: InputEvent) -> void:
	if _is_pause_event(event):
		get_viewport().set_input_as_handled()
		if settings_screen.visible:
			_hide_settings_menu()
			return
		_toggle_pause_menu()

func _is_pause_event(event: InputEvent) -> bool:
	if InputMap.has_action("ui_cancel") and event.is_action_pressed("ui_cancel"):
		return true
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.pressed and not key_event.echo and (key_event.keycode == KEY_ESCAPE or key_event.keycode == KEY_BACK)
	return false

func _apply_map_radius_from_player() -> void:
	var endless_map := get_node_or_null("LevelContainer") as EndlessMap
	if endless_map == null or player == null:
		push_warning("Gameplay start trace: map radius apply skipped; map_node=%s player_node=%s" % [str(endless_map), str(player)])
		return
	endless_map.map_radius = player.play_area_radius
	if DEBUG_GAMEPLAY_TRACE:
		print("Gameplay start trace: map radius applied=%s level_container_path=%s" % [str(endless_map.map_radius), str(endless_map.get_path())])

func _trace_gameplay_scene_state(stage: String) -> void:
	var level_container := get_node_or_null("LevelContainer")
	var level_path := "res://scenes/levels/level_container.tscn"
	var selected_level_id := String(game_manager.current_level_id) if game_manager != null else ""
	var hero_id := game_manager.selected_hero_id if game_manager != null else ""
	var weapon_id := game_manager.selected_weapon_id if game_manager != null else ""
	if DEBUG_GAMEPLAY_TRACE:
		print("Gameplay start trace: stage=%s selected_level_id=%s resolved_map_scene_path=%s map_load_result=%s selected_hero_id=%s player_spawn_result=%s selected_weapon_id=%s" % [
			stage,
			selected_level_id,
			level_path,
			str(level_container != null),
			hero_id,
			str(player != null),
			weapon_id,
		])
	if level_container == null:
		push_warning("Gameplay start trace: LevelContainer is missing from game scene; map cannot load.")
	if player == null:
		push_warning("Gameplay start trace: Player is missing from game scene; hero cannot spawn.")

func _spawn_selected_pet_companion() -> void:
	if game_manager == null:
		return
	var pet_id := game_manager.selected_pet_id
	var model_path := game_manager.resolve_pet_model_path(pet_id)
	var pet_scene := load(model_path) as PackedScene
	if pet_scene == null:
		push_warning("Gameplay pet %s could not resolve model scene %s; keeping existing pet." % [pet_id, model_path])
		return

	var previous_pet := pet_companion as Node3D
	var spawn_position := Vector3(-1.2, 0.7, 0.8)
	if previous_pet != null:
		spawn_position = previous_pet.position
		remove_child(previous_pet)
		previous_pet.free()

	var new_pet := pet_scene.instantiate() as Node3D
	if new_pet == null:
		push_warning("Gameplay pet %s model %s did not instantiate as Node3D." % [pet_id, model_path])
		return
	new_pet.name = "PetCompanion"
	new_pet.position = spawn_position
	new_pet.set_meta("pet_id", pet_id)
	new_pet.set_meta("model_path", model_path)
	new_pet.set_meta("source_scene_path", model_path)
	MODEL_NORMALIZER.normalize(new_pet, "pet", pet_id, model_path)
	add_child(new_pet)
	move_child(new_pet, min(2, get_child_count() - 1))
	pet_companion = new_pet

func _apply_pet_buffs_to_player() -> void:
	if player == null or pet_companion == null or not pet_companion.has_method("get_active_buffs"):
		return
	var buffs: Dictionary = pet_companion.call("get_active_buffs")
	for buff_type in buffs.keys():
		var value := float(buffs.get(buff_type, 0.0))
		match str(buff_type):
			"damage_multiplier":
				player.support_damage_multiplier = maxf(player.support_damage_multiplier, 1.0 + value)
			"move_speed_multiplier":
				player.move_speed *= 1.0 + value
			"max_hp_multiplier":
				player.increase_max_hp(maxi(roundi(float(player.max_hp) * value), 1))
			"cooldown_reduction":
				player.skill_primary_cooldown = maxf(player.skill_primary_cooldown * (1.0 - clampf(value, 0.0, 0.8)), 1.0)
			"xp_gain_multiplier":
				player.set_meta("xp_gain_multiplier", 1.0 + value)
				game_manager.set_run_reward_multiplier("xp_gain_multiplier", 1.0 + value)

func _toggle_pause_menu() -> void:
	if game_manager.is_game_over:
		return
	if game_manager.is_upgrade_selection_active:
		return

	pause_menu.visible = not pause_menu.visible
	if pause_menu.visible:
		game_manager.pause_game()
	else:
		game_manager.resume_game()

func _hide_pause_menu() -> void:
	pause_menu.visible = false
	game_manager.resume_game()

func _show_settings_menu() -> void:
	pause_menu.visible = false
	settings_screen.visible = true

func _hide_settings_menu() -> void:
	settings_screen.visible = false
	if not game_manager.is_game_over:
		pause_menu.visible = true

func _on_player_died() -> void:
	pause_menu.visible = false
	settings_screen.visible = false
	game_manager.trigger_game_over()

func _restart_game() -> void:
	game_manager.resume_game()
	game_manager.restart_game()

func _on_upgrade_selected(upgrade_id: StringName) -> void:
	game_manager.select_upgrade(player, upgrade_id)

func _on_guard_hire_requested(guard_id: StringName) -> void:
	spawn_guard(guard_id)

func spawn_guard(guard_id: StringName) -> bool:
	if guard_container == null:
		push_warning("Guard spawn failed: GuardContainer is missing.")
		return false
	if _active_guards.size() >= MAX_GUARDS and not _active_guards.has(String(guard_id)):
		return false
	if _active_guards.has(String(guard_id)):
		var existing_guard := _active_guards[String(guard_id)] as Node3D
		if existing_guard != null and is_instance_valid(existing_guard):
			_refresh_guard_hud(String(guard_id))
			return true
		_active_guards.erase(String(guard_id))

	var guard_definition := game_manager.get_guardian(String(guard_id))
	var guard_scene: PackedScene
	match guard_id:
		GUARD_SHOOTER_ID:
			guard_scene = SHOOTER_GUARD_SCENE
		GUARD_BRUISER_ID:
			guard_scene = BRUISER_GUARD_SCENE
		_:
			var guard_scene_path := str(guard_definition.get("model_scene_path", "")).strip_edges()
			if guard_scene_path.is_empty():
				guard_scene_path = "res://scenes/entities/shooter_guard.tscn"
			guard_scene = load(guard_scene_path) as PackedScene
			if guard_scene == null:
				push_warning("Unknown guard id requested and model_scene_path failed to load: %s (%s)" % [String(guard_id), guard_scene_path])
				return false

	var guard := guard_scene.instantiate() as Node3D
	if guard == null:
		push_warning("Guard scene failed to instantiate for id: %s" % String(guard_id))
		return false
	guard.name = "%sRuntime" % String(guard_id).replace("_", "")
	if _has_node_property(guard, "guardian_id"):
		guard.set("guardian_id", String(guard_id))
	var guard_model_path := str(guard_definition.get("model_scene_path", ""))
	MODEL_NORMALIZER.normalize(guard, "guard", String(guard_id), guard_model_path)
	guard_container.add_child(guard)
	guard.global_position = player.global_position + Vector3(1.4, 0.6, 0.9)
	_active_guards[String(guard_id)] = guard
	_refresh_guard_hud(String(guard_id))
	return true

func _refresh_guard_hud(guard_id: String) -> void:
	if hud == null or not hud.has_method("set_active_guard"):
		return
	var guard_definition := game_manager.get_guardian(guard_id)
	hud.call("set_active_guard", guard_id, game_manager.get_display_name(guard_definition, "Guard"))

func _has_node_property(node: Object, property_name: String) -> bool:
	if node == null:
		return false
	for property in node.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false

func _go_home() -> void:
	game_manager.resume_game()
	scene_router.go_to_home()
