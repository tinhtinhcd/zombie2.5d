extends Node3D

@onready var player: Player = $Player
@onready var pet_companion = $PetCompanion
@onready var hud: HUD = $HUD
@onready var pause_menu: PauseMenuUI = $GameOverlayLayer/PauseMenu
@onready var settings_screen: SettingsScreen = $GameOverlayLayer/SettingsScreen
@onready var game_manager: GameManager = get_node("/root/GameManager") as GameManager
@onready var scene_router: SceneRouter = get_node("/root/SceneRouter") as SceneRouter

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
    _spawn_selected_pet_companion()
    _apply_map_radius_from_player()
    _trace_gameplay_scene_state("after_loadout")
    if pet_companion != null:
        pet_companion.apply_pet_definition(game_manager.get_selected_pet_definition())
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
    hud.set_hp(player.current_hp)

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
    print("Gameplay start trace: map radius applied=%s level_container_path=%s" % [str(endless_map.map_radius), str(endless_map.get_path())])

func _trace_gameplay_scene_state(stage: String) -> void:
    var level_container := get_node_or_null("LevelContainer")
    var level_path := "res://scenes/levels/level_container.tscn"
    var selected_level_id := String(game_manager.current_level_id) if game_manager != null else ""
    var hero_id := game_manager.selected_hero_id if game_manager != null else ""
    var weapon_id := game_manager.selected_weapon_id if game_manager != null else ""
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
    add_child(new_pet)
    move_child(new_pet, min(2, get_child_count() - 1))
    pet_companion = new_pet

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

func _go_home() -> void:
    game_manager.resume_game()
    scene_router.go_to_home()
