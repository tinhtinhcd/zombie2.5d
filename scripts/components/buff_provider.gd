extends Node
class_name BuffProvider

var pet_id: String = ""
var game_manager: GameManager
var buff_type: String = ""
var base_buff_value: float = 0.0
var stages: Array = []

func setup(new_pet_id: String, manager: GameManager) -> void:
	pet_id = new_pet_id
	game_manager = manager
	_load_evolution_data()

func get_active_buffs() -> Dictionary:
	if game_manager == null or pet_id.is_empty():
		return {}
	var stage := game_manager.get_pet_evolution_stage(pet_id)
	var stage_data := _get_stage_data(stage)
	var multiplier := float(stage_data.get("buff_multiplier", 1.0)) + game_manager.get_pet_accessory_bonus(pet_id)
	return {
		buff_type: base_buff_value * multiplier,
		"pet_id": pet_id,
		"stage": stage,
		"visual_change": str(stage_data.get("visual_change", "")),
	}

func get_next_stage_cost() -> int:
	if game_manager == null:
		return 0
	var next_stage := game_manager.get_pet_evolution_stage(pet_id) + 1
	var stage_data := _get_stage_data(next_stage)
	return int(stage_data.get("shard_cost", 0))

func _load_evolution_data() -> void:
	buff_type = ""
	base_buff_value = 0.0
	stages.clear()
	if game_manager == null:
		return
	var evolution := game_manager.get_pet_evolution(pet_id)
	buff_type = str(evolution.get("buff_type", ""))
	base_buff_value = float(evolution.get("base_buff_value", 0.0))
	var stages_value: Variant = evolution.get("stages", [])
	if typeof(stages_value) == TYPE_ARRAY:
		stages = stages_value.duplicate(true)

func _get_stage_data(stage: int) -> Dictionary:
	for entry in stages:
		if typeof(entry) == TYPE_DICTIONARY and int((entry as Dictionary).get("stage", 0)) == stage:
			return (entry as Dictionary).duplicate(true)
	return stages[0].duplicate(true) if not stages.is_empty() and typeof(stages[0]) == TYPE_DICTIONARY else {}
