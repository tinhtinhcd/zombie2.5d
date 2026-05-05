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
const SKILL_HUD_SCENE := preload("res://scenes/ui/skill_hud.tscn")
const SCI_FI_THEME := preload("res://scripts/ui/sci_fi_theme.gd")

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
@onready var root_layout: VBoxContainer = $HUDRoot/SafeMargin/Root

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
var skill_hud: HBoxContainer
var guard_panel: PanelContainer
var guard_label: Label
var guard_hp_bar: ProgressBar
var guard_cooldown_label: Label
var mobile_layer: Control
var mobile_hp_bar: ProgressBar
var mobile_hp_label: Label
var mobile_wave_label: Label
var mobile_enemy_label: Label
var mobile_coins_label: Label
var mobile_pause_button: Button
var mobile_guard_panel: PanelContainer
var mobile_guard_name_label: Label
var mobile_guard_hp_bar: ProgressBar
var mobile_guard_cooldown_label: Label
var mobile_fire_button: Button
var mobile_telegraph_panel: PanelContainer
var mobile_telegraph_label: Label
var _active_guard_id: String = ""
var _telegraph_timer: float = 0.0
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
	_setup_skill_hud()
	_setup_guard_indicator()
	_setup_mobile_hud()
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
		game_manager.wallet_changed.connect(_on_wallet_changed)
		if game_manager.has_signal("boss_telegraph_started"):
			game_manager.connect("boss_telegraph_started", _on_boss_telegraph_started)
		_on_score_changed(game_manager.score)
		_on_xp_changed(game_manager.xp)
		_on_player_level_changed(game_manager.run_level, game_manager.current_level_xp, game_manager.xp_to_next_level)
		_on_level_changed(game_manager.current_level, game_manager.current_level_id, game_manager.current_level_display_name)
		_on_wave_changed(game_manager.current_wave)
		_on_boss_wave_changed(game_manager.is_boss_wave)
		_on_mission_progress_changed(game_manager.get_mission_summary())
		_on_wallet_changed(game_manager.gold, game_manager.gems, game_manager.shards)

func set_active_guard(guard_id: String, display_name: String = "") -> void:
	_active_guard_id = guard_id
	if guard_label == null:
		_setup_guard_indicator()
	if guard_label == null:
		return
	var resolved_name := display_name
	if resolved_name.is_empty() and game_manager != null:
		resolved_name = game_manager.get_display_name(game_manager.get_guardian(guard_id), "Guard")
	if resolved_name.is_empty():
		resolved_name = "Guard"
	guard_label.text = "Guard: %s" % resolved_name
	guard_label.tooltip_text = guard_id
	if guard_panel != null:
		guard_panel.visible = not guard_id.is_empty()
	if mobile_guard_panel != null:
		mobile_guard_panel.visible = not guard_id.is_empty()
	if mobile_guard_name_label != null:
		mobile_guard_name_label.text = "%s  %s" % [_guard_abbreviation(resolved_name), resolved_name]
		mobile_guard_name_label.tooltip_text = guard_id
	if mobile_guard_cooldown_label != null:
		mobile_guard_cooldown_label.text = "READY" if not guard_id.is_empty() else "DOWN"

func set_guard_hp(current_hp: int, max_hp: int) -> void:
	if guard_label == null:
		_setup_guard_indicator()
	if guard_label == null:
		return
	var base_text := guard_label.text
	var hp_index := base_text.find(" HP ")
	if hp_index >= 0:
		base_text = base_text.substr(0, hp_index)
	guard_label.text = "%s HP %d/%d" % [base_text, current_hp, max(max_hp, 1)]
	if guard_hp_bar != null:
		guard_hp_bar.max_value = max(max_hp, 1)
		guard_hp_bar.value = clampi(current_hp, 0, max(max_hp, 1))
	if mobile_guard_hp_bar != null:
		mobile_guard_hp_bar.max_value = max(max_hp, 1)
		mobile_guard_hp_bar.value = clampi(current_hp, 0, max(max_hp, 1))
	if mobile_guard_cooldown_label != null and current_hp <= 0:
		mobile_guard_cooldown_label.text = "DOWN"

