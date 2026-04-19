extends Node
class_name SaveManager

# Minimal save manager for lightweight progression data.

const SAVE_PATH := "user://progression.save"
const SAVE_VERSION := 1
const DEFAULT_SAVE_DATA := {
    "version": SAVE_VERSION,
    "highest_unlocked_level": 1,
    "permanent_upgrades": {},
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

    var settings_value: Variant = source.get("settings", {})
    if typeof(settings_value) == TYPE_DICTIONARY:
        var settings: Dictionary = settings_value
        merged["settings"] = settings.duplicate(true)

    return merged
