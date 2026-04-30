extends RefCounted
class_name EquipmentPanel

signal slot_selected(slot_id: String)
signal change_requested(slot_id: String)
signal unequip_requested(slot_id: String)

const HOME_UI_STYLE := preload("res://scripts/ui/home/HomeUIStyle.gd")

const SLOT_DEFINITIONS := [
	{"slot_id": "weapon", "display_name": "Weapon", "short_label": "WPN", "accepted_item_type": "weapon", "can_change": true},
	{"slot_id": "armor", "display_name": "Armor", "short_label": "ARM", "accepted_item_type": "armor", "can_change": true},
	{"slot_id": "helmet", "display_name": "Helmet", "short_label": "HELM", "accepted_item_type": "helmet", "can_change": false},
	{"slot_id": "boots", "display_name": "Boots", "short_label": "BOOTS", "accepted_item_type": "boots", "can_change": false},
	{"slot_id": "accessory", "display_name": "Accessory", "short_label": "ACC", "accepted_item_type": "accessory", "can_change": true},
	{"slot_id": "pet_gear", "display_name": "Pet Gear", "short_label": "PET", "accepted_item_type": "pet_gear", "can_change": false},
]

var _summary_label: Label
var _change_button: Button
var _unequip_button: Button
var _upgrade_button: Button
var _slot_buttons: Dictionary = {}
var _category_buttons: Dictionary = {}
var _game_manager: GameManager
var _home_state
var _weapon_cycle_index: int = 0

func setup(summary_label: Label, slot_buttons: Dictionary, change_button: Button, unequip_button: Button, upgrade_button: Button, game_manager: GameManager, home_state = null, category_buttons: Dictionary = {}) -> void:
	_summary_label = summary_label
	_slot_buttons = slot_buttons
	_change_button = change_button
	_unequip_button = unequip_button
	_upgrade_button = upgrade_button
	_game_manager = game_manager
	_home_state = home_state
	_category_buttons = category_buttons

	for slot_definition in SLOT_DEFINITIONS:
		var slot_id := str(slot_definition.get("slot_id", ""))
		var button := _slot_buttons.get(slot_id) as Button
		_connect_slot_button(button, slot_id)

	if _change_button != null:
		_change_button.pressed.connect(_on_change_pressed)
	if _unequip_button != null:
		_unequip_button.pressed.connect(_on_unequip_pressed)
	if _upgrade_button != null:
		_upgrade_button.disabled = true
		HOME_UI_STYLE.apply_compact_button_state(_upgrade_button, "locked")

	_connect_category_button("weapon", "weapon")
	_connect_category_button("armor", "armor")
	_connect_category_button("accessory", "accessory")
	_connect_category_button("pet", "pet_gear")
	_connect_category_button("all", "weapon")

func sync_selected_weapon(selected_weapon_id: String) -> void:
	if _game_manager == null:
		return
	var weapon_ids := _game_manager.get_weapon_ids()
	_weapon_cycle_index = max(weapon_ids.find(selected_weapon_id), 0)

func cycle_weapon(selected_weapon_id: String) -> String:
	var weapon_ids := get_unlocked_weapon_ids()
	if weapon_ids.is_empty():
		return selected_weapon_id

	var selected_index := weapon_ids.find(selected_weapon_id)
	if selected_index >= 0:
		_weapon_cycle_index = selected_index
	_weapon_cycle_index = (_weapon_cycle_index + 1) % weapon_ids.size()
	return str(weapon_ids[_weapon_cycle_index])

func get_unlocked_weapon_ids() -> Array:
	var unlocked_weapon_ids := []
	if _game_manager == null:
		return unlocked_weapon_ids

	for weapon_id in _game_manager.get_weapon_ids():
		if _game_manager.is_weapon_unlocked(str(weapon_id)):
			unlocked_weapon_ids.append(weapon_id)
	return unlocked_weapon_ids

