extends Node
class_name SaveManager

# Minimal save manager for lightweight progression data.

const SAVE_PATH := "user://progression.save"
const SAVE_VERSION := 1
const DEFAULT_HERO_ID := "hero_knight"
const DEFAULT_WEAPON_ID := "weapon_basic"
const DEFAULT_PET_ID := "pet_drone"
const DEFAULT_SAVE_DATA := {
	"version": SAVE_VERSION,
	"highest_unlocked_level": 1,
	"permanent_upgrades": {},
	"soft_currency": 0,
	"gold": 0,
	"gems": 0,
	"shards": {},
	"energy": 5,
	"last_energy_time": 0,
	"daily_reward_day": "",
	"last_login_date": "",
	"claimed_daily_reward_date": "",
	"login_streak": 0,
	"daily_quests": [],
	"daily_quest_progress": {},
	"selected_hero_id": DEFAULT_HERO_ID,
	"selected_weapon_id": DEFAULT_WEAPON_ID,
	"selected_pet_id": DEFAULT_PET_ID,
	"unlocked_heroes": [DEFAULT_HERO_ID],
	"unlocked_weapons": [DEFAULT_WEAPON_ID],
	"weapon_levels": {},
	"unlocked_pets": [DEFAULT_PET_ID],
	"pet_evolution_stages": {},
	"pet_evolution_shards": 0,
	"pet_accessories": {},
	"inventory": {},
	"settings": {},
}

var last_saved_snapshot: Dictionary = {}

func _ready() -> void:
	last_saved_snapshot = _read_save_data()

func save_game(save_data: Dictionary = {}) -> Dictionary:
	var data_to_save: Dictionary = save_data.duplicate(true)
	if data_to_save.is_empty():
		data_to_save = last_saved_snapshot.duplicate(true)

	last_saved_snapshot = _merge_with_defaults(data_to_save)

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return last_saved_snapshot.duplicate(true)

	file.store_string(JSON.stringify(last_saved_snapshot))
	return last_saved_snapshot.duplicate(true)

func load_game() -> Dictionary:
	last_saved_snapshot = _read_save_data()
	return last_saved_snapshot.duplicate(true)

func save_permanent_upgrades(permanent_upgrades: Dictionary) -> void:
	var save_data: Dictionary = load_game()
	save_data["permanent_upgrades"] = permanent_upgrades.duplicate(true)
	save_game(save_data)

func load_permanent_upgrades() -> Dictionary:
	var save_data: Dictionary = load_game()
	var permanent_upgrades_value: Variant = save_data.get("permanent_upgrades", {})
	if typeof(permanent_upgrades_value) != TYPE_DICTIONARY:
		return {}

	var permanent_upgrades: Dictionary = permanent_upgrades_value
	return permanent_upgrades.duplicate(true)

func save_highest_unlocked_level(level_index: int) -> void:
	var save_data: Dictionary = load_game()
	var current_highest := int(save_data.get("highest_unlocked_level", 1))
	save_data["highest_unlocked_level"] = max(max(level_index, current_highest), 1)
	save_game(save_data)

func get_highest_unlocked_level() -> int:
	var save_data: Dictionary = load_game()
	return max(int(save_data.get("highest_unlocked_level", 1)), 1)

func _read_save_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return DEFAULT_SAVE_DATA.duplicate(true)

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return DEFAULT_SAVE_DATA.duplicate(true)

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return DEFAULT_SAVE_DATA.duplicate(true)

	var parsed_data: Dictionary = parsed
	return _merge_with_defaults(parsed_data)

