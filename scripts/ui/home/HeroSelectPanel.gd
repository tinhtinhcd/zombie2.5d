extends RefCounted
class_name HeroSelectPanel

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
	if _rogue_button != null:
		_rogue_button.text = _get_select_button_text("hero_rogue", selected_hero_id, _game_manager.is_hero_unlocked("hero_rogue"))
	if _mage_button != null:
		_mage_button.text = _get_select_button_text("hero_mage", selected_hero_id, _game_manager.is_hero_unlocked("hero_mage"))

	if has_selection:
		var hero_definition := _game_manager.get_hero_definition(selected_hero_id)
		_status_label.text = "Selected hero: %s\nStats apply when the run starts." % _game_manager.get_display_name(hero_definition, "Hero")
	else:
		_status_label.text = "Select a hero to continue. Each hero changes basic run stats."

func _get_select_button_text(item_id: String, selected_id: String, unlocked: bool) -> String:
	if selected_id == item_id:
		return "Selected"
	if not unlocked:
		return "Locked"
	return "Select"
