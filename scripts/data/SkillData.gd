extends RefCounted
class_name SkillData

var id: String = ""
var hero_id: String = ""
var name: String = ""
var type: String = "active"
var cooldown: float = 0.0
var damage: int = 0
var effect: String = ""
var description: String = ""
var unlock_level: int = 1

func load_from_dictionary(data: Dictionary) -> void:
	id = str(data.get("id", ""))
	hero_id = str(data.get("hero_id", ""))
	name = str(data.get("name", ""))
	type = str(data.get("type", "active"))
	cooldown = float(data.get("cooldown", 0.0))
	damage = int(data.get("damage", 0))
	effect = str(data.get("effect", ""))
	description = str(data.get("description", ""))
	unlock_level = int(data.get("unlock_level", 1))

func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"hero_id": hero_id,
		"name": name,
		"type": type,
		"cooldown": cooldown,
		"damage": damage,
		"effect": effect,
		"description": description,
		"unlock_level": unlock_level,
	}
