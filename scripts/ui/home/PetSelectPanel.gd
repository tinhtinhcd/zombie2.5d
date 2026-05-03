extends RefCounted
class_name PetSelectPanel

const HOME_UI_STYLE := preload("res://scripts/ui/home/HomeUIStyle.gd")

const PET_IDS := ["pet_drone", "pet_sprite", "pet_wisp"]
const PET_PRESENTATION := {
	"pet_drone": {
		"name": "Rex",
		"role": "Auto Turret",
		"level": 15,
		"power": 1840,
		"bonus": "+1 auto-shot",
		"portrait": "REX",
	},
	"pet_sprite": {
		"name": "Luna",
		"role": "Support",
		"level": 12,
		"power": 1620,
		"bonus": "Faster assist",
		"portrait": "LUNA",
	},
	"pet_wisp": {
		"name": "Bruno",
		"role": "Collector",
		"level": 10,
		"power": 1710,
		"bonus": "XP sweep",
		"portrait": "BRUNO",
	},
}

var _status_label: Label
var _start_button: Button
var _drone_button: Button
var _sprite_button: Button
var _wisp_button: Button
var _game_manager: GameManager
var _home_state
var selected_pet_index: int = 0
var _pet_cards: GridContainer
var _pet_buttons: Dictionary = {}
var _pet_card_nodes: Dictionary = {}
var _left_button: Button
var _right_button: Button
var _evolve_button: Button

func setup(status_label: Label, start_button: Button, drone_button: Button, sprite_button: Button, wisp_button: Button, game_manager: GameManager, home_state = null) -> void:
	_status_label = status_label
	_start_button = start_button
	_drone_button = drone_button
	_sprite_button = sprite_button
	_wisp_button = wisp_button
	_game_manager = game_manager
	_home_state = home_state
	_pet_buttons = {
		"pet_drone": _drone_button,
		"pet_sprite": _sprite_button,
		"pet_wisp": _wisp_button,
	}
	_cache_card_nodes()
	_install_carousel_controls()
	_install_evolve_button()

