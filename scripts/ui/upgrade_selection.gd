extends PanelContainer
class_name UpgradeSelection

signal upgrade_selected(upgrade_id: StringName)

var _buttons: Array[Button] = []
var _option_ids: Array[StringName] = []

func _ready() -> void:
	_build_buttons()

func show_options(options: Array) -> void:
	_option_ids.clear()
	_build_buttons()
	for index in range(_buttons.size()):
		var button := _buttons[index]
		if index >= options.size() or typeof(options[index]) != TYPE_DICTIONARY:
			button.visible = false
			continue
		var option: Dictionary = options[index]
		_option_ids.append(StringName(str(option.get("id", ""))))
		button.visible = true
		button.text = "%s\n%s\n%s" % [
			str(option.get("title", option.get("name", ""))),
			str(option.get("tier", "common")).capitalize(),
			str(option.get("description", "")),
		]
	visible = true

func _build_buttons() -> void:
	if not _buttons.is_empty():
		return
	var box := VBoxContainer.new()
	add_child(box)
	for index in range(3):
		var button := Button.new()
		button.custom_minimum_size = Vector2(360, 72)
		button.pressed.connect(_on_button_pressed.bind(index))
		box.add_child(button)
		_buttons.append(button)

func _on_button_pressed(index: int) -> void:
	if index < 0 or index >= _option_ids.size():
		return
	upgrade_selected.emit(_option_ids[index])
	visible = false
