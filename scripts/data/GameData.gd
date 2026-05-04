extends RefCounted
class_name GameData

const SkillDataScript := preload("res://scripts/data/SkillData.gd")
const GuardianDataScript := preload("res://scripts/data/GuardianData.gd")
const PetEvolutionDataScript := preload("res://scripts/data/PetEvolutionData.gd")
const UpgradeDataScript := preload("res://scripts/data/UpgradeData.gd")

const HEROES_PATH := "res://data/heroes.json"
const WEAPONS_PATH := "res://data/weapons.json"
const PETS_PATH := "res://data/pets.json"
const SKILLS_PATH := "res://data/skills.json"
const GUARDIANS_PATH := "res://data/guardians.json"
const PET_EVOLUTIONS_PATH := "res://data/pet_evolutions.json"
const PET_ACCESSORIES_PATH := "res://data/pet_accessories.json"
const UPGRADES_PATH := "res://data/upgrades.json"
const MISSIONS_PATH := "res://data/missions.json"
const PERMANENT_UPGRADES_PATH := "res://data/permanent_upgrades.json"
const DEBUG_MODEL_TRACE := false

const DEFAULT_HERO_ID := "hero_knight"
const DEFAULT_WEAPON_ID := "weapon_basic"
const DEFAULT_PET_ID := "pet_drone"
const WEAPON_RARITY_MULTIPLIERS := {
	"common": 1.0,
	"uncommon": 1.15,
	"rare": 1.3,
	"epic": 1.5,
	"legendary": 1.8,
}
const WEAPON_RARITY_COLORS := {
	"common": "9ca3af",
	"uncommon": "22c55e",
	"rare": "3b82f6",
	"epic": "a855f7",
	"legendary": "f97316",
}

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
		"rarity": "common",
		"base_damage": 1,
		"upgrade_base_cost": 20,
		"special_effect": "ricochet",
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
	},
}

const FALLBACK_UPGRADES := [
	{
		"id": "projectile_damage",
		"name": "Power Shot",
		"title": "Power Shot",
		"tier": "common",
		"effect_type": "projectile_damage",
		"effect_value": 1,
		"description": "Increase projectile damage by 1.",
		"icon": "",
		"weight": 100,
		"max_stack": 12,
	},
	{
		"id": "fire_rate",
		"name": "Rapid Fire",
		"title": "Rapid Fire",
		"tier": "common",
		"effect_type": "fire_rate",
		"effect_value": 0.08,
		"description": "Reduce fire interval slightly.",
		"icon": "",
		"weight": 95,
		"max_stack": 8,
	},
	{
		"id": "move_speed",
		"name": "Sprint",
		"title": "Sprint",
		"tier": "common",
		"effect_type": "move_speed",
		"effect_value": 0.5,
		"description": "Increase movement speed.",
		"icon": "",
		"weight": 85,
		"max_stack": 6,
	},
	{
		"id": "hire_shooter_guard",
		"name": "Hire Shooter Guard",
		"title": "Hire Shooter Guard",
		"tier": "rare",
		"effect_type": "hire_guard",
		"effect_value": "guard_shooter",
		"description": "Hire a shooter guard to fight for this run.",
		"icon": "",
		"weight": 40,
		"max_stack": 1,
	},
]

const FALLBACK_SKILLS := [
	{
		"id": "skill_knight_iron_skin",
		"hero_id": "hero_knight",
		"name": "Iron Skin",
		"type": "passive",
		"cooldown": 0.0,
		"damage": 0,
		"effect": "incoming_damage_reduction:1",
		"description": "Reduces incoming damage by 1, to a minimum of 1.",
		"unlock_level": 1,
	},
]

const FALLBACK_GUARDIANS := {
	"guard_shooter": {
		"display_name": "Shooter Guard",
		"type": "ranged",
		"role": "single_target_damage",
		"follow_distance": 2.4,
		"scan_interval": 0.2,
		"skills": [
			{
				"name": "Cover Fire",
				"cooldown": 1.0,
				"damage": 1,
				"range": 18.0,
				"shape": "line",
				"trigger_condition": "enemy_in_range",
				"effect": "projectile",
			},
		],
		"model_scene_path": "res://scenes/entities/shooter_guard.tscn",
		"rarity": "common",
		"unlock_condition": "hire_upgrade",
	},
}

