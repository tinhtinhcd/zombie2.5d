extends RefCounted
class_name LevelLibrary

# Loads placeholder level resources from a single directory.
# Keep levels as `.tres` files so they stay editor-friendly as the project grows.

const LEVELS_DIRECTORY := "res://data/levels"

static var _cached_levels_directory: String = ""
static var _cached_levels: Array[LevelData] = []
static var _has_cached_levels: bool = false

static func load_all_levels(levels_directory: String = LEVELS_DIRECTORY) -> Array[LevelData]:
    if _has_cached_levels and _cached_levels_directory == levels_directory:
        return _cached_levels

    var levels: Array[LevelData] = []
    var directory := DirAccess.open(levels_directory)
    if directory == null:
        _cached_levels_directory = levels_directory
        _cached_levels = levels
        _has_cached_levels = true
        return levels

    var file_names: PackedStringArray = []
    directory.list_dir_begin()

    while true:
        var file_name := directory.get_next()
        if file_name.is_empty():
            break
        if directory.current_is_dir():
            continue
        if not file_name.ends_with(".tres") and not file_name.ends_with(".res"):
            continue
        file_names.append(file_name)

    directory.list_dir_end()
    file_names.sort()

    for file_name in file_names:
        var resource_path := "%s/%s" % [levels_directory, file_name]
        var level_data := load(resource_path) as LevelData
        if level_data != null:
            levels.append(level_data)

    _cached_levels_directory = levels_directory
    _cached_levels = levels
    _has_cached_levels = true
    return levels

static func invalidate_cache() -> void:
    _cached_levels_directory = ""
    _cached_levels.clear()
    _has_cached_levels = false

static func reload_levels(levels_directory: String = LEVELS_DIRECTORY) -> Array[LevelData]:
    invalidate_cache()
    return load_all_levels(levels_directory)

static func load_level(level_id: StringName, levels_directory: String = LEVELS_DIRECTORY) -> LevelData:
    for level_data in load_all_levels(levels_directory):
        if level_data.level_id == level_id:
            return level_data
    return null

static func load_level_by_index(level_index: int, levels_directory: String = LEVELS_DIRECTORY) -> LevelData:
    var levels := load_all_levels(levels_directory)
    var resolved_index := level_index - 1
    if resolved_index < 0 or resolved_index >= levels.size():
        return null
    return levels[resolved_index]

static func get_level_count(levels_directory: String = LEVELS_DIRECTORY) -> int:
    return load_all_levels(levels_directory).size()
