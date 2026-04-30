extends RefCounted
class_name HomeState

signal hero_changed(hero_id: String)
signal weapon_changed(weapon_id: String)
signal pet_changed(pet_id: String)
signal equipment_slot_changed(slot_id: String)
signal equipment_changed(slot_id: String, item: Dictionary)
signal equipment_summary_changed(summary: String)
signal inventory_summary_changed(summary: String)

const EQUIPMENT_SLOTS := ["weapon", "armor", "helmet", "boots", "accessory", "pet_gear"]
const MOCK_INVENTORY_ITEMS := [
	{
		"id": "training_blade",
		"name": "Training Blade",
		"slot": "weapon",
		"rarity": "common",
		"level": 1,
		"stats": {"atk": "+1 placeholder"},
		"description": "Reliable backup weapon for testing the equip flow.",
	},
	{
		"id": "leather_vest",
		"name": "Leather Vest",
		"slot": "armor",
		"rarity": "common",
		"level": 1,
		"stats": {"def": "+2 placeholder"},
		"description": "Light armor scavenged from an abandoned checkpoint.",
	},
	{
		"id": "scout_cloak",
		"name": "Scout Cloak",
		"slot": "armor",
		"rarity": "uncommon",
		"level": 2,
		"stats": {"speed": "+0.2 placeholder"},
		"description": "Flexible outerwear for moving through infected streets.",
	},
	{
		"id": "lucky_charm",
		"name": "Lucky Charm",
		"slot": "accessory",
		"rarity": "rare",
		"level": 3,
		"stats": {"xp": "+5% placeholder"},
		"description": "Small survivor keepsake with placeholder progression value.",
	},
	{
		"id": "focus_ring",
		"name": "Focus Ring",
		"slot": "accessory",
		"rarity": "uncommon",
		"level": 2,
		"stats": {"fire": "-0.03s placeholder"},
		"description": "Mock accessory used to validate detail and equip UI.",
	},
]

var selected_hero_id: String = "hero_knight"
var selected_weapon_id: String = "weapon_basic"
var selected_pet_id: String = "pet_drone"
var selected_equipment_slot: String = "weapon"
var inventory_items: Array = MOCK_INVENTORY_ITEMS.duplicate(true)
var equipped_items: Dictionary = {
	"weapon": {},
	"armor": {},
	"helmet": {},
	"boots": {},
	"accessory": {},
	"pet_gear": {},
}
var equipped_items_summary: String = "Weapon: Empty\nArmor: Empty\nHelmet: Locked\nBoots: Locked\nAccessory: Empty\nPet Gear: Locked"
var inventory_summary: String = "Inventory depth stays intentionally light."

func sync_loadout(hero_id: String, weapon_id: String, pet_id: String, emit_changes: bool = false) -> void:
	selected_hero_id = hero_id
	selected_weapon_id = weapon_id
	selected_pet_id = pet_id
	if emit_changes:
		hero_changed.emit(selected_hero_id)
		weapon_changed.emit(selected_weapon_id)
		pet_changed.emit(selected_pet_id)

func set_selected_hero(hero_id: String) -> void:
	if selected_hero_id == hero_id:
		return
	selected_hero_id = hero_id
	hero_changed.emit(selected_hero_id)

func set_selected_weapon(weapon_id: String) -> void:
	if selected_weapon_id == weapon_id:
		return
	selected_weapon_id = weapon_id
	weapon_changed.emit(selected_weapon_id)

func set_selected_pet(pet_id: String) -> void:
	if selected_pet_id == pet_id:
		return
	selected_pet_id = pet_id
	pet_changed.emit(selected_pet_id)

func set_selected_equipment_slot(slot_id: String) -> void:
	if not EQUIPMENT_SLOTS.has(slot_id):
		return
	if selected_equipment_slot == slot_id:
		return
	selected_equipment_slot = slot_id
	equipment_slot_changed.emit(selected_equipment_slot)
	_refresh_inventory_summary()

func get_inventory_items_for_selected_slot() -> Array:
	return get_inventory_items_for_slot(selected_equipment_slot)

func get_inventory_items_for_slot(slot_id: String) -> Array:
	var filtered_items := []
	for item in inventory_items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var item_dictionary: Dictionary = item
		if slot_id.is_empty() or str(item_dictionary.get("slot", "")) == slot_id:
			filtered_items.append(item_dictionary.duplicate(true))
	return filtered_items

func equip_item(item_id: String) -> bool:
	var item := get_inventory_item(item_id)
	if item.is_empty():
		return false
	var item_slot := str(item.get("slot", ""))
	if selected_equipment_slot.is_empty() or item_slot != selected_equipment_slot:
		return false
	equipped_items[selected_equipment_slot] = item.duplicate(true)
	set_equipment_summary(_format_equipped_items_summary())
	equipment_changed.emit(selected_equipment_slot, item.duplicate(true))
	return true

func unequip_item(slot_id: String) -> bool:
	if not EQUIPMENT_SLOTS.has(slot_id):
		return false
	if get_equipped_item(slot_id).is_empty():
		return false
	equipped_items[slot_id] = {}
	set_equipment_summary(_format_equipped_items_summary())
	equipment_changed.emit(slot_id, {})
	return true

func get_inventory_item(item_id: String) -> Dictionary:
	for item in inventory_items:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var item_dictionary: Dictionary = item
		if str(item_dictionary.get("id", "")) == item_id:
			return item_dictionary.duplicate(true)
	return {}

func get_equipped_item(slot_id: String) -> Dictionary:
	var item_value: Variant = equipped_items.get(slot_id, {})
	if typeof(item_value) != TYPE_DICTIONARY:
		return {}
	var item: Dictionary = item_value
	return item.duplicate(true)

func set_equipment_summary(summary: String) -> void:
	if equipped_items_summary == summary:
		return
	equipped_items_summary = summary
	equipment_summary_changed.emit(equipped_items_summary)

func set_inventory_summary(summary: String) -> void:
	if inventory_summary == summary:
		return
	inventory_summary = summary
	inventory_summary_changed.emit(inventory_summary)

func _refresh_inventory_summary() -> void:
	var slot_label := "all slots" if selected_equipment_slot.is_empty() else selected_equipment_slot
	set_inventory_summary("Choose an item for %s. Mock inventory data is temporary." % slot_label)

func _format_equipped_items_summary() -> String:
	return "Weapon: %s\nArmor: %s\nHelmet: %s\nBoots: %s\nAccessory: %s\nPet Gear: %s" % [
		_get_equipped_item_name("weapon"),
		_get_equipped_item_name("armor"),
		_get_equipped_item_name("helmet"),
		_get_equipped_item_name("boots"),
		_get_equipped_item_name("accessory"),
		_get_equipped_item_name("pet_gear"),
	]

func _get_equipped_item_name(slot_id: String) -> String:
	var item := get_equipped_item(slot_id)
	if item.is_empty():
		return "Empty"
	return str(item.get("name", "Unknown"))
