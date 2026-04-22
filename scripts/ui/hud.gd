extends CanvasLayer
class_name HUD

signal pause_requested
signal restart_requested
signal main_menu_requested
signal upgrade_selected(upgrade_id: StringName)

const XP_BAR_TARGET = 10
const MOBILE_WIDTH_THRESHOLD = 700.0
const COMPACT_HEIGHT_THRESHOLD = 620.0
const MOBILE_MARGIN = 12.0

@onready var hud_root: Control = $HUDRoot
@onready var safe_margin: MarginContainer = $HUDRoot/SafeMargin
@onready var pause_button: Button = $HUDRoot/SafeMargin/Root/TopBar/PauseButton
@onready var debug_upgrade_button: Button = $HUDRoot/SafeMargin/Root/TopBar/DebugUpgradeButton
@onready var debug_game_over_button: Button = $HUDRoot/SafeMargin/Root/TopBar/DebugGameOverButton
@onready var kills_label: Label = $HUDRoot/SafeMargin/Root/TopBar/KillsLabel
@onready var timer_label: Label = $HUDRoot/SafeMargin/Root/TopBar/TimerLabel
@onready var level_label: Label = $HUDRoot/SafeMargin/Root/StatusPanel/Margin/Content/StatsGrid/LevelLabel
@onready var wave_label: Label = $HUDRoot/SafeMargin/Root/StatusPanel/Margin/Content/StatsGrid/WaveLabel
@onready var mission_label: Label = $HUDRoot/OverlayRoot/MissionPanel/Margin/MissionLabel
@onready var boss_panel: PanelContainer = $HUDRoot/SafeMargin/Root/BossPanel
@onready var boss_bar: ProgressBar = $HUDRoot/SafeMargin/Root/BossPanel/Margin/BossContent/BossBar
@onready var boss_label: Label = $HUDRoot/SafeMargin/Root/BossPanel/Margin/BossContent/BossLabel
@onready var hp_bar: ProgressBar = $HUDRoot/SafeMargin/Root/StatusPanel/Margin/Content/Bars/HPRow/HPBar
@onready var hp_label: Label = $HUDRoot/SafeMargin/Root/StatusPanel/Margin/Content/Bars/HPRow/HPLabel
@onready var xp_bar: ProgressBar = $HUDRoot/SafeMargin/Root/StatusPanel/Margin/Content/Bars/XPRow/XPBar
@onready var xp_label: Label = $HUDRoot/SafeMargin/Root/StatusPanel/Margin/Content/Bars/XPRow/XPLabel
@onready var mission_panel: PanelContainer = $HUDRoot/OverlayRoot/MissionPanel

@onready var upgrade_panel: PanelContainer = $HUDRoot/OverlayRoot/ModalCenter/UpgradePanel
@onready var upgrade_button_1: Button = $HUDRoot/OverlayRoot/ModalCenter/UpgradePanel/MarginContainer/VBoxContainer/UpgradeButtons/UpgradeButton1
@onready var upgrade_button_2: Button = $HUDRoot/OverlayRoot/ModalCenter/UpgradePanel/MarginContainer/VBoxContainer/UpgradeButtons/UpgradeButton2
@onready var upgrade_button_3: Button = $HUDRoot/OverlayRoot/ModalCenter/UpgradePanel/MarginContainer/VBoxContainer/UpgradeButtons/UpgradeButton3

@onready var game_over_panel: PanelContainer = $HUDRoot/OverlayRoot/ModalCenter/GameOverPanel
@onready var game_over_stats_label: Label = $HUDRoot/OverlayRoot/ModalCenter/GameOverPanel/MarginContainer/VBoxContainer/StatsLabel
@onready var restart_button: Button = $HUDRoot/OverlayRoot/ModalCenter/GameOverPanel/MarginContainer/VBoxContainer/Actions/RestartButton
@onready var results_button: Button = $HUDRoot/OverlayRoot/ModalCenter/GameOverPanel/MarginContainer/VBoxContainer/Actions/ResultsButton
@onready var game_over_home_button: Button = $HUDRoot/OverlayRoot/ModalCenter/GameOverPanel/MarginContainer/VBoxContainer/Actions/HomeButton

