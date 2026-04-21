extends Node3D
class_name FixedCameraRig

# Fixed-angle camera that follows the hero with a stable offset.

@export var target_path: NodePath = NodePath("../Player")
@export var follow_offset: Vector3 = Vector3(0.0, 10.0, 10.0)
@export var look_ahead: Vector3 = Vector3.ZERO
@export var follow_speed: float = 10.0

@onready var camera: Camera3D = $Camera3D

var _target: Node3D

func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_update_camera(1.0)

func _process(delta: float) -> void:
	_update_camera(delta)

func _update_camera(delta: float) -> void:
	if _target == null:
		return

	var desired_position := _target.global_position + follow_offset
	camera.global_position = camera.global_position.lerp(desired_position, min(delta * follow_speed, 1.0))
	camera.look_at(_target.global_position + look_ahead, Vector3.UP)
