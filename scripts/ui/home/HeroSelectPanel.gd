extends RefCounted
class_name HeroSelectPanel

const HOME_UI_STYLE := preload("res://scripts/ui/home/HomeUIStyle.gd")

var _status_label: Label
var _continue_button: Button
var _knight_button: Button
var _rogue_button: Button
var _mage_button: Button
var _game_manager: GameManager
var _home_state

func setup(status_label: Label, continue_button: Button, knight_button: Button, rogue_button: Button, mage_button: Button, game_manager: GameManager, home_state = null) -> void:
	_status_label = status_label
	_continue_button = continue_button
	_knight_button = knight_button
	_rogue_button = rogue_button
	_mage_button = mage_button
	_game_manager = game_manager
	_home_state = home_state

func refresh(selected_hero_id: String) -> void:
	if _status_label == null or _continue_button == null or _game_manager == null:
		return
	if selected_hero_id.is_empty() and _home_state != null:
		selected_hero_id = _home_state.selected_hero_id

	var has_selection := selected_hero_id != ""
	_continue_button.disabled = not has_selection
	if _knight_button != null:
		_knight_button.text = "Selected" if selected_hero_id == "hero_knight" else "Select"
		_style_select_button(_knight_button, selected_hero_id == "hero_knight", true)
	if _rogue_button != null:
		_rogue_button.text = _get_select_button_text("hero_rogue", selected_hero_id, _game_manager.is_hero_unlocked("hero_rogue"))
		_style_select_button(_rogue_button, selected_hero_id == "hero_rogue", _game_manager.is_hero_unlocked("hero_rogue"))
	if _mage_button != null:
		_mage_button.text = _get_select_button_text("hero_mage", selected_hero_id, _game_manager.is_hero_unlocked("hero_mage"))
		_style_select_button(_mage_button, selected_hero_id == "hero_mage", _game_manager.is_hero_unlocked("hero_mage"))
	HOME_UI_STYLE.apply_button_state(_continue_button, "selected" if has_selection else "locked")

	if has_selection:
		var hero_definition := _game_manager.get_hero_definition(selected_hero_id)
		_status_label.text = "Selected Hero\n%s\nRun stats are applied when the game starts." % _game_manager.get_display_name(hero_definition, "Hero")
	else:
		_status_label.text = "Select a hero to continue. Each hero changes basic run stats."

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
