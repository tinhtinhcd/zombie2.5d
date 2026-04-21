extends Control
class_name SettingsScreen

signal back_requested

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

func _on_back_pressed() -> void:
	back_requested.emit()
