extends RefCounted
class_name GameData

const HEROES_PATH := "res://data/heroes.json"
const WEAPONS_PATH := "res://data/weapons.json"
const PETS_PATH := "res://data/pets.json"
const UPGRADES_PATH := "res://data/upgrades.json"
const MISSIONS_PATH := "res://data/missions.json"
const PERMANENT_UPGRADES_PATH := "res://data/permanent_upgrades.json"
const DEBUG_MODEL_TRACE := false

const DEFAULT_HERO_ID := "hero_knight"
const DEFAULT_WEAPON_ID := "weapon_basic"
const DEFAULT_PET_ID := "pet_drone"

const FALLBACK_HEROES := {
    "hero_knight": {
        "display_name": "Knight",
        "model_scene_path": "res://assets/KayKit_Adventurers_2.0_FREE/KayKit_Adventurers_2.0_FREE/Characters/gltf/Knight.glb",
        "max_hp_bonus": 4,
        "move_speed_bonus": 0.0,
        "projectile_damage_bonus": 1,
    },
}

const FALLBACK_WEAPONS := {
    "weapon_basic": {
        "id": "weapon_basic",
        "display_name": "Basic Gun",
        "description": "Reliable starter weapon.",
        "weapon_type": "basic",
        "damage": 1,
        "fire_rate": 0.6,
        "projectile_count": 1,
        "spread_angle": 0.0,
        "projectile_speed": 14.0,
        "range": 20.0,
        "unlocked": true,
        "implemented": true,
        "icon": "",
        "projectile_scene": "res://scenes/effects/projectile.tscn",
        "model_scene_path": "res://assets/Styloo Guns Asset Pack GLTF FBX V1.1/Styloo Guns Asset Pack GLTF FBX V1.1/Normal version Color and NormalMap/GLB/pew.glb",
        "attachment_bone": "handslot.r",
        "attachment_position": [0.0, 0.0, 0.0],
        "attachment_rotation_degrees": [0.0, 90.0, 0.0],
        "attachment_scale": [3.0, 3.0, 3.0],
    },
}

const FALLBACK_PETS := {
    "pet_drone": {
        "display_name": "Drone",
        "model_scene_path": "res://scenes/entities/pet_companion.tscn",
        "damage": 1,
        "attack_interval": 1.2,
    },
}

const FALLBACK_UPGRADES := [
    {
        "id": "projectile_damage",
        "title": "Power Shot",
        "description": "Increase projectile damage by 1.",
    },
    {
        "id": "fire_rate",
        "title": "Rapid Fire",
        "description": "Reduce fire interval slightly.",
    },
    {
        "id": "move_speed",
        "title": "Sprint",
        "description": "Increase movement speed.",
    },
    {
        "id": "hire_shooter_guard",
        "title": "Hire Shooter Guard",
        "description": "Hire a shooter guard to fight for this run.",
    },
]

const FALLBACK_MISSIONS := [
    {"id": "mission_kills", "label": "Defeat 15 enemies", "stat": "kills", "target": 15},
]

const FALLBACK_PERMANENT_UPGRADES := {
    "perm_max_hp": {
        "title": "Vitality",
        "description": "Permanent +2 max HP per rank.",
        "max_rank": 5,
    },
}

var heroes: Dictionary = {}
var weapons: Dictionary = {}
var pets: Dictionary = {}
var upgrades: Array = []
var missions: Array = []
var permanent_upgrades: Dictionary = {}

func _init() -> void:
    load_all()

func load_all() -> void:
    heroes = _load_dictionary(HEROES_PATH, FALLBACK_HEROES)
    weapons = _load_dictionary(WEAPONS_PATH, FALLBACK_WEAPONS)
    pets = _load_dictionary(PETS_PATH, FALLBACK_PETS)
    upgrades = _load_array(UPGRADES_PATH, FALLBACK_UPGRADES)
    missions = _load_array(MISSIONS_PATH, FALLBACK_MISSIONS)
    permanent_upgrades = _load_dictionary(PERMANENT_UPGRADES_PATH, FALLBACK_PERMANENT_UPGRADES)
    _validate_heroes()
    _validate_weapons()
    _validate_pets()
    _validate_upgrades()
    _validate_missions()
    _validate_permanent_upgrades()
    _ensure_required_defaults()