func _merge_with_defaults(source: Dictionary) -> Dictionary:
	var merged: Dictionary = DEFAULT_SAVE_DATA.duplicate(true)
	merged["version"] = int(source.get("version", SAVE_VERSION))
	merged["highest_unlocked_level"] = max(int(source.get("highest_unlocked_level", 1)), 1)

	var permanent_upgrades_value: Variant = source.get("permanent_upgrades", {})
	if typeof(permanent_upgrades_value) == TYPE_DICTIONARY:
		var permanent_upgrades: Dictionary = permanent_upgrades_value
		merged["permanent_upgrades"] = permanent_upgrades.duplicate(true)

	merged["soft_currency"] = max(int(source.get("soft_currency", 0)), 0)
	merged["gold"] = max(int(source.get("gold", merged["soft_currency"])), 0)
	merged["soft_currency"] = max(merged["soft_currency"], merged["gold"])
	merged["gems"] = max(int(source.get("gems", 0)), 0)
	var shards_value: Variant = source.get("shards", {})
	if typeof(shards_value) == TYPE_DICTIONARY:
		var shards: Dictionary = shards_value
		merged["shards"] = shards.duplicate(true)
	merged["energy"] = clampi(int(source.get("energy", 5)), 0, 5)
	merged["last_energy_time"] = max(int(source.get("last_energy_time", 0)), 0)
	merged["daily_reward_day"] = str(source.get("daily_reward_day", ""))
	merged["last_login_date"] = str(source.get("last_login_date", ""))
	merged["claimed_daily_reward_date"] = str(source.get("claimed_daily_reward_date", merged["daily_reward_day"]))
	merged["login_streak"] = clampi(int(source.get("login_streak", 0)), 0, 7)
	var daily_quests_value: Variant = source.get("daily_quests", [])
	if typeof(daily_quests_value) == TYPE_ARRAY:
		merged["daily_quests"] = daily_quests_value.duplicate(true)
	var daily_quest_progress_value: Variant = source.get("daily_quest_progress", {})
	if typeof(daily_quest_progress_value) == TYPE_DICTIONARY:
		var daily_quest_progress: Dictionary = daily_quest_progress_value
		merged["daily_quest_progress"] = daily_quest_progress.duplicate(true)
	merged["selected_hero_id"] = str(source.get("selected_hero_id", DEFAULT_HERO_ID))
	merged["selected_weapon_id"] = str(source.get("selected_weapon_id", DEFAULT_WEAPON_ID))
	merged["selected_pet_id"] = str(source.get("selected_pet_id", DEFAULT_PET_ID))

	var unlocked_heroes_value: Variant = source.get("unlocked_heroes", DEFAULT_SAVE_DATA["unlocked_heroes"])
	if typeof(unlocked_heroes_value) == TYPE_ARRAY:
		merged["unlocked_heroes"] = unlocked_heroes_value.duplicate(true)
	_ensure_array_contains(merged["unlocked_heroes"], DEFAULT_HERO_ID)

	var unlocked_weapons_value: Variant = source.get("unlocked_weapons", DEFAULT_SAVE_DATA["unlocked_weapons"])
	if typeof(unlocked_weapons_value) == TYPE_ARRAY:
		merged["unlocked_weapons"] = unlocked_weapons_value.duplicate(true)
	_ensure_array_contains(merged["unlocked_weapons"], DEFAULT_WEAPON_ID)

	var weapon_levels_value: Variant = source.get("weapon_levels", {})
	if typeof(weapon_levels_value) == TYPE_DICTIONARY:
		var weapon_levels: Dictionary = weapon_levels_value
		merged["weapon_levels"] = weapon_levels.duplicate(true)

	var unlocked_pets_value: Variant = source.get("unlocked_pets", DEFAULT_SAVE_DATA["unlocked_pets"])
	if typeof(unlocked_pets_value) == TYPE_ARRAY:
		merged["unlocked_pets"] = unlocked_pets_value.duplicate(true)
	_ensure_array_contains(merged["unlocked_pets"], DEFAULT_PET_ID)

	var pet_evolution_stages_value: Variant = source.get("pet_evolution_stages", {})
	if typeof(pet_evolution_stages_value) == TYPE_DICTIONARY:
		var pet_evolution_stages: Dictionary = pet_evolution_stages_value
		merged["pet_evolution_stages"] = pet_evolution_stages.duplicate(true)
	merged["pet_evolution_shards"] = max(int(source.get("pet_evolution_shards", 0)), 0)
	var pet_accessories_value: Variant = source.get("pet_accessories", {})
	if typeof(pet_accessories_value) == TYPE_DICTIONARY:
		var pet_accessories: Dictionary = pet_accessories_value
		merged["pet_accessories"] = pet_accessories.duplicate(true)
	_validate_selected_loadout(merged)

	var inventory_value: Variant = source.get("inventory", {})
	if typeof(inventory_value) == TYPE_DICTIONARY:
		var inventory: Dictionary = inventory_value
		merged["inventory"] = inventory.duplicate(true)

	var settings_value: Variant = source.get("settings", {})
	if typeof(settings_value) == TYPE_DICTIONARY:
		var settings: Dictionary = settings_value
		merged["settings"] = settings.duplicate(true)

	return merged

func _ensure_array_contains(items: Array, item_id: String) -> void:
	if not items.has(item_id):
		items.append(item_id)

func _validate_selected_loadout(save_data: Dictionary) -> void:
	var unlocked_heroes_value: Array = save_data.get("unlocked_heroes", [])
	if not unlocked_heroes_value.has(save_data.get("selected_hero_id", "")):
		save_data["selected_hero_id"] = DEFAULT_HERO_ID

	var unlocked_weapons_value: Array = save_data.get("unlocked_weapons", [])
	if not unlocked_weapons_value.has(save_data.get("selected_weapon_id", "")):
		save_data["selected_weapon_id"] = DEFAULT_WEAPON_ID

	var unlocked_pets_value: Array = save_data.get("unlocked_pets", [])
	if not unlocked_pets_value.has(save_data.get("selected_pet_id", "")):
		save_data["selected_pet_id"] = DEFAULT_PET_ID
