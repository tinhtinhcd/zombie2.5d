extends Node3D

@onready var player: Player = $Player
@onready var pet_companion = $PetCompanion
@onready var hud: HUD = $HUD
@onready var pause_menu: PauseMenuUI = $PauseMenu
@onready var settings_screen: SettingsScreen = $SettingsScreen
@onready var game_manager: GameManager = get_node("/root/GameManager") as GameManager
@onready var scene_router: SceneRouter = get_node("/root/SceneRouter") as SceneRouter

func _ready() -> void:
    # This scene is the single entry point for a fresh gameplay run.
    # reset_game() clears session state; apply_permanent_upgrades() layers
    # in any persistent progression the player has earned across runs.
    game_manager.reset_game()
    game_manager.apply_selected_loadout(player)
    game_manager.apply_permanent_upgrades(player)
    _apply_map_radius_from_player()
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

func _apply_map_radius_from_player() -> void:
    var endless_map := $LevelContainer as EndlessMap
    if endless_map == null or player == null:
        return
    endless_map.map_radius = player.play_area_radius

func _toggle_pause_menu() -> void:
    if game_manager.is_game_over:
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
    game_manager.restart_game()

func _on_upgrade_selected(upgrade_id: StringName) -> void:
    game_manager.select_upgrade(player, upgrade_id)

func _go_home() -> void:
    scene_router.go_to_home()