func get_hero_definition(hero_id: String) -> Dictionary:
    return heroes.get(hero_id, heroes[DEFAULT_HERO_ID]).duplicate(true)

func get_weapon_definition(weapon_id: String) -> Dictionary:
    return weapons.get(weapon_id, weapons[DEFAULT_WEAPON_ID]).duplicate(true)

func get_pet_definition(pet_id: String) -> Dictionary:
    return pets.get(pet_id, pets[DEFAULT_PET_ID]).duplicate(true)

func resolve_hero_model_scene(hero_id: String) -> PackedScene:
    var definition := _get_model_definition(heroes, DEFAULT_HERO_ID, hero_id, "Hero")
    var model_path := str(definition.get("model_scene_path", ""))
    return _resolve_model_scene("Hero", hero_id, model_path, str(FALLBACK_HEROES[DEFAULT_HERO_ID]["model_scene_path"]))

func resolve_pet_model_scene(pet_id: String) -> PackedScene:
    var definition := _get_model_definition(pets, DEFAULT_PET_ID, pet_id, "Pet")
    var model_path := str(definition.get("model_scene_path", ""))
    return _resolve_model_scene("Pet", pet_id, model_path, str(FALLBACK_PETS[DEFAULT_PET_ID]["model_scene_path"]))

func resolve_weapon_model_scene(weapon_id: String) -> PackedScene:
    var definition := _get_model_definition(weapons, DEFAULT_WEAPON_ID, weapon_id, "Weapon")
    var model_path := str(definition.get("model_scene_path", ""))
    return _resolve_model_scene("Weapon", weapon_id, model_path, str(FALLBACK_WEAPONS[DEFAULT_WEAPON_ID]["model_scene_path"]))

func resolve_weapon_scene(weapon_id: String) -> PackedScene:
    return resolve_weapon_model_scene(weapon_id)

func resolve_hero_model_path(hero_id: String) -> String:
    var definition := _get_model_definition(heroes, DEFAULT_HERO_ID, hero_id, "Hero")
    return _resolve_model_path("Hero", hero_id, str(definition.get("model_scene_path", "")), str(FALLBACK_HEROES[DEFAULT_HERO_ID]["model_scene_path"]))

func resolve_pet_model_path(pet_id: String) -> String:
    var definition := _get_model_definition(pets, DEFAULT_PET_ID, pet_id, "Pet")
    return _resolve_model_path("Pet", pet_id, str(definition.get("model_scene_path", "")), str(FALLBACK_PETS[DEFAULT_PET_ID]["model_scene_path"]))

func resolve_weapon_model_path(weapon_id: String) -> String:
    var definition := _get_model_definition(weapons, DEFAULT_WEAPON_ID, weapon_id, "Weapon")
    return _resolve_model_path("Weapon", weapon_id, str(definition.get("model_scene_path", "")), str(FALLBACK_WEAPONS[DEFAULT_WEAPON_ID]["model_scene_path"]))

func get_permanent_upgrade_definition(upgrade_id: String) -> Dictionary:
    return permanent_upgrades.get(upgrade_id, {}).duplicate(true)

func get_hero_ids() -> Array:
    return heroes.keys()

func get_weapon_ids() -> Array:
    return weapons.keys()

func get_pet_ids() -> Array:
    return pets.keys()

func has_hero(hero_id: String) -> bool:
    return heroes.has(hero_id)

func has_weapon(weapon_id: String) -> bool:
    return weapons.has(weapon_id)

func has_pet(pet_id: String) -> bool:
    return pets.has(pet_id)

func get_upgrade_options() -> Array:
    return upgrades.duplicate(true)

func get_missions() -> Array:
    return missions.duplicate(true)

func _load_dictionary(path: String, fallback: Dictionary) -> Dictionary:
    var parsed: Variant = _load_json(path)
    if typeof(parsed) != TYPE_DICTIONARY:
        if parsed != null:
            _warn("%s top-level data is not an object; using fallback data." % path.get_file())
        return fallback.duplicate(true)

    var parsed_dictionary: Dictionary = parsed
    if parsed_dictionary.is_empty():
        _warn("%s has no entries; using fallback data." % path.get_file())
        return fallback.duplicate(true)
    return parsed_dictionary.duplicate(true)

