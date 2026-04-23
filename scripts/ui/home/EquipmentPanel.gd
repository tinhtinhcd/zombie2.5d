extends RefCounted
class_name EquipmentPanel

signal equip_slot_requested(slot_id: String)

const HOME_UI_STYLE := preload("res://scripts/ui/home/HomeUIStyle.gd")

var _summary_label: Label
var _weapon_slot_button: Button
var _armor_slot_button: Button
var _accessory_slot_button: Button
var _game_manager: GameManager
var _home_state
var _weapon_cycle_index: int = 0

func setup(summary_label: Label, weapon_slot_button: Button, armor_slot_button: Button, accessory_slot_button: Button, game_manager: GameManager, home_state = null) -> void:
	_summary_label = summary_label
	_weapon_slot_button = weapon_slot_button
	_armor_slot_button = armor_slot_button
	_accessory_slot_button = accessory_slot_button
	_game_manager = game_manager
	_home_state = home_state
	_connect_slot_button(_weapon_slot_button, "weapon")
	_connect_slot_button(_armor_slot_button, "armor")
	_connect_slot_button(_accessory_slot_button, "accessory")

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

	var weapon_definition := _game_manager.get_weapon_definition(selected_weapon_id)
	var weapon_name := _game_manager.get_display_name(weapon_definition, "Basic Gun")
	var selected_slot := "none"
	var slot_info := "Select a slot to equip gear."
	if _home_state != null:
		selected_slot = _home_state.selected_equipment_slot
		slot_info = _format_selected_slot_info(selected_slot, weapon_name)
	_summary_label.text = "Selected: %s\n%s  ATK %d  %.1fm" % [
		slot_info,
		weapon_name,
		int(weapon_definition.get("damage", weapon_definition.get("projectile_damage", 1))),
		float(weapon_definition.get("range", 20.0)),
	]
	if _weapon_slot_button != null:
		_weapon_slot_button.text = "Equip Weapon"
		HOME_UI_STYLE.apply_button_state(_weapon_slot_button, "selected" if _has_equipped_item("weapon") else "default")
		HOME_UI_STYLE.apply_related_card_from_button(_weapon_slot_button, _home_state != null and _home_state.selected_equipment_slot == "weapon")
	if _armor_slot_button != null:
		_armor_slot_button.text = "Equip Armor"
		HOME_UI_STYLE.apply_button_state(_armor_slot_button, "selected" if _has_equipped_item("armor") else "secondary")
		HOME_UI_STYLE.apply_related_card_from_button(_armor_slot_button, _home_state != null and _home_state.selected_equipment_slot == "armor")
	if _accessory_slot_button != null:
		_accessory_slot_button.text = "Equip Accessory"
		HOME_UI_STYLE.apply_button_state(_accessory_slot_button, "selected" if _has_equipped_item("accessory") else "secondary")
		HOME_UI_STYLE.apply_related_card_from_button(_accessory_slot_button, _home_state != null and _home_state.selected_equipment_slot == "accessory")

func _connect_slot_button(button: Button, slot_id: String) -> void:
	if button == null:
		return
	button.pressed.connect(_on_slot_button_pressed.bind(slot_id))

func _on_slot_button_pressed(slot_id: String) -> void:
	equip_slot_requested.emit(slot_id)

func _format_weapon_unlocks() -> String:
	var lines := PackedStringArray()
	lines.append("Weapon Unlocks")
	if _game_manager == null:
		return "\n".join(lines)

	for weapon_id in _game_manager.get_weapon_ids():
		var weapon_definition := _game_manager.get_weapon_definition(str(weapon_id))
		var status := "Unlocked" if _game_manager.is_weapon_unlocked(str(weapon_id)) else "Locked"
		lines.append("%s: %s" % [_game_manager.get_display_name(weapon_definition, str(weapon_id)), status])
	return "\n".join(lines)

func _format_selected_slot_info(slot_id: String, weapon_name: String) -> String:
	if slot_id.is_empty():
		return "None selected"
	if slot_id == "weapon":
		return "Weapon: %s" % weapon_name
	if _home_state == null:
		return "%s: Empty" % slot_id.capitalize()
	var equipped_item: Dictionary = _home_state.get_equipped_item(slot_id)
	if equipped_item.is_empty():
		return "%s: Empty" % slot_id.capitalize()
	return "%s: %s" % [slot_id.capitalize(), str(equipped_item.get("name", "Equipped"))]

func _has_equipped_item(slot_id: String) -> bool:
	if _home_state == null:
		return false
	return not _home_state.get_equipped_item(slot_id).is_empty()
