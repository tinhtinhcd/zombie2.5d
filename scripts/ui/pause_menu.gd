extends Control
class_name PauseMenuUI

signal resume_requested
signal settings_requested
signal home_requested

const MOBILE_WIDTH_THRESHOLD = 700.0
const MOBILE_MARGIN = 14

@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var margin_container: MarginContainer = $CenterContainer/PanelContainer/MarginContainer
@onready var resume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var settings_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SettingsButton
@onready var home_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HomeButton

func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	home_button.pressed.connect(_on_home_pressed)
	get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()

func _on_resume_pressed() -> void:
	visible = false
	resume_requested.emit()

func _on_settings_pressed() -> void:
	settings_requested.emit()

func _on_home_pressed() -> void:
	visible = false
	home_requested.emit()

func _apply_responsive_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var is_narrow := viewport_size.x <= MOBILE_WIDTH_THRESHOLD
	var margin := MOBILE_MARGIN if is_narrow else 24
	panel_container.custom_minimum_size = Vector2(min(360.0, viewport_size.x - float(margin * 2)), 0.0)
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)
	for button in [resume_button, settings_button, home_button]:
		button.custom_minimum_size = Vector2(0.0 if is_narrow else button.custom_minimum_size.x, max(button.custom_minimum_size.y, 52.0))