func _process(delta: float) -> void:
	if game_manager != null and game_manager.is_gameplay_active:
		_elapsed_time += delta
	if _telegraph_timer > 0.0:
		_telegraph_timer = maxf(_telegraph_timer - delta, 0.0)
		if _telegraph_timer <= 0.0 and mobile_telegraph_panel != null:
			mobile_telegraph_panel.visible = false
	_update_timer_label()
	_update_mobile_enemy_count()
	_update_guard_cooldown_indicator()

func set_hp(value: int) -> void:
	hp_bar.max_value = max(hp_bar.max_value, value)
	hp_bar.value = value
	hp_label.text = "HP %d / %d" % [value, int(hp_bar.max_value)]
	if mobile_hp_bar != null:
		mobile_hp_bar.max_value = hp_bar.max_value
		mobile_hp_bar.value = value
	if mobile_hp_label != null:
		mobile_hp_label.text = "HP %d/%d" % [value, int(hp_bar.max_value)]

func setup_skill_manager(manager: Node) -> void:
	if skill_hud == null:
		_setup_skill_hud()
	if skill_hud != null:
		skill_hud.call("setup", manager)

func _setup_skill_hud() -> void:
	if skill_hud != null:
		return
	skill_hud = root_layout.get_node_or_null("SkillHud") as HBoxContainer
	if skill_hud == null:
		skill_hud = SKILL_HUD_SCENE.instantiate() as HBoxContainer
		if skill_hud == null:
			return
		root_layout.add_child(skill_hud)
		var status_panel_index := root_layout.get_children().find(boss_panel)
		if status_panel_index >= 0:
			root_layout.move_child(skill_hud, status_panel_index + 1)

func _setup_guard_indicator() -> void:
	if guard_panel != null:
		return
	guard_panel = root_layout.get_node_or_null("GuardPanel") as PanelContainer
	if guard_panel == null:
		guard_panel = PanelContainer.new()
		guard_panel.name = "GuardPanel"
		guard_panel.custom_minimum_size = Vector2(0.0, 28.0)
		root_layout.add_child(guard_panel)
		var skill_index := root_layout.get_children().find(skill_hud)
		if skill_index >= 0:
			root_layout.move_child(guard_panel, skill_index + 1)
	guard_label = guard_panel.get_node_or_null("Margin/GuardLabel") as Label
	if guard_label == null:
		var margin := MarginContainer.new()
		margin.name = "Margin"
		margin.add_theme_constant_override("margin_left", 8)
		margin.add_theme_constant_override("margin_top", 4)
		margin.add_theme_constant_override("margin_right", 8)
		margin.add_theme_constant_override("margin_bottom", 4)
		guard_panel.add_child(margin)
		guard_label = Label.new()
		guard_label.name = "GuardLabel"
		guard_label.text = "Guard: None"
		guard_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		margin.add_child(guard_label)
		guard_hp_bar = ProgressBar.new()
		guard_hp_bar.name = "GuardHPBar"
		guard_hp_bar.custom_minimum_size = Vector2(0.0, 10.0)
		guard_hp_bar.show_percentage = false
		guard_hp_bar.max_value = 1.0
		guard_hp_bar.value = 1.0
		SCI_FI_THEME.apply_progress(guard_hp_bar, SCI_FI_THEME.SUCCESS)
		margin.add_child(guard_hp_bar)