const FALLBACK_PET_EVOLUTIONS := {
	"pet_drone": {
		"pet_id": "pet_drone",
		"buff_type": "damage_multiplier",
		"base_buff_value": 0.1,
		"stages": [
			{"stage": 1, "shard_cost": 0, "buff_multiplier": 1.0, "visual_change": "starter_frame"},
			{"stage": 2, "shard_cost": 25, "buff_multiplier": 1.5, "visual_change": "blue_core"},
			{"stage": 3, "shard_cost": 60, "buff_multiplier": 2.0, "visual_change": "twin_rotors"},
		],
	},
}

const FALLBACK_PET_ACCESSORIES := {
	"pet_charm_damage": {
		"display_name": "Power Charm",
		"pet_id": "any",
		"modifier_type": "buff_multiplier_bonus",
		"modifier_value": 0.15,
		"rarity": "common",
		"description": "Slightly improves the equipped pet's buff.",
	},
}

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
var skills: Dictionary = {}
var guardians: Dictionary = {}
var pet_evolutions: Dictionary = {}
var pet_accessories: Dictionary = {}
var upgrades: Array = []
var missions: Array = []
var permanent_upgrades: Dictionary = {}

func _init() -> void:
	load_all()

func load_all() -> void:
	heroes = _load_dictionary(HEROES_PATH, FALLBACK_HEROES)
	weapons = _load_dictionary(WEAPONS_PATH, FALLBACK_WEAPONS)
	pets = _load_dictionary(PETS_PATH, FALLBACK_PETS)
	skills = _load_skill_dictionary()
	guardians = _load_dictionary(GUARDIANS_PATH, FALLBACK_GUARDIANS)
	pet_evolutions = _load_dictionary(PET_EVOLUTIONS_PATH, FALLBACK_PET_EVOLUTIONS)
	pet_accessories = _load_dictionary(PET_ACCESSORIES_PATH, FALLBACK_PET_ACCESSORIES)
	upgrades = _load_array(UPGRADES_PATH, FALLBACK_UPGRADES)
	missions = _load_array(MISSIONS_PATH, FALLBACK_MISSIONS)
	permanent_upgrades = _load_dictionary(PERMANENT_UPGRADES_PATH, FALLBACK_PERMANENT_UPGRADES)
	_validate_heroes()
	_validate_weapons()
	_validate_pets()
	_validate_skills()
	_validate_guardians()
	_validate_pet_evolutions()
	_validate_pet_accessories()
	_validate_upgrades()
	_validate_missions()
	_validate_permanent_upgrades()
	_ensure_required_defaults()

func get_hero_definition(hero_id: String) -> Dictionary:
	return heroes.get(hero_id, heroes[DEFAULT_HERO_ID]).duplicate(true)

func get_weapon_definition(weapon_id: String) -> Dictionary:
	return weapons.get(weapon_id, weapons[DEFAULT_WEAPON_ID]).duplicate(true)

func get_weapon_rarity_multiplier(rarity: String) -> float:
	return float(WEAPON_RARITY_MULTIPLIERS.get(rarity.to_lower(), 1.0))

func get_weapon_rarity_color(rarity: String) -> String:
	return str(WEAPON_RARITY_COLORS.get(rarity.to_lower(), WEAPON_RARITY_COLORS["common"]))

func get_pet_definition(pet_id: String) -> Dictionary:
	return pets.get(pet_id, pets[DEFAULT_PET_ID]).duplicate(true)

func get_skill(skill_id: String) -> Dictionary:
	return skills.get(skill_id, {}).duplicate(true)

func get_skill_data(skill_id: String) -> RefCounted:
	var skill := SkillDataScript.new()
	skill.load_from_dictionary(get_skill(skill_id))
	return skill

func get_skills_for_hero(hero_id: String) -> Array:
	var hero_skills := []
	for skill_id in skills.keys():
		var skill: Dictionary = skills[skill_id]
		if str(skill.get("hero_id", "")) == hero_id:
			hero_skills.append(skill.duplicate(true))
	hero_skills.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.get("unlock_level", 1)) < int(b.get("unlock_level", 1))
	)
	return hero_skills