func _load_array(path: String, fallback: Array) -> Array:
    var parsed: Variant = _load_json(path)
    if typeof(parsed) != TYPE_ARRAY:
        if parsed != null:
            _warn("%s top-level data is not an array; using fallback data." % path.get_file())
        return fallback.duplicate(true)

    var parsed_array: Array = parsed
    if parsed_array.is_empty():
        _warn("%s has no entries; using fallback data." % path.get_file())
        return fallback.duplicate(true)
    return parsed_array.duplicate(true)

func _load_json(path: String) -> Variant:
    if not FileAccess.file_exists(path):
        _warn("%s is missing; using fallback data." % path.get_file())
        return null

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        _warn("%s could not be opened; using fallback data." % path.get_file())
        return null

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if parsed == null:
        _warn("%s could not be parsed; using fallback data." % path.get_file())
    return parsed

func _validate_heroes() -> void:
    for hero_id_variant in heroes.keys():
        var hero_id := str(hero_id_variant)
        var defaults := _get_dictionary_default(FALLBACK_HEROES, hero_id, _default_hero_entry(hero_id))
        if typeof(heroes[hero_id_variant]) != TYPE_DICTIONARY:
            _warn("heroes.json entry \"%s\" is not an object; using safe defaults." % hero_id)
            heroes[hero_id_variant] = defaults
            continue

        var hero: Dictionary = heroes[hero_id_variant]
        hero["id"] = hero_id
        _ensure_string_field(hero, "display_name", str(defaults.get("display_name", _display_name_from_id(hero_id))), "heroes.json", hero_id)
        _ensure_model_scene_path(hero, "heroes.json", hero_id, str(defaults.get("model_scene_path", FALLBACK_HEROES[DEFAULT_HERO_ID]["model_scene_path"])))
        _ensure_number_field(hero, "max_hp_bonus", defaults.get("max_hp_bonus", 0), "heroes.json", hero_id)
        _ensure_number_field(hero, "move_speed_bonus", defaults.get("move_speed_bonus", 0.0), "heroes.json", hero_id)
        _ensure_number_field(hero, "projectile_damage_bonus", defaults.get("projectile_damage_bonus", 0), "heroes.json", hero_id)
        heroes[hero_id_variant] = hero

func _validate_weapons() -> void:
    for weapon_id_variant in weapons.keys():
        var weapon_id := str(weapon_id_variant)
        var defaults := _get_dictionary_default(FALLBACK_WEAPONS, weapon_id, _default_weapon_entry(weapon_id))
        if typeof(weapons[weapon_id_variant]) != TYPE_DICTIONARY:
            _warn("weapons.json entry \"%s\" is not an object; using safe defaults." % weapon_id)
            weapons[weapon_id_variant] = defaults
            continue

        var weapon: Dictionary = weapons[weapon_id_variant]
        _ensure_string_field(weapon, "id", str(defaults.get("id", weapon_id)), "weapons.json", weapon_id)
        _ensure_string_field(weapon, "display_name", str(defaults.get("display_name", _display_name_from_id(weapon_id))), "weapons.json", weapon_id)
        _ensure_number_field(weapon, "damage", defaults.get("damage", 1), "weapons.json", weapon_id)
        _ensure_number_field(weapon, "fire_rate", defaults.get("fire_rate", 0.5), "weapons.json", weapon_id)
        _ensure_number_field(weapon, "projectile_count", defaults.get("projectile_count", 1), "weapons.json", weapon_id)
        _ensure_number_field(weapon, "spread_angle", defaults.get("spread_angle", 0.0), "weapons.json", weapon_id)
        _ensure_number_field(weapon, "projectile_speed", defaults.get("projectile_speed", 14.0), "weapons.json", weapon_id)
        _ensure_number_field(weapon, "range", defaults.get("range", 20.0), "weapons.json", weapon_id)
        _ensure_model_scene_path(weapon, "weapons.json", weapon_id, str(defaults.get("model_scene_path", FALLBACK_WEAPONS[DEFAULT_WEAPON_ID]["model_scene_path"])))
        _ensure_string_field(weapon, "attachment_bone", str(defaults.get("attachment_bone", "handslot.r")), "weapons.json", weapon_id)
        _ensure_vector3_array_field(weapon, "attachment_position", defaults.get("attachment_position", [0.0, 0.0, 0.0]), "weapons.json", weapon_id)
        _ensure_vector3_array_field(weapon, "attachment_rotation_degrees", defaults.get("attachment_rotation_degrees", [0.0, 90.0, 0.0]), "weapons.json", weapon_id)
        _ensure_vector3_array_field(weapon, "attachment_scale", defaults.get("attachment_scale", [0.18, 0.18, 0.18]), "weapons.json", weapon_id)

        if int(weapon.get("projectile_count", 1)) < 1:
            _warn("weapons.json entry \"%s\" invalid projectile_count; using 1." % weapon_id)
            weapon["projectile_count"] = 1
        if float(weapon.get("fire_rate", 0.5)) <= 0.0:
            _warn("weapons.json entry \"%s\" invalid fire_rate; using 0.5." % weapon_id)
            weapon["fire_rate"] = 0.5
        if float(weapon.get("range", 20.0)) <= 0.0:
            _warn("weapons.json entry \"%s\" invalid range; using 20.0." % weapon_id)
            weapon["range"] = 20.0
        weapons[weapon_id_variant] = weapon

