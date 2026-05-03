extends Node3D
class_name FixedCameraRig

# Fixed-angle camera that follows the hero with a stable offset.

@export var target_path: NodePath = NodePath("../Player")
@export var follow_offset: Vector3 = Vector3(0.0, 10.0, 10.0)
@export var look_ahead: Vector3 = Vector3.ZERO
@export var follow_speed: float = 10.0
@export var shake_decay_speed: float = 16.0

@onready var camera: Camera3D = $Camera3D

var _target: Node3D
var _shake_timer: float = 0.0
var _shake_duration: float = 0.0
var _shake_amount: float = 0.0
<<<<<<< ours
=======
var _shake_base_amount: float = 0.0
>>>>>>> theirs

func _ready() -> void:
	add_to_group("camera_rigs")
	_target = get_node_or_null(target_path) as Node3D
	_update_camera(1.0)

func _process(delta: float) -> void:
	_update_shake(delta)
	_update_camera(delta)

func _update_camera(delta: float) -> void:
	if _target == null:
		return

	var desired_position := _target.global_position + follow_offset
	if _shake_amount > 0.0:
		desired_position += Vector3(
			randf_range(-_shake_amount, _shake_amount),
			randf_range(-_shake_amount, _shake_amount),
			randf_range(-_shake_amount, _shake_amount)
		)
	camera.global_position = camera.global_position.lerp(desired_position, min(delta * follow_speed, 1.0))
	if _shake_timer > 0.0:
		_shake_timer = max(_shake_timer - delta, 0.0)
		var strength: float = _shake_amount * (_shake_timer / max(_shake_duration, 0.01))
		camera.global_position += Vector3(
			sin(Time.get_ticks_msec() * 0.047) * strength,
			cos(Time.get_ticks_msec() * 0.061) * strength * 0.45,
			sin(Time.get_ticks_msec() * 0.073) * strength
		)
	camera.look_at(_target.global_position + look_ahead, Vector3.UP)

<<<<<<< ours
func shake(amount: float = 0.12, duration: float = 0.12) -> void:
	_shake_amount = max(_shake_amount, max(amount, 0.0))
	_shake_duration = max(duration, 0.01)
	_shake_timer = max(_shake_timer, _shake_duration)
=======
func trigger_shake(amount: float, duration: float) -> void:
	_shake_base_amount = maxf(amount, 0.0)
	_shake_amount = _shake_base_amount
	_shake_duration = maxf(duration, 0.0)
	_shake_timer = _shake_duration

func _update_shake(delta: float) -> void:
	if _shake_timer <= 0.0:
		if _shake_amount != 0.0:
			_shake_amount = 0.0
		return
	_shake_timer = maxf(_shake_timer - delta, 0.0)
	if _shake_duration > 0.0:
		var alpha := clampf(_shake_timer / _shake_duration, 0.0, 1.0)
		_shake_amount = lerpf(0.0, _shake_base_amount, alpha)
	if _shake_timer <= 0.0:
		_shake_amount = 0.0
		_shake_base_amount = 0.0
>>>>>>> theirs
