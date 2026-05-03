extends RefCounted
class_name UpgradeData

var id: String = ""
var name: String = ""
var title: String = ""
var tier: String = "common"
var effect_type: String = ""
var effect_value: Variant
var description: String = ""
var icon: String = ""
var weight: int = 1
var max_stack: int = 1

func load_from_dictionary(data: Dictionary) -> void:
	id = str(data.get("id", ""))
	name = str(data.get("name", data.get("title", "")))
	title = str(data.get("title", data.get("name", "")))
	tier = str(data.get("tier", "common"))
	effect_type = str(data.get("effect_type", ""))
	effect_value = data.get("effect_value", null)
	description = str(data.get("description", ""))
	icon = str(data.get("icon", ""))
	weight = int(data.get("weight", 1))
	max_stack = int(data.get("max_stack", 1))

func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"title": title,
		"tier": tier,
		"effect_type": effect_type,
		"effect_value": effect_value,
		"description": description,
		"icon": icon,
		"weight": weight,
		"max_stack": max_stack,
	}
