extends Control

const HOME_SCREEN_CONTROLLER_SCRIPT := preload("res://scripts/ui/home/HomeScreenController.gd")

var _controller: Node
var _home_state

func _ready() -> void:
	_controller = Node.new()
	_controller.name = "HomeScreenController"
	_controller.set_script(HOME_SCREEN_CONTROLLER_SCRIPT)
	add_child(_controller)
	_home_state = _controller.get("_home_state")

func _show_screen(screen_name: String, add_to_history: bool = true) -> void:
	_controller.call("_show_screen", screen_name, add_to_history)

func _go_back() -> void:
	_controller.call("_go_back")

func _get_ui_node(path: String) -> Node:
	return _controller.call("_get_ui_node", path) as Node

func _on_play_pressed() -> void:
	_controller.call("_on_play_pressed")

func _on_hub_hero_pressed() -> void:
	_controller.call("_on_hub_hero_pressed")

func _on_hub_pet_pressed() -> void:
	_controller.call("_on_hub_pet_pressed")

func _on_hub_equipment_pressed() -> void:
	_controller.call("_on_hub_equipment_pressed")

func _on_inventory_pressed() -> void:
	_controller.call("_on_inventory_pressed")

func _on_knight_pressed() -> void:
	_controller.call("_on_knight_pressed")

func _on_rogue_pressed() -> void:
	_controller.call("_on_rogue_pressed")

func _on_mage_pressed() -> void:
	_controller.call("_on_mage_pressed")

func _on_hero_continue_pressed() -> void:
	_controller.call("_on_hero_continue_pressed")

func _on_drone_pressed() -> void:
	_controller.call("_on_drone_pressed")

func _on_sprite_pressed() -> void:
	_controller.call("_on_sprite_pressed")

func _on_wisp_pressed() -> void:
	_controller.call("_on_wisp_pressed")

func _on_equipment_slot_requested(slot_id: String) -> void:
	_controller.call("_on_equipment_slot_requested", slot_id)

func _on_inventory_item_selected(item_id: String) -> void:
	_controller.call("_on_inventory_item_selected", item_id)