func _validate_pets() -> void:
    for pet_id_variant in pets.keys():
        var pet_id := str(pet_id_variant)
        var defaults := _get_dictionary_default(FALLBACK_PETS, pet_id, _default_pet_entry(pet_id))
        if typeof(pets[pet_id_variant]) != TYPE_DICTIONARY:
            _warn("pets.json entry \"%s\" is not an object; using safe defaults." % pet_id)
            pets[pet_id_variant] = defaults
            continue

        var pet: Dictionary = pets[pet_id_variant]
        pet["id"] = pet_id
        _ensure_string_field(pet, "display_name", str(defaults.get("display_name", _display_name_from_id(pet_id))), "pets.json", pet_id)
        _ensure_model_scene_path(pet, "pets.json", pet_id, str(defaults.get("model_scene_path", FALLBACK_PETS[DEFAULT_PET_ID]["model_scene_path"])))
        _ensure_number_field(pet, "damage", defaults.get("damage", 1), "pets.json", pet_id)
        _ensure_number_field(pet, "attack_interval", defaults.get("attack_interval", 1.0), "pets.json", pet_id)
        if float(pet.get("attack_interval", 1.0)) <= 0.0:
            _warn("pets.json entry \"%s\" invalid attack_interval; using 1.0." % pet_id)
            pet["attack_interval"] = 1.0
        pets[pet_id_variant] = pet

func _validate_upgrades() -> void:
    var validated_upgrades := []
    for index in range(upgrades.size()):
        var entry: Variant = upgrades[index]
        if typeof(entry) != TYPE_DICTIONARY:
            _warn("upgrades.json entry %d is not an object; skipping." % index)
            continue

        var upgrade: Dictionary = entry
        if not _has_required_string(upgrade, "id") or not _has_required_string(upgrade, "title") or not _has_required_string(upgrade, "description"):
            _warn("upgrades.json entry %d is missing id, title, or description; skipping." % index)
            continue
        validated_upgrades.append(upgrade.duplicate(true))

    if validated_upgrades.is_empty():
        _warn("upgrades.json has no valid entries; using fallback data.")
        upgrades = FALLBACK_UPGRADES.duplicate(true)
        return
    upgrades = validated_upgrades

func _validate_missions() -> void:
    var validated_missions := []
    for index in range(missions.size()):
        var defaults := _default_mission_entry(index)
        var entry: Variant = missions[index]
        if typeof(entry) != TYPE_DICTIONARY:
            _warn("missions.json entry %d is not an object; using safe defaults." % index)
            validated_missions.append(defaults)
            continue

        var mission: Dictionary = entry
        var entry_id := str(mission.get("id", "mission_%d" % index))
        _ensure_string_field(mission, "id", str(defaults.get("id")), "missions.json", entry_id)
        _ensure_string_field(mission, "label", str(defaults.get("label")), "missions.json", entry_id)
        _ensure_string_field(mission, "stat", str(defaults.get("stat")), "missions.json", entry_id)
        _ensure_number_field(mission, "target", defaults.get("target", 1), "missions.json", entry_id)
        if int(mission.get("target", 1)) <= 0:
            _warn("missions.json entry \"%s\" invalid target; using 1." % entry_id)
            mission["target"] = 1
        validated_missions.append(mission.duplicate(true))

    if validated_missions.is_empty():
        _warn("missions.json has no valid entries; using fallback data.")
        missions = FALLBACK_MISSIONS.duplicate(true)
        return
    missions = validated_missions

