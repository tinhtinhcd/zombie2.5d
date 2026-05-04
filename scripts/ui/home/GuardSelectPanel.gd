extends RefCounted
class_name GuardSelectPanel

const HOME_UI_STYLE := preload("res://scripts/ui/home/HomeUIStyle.gd")

signal guard_focused(guard_id: String)
signal guard_confirmed(guard_id: String)

var _status_label: Label
var _confirm_button: Button
var _grid: GridContainer
var _game_manager: GameManager
var _home_state
var _guard_buttons: Dictionary = {}
var _guard_cards: Dictionary = {}
var selected_guard_index: int = 0

func setup(status_label: Label, confirm_button: Button, grid: GridContainer, game_manager: GameManager, home_state = null) -> void:
	_status_label = status_label
	_confirm_button = confirm_button
	_grid = grid
	_game_manager = game_manager
	_home_state = home_state
	if _confirm_button != null:
		_confirm_button.pressed.connect(_on_confirm_pressed)
	_rebuild_cards()

func refresh(selected_guard_id: String) -> void:
	if _game_manager == null:
		return
	var guard_ids := _get_guard_ids()
	if guard_ids.is_empty():
		return
	if selected_guard_id.is_empty() and _home_state != null:
		selected_guard_id = _home_state.selected_guard_id
	selected_guard_index = max(guard_ids.find(selected_guard_id), 0)
	var centered_guard_id := str(guard_ids[selected_guard_index])
	var unlocked := _game_manager.is_guardian_unlocked(centered_guard_id)
	if _confirm_button != null:
		_confirm_button.text = "Confirm" if unlocked else "Locked"
		_confirm_button.disabled = not unlocked
		HOME_UI_STYLE.apply_button_state(_confirm_button, "selected" if unlocked else "locked")
	_refresh_status(centered_guard_id, unlocked)
	_refresh_cards(centered_guard_id)

func _rebuild_cards() -> void:
	if _grid == null or _game_manager == null:
		return
	for child in _grid.get_children():
		child.queue_free()
	_guard_buttons.clear()
	_guard_cards.clear()
	for guard_id in _get_guard_ids():
		var card := _create_card(str(guard_id))
		_grid.add_child(card)
		_guard_cards[str(guard_id)] = card

func _create_card(guard_id: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "%sCard" % _node_suffix(guard_id)
	card.custom_minimum_size = Vector2(120.0, 170.0)
	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	vbox.add_theme_constant_override("separation", 5)
	margin.add_child(vbox)
	var portrait := Label.new()
	portrait.name = "PortraitLabel"
	portrait.custom_minimum_size = Vector2(0.0, 64.0)
	portrait.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	portrait.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	vbox.add_child(portrait)
	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)
	var description_label := Label.new()
	description_label.name = "DescriptionLabel"
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(description_label)
	var button := Button.new()
	button.name = "SelectButton"
	button.custom_minimum_size = Vector2(0.0, 36.0)
	button.pressed.connect(_focus_guard.bind(guard_id))
	vbox.add_child(button)
	_guard_buttons[guard_id] = button
	return card

func _refresh_status(guard_id: String, unlocked: bool) -> void:
	if _status_label == null:
		return
	var definition := _game_manager.get_guardian(guard_id)
	var skills: Array = definition.get("skills", [])
	var first_skill := "Support"
	if not skills.is_empty() and typeof(skills[0]) == TYPE_DICTIONARY:
		first_skill = str((skills[0] as Dictionary).get("name", first_skill))
	_status_label.text = "%s\n%s | %s | %s" % [
		_game_manager.get_display_name(definition, "Guard"),
		str(definition.get("role", "support")).replace("_", " ").capitalize(),
		first_skill,
		"Ready" if unlocked else _format_unlock(definition),
	]

func _refresh_cards(selected_guard_id: String) -> void:
	for guard_id in _guard_cards.keys():
		var card := _guard_cards.get(guard_id) as PanelContainer
		var button := _guard_buttons.get(guard_id) as Button
		if card == null or button == null:
			continue
		var selected := str(guard_id) == selected_guard_id
		var unlocked := _game_manager.is_guardian_unlocked(str(guard_id))
		var definition := _game_manager.get_guardian(str(guard_id))
		card.modulate = Color(1.0, 1.0, 1.0, 1.0 if selected else 0.62)
		HOME_UI_STYLE.apply_related_card_from_button(button, selected)
		HOME_UI_STYLE.apply_button_state(button, "selected" if selected and unlocked else ("locked" if not unlocked else "default"))
		button.text = "Centered" if selected else ("Locked" if not unlocked else "Focus")
		var portrait_label := card.get_node_or_null("Margin/VBox/PortraitLabel") as Label
		var name_label := card.get_node_or_null("Margin/VBox/NameLabel") as Label
		var description_label := card.get_node_or_null("Margin/VBox/DescriptionLabel") as Label
		if portrait_label != null:
			portrait_label.text = _portrait_for_guard(str(guard_id))
		if name_label != null:
			name_label.text = _game_manager.get_display_name(definition, "Guard")
		if description_label != null:
			description_label.text = str(definition.get("role", "support")).replace("_", " ").capitalize()

func _focus_guard(guard_id: String) -> void:
	if _home_state != null:
		_home_state.set_selected_guard(guard_id)
	else:
		refresh(guard_id)
	guard_focused.emit(guard_id)

func _on_confirm_pressed() -> void:
	var guard_ids := _get_guard_ids()
	if guard_ids.is_empty():
		return
	guard_confirmed.emit(str(guard_ids[selected_guard_index]))

func _get_guard_ids() -> Array:
	if _game_manager == null:
		return []
	return _game_manager.get_guardian_ids()

func _format_unlock(definition: Dictionary) -> String:
	return str(definition.get("unlock_condition", "locked")).replace("_", " ").capitalize()

func _portrait_for_guard(guard_id: String) -> String:
	match guard_id:
		"guard_bruiser":
			return "BRZ"
		"guard_shooter":
			return "SHT"
		"guard_medic":
			return "MED"
		"guard_engineer":
			return "ENG"
		"guard_sentinel":
			return "SNT"
	return "GRD"

func _node_suffix(value: String) -> String:
	var parts := value.split("_", false)
	var suffix := ""
	for part in parts:
		suffix += str(part).capitalize().replace(" ", "")
	return suffix
