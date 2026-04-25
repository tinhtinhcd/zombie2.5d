extends RefCounted
class_name HeroSelectPanel

const HOME_UI_STYLE := preload("res://scripts/ui/home/HomeUIStyle.gd")

const HERO_IDS := ["hero_knight", "hero_rogue", "hero_mage"]
const HERO_PRESENTATION := {
	"hero_knight": {
		"name": "Alex Mercer",
		"role": "Vanguard",
		"level": 25,
		"power": 32540,
		"summary": "Balanced survivor with reliable starter stats.",
	},
	"hero_rogue": {
		"name": "Mia Stone",
		"role": "Scout",
		"level": 18,
		"power": 28720,
		"summary": "Fast survivor built for later unlock progression.",
	},
	"hero_mage": {
		"name": "Derek Walker",
		"role": "Tech",
		"level": 14,
		"power": 30110,
		"summary": "High damage survivor planned for a future milestone.",
	},
}

var _status_label: Label
var _continue_button: Button
var _knight_button: Button
var _rogue_button: Button
var _mage_button: Button
var _game_manager: GameManager
var _home_state
var selected_hero_index: int = 0
var _hero_cards: GridContainer
var _hero_buttons: Dictionary = {}
var _hero_card_nodes: Dictionary = {}
var _left_button: Button
var _right_button: Button

func setup(status_label: Label, continue_button: Button, knight_button: Button, rogue_button: Button, mage_button: Button, game_manager: GameManager, home_state = null) -> void:
	_status_label = status_label
	_continue_button = continue_button
	_knight_button = knight_button
	_rogue_button = rogue_button
	_mage_button = mage_button
	_game_manager = game_manager
	_home_state = home_state
	_hero_buttons = {
		"hero_knight": _knight_button,
		"hero_rogue": _rogue_button,
		"hero_mage": _mage_button,
	}
	_cache_card_nodes()
	_install_carousel_controls()

func refresh(selected_hero_id: String) -> void:
	if _status_label == null or _continue_button == null or _game_manager == null:
		return
	if selected_hero_id.is_empty() and _home_state != null:
		selected_hero_id = _home_state.selected_hero_id

	selected_hero_index = _get_hero_index(selected_hero_id)
	var centered_hero_id: String = str(HERO_IDS[selected_hero_index])
	var centered_unlocked := _game_manager.is_hero_unlocked(centered_hero_id)
	_continue_button.disabled = not centered_unlocked
	_continue_button.text = "Confirm" if centered_unlocked else "Locked"
	HOME_UI_STYLE.apply_button_state(_continue_button, "selected" if centered_unlocked else "locked")
	_update_carousel_order()

	var presentation: Dictionary = HERO_PRESENTATION.get(centered_hero_id, {})
	_status_label.text = "%s  Lv.%d  Power %d\n%s | %s" % [
		str(presentation.get("name", _game_manager.get_display_name(_game_manager.get_hero_definition(centered_hero_id), "Hero"))),
		int(presentation.get("level", 1)),
		int(presentation.get("power", 1)),
		str(presentation.get("role", "Survivor")),
		"Ready" if centered_unlocked else "Locked",
	]

func _get_select_button_text(item_id: String, selected_id: String, unlocked: bool) -> String:
	if selected_id == item_id:
		return "Centered"
	if not unlocked:
		return "Locked"
	return "Focus"

func _style_select_button(button: Button, is_selected: bool, is_unlocked: bool) -> void:
	var state := "selected" if is_selected else ("default" if is_unlocked else "locked")
	HOME_UI_STYLE.apply_button_state(button, state)
	HOME_UI_STYLE.apply_related_card_from_button(button, is_selected)

func _cache_card_nodes() -> void:
	_hero_card_nodes.clear()
	_hero_cards = _find_ancestor_grid(_knight_button)
	for hero_id in _hero_buttons.keys():
		var button := _hero_buttons[hero_id] as Button
		if button == null:
			continue
		var card := _find_ancestor_panel(button)
		if card != null:
			_hero_card_nodes[hero_id] = card

