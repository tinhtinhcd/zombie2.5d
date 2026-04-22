extends RefCounted
class_name EquipmentPanel

var _summary_label: Label
var _weapon_slot_button: Button
var _armor_slot_button: Button
var _accessory_slot_button: Button
var _game_manager: GameManager
var _weapon_cycle_index: int = 0

func setup(summary_label: Label, weapon_slot_button: Button, armor_slot_button: Button, accessory_slot_button: Button, game_manager: GameManager) -> void:
	_summary_label = summary_label
	_weapon_slot_button = weapon_slot_button
	_armor_slot_button = armor_slot_button
	_accessory_slot_button = accessory_slot_button
	_game_manager = game_manager

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

	var weapon_definition := _game_manager.get_weapon_definition(selected_weapon_id)
	var weapon_name := _game_manager.get_display_name(weapon_definition, "Basic Gun")
	_summary_label.text = "Selected loadout\nWeapon: %s\nDamage: %d\nFire: %.2fs\nProjectiles: %d\nRange: %.1f\n%s\nArmor: Placeholder\nAccessory: Placeholder" % [
		weapon_name,
		int(weapon_definition.get("damage", weapon_definition.get("projectile_damage", 1))),
		float(weapon_definition.get("fire_rate", weapon_definition.get("fire_interval", 0.6))),
		int(weapon_definition.get("projectile_count", 1)),
		float(weapon_definition.get("range", 20.0)),
		_format_weapon_unlocks(),
	]
	if _weapon_slot_button != null:
		_weapon_slot_button.text = "Change Weapon"
	if _armor_slot_button != null:
		_armor_slot_button.text = "Locked"
	if _accessory_slot_button != null:
		_accessory_slot_button.text = "Locked"

func _format_weapon_unlocks() -> String:
	var lines := PackedStringArray()
	lines.append("Weapons")
	if _game_manager == null:
		return "\n".join(lines)

	for weapon_id in _game_manager.get_weapon_ids():
		var weapon_definition := _game_manager.get_weapon_definition(str(weapon_id))
		var status := "Unlocked" if _game_manager.is_weapon_unlocked(str(weapon_id)) else "Locked"
		lines.append("%s: %s" % [_game_manager.get_display_name(weapon_definition, str(weapon_id)), status])
	return "\n".join(lines)
