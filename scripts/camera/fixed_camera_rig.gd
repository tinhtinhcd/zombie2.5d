extends Node3D
class_name FixedCameraRig

# Fixed isometric-style camera rig for 2.5D gameplay.
# The rig follows a target node each frame while keeping a constant
# viewing angle, distance, and height. The offset is precomputed once
# to avoid redundant trig every frame.

@export_range(-180.0, 180.0, 0.1, "degrees") var angle: float = -40.0
@export_range(0.1, 100.0, 0.1) var distance: float = 14.0
@export_range(0.0, 100.0, 0.1) var height: float = 8.0
@export var follow_target: Node3D

@onready var camera: Camera3D = $Camera3D

var _camera_offset: Vector3 = Vector3.ZERO

func _ready() -> void:
    _recompute_offset()

func _process(_delta: float) -> void:
    # Follow the target each frame, then point the camera at the rig origin.
    if follow_target != null:
        global_position = follow_target.global_position
    camera.position = _camera_offset
    camera.look_at(global_position, Vector3.UP)

func _recompute_offset() -> void:
    # Recalculate the camera offset from angle/distance/height exports.
    # Call this again at runtime if you change those values dynamically.
    var radians := deg_to_rad(angle)
    _camera_offset = Vector3(sin(radians) * distance, height, cos(radians) * distance)
    if is_node_ready():
        camera.position = _camera_offset
        camera.look_at(global_position, Vector3.UP)
