extends RefCounted
class_name GameData

const HEROES_PATH := "res://data/heroes.json"
const WEAPONS_PATH := "res://data/weapons.json"
const PETS_PATH := "res://data/pets.json"
const UPGRADES_PATH := "res://data/upgrades.json"
const MISSIONS_PATH := "res://data/missions.json"
const PERMANENT_UPGRADES_PATH := "res://data/permanent_upgrades.json"

const DEFAULT_HERO_ID := "hero_knight"
const DEFAULT_WEAPON_ID := "weapon_basic"
const DEFAULT_PET_ID := "pet_drone"

const FALLBACK_HEROES := {
    "hero_knight": {
        "display_name": "Knight",
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
    },
}

const FALLBACK_PETS := {
    "pet_drone": {
        "display_name": "Drone",
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
    _ensure_required_defaults()

func get_hero_definition(hero_id: String) -> Dictionary:
    return heroes.get(hero_id, heroes[DEFAULT_HERO_ID]).duplicate(true)

func get_weapon_definition(weapon_id: String) -> Dictionary:
    return weapons.get(weapon_id, weapons[DEFAULT_WEAPON_ID]).duplicate(true)

func get_pet_definition(pet_id: String) -> Dictionary:
    return pets.get(pet_id, pets[DEFAULT_PET_ID]).duplicate(true)

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
        return fallback.duplicate(true)

    var parsed_dictionary: Dictionary = parsed
    if parsed_dictionary.is_empty():
        return fallback.duplicate(true)
    return parsed_dictionary.duplicate(true)

func _load_array(path: String, fallback: Array) -> Array:
    var parsed: Variant = _load_json(path)
    if typeof(parsed) != TYPE_ARRAY:
        return fallback.duplicate(true)

    var parsed_array: Array = parsed
    if parsed_array.is_empty():
        return fallback.duplicate(true)
    return parsed_array.duplicate(true)

func _load_json(path: String) -> Variant:
    if not FileAccess.file_exists(path):
        return null

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return null

    return JSON.parse_string(file.get_as_text())

func _ensure_required_defaults() -> void:
    if not heroes.has(DEFAULT_HERO_ID):
        heroes[DEFAULT_HERO_ID] = FALLBACK_HEROES[DEFAULT_HERO_ID].duplicate(true)
    if not weapons.has(DEFAULT_WEAPON_ID):
        weapons[DEFAULT_WEAPON_ID] = FALLBACK_WEAPONS[DEFAULT_WEAPON_ID].duplicate(true)
    if not pets.has(DEFAULT_PET_ID):
        pets[DEFAULT_PET_ID] = FALLBACK_PETS[DEFAULT_PET_ID].duplicate(true)
