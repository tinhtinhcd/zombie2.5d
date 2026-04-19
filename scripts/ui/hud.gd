extends CanvasLayer
class_name HUD

signal pause_requested
signal restart_requested
signal upgrade_selected(upgrade_id: StringName)

# Placeholder HUD for future score, health, and wave updates.

@onready var pause_button: Button = $HUDRoot/PauseButton
@onready var score_label: Label = $HUDRoot/ScoreLabel
@onready var xp_label: Label = $HUDRoot/XPLabel
@onready var level_label: Label = $HUDRoot/LevelLabel
@onready var hp_label: Label = $HUDRoot/HPLabel
@onready var wave_label: Label = $HUDRoot/WaveLabel
@onready var game_over_panel: Panel = $HUDRoot/GameOverPanel
@onready var restart_button: Button = $HUDRoot/GameOverPanel/RestartButton
@onready var upgrade_panel: Panel = $HUDRoot/UpgradePanel
@onready var upgrade_button_1: Button = $HUDRoot/UpgradePanel/UpgradeButton1
@onready var upgrade_button_2: Button = $HUDRoot/UpgradePanel/UpgradeButton2
@onready var upgrade_button_3: Button = $HUDRoot/UpgradePanel/UpgradeButton3

var _upgrade_option_ids: Array[StringName] = []
var game_manager: GameManager

func _ready() -> void:
    game_manager = get_node("/root/GameManager") as GameManager
    pause_button.pressed.connect(_on_pause_pressed)
    restart_button.pressed.connect(_on_restart_pressed)
    upgrade_button_1.pressed.connect(func() -> void: _emit_upgrade_selected(0))
    upgrade_button_2.pressed.connect(func() -> void: _emit_upgrade_selected(1))
    upgrade_button_3.pressed.connect(func() -> void: _emit_upgrade_selected(2))
    game_over_panel.visible = false
    upgrade_panel.visible = false

    if game_manager != null:
        game_manager.score_changed.connect(_on_score_changed)
        game_manager.xp_changed.connect(_on_xp_changed)
        game_manager.level_changed.connect(_on_level_changed)
        game_manager.wave_changed.connect(_on_wave_changed)
        game_manager.boss_wave_changed.connect(_on_boss_wave_changed)
        game_manager.game_over_changed.connect(_on_game_over_changed)
        game_manager.upgrade_options_requested.connect(_show_upgrade_options)
        game_manager.upgrade_selection_closed.connect(_hide_upgrade_panel)
        _on_score_changed(game_manager.score)
        _on_xp_changed(game_manager.xp)
        _on_level_changed(game_manager.current_level, game_manager.current_level_id, game_manager.current_level_display_name)
        _on_wave_changed(game_manager.current_wave)
        _on_boss_wave_changed(game_manager.is_boss_wave)

func _on_pause_pressed() -> void:
    pause_requested.emit()

func _on_restart_pressed() -> void:
    restart_requested.emit()

func set_hp(value: int) -> void:
    hp_label.text = "HP: %d" % value

func _on_score_changed(value: int) -> void:
    score_label.text = "Score: %d" % value

func _on_xp_changed(value: int) -> void:
    xp_label.text = "XP: %d" % value

func _on_level_changed(level_index: int, _level_id: StringName, display_name: String) -> void:
    var resolved_name := display_name if not display_name.is_empty() else "Level %d" % level_index
    level_label.text = resolved_name

func _on_wave_changed(value: int) -> void:
    var boss_suffix := ""

    if game_manager != null and game_manager.is_boss_wave:
        boss_suffix = " Boss"
    wave_label.text = "Wave: %d%s" % [value, boss_suffix]

func _on_boss_wave_changed(is_boss_wave_now: bool) -> void:
    var boss_suffix := ""
    if is_boss_wave_now:
        boss_suffix = " Boss"

    var wave_value := 0
    if game_manager != null:
        wave_value = game_manager.current_wave
    wave_label.text = "Wave: %d%s" % [wave_value, boss_suffix]

func _on_game_over_changed(is_game_over_now: bool) -> void:
    game_over_panel.visible = is_game_over_now
    pause_button.disabled = is_game_over_now

func _show_upgrade_options(options: Array) -> void:
    if options.size() < 3:
        return

    _upgrade_option_ids = []
    for option in options:
        _upgrade_option_ids.append(option.get("id", &""))

    upgrade_button_1.text = _format_upgrade_text(options[0])
    upgrade_button_2.text = _format_upgrade_text(options[1])
    upgrade_button_3.text = _format_upgrade_text(options[2])
    upgrade_panel.visible = true
    pause_button.disabled = true

func _hide_upgrade_panel() -> void:
    upgrade_panel.visible = false
    _upgrade_option_ids.clear()


    if game_manager != null:
        pause_button.disabled = game_manager.is_game_over

func _emit_upgrade_selected(index: int) -> void:
    if index < 0 or index >= _upgrade_option_ids.size():
        return
    upgrade_selected.emit(_upgrade_option_ids[index])

func _format_upgrade_text(option: Dictionary) -> String:
    return "%s\n%s" % [option.get("title", ""), option.get("description", "")]