func get_guardian(guardian_id: String) -> Dictionary:
	return guardians.get(guardian_id, {}).duplicate(true)

func get_guardian_data(guardian_id: String) -> RefCounted:
	var guardian := GuardianDataScript.new()
	guardian.load_from_dictionary(get_guardian(guardian_id))
	return guardian

func get_pet_evolution(pet_id: String) -> Dictionary:
	return pet_evolutions.get(pet_id, {}).duplicate(true)

func get_pet_accessory(accessory_id: String) -> Dictionary:
	return pet_accessories.get(accessory_id, {}).duplicate(true)

func get_pet_evolution_data(pet_id: String) -> RefCounted:
	var evolution := PetEvolutionDataScript.new()
	evolution.load_from_dictionary(get_pet_evolution(pet_id))
	return evolution

func get_upgrade(upgrade_id: String) -> Dictionary:
	for upgrade in upgrades:
		if typeof(upgrade) == TYPE_DICTIONARY and str(upgrade.get("id", "")) == upgrade_id:
			return upgrade.duplicate(true)
	return {}

func get_upgrade_data(upgrade_id: String) -> RefCounted:
	var upgrade := UpgradeDataScript.new()
	upgrade.load_from_dictionary(get_upgrade(upgrade_id))
	return upgrade

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

func get_skill_ids() -> Array:
	return skills.keys()

func get_guardian_ids() -> Array:
	return guardians.keys()

func get_pet_evolution_ids() -> Array:
	return pet_evolutions.keys()

func get_pet_accessory_ids() -> Array:
	return pet_accessories.keys()

func has_hero(hero_id: String) -> bool:
	return heroes.has(hero_id)

func has_weapon(weapon_id: String) -> bool:
	return weapons.has(weapon_id)

func has_pet(pet_id: String) -> bool:
	return pets.has(pet_id)

func has_skill(skill_id: String) -> bool:
	return skills.has(skill_id)

func has_guardian(guardian_id: String) -> bool:
	return guardians.has(guardian_id)

func has_pet_evolution(pet_id: String) -> bool:
	return pet_evolutions.has(pet_id)

func has_pet_accessory(accessory_id: String) -> bool:
	return pet_accessories.has(accessory_id)

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

func _load_skill_dictionary() -> Dictionary:
	var parsed_array := _load_array(SKILLS_PATH, FALLBACK_SKILLS)
	var skill_dictionary := {}
	for index in range(parsed_array.size()):
		var entry: Variant = parsed_array[index]
		if typeof(entry) != TYPE_DICTIONARY:
			_warn("skills.json entry %d is not an object; skipping." % index)
			continue
		var skill: Dictionary = entry
		var skill_id := str(skill.get("id", "")).strip_edges()
		if skill_id.is_empty():
			_warn("skills.json entry %d is missing id; skipping." % index)
			continue
		skill_dictionary[skill_id] = skill.duplicate(true)
	if skill_dictionary.is_empty():
		_warn("skills.json has no valid entries; using fallback data.")
		for fallback_skill in FALLBACK_SKILLS:
			if typeof(fallback_skill) == TYPE_DICTIONARY:
				var fallback_entry: Dictionary = fallback_skill
				skill_dictionary[str(fallback_entry.get("id", "skill_fallback"))] = fallback_entry.duplicate(true)
	return skill_dictionary

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
		_ensure_string_field(weapon, "rarity", str(defaults.get("rarity", "common")), "weapons.json", weapon_id)
		_ensure_number_field(weapon, "base_damage", defaults.get("base_damage", weapon.get("damage", 1)), "weapons.json", weapon_id)
		_ensure_number_field(weapon, "upgrade_base_cost", defaults.get("upgrade_base_cost", 20), "weapons.json", weapon_id)
		_ensure_string_field(weapon, "special_effect", str(defaults.get("special_effect", "none")), "weapons.json", weapon_id)
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
		var rarity := str(weapon.get("rarity", "common")).to_lower()
		if not WEAPON_RARITY_MULTIPLIERS.has(rarity):
			_warn("weapons.json entry \"%s\" invalid rarity; using common." % weapon_id)
			rarity = "common"
			weapon["rarity"] = rarity
		var rarity_multiplier := get_weapon_rarity_multiplier(rarity)
		weapon["rarity_multiplier"] = rarity_multiplier
		weapon["rarity_color"] = get_weapon_rarity_color(rarity)
		weapon["damage"] = maxi(roundi(float(weapon.get("base_damage", weapon.get("damage", 1))) * rarity_multiplier), 1)
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
		pet.erase("damage")
		pet.erase("attack_interval")
		pets[pet_id_variant] = pet