func _setup_mobile_hud() -> void:
	if mobile_layer != null:
		return
	root_layout.visible = false
	mission_panel.visible = false

	mobile_layer = Control.new()
	mobile_layer.name = "MobileSciFiHUD"
	mobile_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	mobile_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(mobile_layer)
	hud_root.move_child(mobile_layer, hud_root.get_children().find($HUDRoot/OverlayRoot))

	var top_margin := MarginContainer.new()
	top_margin.name = "TopSafe"
	top_margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_margin.offset_left = 12.0
	top_margin.offset_top = 10.0
	top_margin.offset_right = -12.0
	top_margin.offset_bottom = 104.0
	mobile_layer.add_child(top_margin)

	var top_row := HBoxContainer.new()
	top_row.name = "TopRow"
	top_row.add_theme_constant_override("separation", 10)
	top_margin.add_child(top_row)

	var hp_panel := _make_mobile_panel("HeroStatus", Vector2(170, 86))
	top_row.add_child(hp_panel)
	var hp_box := _panel_vbox(hp_panel)
	var hero_label := Label.new()
	hero_label.text = "HERO"
	SCI_FI_THEME.apply_label(hero_label, true, 13)
	hp_box.add_child(hero_label)
	mobile_hp_bar = ProgressBar.new()
	mobile_hp_bar.show_percentage = false
	mobile_hp_bar.max_value = 10.0
	mobile_hp_bar.value = 10.0
	SCI_FI_THEME.apply_progress(mobile_hp_bar, SCI_FI_THEME.DANGER)
	hp_box.add_child(mobile_hp_bar)
	mobile_hp_label = Label.new()
	mobile_hp_label.text = "HP 10/10"
	SCI_FI_THEME.apply_label(mobile_hp_label, false, 14)
	hp_box.add_child(mobile_hp_label)

	var wave_panel := _make_mobile_panel("WaveStatus", Vector2(0, 86))
	wave_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(wave_panel)
	var wave_box := _panel_vbox(wave_panel)
	mobile_wave_label = Label.new()
	mobile_wave_label.text = "WAVE 0"
	mobile_wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	SCI_FI_THEME.apply_label(mobile_wave_label, false, 20)
	wave_box.add_child(mobile_wave_label)
	mobile_enemy_label = Label.new()
	mobile_enemy_label.text = "HOSTILES 0"
	mobile_enemy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	SCI_FI_THEME.apply_label(mobile_enemy_label, true, 14)
	wave_box.add_child(mobile_enemy_label)

	var wallet_panel := _make_mobile_panel("WalletStatus", Vector2(150, 86))
	top_row.add_child(wallet_panel)
	var wallet_box := _panel_vbox(wallet_panel)
	mobile_coins_label = Label.new()
	mobile_coins_label.text = "G 0"
	SCI_FI_THEME.apply_label(mobile_coins_label, false, 15)
	wallet_box.add_child(mobile_coins_label)
	mobile_pause_button = Button.new()
	mobile_pause_button.text = "II"
	mobile_pause_button.custom_minimum_size = Vector2(64, 36)
	SCI_FI_THEME.apply_button(mobile_pause_button)
	mobile_pause_button.pressed.connect(_on_pause_pressed)
	wallet_box.add_child(mobile_pause_button)

	_setup_mobile_bottom()
	_setup_mobile_telegraph()

