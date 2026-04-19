extends CharacterBody3D
class_name Player

# Minimal 2.5D movement controller.
# Change `movement_plane_normal` to move on a different plane later.
# Set `use_camera_relative_input` to false if you want fixed world-axis movement.

signal hp_changed(current_hp_value: int)
signal died

@export var move_speed: float = 5.0
@export var movement_plane_normal: Vector3 = Vector3.UP
@export var use_camera_relative_input: bool = true
@export var fire_interval: float = 0.6
@export var projectile_scene: PackedScene
@export var projectile_container_path: NodePath = NodePath("../ProjectileContainer")
@export var max_hp: int = 10
@export var projectile_damage: int = 1
@export var damage_cooldown: float = 0.45

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var shoot_point: Marker3D = $ShootPoint

var current_hp: int = 0
var _plane_origin: Vector3 = Vector3.ZERO
var _plane_normal: Vector3 = Vector3.UP
var _fire_timer: float = 0.0
var _damage_cooldown_timer: float = 0.0
var _base_scale: Vector3 = Vector3.ONE
var _base_color: Color = Color(1.0, 1.0, 1.0, 1.0)
var _feedback_material: StandardMaterial3D
var _feedback_tween: Tween

func _ready() -> void:
    current_hp = max(max_hp, 1)
    _base_scale = scale
    _plane_origin = global_position
    _plane_normal = movement_plane_normal.normalized()
    if _plane_normal == Vector3.ZERO:
        _plane_normal = Vector3.UP
    _constrain_to_plane()
    _fire_timer = max(fire_interval, 0.01)
    _setup_feedback_material()
    hp_changed.emit(current_hp)

func _physics_process(delta: float) -> void:
    var game_manager := get_node_or_null("/root/GameManager") as GameManager
    _damage_cooldown_timer = max(_damage_cooldown_timer - delta, 0.0)
    if game_manager != null and not game_manager.is_gameplay_active:
        velocity = Vector3.ZERO
        return

    var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
    var move_direction := _get_move_direction(input_vector)

    velocity = move_direction * move_speed
    velocity -= _plane_normal * velocity.dot(_plane_normal)

    move_and_slide()
    _constrain_to_plane()

func _process(delta: float) -> void:
    var game_manager := get_node_or_null("/root/GameManager") as GameManager
    if game_manager != null and not game_manager.is_gameplay_active:
        return

    _fire_timer -= delta
    if _fire_timer > 0.0:
        return

    spawn_projectile()
    _fire_timer = max(fire_interval, 0.01)

func _get_move_direction(input_vector: Vector2) -> Vector3:
    if input_vector.is_zero_approx():
        return Vector3.ZERO

    var right_axis := Vector3.RIGHT
    var forward_axis := Vector3.FORWARD

    if use_camera_relative_input:
        var active_camera := get_viewport().get_camera_3d()
        if active_camera != null:
            right_axis = active_camera.global_transform.basis.x
            forward_axis = -active_camera.global_transform.basis.z

    right_axis = _project_to_plane(right_axis)
    forward_axis = _project_to_plane(forward_axis)

    if right_axis == Vector3.ZERO or forward_axis == Vector3.ZERO:
        return Vector3.ZERO

    return (right_axis * input_vector.x + forward_axis * input_vector.y).normalized()

func _project_to_plane(direction: Vector3) -> Vector3:
    var projected := direction - _plane_normal * direction.dot(_plane_normal)
    if projected.is_zero_approx():
        return Vector3.ZERO
    return projected.normalized()

func _constrain_to_plane() -> void:
    var distance_from_plane := _plane_normal.dot(global_position - _plane_origin)
    if is_zero_approx(distance_from_plane):
        return
    global_position -= _plane_normal * distance_from_plane

func spawn_projectile() -> void:
    if projectile_scene == null:
        return

    var projectile := projectile_scene.instantiate() as Projectile
    var projectile_container := get_node_or_null(projectile_container_path) as Node3D
    if projectile == null or projectile_container == null:
        return

    projectile_container.add_child(projectile)
    projectile.global_transform = shoot_point.global_transform
    projectile.damage = projectile_damage
    projectile.setup(-shoot_point.global_transform.basis.z)

func take_damage(amount: int) -> void:
    if current_hp <= 0:
        return
    if _damage_cooldown_timer > 0.0:
        return

    _damage_cooldown_timer = damage_cooldown
    current_hp -= max(amount, 0)
    current_hp = max(current_hp, 0)
    _play_damage_feedback()
    hp_changed.emit(current_hp)

    if current_hp == 0:
        died.emit()

func increase_projectile_damage(amount: int) -> void:
    projectile_damage += max(amount, 0)

func reduce_fire_interval(amount: float) -> void:
    fire_interval = max(fire_interval - max(amount, 0.0), 0.12)

func increase_max_hp(amount: int) -> void:
    var clamped_amount: int = max(amount, 0)
    max_hp += clamped_amount
    current_hp = min(current_hp + clamped_amount, max_hp)
    hp_changed.emit(current_hp)

func restore_hp(amount: int) -> void:
    current_hp = min(current_hp + max(amount, 0), max_hp)
    hp_changed.emit(current_hp)

func receive_experience(amount: int) -> void:
    var game_manager := get_node_or_null("/root/GameManager") as GameManager
    if game_manager != null:
        game_manager.add_xp(amount)

func _setup_feedback_material() -> void:
    if mesh_instance == null:
        return

    var source_material := mesh_instance.material_override as StandardMaterial3D
    if source_material == null:
        source_material = StandardMaterial3D.new()
    else:
        source_material = source_material.duplicate(true) as StandardMaterial3D

    source_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mesh_instance.material_override = source_material
    _feedback_material = source_material
    _base_color = _feedback_material.albedo_color

func _play_damage_feedback() -> void:
    if _feedback_tween != null:
        _feedback_tween.kill()

    _feedback_tween = create_tween()
    _feedback_tween.set_parallel(true)
    _feedback_tween.tween_method(_set_damage_flash, 1.0, 0.0, 0.14)
    _feedback_tween.tween_property(self, "scale", _base_scale * 0.94, 0.07)
    _feedback_tween.chain().tween_property(self, "scale", _base_scale, 0.07)

func _set_damage_flash(strength: float) -> void:
    if _feedback_material == null:
        return
    _feedback_material.albedo_color = _base_color.lerp(Color(1.0, 0.35, 0.35, 1.0), strength)
