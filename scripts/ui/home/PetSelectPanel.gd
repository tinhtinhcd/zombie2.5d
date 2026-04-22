extends RefCounted
class_name PetSelectPanel

const HOME_UI_STYLE := preload("res://scripts/ui/home/HomeUIStyle.gd")

var _status_label: Label
var _drone_button: Button
var _sprite_button: Button
var _wisp_button: Button
var _game_manager: GameManager
var _home_state

func setup(status_label: Label, drone_button: Button, sprite_button: Button, wisp_button: Button, game_manager: GameManager, home_state = null) -> void:
	_status_label = status_label
	_drone_button = drone_button
	_sprite_button = sprite_button
	_wisp_button = wisp_button
	_game_manager = game_manager
	_home_state = home_state

func refresh(selected_pet_id: String) -> void:
	if _status_label == null or _game_manager == null:
		return
	if selected_pet_id.is_empty() and _home_state != null:
		selected_pet_id = _home_state.selected_pet_id

	if _drone_button != null:
		_drone_button.text = "Selected" if selected_pet_id == "pet_drone" else "Select"
		_style_select_button(_drone_button, selected_pet_id == "pet_drone", true)
	if _sprite_button != null:
		_sprite_button.text = _get_select_button_text("pet_sprite", selected_pet_id, _game_manager.is_pet_unlocked("pet_sprite"))
		_style_select_button(_sprite_button, selected_pet_id == "pet_sprite", _game_manager.is_pet_unlocked("pet_sprite"))
	if _wisp_button != null:
		_wisp_button.text = _get_select_button_text("pet_wisp", selected_pet_id, _game_manager.is_pet_unlocked("pet_wisp"))
		_style_select_button(_wisp_button, selected_pet_id == "pet_wisp", _game_manager.is_pet_unlocked("pet_wisp"))

	if selected_pet_id == "":
		_status_label.text = "No pet selected.\nThis is intentional for MVP, and Start Game still works."
	else:
		var pet_definition := _game_manager.get_pet_definition(selected_pet_id)
		_status_label.text = "Selected Pet\n%s\nPet assists with light automatic damage." % _game_manager.get_display_name(pet_definition, "Pet")

func _get_select_button_text(item_id: String, selected_id: String, unlocked: bool) -> String:
	if selected_id == item_id:
		return "Selected"
	if not unlocked:
		return "Locked"
	return "Select"

func _style_select_button(button: Button, is_selected: bool, is_unlocked: bool) -> void:
	var state := "selected" if is_selected else ("default" if is_unlocked else "locked")
	HOME_UI_STYLE.apply_button_state(button, state)
	HOME_UI_STYLE.apply_related_card_from_button(button, is_selected)