func _setup_mobile_bottom() -> void:
	var bottom := Control.new()
	bottom.name = "BottomControls"
	bottom.set_anchors_preset(Control.PRESET_FULL_RECT)
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mobile_layer.add_child(bottom)

	var joystick := PanelContainer.new()
	joystick.name = "JoystickZone"
	joystick.custom_minimum_size = Vector2(132, 132)
	joystick.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	joystick.offset_left = 18.0
	joystick.offset_top = -154.0
	joystick.offset_right = 150.0
	joystick.offset_bottom = -22.0
	SCI_FI_THEME.apply_panel(joystick, Color(0.0705882, 0.101961, 0.141176, 0.45), Color(0.156863, 0.843137, 1.0, 0.18))
	bottom.add_child(joystick)
	var joy_label := Label.new()
	joy_label.text = "MOVE"
	joy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	joy_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	SCI_FI_THEME.apply_label(joy_label, true, 13)
	joystick.add_child(joy_label)

	mobile_guard_panel = _make_mobile_panel("GuardMiniCard", Vector2(260, 70))
	mobile_guard_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	mobile_guard_panel.offset_left = -130.0
	mobile_guard_panel.offset_top = -92.0
	mobile_guard_panel.offset_right = 130.0
	mobile_guard_panel.offset_bottom = -22.0
	mobile_guard_panel.visible = false
	bottom.add_child(mobile_guard_panel)
	var guard_box := _panel_vbox(mobile_guard_panel)
	mobile_guard_name_label = Label.new()
	mobile_guard_name_label.text = "GD  Guard"
	SCI_FI_THEME.apply_label(mobile_guard_name_label, false, 14)
	guard_box.add_child(mobile_guard_name_label)
	mobile_guard_hp_bar = ProgressBar.new()
	mobile_guard_hp_bar.show_percentage = false
	mobile_guard_hp_bar.max_value = 1.0
	mobile_guard_hp_bar.value = 1.0
	SCI_FI_THEME.apply_progress(mobile_guard_hp_bar, SCI_FI_THEME.SUCCESS)
	guard_box.add_child(mobile_guard_hp_bar)
	mobile_guard_cooldown_label = Label.new()
	mobile_guard_cooldown_label.text = "READY"
	SCI_FI_THEME.apply_label(mobile_guard_cooldown_label, true, 12)
	guard_box.add_child(mobile_guard_cooldown_label)

	var actions := VBoxContainer.new()
	actions.name = "ActionCluster"
	actions.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	actions.offset_left = -292.0
	actions.offset_top = -184.0
	actions.offset_right = -18.0
	actions.offset_bottom = -18.0
	actions.add_theme_constant_override("separation", 10)
	bottom.add_child(actions)
	if skill_hud != null:
		if skill_hud.get_parent() != null:
			skill_hud.get_parent().remove_child(skill_hud)
		actions.add_child(skill_hud)
	mobile_fire_button = Button.new()
	mobile_fire_button.name = "FireButton"
	mobile_fire_button.text = "FIRE"
	mobile_fire_button.custom_minimum_size = Vector2(274, 72)
	SCI_FI_THEME.apply_button(mobile_fire_button, SCI_FI_THEME.WARNING)
	mobile_fire_button.pressed.connect(_on_fire_button_pressed)
	actions.add_child(mobile_fire_button)

