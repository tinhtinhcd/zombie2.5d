extends Control
class_name PlaceholderPopup

signal closed

const MOBILE_WIDTH_THRESHOLD = 700.0
const MOBILE_MARGIN = 14

@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var margin_container: MarginContainer = $CenterContainer/PanelContainer/MarginContainer
@onready var title_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var message_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MessageLabel
@onready var close_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/CloseButton

func _ready() -> void:
	visible = false
	close_button.pressed.connect(_on_close_pressed)
	get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()

func show_message(title: String, message: String) -> void:
	title_label.text = title
	message_label.text = message
	visible = true

func _on_close_pressed() -> void:
	visible = false
	closed.emit()

func _apply_responsive_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var is_narrow := viewport_size.x <= MOBILE_WIDTH_THRESHOLD
	var margin := MOBILE_MARGIN if is_narrow else 24
	panel_container.custom_minimum_size = Vector2(min(420.0, viewport_size.x - float(margin * 2)), 0.0)
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)
	close_button.custom_minimum_size = Vector2(0.0 if is_narrow else close_button.custom_minimum_size.x, max(close_button.custom_minimum_size.y, 52.0))
