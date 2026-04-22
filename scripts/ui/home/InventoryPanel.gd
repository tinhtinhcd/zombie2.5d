extends RefCounted
class_name InventoryPanel

signal item_selected(item_id: String)
signal equip_requested(item_id: String)

const HOME_UI_STYLE := preload("res://scripts/ui/home/HomeUIStyle.gd")

var _description_label: Label
var _name_label: Label
var _type_label: Label
var _stats_label: Label
var _equip_button: Button
var _drop_button: Button
var _item_buttons: Array[Button] = []
var _visible_items: Array = []
var _selected_item_id: String = ""
var _game_manager: GameManager
var _home_state

func setup(description_label: Label, item_buttons: Array[Button], game_manager: GameManager, home_state = null, name_label: Label = null, type_label: Label = null, stats_label: Label = null, equip_button: Button = null, drop_button: Button = null) -> void:
	_description_label = description_label
	_item_buttons = item_buttons
	_game_manager = game_manager
	_home_state = home_state
	_name_label = name_label
	_type_label = type_label
	_stats_label = stats_label
	_equip_button = equip_button
	_drop_button = drop_button
	for index in range(_item_buttons.size()):
		var button := _item_buttons[index]
		if button == null:
			continue
		button.pressed.connect(_on_item_button_pressed.bind(index))
	if _equip_button != null:
		_equip_button.pressed.connect(_on_equip_pressed)
	if _drop_button != null:
		_drop_button.disabled = true

func refresh(_inventory: Dictionary = {}) -> void:
	if _description_label == null or _game_manager == null:
		return

	_visible_items = []
	if _home_state != null:
		_visible_items = _home_state.get_inventory_items_for_selected_slot()
	if not _has_visible_item(_selected_item_id):
		_selected_item_id = ""
	_refresh_item_buttons()
	_refresh_detail_panel()

	var scrap_count := int(_game_manager.inventory.get("scrap", 0))
	var summary := "Enemies can drop scrap during runs. Equipment depth stays intentionally light."
	if _home_state != null:
		summary = _home_state.inventory_summary
	if _selected_item_id.is_empty():
		_description_label.text = "Inventory\nCoins: %d\nScrap: %d\n\n%s" % [
			_game_manager.soft_currency,
			scrap_count,
			summary,
		]

func _refresh_detail_panel() -> void:
	var selected_item := _get_selected_item()
	var has_selection := not selected_item.is_empty()
	if _name_label != null:
		_name_label.text = str(selected_item.get("name", "No Item Selected")) if has_selection else "No Item Selected"
	if _type_label != null:
		_type_label.text = "Type: %s" % str(selected_item.get("slot", "-")).capitalize() if has_selection else "Type: -"
	if _stats_label != null:
		_stats_label.text = "Stats: %s" % _format_stats(selected_item) if has_selection else "Stats: -"
	if has_selection and _description_label != null:
		_description_label.text = "%s\n\n%s" % [
			str(selected_item.get("description", "Field gear from the survivor cache.")),
			"Select Equip to place this item in the active slot.",
		]
	if _equip_button != null:
		_equip_button.disabled = not has_selection
		HOME_UI_STYLE.apply_button_state(_equip_button, "selected" if has_selection else "locked")
	if _drop_button != null:
		_drop_button.disabled = true
		HOME_UI_STYLE.apply_button_state(_drop_button, "locked")

func _get_selected_item() -> Dictionary:
	for item in _visible_items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var item_dictionary: Dictionary = item
		if str(item_dictionary.get("id", "")) == _selected_item_id:
			return item_dictionary
	return {}

func _has_visible_item(item_id: String) -> bool:
	if item_id.is_empty():
		return false
	for item in _visible_items:
		if typeof(item) == TYPE_DICTIONARY and str((item as Dictionary).get("id", "")) == item_id:
			return true
	return false

func _on_equip_pressed() -> void:
	if _selected_item_id.is_empty():
		return
	equip_requested.emit(_selected_item_id)

func _set_inventory_summary_text(summary: String, scrap_count: int) -> void:
	if _description_label == null:
		return
	_description_label.text = "Inventory\nCoins: %d\nScrap: %d\n\n%s" % [
		_game_manager.soft_currency,
		scrap_count,
		summary,
	]

func _refresh_item_buttons() -> void:
	for index in range(_item_buttons.size()):
		var button := _item_buttons[index]
		if button == null:
			continue
		if index >= _visible_items.size():
			button.visible = false
			button.disabled = true
			continue
		var item: Dictionary = _visible_items[index]
		button.visible = true
		button.disabled = false
		var is_equipped := _is_equipped(item)
		var is_selected := str(item.get("id", "")) == _selected_item_id
		button.text = "%s%s\n%s" % [str(item.get("name", "Item")), "  Equipped" if is_equipped else "", _format_stats(item)]
		HOME_UI_STYLE.apply_item_button(button, is_equipped or is_selected)

func _on_item_button_pressed(index: int) -> void:
	if index < 0 or index >= _visible_items.size():
		return
	var item: Dictionary = _visible_items[index]
	_selected_item_id = str(item.get("id", ""))
	_refresh_item_buttons()
	_refresh_detail_panel()
	item_selected.emit(_selected_item_id)

func _is_equipped(item: Dictionary) -> bool:
	if _home_state == null:
		return false
	var slot_id := str(item.get("slot", ""))
	var equipped_item: Dictionary = _home_state.get_equipped_item(slot_id)
	return str(equipped_item.get("id", "")) == str(item.get("id", ""))

func _format_stats(item: Dictionary) -> String:
	var stats_value: Variant = item.get("stats", {})
	if typeof(stats_value) != TYPE_DICTIONARY:
		return str(item.get("slot", ""))
	var stats: Dictionary = stats_value
	var parts := PackedStringArray()
	for key in stats.keys():
		parts.append("%s %s" % [str(key).capitalize(), str(stats[key])])
	return ", ".join(parts)