func _setup_mobile_telegraph() -> void:
	mobile_telegraph_panel = _make_mobile_panel("BossTelegraph", Vector2(260, 46))
	mobile_telegraph_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	mobile_telegraph_panel.offset_left = -130.0
	mobile_telegraph_panel.offset_top = 108.0
	mobile_telegraph_panel.offset_right = 130.0
	mobile_telegraph_panel.offset_bottom = 154.0
	mobile_telegraph_panel.visible = false
	SCI_FI_THEME.apply_panel(mobile_telegraph_panel, Color(0.18, 0.04, 0.05, 0.88), Color(1.0, 0.301961, 0.301961, 0.9))
	mobile_layer.add_child(mobile_telegraph_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	mobile_telegraph_panel.add_child(margin)
	mobile_telegraph_label = Label.new()
	mobile_telegraph_label.text = "WARNING"
	mobile_telegraph_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	SCI_FI_THEME.apply_label(mobile_telegraph_label, false, 15)
	margin.add_child(mobile_telegraph_label)

func _make_mobile_panel(panel_name: String, minimum_size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.name = panel_name
	panel.custom_minimum_size = minimum_size
	SCI_FI_THEME.apply_panel(panel)
	return panel

func _panel_vbox(panel: PanelContainer) -> VBoxContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)
	return box

func _guard_abbreviation(display_name: String) -> String:
	var words := display_name.split(" ", false)
	var abbreviation := ""
	for word in words:
		if word.length() > 0:
			abbreviation += word.substr(0, 1).to_upper()
		if abbreviation.length() >= 2:
			break
	return "GD" if abbreviation.is_empty() else abbreviation

func _on_fire_button_pressed() -> void:
	_play_button_press(mobile_fire_button)
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("spawn_projectile"):
		player.call("spawn_projectile")

func _update_mobile_enemy_count() -> void:
	if mobile_enemy_label == null:
		return
	var count := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is Enemy and not (enemy as Enemy).is_dead():
			count += 1
	mobile_enemy_label.text = "HOSTILES %d" % count

func _update_guard_cooldown_indicator() -> void:
	if mobile_guard_cooldown_label == null or _active_guard_id.is_empty():
		return
	var best_remaining := 0.0
	for guard in get_tree().get_nodes_in_group("guards"):
		if guard == null or not is_instance_valid(guard):
			continue
		var guard_id := ""
		if guard is ShooterGuard:
			guard_id = (guard as ShooterGuard).guardian_id
		elif guard is BruiserGuard:
			guard_id = "guard_bruiser"
		if guard_id != _active_guard_id:
			continue
		if guard.has_method("is_dead") and bool(guard.call("is_dead")):
			mobile_guard_cooldown_label.text = "DOWN"
			return
		var cooldowns: Dictionary = guard.get("_cooldowns")
		var shortest := INF
		for key in cooldowns.keys():
			var remaining := float(cooldowns.get(key, 0.0))
			if remaining > 0.0:
				shortest = minf(shortest, remaining)
		best_remaining = 0.0 if is_inf(shortest) else shortest
		break
	mobile_guard_cooldown_label.text = "READY" if best_remaining <= 0.0 else "%.0fs" % ceilf(best_remaining)

func _play_button_press(button: Button) -> void:
	if button == null:
		return
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(button, "scale", Vector2.ONE, 0.08)

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
	if mobile_wave_label != null:
		mobile_wave_label.text = "WAVE %d%s" % [value, boss_suffix.to_upper()]

func _on_boss_wave_changed(is_boss_wave_now: bool) -> void:
	var boss_suffix := ""
	if is_boss_wave_now:
		boss_suffix = " Boss"

	var wave_value := 0
	if game_manager != null:
		wave_value = game_manager.current_wave
	wave_label.text = "Wave: %d%s" % [wave_value, boss_suffix]
	if mobile_wave_label != null:
		mobile_wave_label.text = "WAVE %d%s" % [wave_value, boss_suffix.to_upper()]

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
	if is_visible and mobile_telegraph_panel != null and _telegraph_timer <= 0.0:
		mobile_telegraph_panel.visible = current_hp > 0
		if mobile_telegraph_label != null:
			mobile_telegraph_label.text = "BOSS %d/%d" % [current_hp, max_hp]

func _on_wallet_changed(gold: int, gems: int, _shards: Dictionary) -> void:
	if mobile_coins_label != null:
		mobile_coins_label.text = "G %d   C %d" % [gold, gems]

func _on_boss_telegraph_started(attack_id: String, duration: float) -> void:
	if mobile_telegraph_panel == null or mobile_telegraph_label == null:
		return
	match attack_id:
		"slam":
			mobile_telegraph_label.text = "SLAM"
		"charge":
			mobile_telegraph_label.text = "CHARGE"
		"summon":
			mobile_telegraph_label.text = "SUMMON"
		_:
			mobile_telegraph_label.text = "WARNING"
	mobile_telegraph_panel.visible = true
	_telegraph_timer = maxf(duration, 0.4)

func _on_pause_pressed() -> void:
	_play_button_press(mobile_pause_button)
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
	_style_upgrade_button(upgrade_button_1, options[0])
	_style_upgrade_button(upgrade_button_2, options[1])
	_style_upgrade_button(upgrade_button_3, options[2])
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
	return "%s  %s  x%d\n%s" % [
		option.get("title", option.get("name", "")),
		str(option.get("tier", "common")).capitalize(),
		int(option.get("stack_count", 0)),
		option.get("description", ""),
	]

func _style_upgrade_button(button: Button, option: Dictionary) -> void:
	var tier := str(option.get("tier", "common"))
	var border := Color(0.61, 0.64, 0.69, 1.0)
	match tier:
		"rare":
			border = Color(0.23, 0.51, 0.96, 1.0)
		"epic":
			border = Color(0.66, 0.33, 0.97, 1.0)
		"legendary":
			border = Color(0.98, 0.45, 0.09, 1.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.07, 0.08, 0.96).lerp(border, 0.08)
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_left = 7
	style.corner_radius_bottom_right = 7
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("focus", style)

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
			var compact_height: float = maxf(original_size.y, 64.0)
			button.custom_minimum_size = Vector2(maxf(original_size.x, 64.0) if is_compact else original_size.x, compact_height if is_compact else original_size.y)
		_update_touch_targets(child, is_compact)
