extends CharacterBody3D
class_name Enemy

# Minimal chase movement for the 2.5D setup.
# Change `movement_plane_normal` later if enemies should move on a different plane.

const TYPE_STATS := {
    "normal": {"max_hp": 3, "move_speed": 2.8},
    "fast": {"max_hp": 2, "move_speed": 4.1},
    "tank": {"max_hp": 6, "move_speed": 1.8},
    "boss": {"max_hp": 18, "move_speed": 2.0, "contact_damage": 2, "visual_scale": Vector3(1.8, 1.8, 1.8)},
}

@export var enemy_type: StringName = &"normal"
@export var move_speed: float = 2.8
@export var movement_plane_normal: Vector3 = Vector3.UP
@export var max_hp: int = 3
@export var contact_damage: int = 1
@export var contact_damage_interval: float = 0.8
@export var contact_range: float = 0.9
@export var xp_pickup_scene: PackedScene
@export var pickup_container_path: NodePath = NodePath("../../PickupContainer")
@export var xp_drop_amount: int = 1

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var target: Node3D
var current_hp: int = 0
var _plane_origin: Vector3 = Vector3.ZERO
var _plane_normal: Vector3 = Vector3.UP
var _is_dead: bool = false
var _contact_damage_cooldown: float = 0.0
var _base_scale: Vector3 = Vector3.ONE
var _base_color: Color = Color(1.0, 1.0, 1.0, 1.0)
var _feedback_material: StandardMaterial3D
var _feedback_tween: Tween
var _death_tween: Tween

func _ready() -> void:
    apply_enemy_type(enemy_type)
    _base_scale = scale
    _plane_origin = global_position
    _plane_normal = movement_plane_normal.normalized()
    if _plane_normal == Vector3.ZERO:
        _plane_normal = Vector3.UP
    current_hp = max(max_hp, 1)
    _setup_feedback_material()
    _constrain_to_plane()

func _physics_process(delta: float) -> void:
    var game_manager := get_node_or_null("/root/GameManager") as GameManager
    if game_manager != null and not game_manager.is_gameplay_active:
        velocity = Vector3.ZERO
        return

    var move_direction := _get_move_direction_to_target()
    velocity = move_direction * move_speed
    velocity -= _plane_normal * velocity.dot(_plane_normal)

    move_and_slide()
    _constrain_to_plane()

    _contact_damage_cooldown = max(_contact_damage_cooldown - delta, 0.0)
    _try_damage_player()

func set_target(new_target: Node3D) -> void:
    target = new_target

func apply_enemy_type(type_key: StringName) -> void:
    enemy_type = type_key

    var stats: Dictionary = TYPE_STATS.get(String(type_key), TYPE_STATS["normal"])
    max_hp = int(stats.get("max_hp", max_hp))
    move_speed = float(stats.get("move_speed", move_speed))
    contact_damage = int(stats.get("contact_damage", contact_damage))
    scale = stats.get("visual_scale", Vector3.ONE)
    current_hp = max(max_hp, 1)

func take_damage(amount: int) -> void:
    if _is_dead:
        return

    current_hp -= max(amount, 0)
    _play_hit_feedback()
    if current_hp <= 0:
        die()

func die() -> void:
    if _is_dead:
        return

    _is_dead = true
    set_physics_process(false)
    velocity = Vector3.ZERO
    if collision_shape != null:
        collision_shape.disabled = true
    var game_manager := get_node_or_null("/root/GameManager") as GameManager
    if game_manager != null:
        game_manager.add_score(1)
    _spawn_xp_pickup()
    _play_death_feedback()

func _get_move_direction_to_target() -> Vector3:
    if target == null or not is_instance_valid(target):
        return Vector3.ZERO

    var target_offset := target.global_position - global_position
    var projected_offset := target_offset - _plane_normal * target_offset.dot(_plane_normal)
    if projected_offset.is_zero_approx():
        return Vector3.ZERO

    return projected_offset.normalized()

func _constrain_to_plane() -> void:
    var distance_from_plane := _plane_normal.dot(global_position - _plane_origin)
    if is_zero_approx(distance_from_plane):
        return
    global_position -= _plane_normal * distance_from_plane

func _try_damage_player() -> void:
    if _contact_damage_cooldown > 0.0:
        return
    if target is not Player:
        return
    if global_position.distance_to(target.global_position) > contact_range:
        return

    target.take_damage(contact_damage)
    _contact_damage_cooldown = contact_damage_interval

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

func _play_hit_feedback() -> void:
    if _is_dead:
        return
    if _feedback_tween != null:
        _feedback_tween.kill()

    _feedback_tween = create_tween()
    _feedback_tween.set_parallel(true)
    _feedback_tween.tween_method(_set_hit_flash, 1.0, 0.0, 0.12)
    _feedback_tween.tween_property(self, "scale", _base_scale * 1.08, 0.06)
    _feedback_tween.chain().tween_property(self, "scale", _base_scale, 0.06)

func _play_death_feedback() -> void:
    if _feedback_tween != null:
        _feedback_tween.kill()
    if _death_tween != null:
        _death_tween.kill()

    _death_tween = create_tween()
    _death_tween.set_parallel(true)
    _death_tween.tween_method(_set_death_fade, 0.0, 1.0, 0.18)
    _death_tween.tween_property(self, "scale", _base_scale * 0.15, 0.18)
    _death_tween.chain().tween_callback(queue_free)

func _set_hit_flash(strength: float) -> void:
    if _feedback_material == null:
        return
    _feedback_material.albedo_color = _base_color.lerp(Color(1.0, 0.25, 0.25, 1.0), strength)

func _set_death_fade(progress: float) -> void:
    if _feedback_material == null:
        return

    var death_color := Color(1.0, 0.3, 0.3, 1.0 - progress)
    _feedback_material.albedo_color = _base_color.lerp(death_color, progress)

func _spawn_xp_pickup() -> void:
    if xp_pickup_scene == null:
        return

    var pickup_container := get_node_or_null(pickup_container_path) as Node3D
    var xp_pickup := xp_pickup_scene.instantiate() as XPPickup
    if pickup_container == null or xp_pickup == null:
        return

    pickup_container.add_child(xp_pickup)
    xp_pickup.global_position = global_position
    xp_pickup.xp_amount = xp_drop_amount