func _install_carousel_controls() -> void:
	if _hero_cards == null:
		return
	_hero_cards.columns = 5
	_left_button = _hero_cards.get_node_or_null("CarouselLeftButton") as Button
	if _left_button == null:
		_left_button = Button.new()
		_left_button.name = "CarouselLeftButton"
		_left_button.text = "<"
		_left_button.custom_minimum_size = Vector2(42.0, 88.0)
		_hero_cards.add_child(_left_button)
	_left_button.pressed.connect(_on_left_pressed)
	HOME_UI_STYLE.apply_button_state(_left_button, "secondary")

	_right_button = _hero_cards.get_node_or_null("CarouselRightButton") as Button
	if _right_button == null:
		_right_button = Button.new()
		_right_button.name = "CarouselRightButton"
		_right_button.text = ">"
		_right_button.custom_minimum_size = Vector2(42.0, 88.0)
		_hero_cards.add_child(_right_button)
	_right_button.pressed.connect(_on_right_pressed)
	HOME_UI_STYLE.apply_button_state(_right_button, "secondary")

func _update_carousel_order() -> void:
	if _hero_cards == null:
		return
	_hero_cards.columns = 5
	var previous_id: String = str(HERO_IDS[(selected_hero_index - 1 + HERO_IDS.size()) % HERO_IDS.size()])
	var centered_id: String = str(HERO_IDS[selected_hero_index])
	var next_id: String = str(HERO_IDS[(selected_hero_index + 1) % HERO_IDS.size()])
	if _left_button != null:
		_hero_cards.move_child(_left_button, 0)
	_update_card_slot(previous_id, 1, false)
	_update_card_slot(centered_id, 2, true)
	_update_card_slot(next_id, 3, false)
	if _right_button != null:
		_hero_cards.move_child(_right_button, 4)

func _update_card_slot(hero_id: String, target_index: int, is_centered: bool) -> void:
	var card := _hero_card_nodes.get(hero_id) as PanelContainer
	var button := _hero_buttons.get(hero_id) as Button
	if card == null or button == null:
		return
	var unlocked := _game_manager.is_hero_unlocked(hero_id)
	_hero_cards.move_child(card, target_index)
	card.modulate = Color(1.0, 1.0, 1.0, 1.0 if is_centered else 0.55)
	card.scale = Vector2.ONE if is_centered else Vector2(0.88, 0.88)
	card.pivot_offset = card.size * 0.5
	button.text = _get_select_button_text(hero_id, HERO_IDS[selected_hero_index], unlocked)
	_style_select_button(button, is_centered, unlocked)
	_update_card_text(card, hero_id, is_centered, unlocked)

func _update_card_text(card: PanelContainer, hero_id: String, is_centered: bool, unlocked: bool) -> void:
	var presentation: Dictionary = HERO_PRESENTATION.get(hero_id, {})
	var name_label := card.get_node_or_null("Margin/VBox/NameLabel") as Label
	var description_label := card.get_node_or_null("Margin/VBox/DescriptionLabel") as Label
	var status_label := card.get_node_or_null("Margin/VBox/StatusLabel") as Label
	if name_label != null:
		name_label.text = str(presentation.get("name", _game_manager.get_display_name(_game_manager.get_hero_definition(hero_id), "Hero")))
	if description_label != null:
		description_label.text = "Lv.%d  Power %d\n%s" % [
			int(presentation.get("level", 1)),
			int(presentation.get("power", 1)),
			str(presentation.get("role", "Survivor")),
		] if is_centered else str(presentation.get("role", "Survivor"))
	if status_label != null:
		status_label.text = "Selected" if is_centered and unlocked else ("Locked" if not unlocked else "Tap to center")

func _on_left_pressed() -> void:
	_focus_index(selected_hero_index - 1)

func _on_right_pressed() -> void:
	_focus_index(selected_hero_index + 1)

func _focus_index(index: int) -> void:
	var wrapped_index := (index + HERO_IDS.size()) % HERO_IDS.size()
	selected_hero_index = wrapped_index
	var hero_id: String = str(HERO_IDS[selected_hero_index])
	if _home_state != null:
		_home_state.set_selected_hero(hero_id)
	else:
		refresh(hero_id)

func _get_hero_index(hero_id: String) -> int:
	var index := HERO_IDS.find(hero_id)
	return index if index >= 0 else 0

func _find_ancestor_grid(node: Node) -> GridContainer:
	var current := node
	while current != null:
		if current is GridContainer:
			return current as GridContainer
		current = current.get_parent()
	return null

func _find_ancestor_panel(node: Node) -> PanelContainer:
	var current := node
	while current != null:
		if current is PanelContainer:
			return current as PanelContainer
		current = current.get_parent()
	return null