func refresh(selected_weapon_id: String) -> void:
	if _summary_label == null or _game_manager == null:
		return
	if selected_weapon_id.is_empty() and _home_state != null:
		selected_weapon_id = _home_state.selected_weapon_id

	_refresh_gear_screen(selected_weapon_id)
	_refresh_selected_slot_info(selected_weapon_id)

func _refresh_gear_screen(selected_weapon_id: String) -> void:
	for slot_definition in SLOT_DEFINITIONS:
		var slot_id := str(slot_definition.get("slot_id", ""))
		var button := _slot_buttons.get(slot_id) as Button
		if button == null:
			continue

		var is_selected := _get_selected_slot_id() == slot_id
		var status := _get_slot_status(slot_definition)
		button.text = "%s\n%s" % [
			str(slot_definition.get("short_label", slot_id.to_upper())),
			_get_slot_button_value(slot_id, selected_weapon_id, status),
		]
		button.disabled = false
		HOME_UI_STYLE.apply_compact_button_state(button, "selected" if is_selected else ("locked" if status == "locked" else "secondary"))
		HOME_UI_STYLE.apply_related_card_from_button(button, is_selected)

	for category_id in _category_buttons.keys():
		var category_button := _category_buttons.get(category_id) as Button
		if category_button == null:
			continue
		HOME_UI_STYLE.apply_compact_button_state(category_button, "selected" if _is_category_selected(str(category_id)) else "secondary")

func _refresh_selected_slot_info(selected_weapon_id: String) -> void:
	var slot_id := _get_selected_slot_id()
	var slot_definition := _get_slot_definition(slot_id)
	var display_name := str(slot_definition.get("display_name", slot_id.capitalize()))
	var equipped_item := _get_display_item_for_slot(slot_id, selected_weapon_id)
	var status := _get_slot_status(slot_definition)
	var can_change := bool(slot_definition.get("can_change", false))
	var has_equipped_item := not _get_equipped_item(slot_id).is_empty()

	if _summary_label != null:
		_summary_label.text = "%s\n%s | %s\n%s\n%s" % [
			display_name.to_upper(),
			str(equipped_item.get("name", "Empty")),
			str(equipped_item.get("rarity", status)).capitalize(),
			_format_stats(equipped_item),
			_shorten_text(str(equipped_item.get("description", _get_empty_description(slot_definition))), 42),
		]

	if _change_button != null:
		_change_button.text = "Change"
		_change_button.disabled = not can_change
		HOME_UI_STYLE.apply_compact_button_state(_change_button, "selected" if can_change else "locked")
	if _unequip_button != null:
		_unequip_button.text = "Unequip"
		_unequip_button.disabled = not has_equipped_item
		HOME_UI_STYLE.apply_compact_button_state(_unequip_button, "secondary" if has_equipped_item else "locked")
	if _upgrade_button != null:
		_upgrade_button.text = "Upgrade"
		_upgrade_button.disabled = true
		HOME_UI_STYLE.apply_compact_button_state(_upgrade_button, "locked")

func _connect_slot_button(button: Button, slot_id: String) -> void:
	if button == null:
		return
	button.pressed.connect(_on_slot_button_pressed.bind(slot_id))

func _connect_category_button(category_id: String, slot_id: String) -> void:
	var button := _category_buttons.get(category_id) as Button
	if button == null:
		return
	button.pressed.connect(_on_slot_button_pressed.bind(slot_id))

func _on_slot_button_pressed(slot_id: String) -> void:
	slot_selected.emit(slot_id)

func _on_change_pressed() -> void:
	var slot_id := _get_selected_slot_id()
	var slot_definition := _get_slot_definition(slot_id)
	if not bool(slot_definition.get("can_change", false)):
		return
	change_requested.emit(slot_id)

func _on_unequip_pressed() -> void:
	unequip_requested.emit(_get_selected_slot_id())

