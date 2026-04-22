extends RefCounted
class_name InventoryPanel

signal item_selected(item_id: String)

const HOME_UI_STYLE := preload("res://scripts/ui/home/HomeUIStyle.gd")

var _description_label: Label
var _item_buttons: Array[Button] = []
var _visible_items: Array = []
var _game_manager: GameManager
var _home_state

func setup(description_label: Label, item_buttons: Array[Button], game_manager: GameManager, home_state = null) -> void:
	_description_label = description_label
	_item_buttons = item_buttons
	_game_manager = game_manager
	_home_state = home_state
	for index in range(_item_buttons.size()):
		var button := _item_buttons[index]
		if button == null:
			continue
		button.pressed.connect(_on_item_button_pressed.bind(index))

func refresh(_inventory: Dictionary = {}) -> void:
	if _description_label == null or _game_manager == null:
		return

	_visible_items = []
	if _home_state != null:
		_visible_items = _home_state.get_inventory_items_for_selected_slot()
	_refresh_item_buttons()

	var scrap_count := int(_game_manager.inventory.get("scrap", 0))
	var summary := "Enemies can drop scrap during runs. Equipment depth stays intentionally light."
	if _home_state != null:
		summary = _home_state.inventory_summary
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
		button.text = "%s%s\n%s" % [str(item.get("name", "Item")), "  Equipped" if is_equipped else "", _format_stats(item)]
		HOME_UI_STYLE.apply_item_button(button, is_equipped)

func _on_item_button_pressed(index: int) -> void:
	if index < 0 or index >= _visible_items.size():
		return
	var item: Dictionary = _visible_items[index]
	item_selected.emit(str(item.get("id", "")))

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
