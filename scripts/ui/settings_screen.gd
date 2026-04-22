extends Control
class_name SettingsScreen

signal back_requested

const MOBILE_WIDTH_THRESHOLD = 700.0
const MOBILE_MARGIN = 14

@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var margin_container: MarginContainer = $CenterContainer/PanelContainer/MarginContainer
@onready var sound_toggle: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/SoundToggle
@onready var music_toggle: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/MusicToggle
@onready var vibration_toggle: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/VibrationToggle
@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Footer/BackButton

func _ready() -> void:
	visible = false
	sound_toggle.button_pressed = true
	music_toggle.button_pressed = true
	vibration_toggle.button_pressed = false
	back_button.pressed.connect(_on_back_pressed)
	get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()

func _on_back_pressed() -> void:
	back_requested.emit()

func _apply_responsive_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var is_narrow := viewport_size.x <= MOBILE_WIDTH_THRESHOLD
	var margin := MOBILE_MARGIN if is_narrow else 24
	panel_container.custom_minimum_size = Vector2(min(460.0, viewport_size.x - float(margin * 2)), 0.0)
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)
	for button in [sound_toggle, music_toggle, vibration_toggle, back_button]:
		button.custom_minimum_size = Vector2(0.0 if is_narrow else button.custom_minimum_size.x, max(button.custom_minimum_size.y, 52.0))