func _validate_skills() -> void:
	var validated_skills := {}
	for skill_id_variant in skills.keys():
		var skill_id := str(skill_id_variant)
		if typeof(skills[skill_id_variant]) != TYPE_DICTIONARY:
			_warn("skills.json entry \"%s\" is not an object; skipping." % skill_id)
			continue

		var skill: Dictionary = skills[skill_id_variant]
		_ensure_string_field(skill, "id", skill_id, "skills.json", skill_id)
		_ensure_string_field(skill, "hero_id", DEFAULT_HERO_ID, "skills.json", skill_id)
		_ensure_string_field(skill, "name", _display_name_from_id(skill_id), "skills.json", skill_id)
		_ensure_string_field(skill, "type", "active", "skills.json", skill_id)
		_ensure_number_field(skill, "cooldown", 0.0, "skills.json", skill_id)
		_ensure_number_field(skill, "damage", 0, "skills.json", skill_id)
		_ensure_string_field(skill, "effect", "none", "skills.json", skill_id)
		_ensure_string_field(skill, "description", "", "skills.json", skill_id)
		_ensure_number_field(skill, "unlock_level", 1, "skills.json", skill_id)
		if not ["passive", "active"].has(str(skill.get("type", ""))):
			_warn("skills.json entry \"%s\" invalid type; using active." % skill_id)
			skill["type"] = "active"
		if float(skill.get("cooldown", 0.0)) < 0.0:
			_warn("skills.json entry \"%s\" invalid cooldown; using 0." % skill_id)
			skill["cooldown"] = 0.0
		if int(skill.get("unlock_level", 1)) < 1:
			_warn("skills.json entry \"%s\" invalid unlock_level; using 1." % skill_id)
			skill["unlock_level"] = 1
		if not heroes.has(str(skill.get("hero_id", ""))):
			_warn("skills.json entry \"%s\" references unknown hero_id %s." % [skill_id, str(skill.get("hero_id", ""))])
		validated_skills[skill_id] = skill.duplicate(true)

	if validated_skills.is_empty():
		_warn("skills.json has no valid entries; using fallback data.")
		for fallback_skill in FALLBACK_SKILLS:
			var fallback_entry: Dictionary = fallback_skill
			validated_skills[str(fallback_entry.get("id", "skill_fallback"))] = fallback_entry.duplicate(true)
	skills = validated_skills

func _validate_guardians() -> void:
	for guardian_id_variant in guardians.keys():
		var guardian_id := str(guardian_id_variant)
		var defaults := _get_dictionary_default(FALLBACK_GUARDIANS, guardian_id, _default_guardian_entry(guardian_id))
		if typeof(guardians[guardian_id_variant]) != TYPE_DICTIONARY:
			_warn("guardians.json entry \"%s\" is not an object; using safe defaults." % guardian_id)
			guardians[guardian_id_variant] = defaults
			continue

		var guardian: Dictionary = guardians[guardian_id_variant]
		guardian["id"] = guardian_id
		_ensure_string_field(guardian, "display_name", str(defaults.get("display_name", _display_name_from_id(guardian_id))), "guardians.json", guardian_id)
		_ensure_string_field(guardian, "type", str(defaults.get("type", "support")), "guardians.json", guardian_id)
		_ensure_string_field(guardian, "role", str(defaults.get("role", "support")), "guardians.json", guardian_id)
		_ensure_number_field(guardian, "follow_distance", defaults.get("follow_distance", 2.0), "guardians.json", guardian_id)
		_ensure_number_field(guardian, "scan_interval", defaults.get("scan_interval", 0.25), "guardians.json", guardian_id)
		_ensure_array_field(guardian, "skills", defaults.get("skills", []), "guardians.json", guardian_id)
		_ensure_model_scene_path(guardian, "guardians.json", guardian_id, str(defaults.get("model_scene_path", FALLBACK_GUARDIANS["guard_shooter"]["model_scene_path"])))
		_ensure_string_field(guardian, "rarity", str(defaults.get("rarity", "common")), "guardians.json", guardian_id)
		_ensure_string_field(guardian, "unlock_condition", str(defaults.get("unlock_condition", "")), "guardians.json", guardian_id)
		_validate_guardian_skills(guardian, guardian_id)
		if float(guardian.get("scan_interval", 0.25)) <= 0.0:
			_warn("guardians.json entry \"%s\" invalid scan_interval; using 0.25." % guardian_id)
			guardian["scan_interval"] = 0.25
		if float(guardian.get("follow_distance", 2.0)) <= 0.0:
			_warn("guardians.json entry \"%s\" invalid follow_distance; using 2.0." % guardian_id)
			guardian["follow_distance"] = 2.0
		guardians[guardian_id_variant] = guardian