@onready var result_panel: PanelContainer = $HUDRoot/OverlayRoot/ModalCenter/ResultPanel
@onready var result_summary_label: Label = $HUDRoot/OverlayRoot/ModalCenter/ResultPanel/MarginContainer/VBoxContainer/SummaryLabel
@onready var result_continue_button: Button = $HUDRoot/OverlayRoot/ModalCenter/ResultPanel/MarginContainer/VBoxContainer/ContinueButton

var _upgrade_option_ids: Array = []
var _elapsed_time: float = 0.0
var game_manager: GameManager
var _original_minimum_sizes: Dictionary = {}

func _ready() -> void:
	game_manager = get_node("/root/GameManager") as GameManager
	pause_button.pressed.connect(_on_pause_pressed)
	debug_upgrade_button.pressed.connect(_on_debug_upgrade_pressed)
	debug_game_over_button.pressed.connect(_on_debug_game_over_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	results_button.pressed.connect(_show_result_screen)
	game_over_home_button.pressed.connect(_on_main_menu_pressed)
	result_continue_button.pressed.connect(_on_main_menu_pressed)
	upgrade_button_1.pressed.connect(_on_upgrade_button_1_pressed)
	upgrade_button_2.pressed.connect(_on_upgrade_button_2_pressed)
	upgrade_button_3.pressed.connect(_on_upgrade_button_3_pressed)
	get_viewport().size_changed.connect(_apply_responsive_layout)
	game_over_panel.visible = false
	result_panel.visible = false
	upgrade_panel.visible = false
	boss_panel.visible = false
	_apply_responsive_layout()

	if game_manager != null:
		game_manager.score_changed.connect(_on_score_changed)
		game_manager.xp_changed.connect(_on_xp_changed)
		game_manager.level_changed.connect(_on_level_changed)
		game_manager.wave_changed.connect(_on_wave_changed)
		game_manager.boss_wave_changed.connect(_on_boss_wave_changed)
		game_manager.game_over_changed.connect(_on_game_over_changed)
		game_manager.upgrade_options_requested.connect(_show_upgrade_options)
		game_manager.upgrade_selection_closed.connect(_hide_upgrade_panel)
		game_manager.player_level_changed.connect(_on_player_level_changed)
		game_manager.mission_progress_changed.connect(_on_mission_progress_changed)
		game_manager.boss_health_changed.connect(_on_boss_health_changed)
		_on_score_changed(game_manager.score)
		_on_xp_changed(game_manager.xp)
		_on_player_level_changed(game_manager.run_level, game_manager.current_level_xp, game_manager.xp_to_next_level)
		_on_level_changed(game_manager.current_level, game_manager.current_level_id, game_manager.current_level_display_name)
		_on_wave_changed(game_manager.current_wave)
		_on_boss_wave_changed(game_manager.is_boss_wave)
		_on_mission_progress_changed(game_manager.get_mission_summary())

func _process(delta: float) -> void:
	if game_manager != null and game_manager.is_gameplay_active:
		_elapsed_time += delta
	_update_timer_label()

func set_hp(value: int) -> void:
	hp_bar.max_value = max(hp_bar.max_value, value)
	hp_bar.value = value
	hp_label.text = "HP %d / %d" % [value, int(hp_bar.max_value)]

func _on_score_changed(value: int) -> void:
	kills_label.text = "Kills: %d" % value

func _on_xp_changed(value: int) -> void:
	if game_manager != null:
		_on_player_level_changed(game_manager.run_level, game_manager.current_level_xp, game_manager.xp_to_next_level)
	else:
		xp_bar.value = value

func _on_player_level_changed(level: int, current_xp: int, required_xp: int) -> void:
	xp_bar.max_value = max(required_xp, 1)
	xp_bar.value = clampi(current_xp, 0, required_xp)
	xp_label.text = "XP %d / %d" % [current_xp, required_xp]
	level_label.text = "Level: %d" % level

func _on_level_changed(level_index: int, _level_id: StringName, display_name: String) -> void:
	var resolved_name := display_name if not display_name.is_empty() else "Zone %d" % level_index
	wave_label.tooltip_text = resolved_name

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
	result_panel.visible = false
	pause_button.disabled = is_game_over_now
	if is_game_over_now:
		game_over_stats_label.text = _format_run_stats()

func _on_mission_progress_changed(summary: String) -> void:
	mission_label.text = summary

func _on_boss_health_changed(current_hp: int, max_hp: int, is_visible: bool) -> void:
	boss_panel.visible = is_visible
	boss_bar.max_value = max(max_hp, 1)
	boss_bar.value = clampi(current_hp, 0, max_hp)
	boss_label.text = "Boss HP %d / %d" % [current_hp, max_hp]

func _on_pause_pressed() -> void:
	pause_requested.emit()

func _on_restart_pressed() -> void:
	restart_requested.emit()

func _on_main_menu_pressed() -> void:
	main_menu_requested.emit()

func _on_debug_upgrade_pressed() -> void:
	if game_manager != null:
		game_manager.begin_upgrade_selection()

func _on_debug_game_over_pressed() -> void:
	if game_manager != null:
		game_manager.trigger_game_over()

func _on_upgrade_button_1_pressed() -> void:
	_emit_upgrade_selected(0)

func _on_upgrade_button_2_pressed() -> void:
	_emit_upgrade_selected(1)

func _on_upgrade_button_3_pressed() -> void:
	_emit_upgrade_selected(2)

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

func _show_result_screen() -> void:
	game_over_panel.visible = false
	result_panel.visible = true
	result_summary_label.text = _format_result_summary()

func _format_run_stats() -> String:
	var kills := 0
	var xp := 0
	if game_manager != null:
		kills = game_manager.score
		xp = game_manager.xp
	return "Enemies killed: %d\nTime survived: %s\nXP gained: %d" % [kills, _format_time(_elapsed_time), xp]

func _format_result_summary() -> String:
	var kills := 0
	var xp := 0
	if game_manager != null:
		kills = game_manager.score
		xp = game_manager.xp
	return "Run Summary\nScore: %d\nSurvival time: %s\nXP gained: %d" % [kills, _format_time(_elapsed_time), xp]

func _update_timer_label() -> void:
	timer_label.text = "Time: %s" % _format_time(_elapsed_time)

func _format_time(total_seconds: float) -> String:
	var seconds := int(total_seconds)
	var minutes := int(seconds / 60)
	var remaining_seconds := seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]

