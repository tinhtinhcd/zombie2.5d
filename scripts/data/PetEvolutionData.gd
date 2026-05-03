extends RefCounted
class_name PetEvolutionData

var pet_id: String = ""
var buff_type: String = ""
var base_buff_value: float = 0.0
var stages: Array = []

func load_from_dictionary(data: Dictionary) -> void:
	pet_id = str(data.get("pet_id", ""))
	buff_type = str(data.get("buff_type", ""))
	base_buff_value = float(data.get("base_buff_value", 0.0))
	stages = data.get("stages", []).duplicate(true) if typeof(data.get("stages", [])) == TYPE_ARRAY else []

func to_dictionary() -> Dictionary:
	return {
		"pet_id": pet_id,
		"buff_type": buff_type,
		"base_buff_value": base_buff_value,
		"stages": stages.duplicate(true),
	}
