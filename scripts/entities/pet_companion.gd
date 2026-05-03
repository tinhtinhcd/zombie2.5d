extends Node3D
class_name PetCompanion

const BUFF_PROVIDER_SCRIPT := preload("res://scripts/components/buff_provider.gd")

@export var target_path: NodePath = NodePath("../Player")
@export var follow_offset: Vector3 = Vector3(-1.2, 0.7, 0.8)
@export var follow_speed: float = 8.0

var _target: Node3D
var pet_id: String = "pet_drone"
var buff_provider: Node
var game_manager: GameManager

func _ready() -> void:
	game_manager = get_node("/root/GameManager") as GameManager
	_target = get_node_or_null(target_path) as Node3D
	_setup_buff_provider()

func _process(delta: float) -> void:
	if _target != null:
		var desired_position := _target.global_position + follow_offset
		global_position = global_position.lerp(desired_position, min(delta * follow_speed, 1.0))

func apply_pet_definition(definition: Dictionary) -> void:
	pet_id = str(definition.get("id", pet_id))
	_setup_buff_provider()
	if buff_provider != null:
		buff_provider.call("setup", pet_id, game_manager)

func get_active_buffs() -> Dictionary:
	if buff_provider == null:
		return {}
	return buff_provider.call("get_active_buffs")

func _setup_buff_provider() -> void:
	buff_provider = get_node_or_null("BuffProvider")
	if buff_provider == null:
		buff_provider = Node.new()
		buff_provider.set_script(BUFF_PROVIDER_SCRIPT)
		buff_provider.name = "BuffProvider"
		add_child(buff_provider)
