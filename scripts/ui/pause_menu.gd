extends Control
class_name PauseMenuUI

signal resume_requested
signal settings_requested
signal home_requested

@onready var resume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var settings_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/SettingsButton
@onready var home_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/HomeButton

func _ready() -> void:
	visible = false
	resume_button.pressed.connect(_on_resume_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	home_button.pressed.connect(_on_home_pressed)

func _on_resume_pressed() -> void:
	visible = false
	resume_requested.emit()

func _on_settings_pressed() -> void:
	settings_requested.emit()

func _on_home_pressed() -> void:
	visible = false
	home_requested.emit()