func _validate_permanent_upgrades() -> void:
    for upgrade_id_variant in permanent_upgrades.keys():
        var upgrade_id := str(upgrade_id_variant)
        var defaults := _get_dictionary_default(FALLBACK_PERMANENT_UPGRADES, upgrade_id, _default_permanent_upgrade_entry(upgrade_id))
        if typeof(permanent_upgrades[upgrade_id_variant]) != TYPE_DICTIONARY:
            _warn("permanent_upgrades.json entry \"%s\" is not an object; using safe defaults." % upgrade_id)
            permanent_upgrades[upgrade_id_variant] = defaults
            continue

        var upgrade: Dictionary = permanent_upgrades[upgrade_id_variant]
        _ensure_string_field(upgrade, "title", str(defaults.get("title", _display_name_from_id(upgrade_id))), "permanent_upgrades.json", upgrade_id)
        _ensure_string_field(upgrade, "description", str(defaults.get("description", "")), "permanent_upgrades.json", upgrade_id)
        _ensure_number_field(upgrade, "max_rank", defaults.get("max_rank", 1), "permanent_upgrades.json", upgrade_id)
        if int(upgrade.get("max_rank", 1)) < 1:
            _warn("permanent_upgrades.json entry \"%s\" invalid max_rank; using 1." % upgrade_id)
            upgrade["max_rank"] = 1
        permanent_upgrades[upgrade_id_variant] = upgrade

func _ensure_required_defaults() -> void:
    if not heroes.has(DEFAULT_HERO_ID):
        _warn("heroes.json missing required default \"%s\"; injecting fallback." % DEFAULT_HERO_ID)
        heroes[DEFAULT_HERO_ID] = FALLBACK_HEROES[DEFAULT_HERO_ID].duplicate(true)
    if not weapons.has(DEFAULT_WEAPON_ID):
        _warn("weapons.json missing required default \"%s\"; injecting fallback." % DEFAULT_WEAPON_ID)
        weapons[DEFAULT_WEAPON_ID] = FALLBACK_WEAPONS[DEFAULT_WEAPON_ID].duplicate(true)
    if not pets.has(DEFAULT_PET_ID):
        _warn("pets.json missing required default \"%s\"; injecting fallback." % DEFAULT_PET_ID)
        pets[DEFAULT_PET_ID] = FALLBACK_PETS[DEFAULT_PET_ID].duplicate(true)

func _ensure_string_field(entry: Dictionary, key: String, default_value: String, file_name: String, entry_id: String) -> void:
    if entry.has(key) and typeof(entry.get(key)) == TYPE_STRING and not str(entry.get(key)).strip_edges().is_empty():
        return

    _warn("%s entry \"%s\" %s %s; using default." % [file_name, entry_id, _field_issue(entry, key), key])
    entry[key] = default_value

func _ensure_number_field(entry: Dictionary, key: String, default_value: Variant, file_name: String, entry_id: String) -> void:
    if entry.has(key) and _is_number(entry.get(key)):
        return

    _warn("%s entry \"%s\" %s %s; using default." % [file_name, entry_id, _field_issue(entry, key), key])
    entry[key] = default_value

func _ensure_model_scene_path(entry: Dictionary, file_name: String, entry_id: String, default_value: String) -> void:
    if entry.has("model_scene_path") and typeof(entry.get("model_scene_path")) == TYPE_STRING:
        var model_path := str(entry.get("model_scene_path")).strip_edges()
        if not model_path.is_empty() and ResourceLoader.exists(model_path):
            entry["model_scene_path"] = model_path
            return
    var reason := "missing" if not entry.has("model_scene_path") else "invalid"
    _warn("%s entry \"%s\" has %s model_scene_path; explicitly using fallback %s." % [file_name, entry_id, reason, default_value])
    entry["model_scene_path"] = default_value

func _ensure_vector3_array_field(entry: Dictionary, key: String, default_value: Variant, file_name: String, entry_id: String) -> void:
    if entry.has(key) and typeof(entry.get(key)) == TYPE_ARRAY and (entry.get(key) as Array).size() >= 3:
        return

    _warn("%s entry \"%s\" %s %s; using default." % [file_name, entry_id, _field_issue(entry, key), key])
    entry[key] = default_value

func _has_required_string(entry: Dictionary, key: String) -> bool:
    return entry.has(key) and typeof(entry.get(key)) == TYPE_STRING and not str(entry.get(key)).strip_edges().is_empty()