func _validate_guardian_skills(guardian: Dictionary, guardian_id: String) -> void:
	var validated_skills := []
	var skill_entries: Array = guardian.get("skills", [])
	for index in range(skill_entries.size()):
		var entry: Variant = skill_entries[index]
		if typeof(entry) != TYPE_DICTIONARY:
			_warn("guardians.json entry \"%s\" skill %d is not an object; skipping." % [guardian_id, index])
			continue
		var skill: Dictionary = entry
		_ensure_string_field(skill, "name", "Skill", "guardians.json", "%s.skill_%d" % [guardian_id, index])
		_ensure_number_field(skill, "cooldown", 1.0, "guardians.json", "%s.%s" % [guardian_id, str(skill.get("name", "skill"))])
		_ensure_number_field(skill, "damage", 0, "guardians.json", "%s.%s" % [guardian_id, str(skill.get("name", "skill"))])
		_ensure_number_field(skill, "range", 1.0, "guardians.json", "%s.%s" % [guardian_id, str(skill.get("name", "skill"))])
		_ensure_string_field(skill, "shape", "single_target", "guardians.json", "%s.%s" % [guardian_id, str(skill.get("name", "skill"))])
		_ensure_string_field(skill, "trigger_condition", "manual", "guardians.json", "%s.%s" % [guardian_id, str(skill.get("name", "skill"))])
		_ensure_string_field(skill, "effect", "none", "guardians.json", "%s.%s" % [guardian_id, str(skill.get("name", "skill"))])
		validated_skills.append(skill.duplicate(true))
	if validated_skills.is_empty():
		_warn("guardians.json entry \"%s\" has no valid skills; using Cover Fire fallback." % guardian_id)
		validated_skills.append(FALLBACK_GUARDIANS["guard_shooter"]["skills"][0].duplicate(true))
	guardian["skills"] = validated_skills

func _validate_pet_evolutions() -> void:
	for pet_id_variant in pet_evolutions.keys():
		var pet_id := str(pet_id_variant)
		var defaults := _get_dictionary_default(FALLBACK_PET_EVOLUTIONS, pet_id, _default_pet_evolution_entry(pet_id))
		if typeof(pet_evolutions[pet_id_variant]) != TYPE_DICTIONARY:
			_warn("pet_evolutions.json entry \"%s\" is not an object; using safe defaults." % pet_id)
			pet_evolutions[pet_id_variant] = defaults
			continue

		var evolution: Dictionary = pet_evolutions[pet_id_variant]
		evolution["pet_id"] = str(evolution.get("pet_id", pet_id))
		_ensure_string_field(evolution, "buff_type", str(defaults.get("buff_type", "damage_multiplier")), "pet_evolutions.json", pet_id)
		_ensure_number_field(evolution, "base_buff_value", defaults.get("base_buff_value", 0.0), "pet_evolutions.json", pet_id)
		_ensure_array_field(evolution, "stages", defaults.get("stages", []), "pet_evolutions.json", pet_id)
		_validate_pet_evolution_stages(evolution, pet_id)
		if not pets.has(str(evolution.get("pet_id", ""))):
			_warn("pet_evolutions.json entry \"%s\" references unknown pet_id %s." % [pet_id, str(evolution.get("pet_id", ""))])
		pet_evolutions[pet_id_variant] = evolution

