extends Control
class_name PauseMenuUI

signal resume_requested

# Placeholder pause menu for future pause-state and settings flows.

@onready var resume_button: Button = $Panel/ResumeButton
@onready var home_button: Button = $Panel/HomeButton

func _ready() -> void:
    visible = false
    resume_button.pressed.connect(_on_resume_pressed)
    home_button.pressed.connect(_on_home_pressed)

func _on_resume_pressed() -> void:
    visible = false
    resume_requested.emit()

func _on_home_pressed() -> void:
    visible = false
    SceneRouter.go_to_home()