func _apply_responsive_layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var is_narrow := viewport_size.x <= MOBILE_WIDTH_THRESHOLD
	var is_compact := is_narrow or viewport_size.y <= COMPACT_HEIGHT_THRESHOLD
	var margin := MOBILE_MARGIN if is_compact else 18.0

	_set_margin(safe_margin, int(margin), 10, int(margin), 10)
	_fit_bottom_left_panel(mission_panel, 328.0, 80.0, margin)
	_fit_center_panel(upgrade_panel, 540.0, 340.0, margin)
	_fit_center_panel(game_over_panel, 520.0, 360.0, margin)
	_fit_center_panel(result_panel, 520.0, 320.0, margin)
	_update_touch_targets(hud_root, is_compact)

func _fit_center_panel(panel: Control, desktop_width: float, desktop_height: float, margin: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var panel_width: float = min(desktop_width, max(viewport_size.x - margin * 2.0, 240.0))
	var panel_height: float = min(desktop_height, max(viewport_size.y - margin * 2.0, 260.0))
	panel.custom_minimum_size = Vector2(panel_width, panel_height)

func _fit_bottom_left_panel(panel: Control, desktop_width: float, desktop_height: float, margin: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	panel.offset_left = margin
	panel.offset_right = min(desktop_width + margin, viewport_size.x - margin)
	panel.offset_top = -desktop_height - margin
	panel.offset_bottom = -margin

func _set_margin(margin_container: MarginContainer, left: int, top: int, right: int, bottom: int) -> void:
	margin_container.add_theme_constant_override("margin_left", left)
	margin_container.add_theme_constant_override("margin_top", top)
	margin_container.add_theme_constant_override("margin_right", right)
	margin_container.add_theme_constant_override("margin_bottom", bottom)

func _get_original_minimum_size(control: Control) -> Vector2:
	var id := control.get_instance_id()
	if not _original_minimum_sizes.has(id):
		_original_minimum_sizes[id] = control.custom_minimum_size
	return _original_minimum_sizes[id]

func _update_touch_targets(root: Node, is_compact: bool) -> void:
	for child in root.get_children():
		if child is Button:
			var button := child as Button
			var original_size := _get_original_minimum_size(button)
			var compact_height: float = min(max(original_size.y, 42.0), 48.0)
			button.custom_minimum_size = Vector2(0.0 if is_compact else original_size.x, compact_height if is_compact else original_size.y)
		_update_touch_targets(child, is_compact)