func _validate_pet_accessories() -> void:
	for accessory_id_variant in pet_accessories.keys():
		var accessory_id := str(accessory_id_variant)
		var defaults := _get_dictionary_default(FALLBACK_PET_ACCESSORIES, accessory_id, _default_pet_accessory_entry(accessory_id))
		if typeof(pet_accessories[accessory_id_variant]) != TYPE_DICTIONARY:
			_warn("pet_accessories.json entry \"%s\" is not an object; using safe defaults." % accessory_id)
			pet_accessories[accessory_id_variant] = defaults
			continue
		var accessory: Dictionary = pet_accessories[accessory_id_variant]
		accessory["id"] = accessory_id
		_ensure_string_field(accessory, "display_name", str(defaults.get("display_name", _display_name_from_id(accessory_id))), "pet_accessories.json", accessory_id)
		_ensure_string_field(accessory, "pet_id", str(defaults.get("pet_id", "any")), "pet_accessories.json", accessory_id)
		_ensure_string_field(accessory, "modifier_type", str(defaults.get("modifier_type", "buff_multiplier_bonus")), "pet_accessories.json", accessory_id)
		_ensure_number_field(accessory, "modifier_value", defaults.get("modifier_value", 0.0), "pet_accessories.json", accessory_id)
		_ensure_string_field(accessory, "rarity", str(defaults.get("rarity", "common")), "pet_accessories.json", accessory_id)
		_ensure_string_field(accessory, "description", str(defaults.get("description", "")), "pet_accessories.json", accessory_id)
		pet_accessories[accessory_id_variant] = accessory

func _validate_pet_evolution_stages(evolution: Dictionary, pet_id: String) -> void:
	var validated_stages := []
	var stages: Array = evolution.get("stages", [])
	for index in range(stages.size()):
		var entry: Variant = stages[index]
		if typeof(entry) != TYPE_DICTIONARY:
			_warn("pet_evolutions.json entry \"%s\" stage %d is not an object; skipping." % [pet_id, index])
			continue
		var stage: Dictionary = entry
		_ensure_number_field(stage, "stage", index + 1, "pet_evolutions.json", "%s.stage_%d" % [pet_id, index + 1])
		_ensure_number_field(stage, "shard_cost", 0, "pet_evolutions.json", "%s.stage_%d" % [pet_id, index + 1])
		_ensure_number_field(stage, "buff_multiplier", 1.0, "pet_evolutions.json", "%s.stage_%d" % [pet_id, index + 1])
		_ensure_string_field(stage, "visual_change", "none", "pet_evolutions.json", "%s.stage_%d" % [pet_id, index + 1])
		if int(stage.get("stage", 1)) < 1:
			stage["stage"] = index + 1
		if int(stage.get("shard_cost", 0)) < 0:
			stage["shard_cost"] = 0
		if float(stage.get("buff_multiplier", 1.0)) <= 0.0:
			stage["buff_multiplier"] = 1.0
		validated_stages.append(stage.duplicate(true))
	if validated_stages.is_empty():
		validated_stages = _default_pet_evolution_entry(pet_id).get("stages", []).duplicate(true)
	evolution["stages"] = validated_stages

