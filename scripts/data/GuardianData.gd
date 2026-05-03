extends RefCounted
class_name GuardianData

var id: String = ""
var display_name: String = ""
var type: String = ""
var role: String = ""
var follow_distance: float = 2.0
var scan_interval: float = 0.25
var skills: Array = []
var model_scene_path: String = ""
var rarity: String = "common"
var unlock_condition: String = ""

func load_from_dictionary(data: Dictionary) -> void:
	id = str(data.get("id", ""))
	display_name = str(data.get("display_name", ""))
	type = str(data.get("type", ""))
	role = str(data.get("role", ""))
	follow_distance = float(data.get("follow_distance", 2.0))
	scan_interval = float(data.get("scan_interval", 0.25))
	skills = data.get("skills", []).duplicate(true) if typeof(data.get("skills", [])) == TYPE_ARRAY else []
	model_scene_path = str(data.get("model_scene_path", ""))
	rarity = str(data.get("rarity", "common"))
	unlock_condition = str(data.get("unlock_condition", ""))

func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"type": type,
		"role": role,
		"follow_distance": follow_distance,
		"scan_interval": scan_interval,
		"skills": skills.duplicate(true),
		"model_scene_path": model_scene_path,
		"rarity": rarity,
		"unlock_condition": unlock_condition,
	}
