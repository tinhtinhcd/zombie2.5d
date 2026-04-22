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
@export var enable_auto_fire: bool = false
@export var fire_interval: float = 0.6
@export var projectile_scene: PackedScene
@export var projectile_container_path: NodePath = NodePath("../ProjectileContainer")
@export var enemy_container_path: NodePath = NodePath("../EnemyContainer")
@export var max_hp: int = 10
@export var projectile_damage: int = 1
@export var projectile_speed: float = 14.0
@export var projectile_count: int = 1
@export var spread_angle_degrees: float = 0.0
@export var weapon_range: float = 20.0
@export var play_area_radius: float = 600.0
@export var damage_cooldown: float = 0.45
@export var visual_yaw_offset_degrees: float = 180.0
@export var idle_bob_amount: float = 0.035
@export var run_bob_amount: float = 0.08
@export var run_lean_amount: float = 0.12
@export var shoot_recoil_amount: float = 0.08
@export var shoot_recoil_roll_amount: float = 0.025
@export var shoot_recoil_duration: float = 0.16
@export var movement_animation_scene: PackedScene
@export var character_root_path: NodePath = NodePath("VisualRoot/Knight")
@export var idle_animation_name: String = "Walking_A"
@export var run_animation_name: String = "Running_A"

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var visual_root: Node3D = $VisualRoot
@onready var shoot_point: Marker3D = $ShootPoint

var character_root: Node3D
var current_hp: int = 0
var _plane_origin: Vector3 = Vector3.ZERO
var _plane_normal: Vector3 = Vector3.UP
var _fire_timer: float = 0.0
var _damage_cooldown_timer: float = 0.0
var _base_scale: Vector3 = Vector3.ONE
var _base_color: Color = Color(1.0, 1.0, 1.0, 1.0)
var _feedback_material: StandardMaterial3D
var _feedback_tween: Tween
var _visual_base_position: Vector3 = Vector3.ZERO
var _visual_anim_time: float = 0.0
var _shoot_recoil_timer: float = 0.0
var _animation_player: AnimationPlayer
var _current_animation: String = ""
var current_weapon_id: String = "weapon_basic"
var current_weapon_display_name: String = "Basic Gun"
var game_manager: GameManager

func _ready() -> void:
    game_manager = get_node("/root/GameManager") as GameManager
    current_hp = max(max_hp, 1)
    _base_scale = scale
    _plane_origin = global_position
    _plane_normal = movement_plane_normal.normalized()
    if _plane_normal == Vector3.ZERO:
        _plane_normal = Vector3.UP
    _constrain_to_plane()
    _fire_timer = max(fire_interval, 0.01)
    _visual_base_position = visual_root.position
    character_root = _resolve_character_root()
    _setup_character_animation_player()
    _setup_feedback_material()
    hp_changed.emit(current_hp)

func _physics_process(delta: float) -> void:
    _damage_cooldown_timer = max(_damage_cooldown_timer - delta, 0.0)
    _shoot_recoil_timer = max(_shoot_recoil_timer - delta, 0.0)
    if game_manager != null and not game_manager.is_gameplay_active:
        velocity = Vector3.ZERO
        return

    var input_vector := get_input_vector()
    var move_direction := _get_move_direction(input_vector)

    velocity = move_direction * move_speed
    velocity -= _plane_normal * velocity.dot(_plane_normal)

    move_and_slide()
    _constrain_to_plane()
    _face_combat_target_or_movement(move_direction)
    _animate_visual(delta, move_direction)

func get_input_vector() -> Vector2:
    # Abstracted input reading. Replace this with virtual joystick input
    # when adding mobile touch controls.
    return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func _process(delta: float) -> void:
    if not enable_auto_fire:
        return

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

    return (right_axis * input_vector.x + forward_axis * -input_vector.y).normalized()

func _project_to_plane(direction: Vector3) -> Vector3:
    var projected := direction - _plane_normal * direction.dot(_plane_normal)
    if projected.is_zero_approx():
        return Vector3.ZERO
    return projected.normalized()

func _constrain_to_plane() -> void:
    var distance_from_plane := _plane_normal.dot(global_position - _plane_origin)
    if is_zero_approx(distance_from_plane):
        _clamp_to_play_area()
        return
    global_position -= _plane_normal * distance_from_plane
    _clamp_to_play_area()