func _is_number(value: Variant) -> bool:
    return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT

func _field_issue(entry: Dictionary, key: String) -> String:
    return "missing" if not entry.has(key) else "invalid"

func _get_dictionary_default(fallback: Dictionary, entry_id: String, safe_default: Dictionary) -> Dictionary:
    if fallback.has(entry_id) and typeof(fallback[entry_id]) == TYPE_DICTIONARY:
        var fallback_entry: Dictionary = fallback[entry_id]
        return fallback_entry.duplicate(true)
    return safe_default

func _default_hero_entry(hero_id: String) -> Dictionary:
    return {
        "display_name": _display_name_from_id(hero_id),
        "model_scene_path": str(FALLBACK_HEROES[DEFAULT_HERO_ID]["model_scene_path"]),
        "max_hp_bonus": 0,
        "move_speed_bonus": 0.0,
        "projectile_damage_bonus": 0,
    }

func _default_weapon_entry(weapon_id: String) -> Dictionary:
    return {
        "id": weapon_id,
        "display_name": _display_name_from_id(weapon_id),
        "damage": 1,
        "fire_rate": 0.5,
        "projectile_count": 1,
        "spread_angle": 0.0,
        "projectile_speed": 14.0,
        "range": 20.0,
        "model_scene_path": str(FALLBACK_WEAPONS[DEFAULT_WEAPON_ID]["model_scene_path"]),
        "attachment_bone": "handslot.r",
        "attachment_position": [0.0, 0.0, 0.0],
        "attachment_rotation_degrees": [0.0, 90.0, 0.0],
        "attachment_scale": [3.0, 3.0, 3.0],
    }

func _default_pet_entry(pet_id: String) -> Dictionary:
    return {
        "display_name": _display_name_from_id(pet_id),
        "model_scene_path": str(FALLBACK_PETS[DEFAULT_PET_ID]["model_scene_path"]),
        "damage": 1,
        "attack_interval": 1.0,
    }

func _default_mission_entry(index: int) -> Dictionary:
    return {
        "id": "mission_%d" % index,
        "label": "Mission %d" % (index + 1),
        "stat": "kills",
        "target": 1,
    }

func _default_permanent_upgrade_entry(upgrade_id: String) -> Dictionary:
    return {
        "title": _display_name_from_id(upgrade_id),
        "description": "",
        "max_rank": 1,
    }

func _display_name_from_id(entry_id: String) -> String:
    return entry_id.replace("_", " ").capitalize()

func _warn(message: String) -> void:
    push_warning("GameData warning: %s" % message)

func _get_model_definition(collection: Dictionary, default_id: String, requested_id: String, model_type: String) -> Dictionary:
    if collection.has(requested_id):
        return collection[requested_id].duplicate(true)
    _warn("%s %s is not defined; resolving with explicit fallback id %s." % [model_type, requested_id, default_id])
    return collection[default_id].duplicate(true)

func _resolve_model_scene(model_type: String, requested_id: String, model_path: String, fallback_path: String) -> PackedScene:
    var resolved_path := _resolve_model_path(model_type, requested_id, model_path, fallback_path)
    var scene := load(resolved_path) as PackedScene
    if scene == null:
        _warn("%s %s resolved model %s could not load." % [model_type, requested_id, resolved_path])
    return scene

func _resolve_model_path(model_type: String, requested_id: String, model_path: String, fallback_path: String) -> String:
    var resolved_path := model_path.strip_edges()
    var used_fallback := false
    var fallback_reason := ""
    if resolved_path.is_empty():
        resolved_path = fallback_path
        used_fallback = true
        fallback_reason = "missing model_scene_path"
    elif not ResourceLoader.exists(resolved_path):
        fallback_reason = "missing resource %s" % resolved_path
        resolved_path = fallback_path
        used_fallback = true
    if DEBUG_MODEL_TRACE:
        print("%s model resolve: requested_id=%s resolved_model_path=%s fallback_used=%s%s" % [
            model_type,
            requested_id,
            resolved_path,
            str(used_fallback),
            " reason=%s" % fallback_reason if used_fallback else "",
        ])
    if used_fallback:
        _warn("%s %s using fallback model %s because %s." % [model_type, requested_id, resolved_path, fallback_reason])
    return resolved_path
