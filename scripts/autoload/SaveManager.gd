extends Node
class_name SaveManager

# Minimal save manager for lightweight progression data.

const SAVE_PATH := "user://progression.save"
const SAVE_VERSION := 1
const DEFAULT_SAVE_DATA := {
    "version": SAVE_VERSION,
    "highest_unlocked_level": 1,
    "permanent_upgrades": {},
    "soft_currency": 0,
    "selected_hero_id": "hero_knight",
    "selected_weapon_id": "weapon_basic",
    "selected_pet_id": "pet_drone",
    "unlocked_heroes": ["hero_knight", "hero_rogue", "hero_mage"],
    "unlocked_weapons": ["weapon_basic", "weapon_spread", "weapon_rapid", "weapon_heavy"],
    "unlocked_pets": ["pet_drone", "pet_sprite", "pet_wisp"],
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
    merged["selected_hero_id"] = str(source.get("selected_hero_id", "hero_knight"))
    merged["selected_weapon_id"] = str(source.get("selected_weapon_id", "weapon_basic"))
    merged["selected_pet_id"] = str(source.get("selected_pet_id", "pet_drone"))

    var unlocked_heroes_value: Variant = source.get("unlocked_heroes", DEFAULT_SAVE_DATA["unlocked_heroes"])
    if typeof(unlocked_heroes_value) == TYPE_ARRAY:
        merged["unlocked_heroes"] = unlocked_heroes_value.duplicate(true)

    var unlocked_weapons_value: Variant = source.get("unlocked_weapons", DEFAULT_SAVE_DATA["unlocked_weapons"])
    if typeof(unlocked_weapons_value) == TYPE_ARRAY:
        merged["unlocked_weapons"] = unlocked_weapons_value.duplicate(true)
    for weapon_id in DEFAULT_SAVE_DATA["unlocked_weapons"]:
        if not merged["unlocked_weapons"].has(weapon_id):
            merged["unlocked_weapons"].append(weapon_id)

    var unlocked_pets_value: Variant = source.get("unlocked_pets", DEFAULT_SAVE_DATA["unlocked_pets"])
    if typeof(unlocked_pets_value) == TYPE_ARRAY:
        merged["unlocked_pets"] = unlocked_pets_value.duplicate(true)

    var inventory_value: Variant = source.get("inventory", {})
    if typeof(inventory_value) == TYPE_DICTIONARY:
        var inventory: Dictionary = inventory_value
        merged["inventory"] = inventory.duplicate(true)

    var settings_value: Variant = source.get("settings", {})
    if typeof(settings_value) == TYPE_DICTIONARY:
        var settings: Dictionary = settings_value
        merged["settings"] = settings.duplicate(true)

    return merged