func _clamp_to_play_area() -> void:
    if play_area_radius <= 0.0:
        return

    global_position.x = clampf(global_position.x, -play_area_radius, play_area_radius)
    global_position.z = clampf(global_position.z, -play_area_radius, play_area_radius)

func spawn_projectile() -> void:
    if projectile_scene == null:
        return

    var target_enemy := _find_nearest_enemy()
    if target_enemy == null:
        return
    _face_direction(target_enemy.global_position - global_position)
    _trigger_shoot_feedback()

    var projectile_container := get_node_or_null(projectile_container_path) as Node3D
    if projectile_container == null:
        return

    var base_direction := target_enemy.global_position - shoot_point.global_position
    var shot_count := clampi(projectile_count, 1, 5)
    var angle_step := 0.0
    if shot_count > 1:
        angle_step = deg_to_rad(spread_angle_degrees) / float(shot_count - 1)
    var start_angle := -deg_to_rad(spread_angle_degrees) * 0.5

    for shot_index in range(shot_count):
        var projectile := projectile_scene.instantiate() as Projectile
        if projectile == null:
            continue
        projectile_container.add_child(projectile)
        projectile.global_transform = shoot_point.global_transform
        projectile.damage = projectile_damage
        projectile.speed = projectile_speed
        var shot_direction := base_direction
        if shot_count > 1:
            shot_direction = base_direction.rotated(_plane_normal, start_angle + angle_step * shot_index)
        projectile.setup(shot_direction, weapon_range)

func _face_combat_target_or_movement(move_direction: Vector3) -> void:
    var target_enemy := _find_nearest_enemy()
    if target_enemy != null:
        _face_direction(target_enemy.global_position - global_position)
        return

    if not move_direction.is_zero_approx():
        _face_direction(move_direction)

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

func increase_weapon_range(amount: float) -> void:
    weapon_range = max(weapon_range + max(amount, 0.0), 1.0)

func increase_projectile_count(amount: int) -> void:
    projectile_count = clampi(projectile_count + max(amount, 0), 1, 5)

func increase_max_hp(amount: int) -> void:
    var clamped_amount: int = max(amount, 0)
    max_hp += clamped_amount
    current_hp = min(current_hp + clamped_amount, max_hp)
    hp_changed.emit(current_hp)

func restore_hp(amount: int) -> void:
    current_hp = min(current_hp + max(amount, 0), max_hp)
    hp_changed.emit(current_hp)

func apply_weapon_definition(weapon_definition: Dictionary) -> void:
    current_weapon_id = str(weapon_definition.get("id", current_weapon_id))
    current_weapon_display_name = str(weapon_definition.get("display_name", weapon_definition.get("name", current_weapon_display_name)))
    fire_interval = float(weapon_definition.get("fire_rate", weapon_definition.get("fire_interval", fire_interval)))
    projectile_damage = int(weapon_definition.get("damage", weapon_definition.get("projectile_damage", projectile_damage)))
    projectile_speed = float(weapon_definition.get("projectile_speed", projectile_speed))
    projectile_count = clampi(int(weapon_definition.get("projectile_count", projectile_count)), 1, 5)
    spread_angle_degrees = max(float(weapon_definition.get("spread_angle", spread_angle_degrees)), 0.0)
    weapon_range = max(float(weapon_definition.get("range", weapon_range)), 1.0)
    enable_auto_fire = true

func receive_experience(amount: int) -> void:

    if game_manager != null:
        game_manager.add_xp(amount)

func _find_nearest_enemy(require_weapon_range: bool = true) -> Node3D:
    var enemy_container := get_node_or_null(enemy_container_path) as Node3D
    if enemy_container == null:
        return null

    var nearest_enemy: Node3D
    var nearest_distance := INF
    for child in enemy_container.get_children():
        if child is not Enemy:
            continue
        var enemy := child as Enemy
        var distance := global_position.distance_squared_to(enemy.global_position)
        if require_weapon_range and weapon_range > 0.0 and distance > weapon_range * weapon_range:
            continue
        if distance < nearest_distance:
            nearest_distance = distance
            nearest_enemy = enemy
    return nearest_enemy

func _face_direction(world_direction: Vector3) -> void:
    var facing_direction := _project_to_plane(world_direction)
    if facing_direction.is_zero_approx():
        return

    var yaw := atan2(-facing_direction.x, -facing_direction.z)
    visual_root.rotation.y = yaw + deg_to_rad(visual_yaw_offset_degrees)
    shoot_point.rotation.y = yaw

