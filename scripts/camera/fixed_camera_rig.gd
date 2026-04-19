extends Node3D
class_name FixedCameraRig

@export_range(-180.0, 180.0, 0.1, "degrees") var angle: float = -40.0
@export_range(0.1, 100.0, 0.1) var distance: float = 14.0
@export_range(0.0, 100.0, 0.1) var height: float = 8.0
@export var follow_target: Node3D

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
    _update_camera()

func _process(_delta: float) -> void:
    if follow_target != null:
        global_position = follow_target.global_position
    _update_camera()

func _update_camera() -> void:
    if not is_node_ready():
        return

    var radians := deg_to_rad(angle)
    var offset := Vector3(sin(radians) * distance, height, cos(radians) * distance)
    camera.position = offset
    camera.look_at(global_position, Vector3.UP)