func _validate_upgrades() -> void:
	var validated_upgrades := []
	for index in range(upgrades.size()):
		var entry: Variant = upgrades[index]
		if typeof(entry) != TYPE_DICTIONARY:
			_warn("upgrades.json entry %d is not an object; skipping." % index)
			continue

		var upgrade: Dictionary = entry
		if not _has_required_string(upgrade, "id") or not _has_required_string(upgrade, "description"):
			_warn("upgrades.json entry %d is missing id or description; skipping." % index)
			continue
		var upgrade_id := str(upgrade.get("id", "upgrade_%d" % index))
		if not _has_required_string(upgrade, "name"):
			upgrade["name"] = str(upgrade.get("title", _display_name_from_id(upgrade_id)))
		if not _has_required_string(upgrade, "title"):
			upgrade["title"] = str(upgrade.get("name", _display_name_from_id(upgrade_id)))
		_ensure_string_field(upgrade, "tier", "common", "upgrades.json", upgrade_id)
		_ensure_string_field(upgrade, "effect_type", upgrade_id, "upgrades.json", upgrade_id)
		if not upgrade.has("effect_value"):
			_warn("upgrades.json entry \"%s\" missing effect_value; using 1." % upgrade_id)
			upgrade["effect_value"] = 1
		_ensure_optional_string_field(upgrade, "icon", "", "upgrades.json", upgrade_id)
		_ensure_number_field(upgrade, "weight", 1, "upgrades.json", upgrade_id)
		_ensure_number_field(upgrade, "max_stack", 1, "upgrades.json", upgrade_id)
		if int(upgrade.get("weight", 1)) < 1:
			_warn("upgrades.json entry \"%s\" invalid weight; using 1." % upgrade_id)
			upgrade["weight"] = 1
		if int(upgrade.get("max_stack", 1)) < 1:
			_warn("upgrades.json entry \"%s\" invalid max_stack; using 1." % upgrade_id)
			upgrade["max_stack"] = 1
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
	if skills.is_empty():
		_warn("skills.json missing valid skills; injecting fallback.")
		for fallback_skill in FALLBACK_SKILLS:
			var fallback_entry: Dictionary = fallback_skill
			skills[str(fallback_entry.get("id", "skill_fallback"))] = fallback_entry.duplicate(true)
	if guardians.is_empty():
		_warn("guardians.json missing valid guardians; injecting fallback.")
		guardians = FALLBACK_GUARDIANS.duplicate(true)
	if pet_evolutions.is_empty():
		_warn("pet_evolutions.json missing valid pet evolutions; injecting fallback.")
		pet_evolutions = FALLBACK_PET_EVOLUTIONS.duplicate(true)
	if pet_accessories.is_empty():
		_warn("pet_accessories.json missing valid pet accessories; injecting fallback.")
		pet_accessories = FALLBACK_PET_ACCESSORIES.duplicate(true)

func _ensure_string_field(entry: Dictionary, key: String, default_value: String, file_name: String, entry_id: String) -> void:
	if entry.has(key) and typeof(entry.get(key)) == TYPE_STRING and not str(entry.get(key)).strip_edges().is_empty():
		return

	_warn("%s entry \"%s\" %s %s; using default." % [file_name, entry_id, _field_issue(entry, key), key])
	entry[key] = default_value

func _ensure_optional_string_field(entry: Dictionary, key: String, default_value: String, file_name: String, entry_id: String) -> void:
	if entry.has(key) and typeof(entry.get(key)) == TYPE_STRING:
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

func _ensure_array_field(entry: Dictionary, key: String, default_value: Variant, file_name: String, entry_id: String) -> void:
	if entry.has(key) and typeof(entry.get(key)) == TYPE_ARRAY:
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
		"rarity": "common",
		"base_damage": 1,
		"upgrade_base_cost": 20,
		"special_effect": "none",
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
	}

func _default_guardian_entry(guardian_id: String) -> Dictionary:
	return {
		"display_name": _display_name_from_id(guardian_id),
		"type": "support",
		"role": "support",
		"follow_distance": 2.0,
		"scan_interval": 0.25,
		"skills": FALLBACK_GUARDIANS["guard_shooter"]["skills"].duplicate(true),
		"model_scene_path": str(FALLBACK_GUARDIANS["guard_shooter"]["model_scene_path"]),
		"rarity": "common",
		"unlock_condition": "",
	}

func _default_pet_evolution_entry(pet_id: String) -> Dictionary:
	return {
		"pet_id": pet_id,
		"buff_type": "damage_multiplier",
		"base_buff_value": 0.05,
		"stages": [
			{"stage": 1, "shard_cost": 0, "buff_multiplier": 1.0, "visual_change": "starter"},
			{"stage": 2, "shard_cost": 25, "buff_multiplier": 1.5, "visual_change": "stage_2"},
			{"stage": 3, "shard_cost": 60, "buff_multiplier": 2.0, "visual_change": "stage_3"},
		],
	}

func _default_pet_accessory_entry(accessory_id: String) -> Dictionary:
	return {
		"display_name": _display_name_from_id(accessory_id),
		"pet_id": "any",
		"modifier_type": "buff_multiplier_bonus",
		"modifier_value": 0.0,
		"rarity": "common",
		"description": "",
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