func _animate_visual(delta: float, move_direction: Vector3) -> void:
    _visual_anim_time += delta
    var is_moving := not move_direction.is_zero_approx()
    var bob_amount := run_bob_amount if is_moving else idle_bob_amount
    var bob_speed := 11.0 if is_moving else 3.0
    var bob := sin(_visual_anim_time * bob_speed) * bob_amount
    var recoil_weight := 0.0
    if shoot_recoil_duration > 0.0 and _shoot_recoil_timer > 0.0:
        recoil_weight = sin((_shoot_recoil_timer / shoot_recoil_duration) * PI)

    visual_root.position = _visual_base_position + Vector3(0.0, bob, 0.0)
    visual_root.rotation.x = sin(_visual_anim_time * bob_speed) * (run_lean_amount if is_moving else 0.025) - recoil_weight * shoot_recoil_amount
    visual_root.rotation.z = cos(_visual_anim_time * bob_speed * 0.5) * (run_lean_amount * 0.35 if is_moving else 0.018) + recoil_weight * shoot_recoil_roll_amount
    _play_character_animation(run_animation_name if is_moving else idle_animation_name, 1.25 if is_moving else 0.45)

func _trigger_shoot_feedback() -> void:
    _shoot_recoil_timer = max(shoot_recoil_duration, 0.0)

func _setup_character_animation_player() -> void:
    var source_scene := movement_animation_scene
    if source_scene == null:
        source_scene = load("res://assets/KayKit_Adventurers_2.0_FREE/KayKit_Adventurers_2.0_FREE/Animations/gltf/Rig_Medium/Rig_Medium_MovementBasic.glb") as PackedScene
    if source_scene == null or character_root == null:
        return

    var source_root := source_scene.instantiate()
    var source_player := source_root.get_node_or_null("AnimationPlayer") as AnimationPlayer
    if source_player == null:
        source_root.queue_free()
        return

    var library := AnimationLibrary.new()
    for animation_name in source_player.get_animation_list():
        var animation := source_player.get_animation(animation_name).duplicate(true) as Animation
        animation.loop_mode = Animation.LOOP_LINEAR
        library.add_animation(animation_name, animation)

    _animation_player = AnimationPlayer.new()
    _animation_player.name = "KayKitAnimationPlayer"
    _animation_player.root_node = NodePath("..")
    character_root.add_child(_animation_player)
    _animation_player.add_animation_library("", library)
    _animation_player.animation_finished.connect(_on_character_animation_finished)
    source_root.queue_free()
    _play_character_animation(idle_animation_name, 0.45)

func _resolve_character_root() -> Node3D:
    var configured_root := get_node_or_null(character_root_path) as Node3D
    if configured_root != null:
        return configured_root
    if visual_root != null:
        for child in visual_root.get_children():
            if child is Node3D:
                return child as Node3D
    return null

func _play_character_animation(animation_name: String, speed: float) -> void:
    if _animation_player == null:
        return
    if not _animation_player.has_animation(animation_name):
        animation_name = _get_first_available_animation([run_animation_name, idle_animation_name, "Jog_Fwd", "Sprint", "Walk", "Idle", "Running_A", "Walking_A", "Sword_Dash_RM", "Shield_Dash_RM", "Walk_Carry", "Idle_Shield", "A_TPose"])
    if animation_name.is_empty() or not _animation_player.has_animation(animation_name):
        return
    var animation := _animation_player.get_animation(animation_name)
    if animation != null:
        animation.loop_mode = Animation.LOOP_LINEAR
    if _current_animation != animation_name or not _animation_player.is_playing():
        _animation_player.play(animation_name, 0.12, speed)
        _current_animation = animation_name
    else:
        _animation_player.speed_scale = speed

func _get_first_available_animation(animation_names: Array[String]) -> String:
    if _animation_player == null:
        return ""
    for animation_name in animation_names:
        if _animation_player.has_animation(animation_name):
            return animation_name
    var available_names := _animation_player.get_animation_list()
    if available_names.is_empty():
        return ""
    return str(available_names[0])

func _on_character_animation_finished(animation_name: StringName) -> void:
    if _animation_player == null:
        return
    if _current_animation != String(animation_name):
        return
    _animation_player.play(_current_animation, 0.0, max(_animation_player.speed_scale, 0.01))

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