func refresh(selected_pet_id: String) -> void:
	if _status_label == null or _game_manager == null:
		return
	if selected_pet_id.is_empty() and _home_state != null:
		selected_pet_id = _home_state.selected_pet_id

	selected_pet_index = _get_pet_index(selected_pet_id)
	var centered_pet_id: String = str(PET_IDS[selected_pet_index])
	var centered_unlocked := _game_manager.is_pet_unlocked(centered_pet_id)
	if _start_button != null:
		_start_button.disabled = not centered_unlocked
		_start_button.text = "Confirm" if centered_unlocked else "Locked"
		HOME_UI_STYLE.apply_button_state(_start_button, "selected" if centered_unlocked else "locked")
	_refresh_evolve_button(centered_pet_id, centered_unlocked)
	_update_carousel_order()

	var presentation: Dictionary = PET_PRESENTATION.get(centered_pet_id, {})
	var stage := _game_manager.get_pet_evolution_stage(centered_pet_id)
	var evolution := _game_manager.get_pet_evolution(centered_pet_id)
	_status_label.text = "%s  Stage %d  Shards %d\n%s | %s | %s +%.0f%%" % [
		str(presentation.get("name", _game_manager.get_display_name(_game_manager.get_pet_definition(centered_pet_id), "Pet"))),
		stage,
		_game_manager.pet_evolution_shards,
		str(presentation.get("role", "Companion")),
		str(presentation.get("bonus", "Assist")),
		str(evolution.get("buff_type", "buff")).replace("_", " "),
		float(evolution.get("base_buff_value", 0.0)) * 100.0,
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
	_pet_card_nodes.clear()
	_pet_cards = _find_ancestor_grid(_drone_button)
	for pet_id in _pet_buttons.keys():
		var button := _pet_buttons[pet_id] as Button
		if button == null:
			continue
		var card := _find_ancestor_panel(button)
		if card != null:
			_pet_card_nodes[pet_id] = card

func _install_carousel_controls() -> void:
	if _pet_cards == null:
		return
	_pet_cards.columns = 5
	_left_button = _pet_cards.get_node_or_null("CarouselLeftButton") as Button
	if _left_button == null:
		_left_button = Button.new()
		_left_button.name = "CarouselLeftButton"
		_left_button.text = "<"
		_left_button.custom_minimum_size = Vector2(42.0, 88.0)
		_pet_cards.add_child(_left_button)
	_left_button.pressed.connect(_on_left_pressed)
	HOME_UI_STYLE.apply_button_state(_left_button, "secondary")

	_right_button = _pet_cards.get_node_or_null("CarouselRightButton") as Button
	if _right_button == null:
		_right_button = Button.new()
		_right_button.name = "CarouselRightButton"
		_right_button.text = ">"
		_right_button.custom_minimum_size = Vector2(42.0, 88.0)
		_pet_cards.add_child(_right_button)
	_right_button.pressed.connect(_on_right_pressed)
	HOME_UI_STYLE.apply_button_state(_right_button, "secondary")

func _install_evolve_button() -> void:
	if _start_button == null:
		return
	_evolve_button = _start_button.get_parent().get_node_or_null("EvolveButton") as Button
	if _evolve_button == null:
		_evolve_button = Button.new()
		_evolve_button.name = "EvolveButton"
		_evolve_button.custom_minimum_size = _start_button.custom_minimum_size
		_evolve_button.text = "Evolve"
		_start_button.get_parent().add_child(_evolve_button)
		_start_button.get_parent().move_child(_evolve_button, max(_start_button.get_index(), 0))
	_evolve_button.pressed.connect(_on_evolve_pressed)

func _refresh_evolve_button(pet_id: String, unlocked: bool) -> void:
	if _evolve_button == null:
		return
	var stage := _game_manager.get_pet_evolution_stage(pet_id)
	var cost := _game_manager.get_pet_next_evolution_cost(pet_id)
	_evolve_button.text = "Evolve %d" % cost if stage < 3 else "Max Stage"
	_evolve_button.disabled = not unlocked or stage >= 3 or _game_manager.pet_evolution_shards < cost
	HOME_UI_STYLE.apply_button_state(_evolve_button, "selected" if not _evolve_button.disabled else "locked")

func _update_carousel_order() -> void:
	if _pet_cards == null:
		return
	_pet_cards.columns = 5
	var previous_id: String = str(PET_IDS[(selected_pet_index - 1 + PET_IDS.size()) % PET_IDS.size()])
	var centered_id: String = str(PET_IDS[selected_pet_index])
	var next_id: String = str(PET_IDS[(selected_pet_index + 1) % PET_IDS.size()])
	if _left_button != null:
		_pet_cards.move_child(_left_button, 0)
	_update_card_slot(previous_id, 1, false)
	_update_card_slot(centered_id, 2, true)
	_update_card_slot(next_id, 3, false)
	if _right_button != null:
		_pet_cards.move_child(_right_button, 4)

func _update_card_slot(pet_id: String, target_index: int, is_centered: bool) -> void:
	var card := _pet_card_nodes.get(pet_id) as PanelContainer
	var button := _pet_buttons.get(pet_id) as Button
	if card == null or button == null:
		return
	var unlocked := _game_manager.is_pet_unlocked(pet_id)
	_pet_cards.move_child(card, target_index)
	card.modulate = Color(1.0, 1.0, 1.0, 1.0 if is_centered else 0.55)
	card.scale = Vector2.ONE if is_centered else Vector2(0.88, 0.88)
	card.pivot_offset = card.size * 0.5
	button.text = _get_select_button_text(pet_id, str(PET_IDS[selected_pet_index]), unlocked)
	_style_select_button(button, is_centered, unlocked)
	_update_card_text(card, pet_id, is_centered, unlocked)

func _update_card_text(card: PanelContainer, pet_id: String, is_centered: bool, unlocked: bool) -> void:
	var presentation: Dictionary = PET_PRESENTATION.get(pet_id, {})
	var portrait_label := card.get_node_or_null("Margin/VBox/PortraitLabel") as Label
	var name_label := card.get_node_or_null("Margin/VBox/NameLabel") as Label
	var description_label := card.get_node_or_null("Margin/VBox/DescriptionLabel") as Label
	var status_label := card.get_node_or_null("Margin/VBox/StatusLabel") as Label
	if portrait_label != null:
		portrait_label.text = str(presentation.get("portrait", "PET"))
	if name_label != null:
		name_label.text = str(presentation.get("name", _game_manager.get_display_name(_game_manager.get_pet_definition(pet_id), "Pet")))
	if description_label != null:
		description_label.text = "Lv.%d  Bonus %d\n%s" % [
			int(presentation.get("level", 1)),
			int(presentation.get("power", 1)),
			str(presentation.get("role", "Companion")),
		] if is_centered else str(presentation.get("role", "Companion"))
	if status_label != null:
		status_label.text = "Selected" if is_centered and unlocked else ("Locked" if not unlocked else "Tap to center")

func _on_left_pressed() -> void:
	_focus_index(selected_pet_index - 1)

func _on_right_pressed() -> void:
	_focus_index(selected_pet_index + 1)

func _on_evolve_pressed() -> void:
	var pet_id: String = str(PET_IDS[selected_pet_index])
	if _game_manager.evolve_pet(pet_id):
		refresh(pet_id)

func _focus_index(index: int) -> void:
	var wrapped_index := (index + PET_IDS.size()) % PET_IDS.size()
	selected_pet_index = wrapped_index
	var pet_id: String = str(PET_IDS[selected_pet_index])
	if _home_state != null:
		_home_state.set_selected_pet(pet_id)
	else:
		refresh(pet_id)

func _get_pet_index(pet_id: String) -> int:
	var index := PET_IDS.find(pet_id)
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