func _get_selected_slot_id() -> String:
	if _home_state == null:
		return "weapon"
	var slot_id := str(_home_state.selected_equipment_slot)
	return "weapon" if slot_id.is_empty() else slot_id

func _get_slot_definition(slot_id: String) -> Dictionary:
	for slot_definition in SLOT_DEFINITIONS:
		if str(slot_definition.get("slot_id", "")) == slot_id:
			return slot_definition
	return SLOT_DEFINITIONS[0]

func _get_slot_status(slot_definition: Dictionary) -> String:
	if not bool(slot_definition.get("can_change", false)):
		return "locked"
	if not _get_equipped_item(str(slot_definition.get("slot_id", ""))).is_empty():
		return "equipped"
	return "empty"

func _get_slot_button_value(slot_id: String, selected_weapon_id: String, status: String) -> String:
	if status == "locked":
		return "Locked"
	var item := _get_display_item_for_slot(slot_id, selected_weapon_id)
	if item.is_empty():
		return "Empty"
	return _shorten_text(str(item.get("name", "Equipped")), 13)

func _get_display_item_for_slot(slot_id: String, selected_weapon_id: String) -> Dictionary:
	var equipped_item := _get_equipped_item(slot_id)
	if not equipped_item.is_empty():
		return equipped_item
	if slot_id == "weapon" and _game_manager != null:
		var weapon_definition := _game_manager.get_weapon_definition(selected_weapon_id)
		return {
			"name": _game_manager.get_display_name(weapon_definition, "Basic Gun"),
			"rarity": "starter",
			"stats": {
				"atk": int(weapon_definition.get("damage", weapon_definition.get("projectile_damage", 1))),
				"range": "%.1fm" % float(weapon_definition.get("range", 20.0)),
			},
			"description": str(weapon_definition.get("description", "Current weapon loadout.")),
		}
	if slot_id == "pet_gear" and _game_manager != null:
		var pet_definition := _game_manager.get_pet_definition(_home_state.selected_pet_id if _home_state != null else _game_manager.selected_pet_id)
		return {
			"name": _game_manager.get_display_name(pet_definition, "Pet"),
			"rarity": "locked",
			"stats": {"pet": "active"},
			"description": "Pet gear mods are not available yet.",
		}
	return {
		"name": "Empty",
		"rarity": "locked" if not bool(_get_slot_definition(slot_id).get("can_change", false)) else "empty",
		"stats": {},
		"description": _get_empty_description(_get_slot_definition(slot_id)),
	}

func _get_equipped_item(slot_id: String) -> Dictionary:
	if _home_state == null:
		return {}
	return _home_state.get_equipped_item(slot_id)

func _format_stats(item: Dictionary) -> String:
	var stats_value: Variant = item.get("stats", {})
	if typeof(stats_value) != TYPE_DICTIONARY:
		return "No stats"
	var stats: Dictionary = stats_value
	if stats.is_empty():
		return "No stats"
	var parts := PackedStringArray()
	for key in stats.keys():
		if parts.size() >= 3:
			break
		parts.append("%s %s" % [str(key).to_upper(), str(stats[key]).replace(" placeholder", "")])
	return "  ".join(parts)

func _get_empty_description(slot_definition: Dictionary) -> String:
	if bool(slot_definition.get("can_change", false)):
		return "Tap Change to equip matching gear."
	return "Slot visible for progression, but not equippable yet."

func _is_category_selected(category_id: String) -> bool:
	var selected_slot := _get_selected_slot_id()
	match category_id:
		"weapon":
			return selected_slot == "weapon"
		"armor":
			return selected_slot == "armor" or selected_slot == "helmet" or selected_slot == "boots"
		"accessory":
			return selected_slot == "accessory"
		"pet":
			return selected_slot == "pet_gear"
		"all":
			return false
	return false

func _shorten_text(value: String, max_length: int) -> String:
	if value.length() <= max_length:
		return value
	return "%s..." % value.substr(0, max(max_length - 3, 1))
