extends Control
class_name PauseMenuUI

signal resume_requested
signal home_requested

# Pause menu UI. Emits signals for resume and home actions so the game scene
# controls navigation flow. This keeps scene routing out of the UI layer.

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
    home_requested.emit()
