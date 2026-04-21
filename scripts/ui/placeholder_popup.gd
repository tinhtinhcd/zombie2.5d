extends Control
class_name PlaceholderPopup

signal closed

@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var message_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MessageLabel
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CloseButton

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close_pressed)

func show_message(title: String, message: String) -> void:
	title_label.text = title
	message_label.text = message
	visible = true

func _on_close_pressed() -> void:
	visible = false
	closed.emit()

