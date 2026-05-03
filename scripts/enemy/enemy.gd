extends CharacterBody3D
class_name Enemy

# Minimal chase movement for the 2.5D setup.
# Change `movement_plane_normal` later if enemies should move on a different plane.

const TYPE_STATS := {
	"normal": {"max_hp": 3, "move_speed": 2.8, "color": Color(0.55, 0.9, 0.55, 1.0)},
	"fast": {"max_hp": 2, "move_speed": 4.1, "color": Color(0.4, 0.75, 1.0, 1.0)},
	"tank": {"max_hp": 6, "move_speed": 1.8, "color": Color(0.9, 0.7, 0.35, 1.0)},
	"boss": {"max_hp": 18, "move_speed": 2.0, "contact_damage": 2, "visual_scale": Vector3(1.8, 1.8, 1.8), "color": Color(1.0, 0.35, 0.35, 1.0)},
}
const SHOCKWAVE_SCENE := preload("res://scenes/effects/shockwave.tscn")

@export var enemy_type: StringName = &"normal"
@export var move_speed: float = 2.8
@export var movement_plane_normal: Vector3 = Vector3.UP
@export var max_hp: int = 3
@export var contact_damage: int = 1
@export var contact_damage_interval: float = 0.8
@export var contact_range: float = 0.9
@export var spawn_warmup_duration: float = 0.35
@export var xp_pickup_scene: PackedScene
@export var pickup_container_path: NodePath = NodePath("../../PickupContainer")
@export var effect_container_path: NodePath = NodePath("../EffectContainer")
@export var xp_drop_amount: int = 1
@export var move_bob_amount: float = 0.055
@export var movement_animation_scene: PackedScene

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var visual_root: Node3D = $VisualRoot
@onready var character_root: Node3D = $VisualRoot/SkeletonMinion

var target: Node3D
var current_hp: int = 0
var _plane_origin: Vector3 = Vector3.ZERO
var _plane_normal: Vector3 = Vector3.UP
var _is_dead: bool = false
var _contact_damage_cooldown: float = 0.0
var _spawn_warmup_timer: float = 0.0
var _base_scale: Vector3 = Vector3.ONE
var _base_color: Color = Color(1.0, 1.0, 1.0, 1.0)
var _feedback_material: StandardMaterial3D
var _feedback_materials: Array[StandardMaterial3D] = []
var _base_colors: Array[Color] = []
var _feedback_tween: Tween
var _death_tween: Tween
var _visual_base_position: Vector3 = Vector3.ZERO
var _visual_anim_time: float = 0.0
var _knockback_velocity: Vector3 = Vector3.ZERO
var _animation_player: AnimationPlayer
var _current_animation: String = ""
var game_manager: GameManager

func _ready() -> void:
	game_manager = get_node("/root/GameManager") as GameManager
	add_to_group("enemies")
	apply_enemy_type(enemy_type)
	_base_scale = scale
	_plane_origin = global_position
	_plane_normal = movement_plane_normal.normalized()
	if _plane_normal == Vector3.ZERO:
		_plane_normal = Vector3.UP
	current_hp = max(max_hp, 1)
	_visual_base_position = visual_root.position
	_setup_character_animation_player()
	_setup_feedback_material()
	_apply_type_visual()
	_constrain_to_plane()
	if enemy_type == &"boss" and game_manager != null:
		game_manager.update_boss_health(current_hp, max_hp, true)

func _physics_process(delta: float) -> void:
	# Freeze movement when gameplay is paused, game over, or upgrade selection is active.
	if game_manager != null and not game_manager.is_gameplay_active:
		velocity = Vector3.ZERO
		return

	if _spawn_warmup_timer > 0.0:
		_spawn_warmup_timer = max(_spawn_warmup_timer - delta, 0.0)
		velocity = Vector3.ZERO
		_animate_visual(delta, false)
		return

	var move_direction := _get_move_direction_to_target()
	_knockback_velocity = _knockback_velocity.move_toward(Vector3.ZERO, delta * 14.0)
	velocity = move_direction * move_speed + _knockback_velocity
	velocity -= _plane_normal * velocity.dot(_plane_normal)

	move_and_slide()
	_constrain_to_plane()
	_face_direction(move_direction)
	_animate_visual(delta, not move_direction.is_zero_approx())

	# Tick down contact-damage cooldown so the player isn't hurt every frame.
	_contact_damage_cooldown = max(_contact_damage_cooldown - delta, 0.0)
	_try_damage_player()

func set_target(new_target: Node3D) -> void:
	target = new_target

func prepare_spawn(new_target: Node3D) -> void:
	target = new_target
	_spawn_warmup_timer = max(spawn_warmup_duration, 0.0)
	_contact_damage_cooldown = max(_contact_damage_cooldown, spawn_warmup_duration)

func apply_enemy_type(type_key: StringName) -> void:
	enemy_type = type_key

	var type_string := String(type_key)
	var stats: Dictionary
	if TYPE_STATS.has(type_string):
		stats = TYPE_STATS[type_string]
	else:
		push_warning("Enemy.apply_enemy_type received unknown enemy_type '%s'; falling back to 'normal'." % type_string)
		stats = TYPE_STATS["normal"]
	max_hp = int(stats.get("max_hp", max_hp))
	move_speed = float(stats.get("move_speed", move_speed))
	contact_damage = int(stats.get("contact_damage", contact_damage))
	scale = stats.get("visual_scale", Vector3.ONE)
	current_hp = max(max_hp, 1)

func apply_health_multiplier(multiplier: float) -> void:
	var resolved_multiplier := maxf(multiplier, 0.1)
	max_hp = max(roundi(float(max_hp) * resolved_multiplier), 1)
	current_hp = max_hp
	if enemy_type == &"boss" and game_manager != null:
		game_manager.update_boss_health(current_hp, max_hp, true)

func take_damage(amount: int, hit_position: Vector3 = Vector3.ZERO, hit_direction: Vector3 = Vector3.ZERO, knockback_strength: float = 0.0) -> void:
	if _is_dead:
		return

	current_hp -= max(amount, 0)
	_apply_knockback(hit_position, hit_direction, knockback_strength)
	_play_hit_feedback()
	if enemy_type == &"boss" and game_manager != null:
		game_manager.update_boss_health(current_hp, max_hp, true)
	if current_hp <= 0:
		die()

func die() -> void:
	if _is_dead:
		return

	_is_dead = true
	set_physics_process(false)
	velocity = Vector3.ZERO
	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)

	if game_manager != null:
		game_manager.add_score(1)
		if enemy_type == &"boss":
			game_manager.update_boss_health(0, max_hp, false)
	_spawn_xp_pickup()
	_spawn_death_effect()
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

func _face_direction(world_direction: Vector3) -> void:
	if visual_root == null or world_direction.is_zero_approx():
		return

	var facing_direction := world_direction - _plane_normal * world_direction.dot(_plane_normal)
	if facing_direction.is_zero_approx():
		return

	visual_root.rotation.y = atan2(-facing_direction.x, -facing_direction.z) + PI

func _animate_visual(delta: float, is_moving: bool) -> void:
	if visual_root == null:
		return

	_visual_anim_time += delta
	var bob_speed := 9.0 if is_moving else 2.5
	var bob_amount := move_bob_amount if is_moving else move_bob_amount * 0.35
	var bob := sin(_visual_anim_time * bob_speed) * bob_amount

	visual_root.position = _visual_base_position + Vector3(0.0, bob, 0.0)
	visual_root.rotation.x = sin(_visual_anim_time * bob_speed) * (0.08 if is_moving else 0.02)
	_play_character_animation("Walking_A" if is_moving else "Walking_B", 0.85 if is_moving else 0.35)

func _setup_character_animation_player() -> void:
	var source_scene := movement_animation_scene
	if source_scene == null:
		source_scene = load("res://assets/KayKit_Skeletons_1.1_FREE/KayKit_Skeletons_1.1_FREE/Animations/gltf/Rig_Medium/Rig_Medium_MovementBasic.glb") as PackedScene
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
	_play_character_animation("Walking_B", 0.35)

func _play_character_animation(animation_name: String, speed: float) -> void:
	if _animation_player == null or not _animation_player.has_animation(animation_name):
		return
	var animation := _animation_player.get_animation(animation_name)
	if animation != null:
		animation.loop_mode = Animation.LOOP_LINEAR
	if _current_animation != animation_name or not _animation_player.is_playing():
		_animation_player.play(animation_name, 0.12, speed)
		_current_animation = animation_name
	else:
		_animation_player.speed_scale = speed

func _on_character_animation_finished(animation_name: StringName) -> void:
	if _animation_player == null:
		return
	if _current_animation != String(animation_name):
		return
	_animation_player.play(_current_animation, 0.0, max(_animation_player.speed_scale, 0.01))

func _setup_feedback_material() -> void:
	_feedback_materials.clear()
	_base_colors.clear()
	_collect_feedback_materials(visual_root)
	if _feedback_materials.is_empty() and mesh_instance != null:
		_prepare_feedback_material(mesh_instance)
	if not _feedback_materials.is_empty():
		_feedback_material = _feedback_materials[0]
		_base_color = _base_colors[0]

func _apply_type_visual() -> void:
	if _feedback_materials.is_empty():
		return
	var stats: Dictionary = TYPE_STATS.get(String(enemy_type), TYPE_STATS["normal"])
	var type_color: Color = stats.get("color", _base_color)
	for index in range(_feedback_materials.size()):
		_feedback_materials[index].albedo_color = type_color
		_base_colors[index] = type_color
	_base_color = type_color

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
	if _feedback_materials.is_empty():
		return
	for index in range(_feedback_materials.size()):
		_feedback_materials[index].albedo_color = _base_colors[index].lerp(Color(1.0, 0.25, 0.25, 1.0), strength)

func _set_death_fade(progress: float) -> void:
	if _feedback_materials.is_empty():
		return

	var death_color := Color(1.0, 0.3, 0.3, 1.0 - progress)
	for index in range(_feedback_materials.size()):
		_feedback_materials[index].albedo_color = _base_colors[index].lerp(death_color, progress)

func _collect_feedback_materials(node: Node) -> void:
	if node == null:
		return
	if node is MeshInstance3D:
		_prepare_feedback_material(node as MeshInstance3D)
	for child in node.get_children():
		_collect_feedback_materials(child)

func _prepare_feedback_material(mesh: MeshInstance3D) -> void:
	var material := mesh.material_override as StandardMaterial3D
	if material == null:
		var active_material := mesh.get_active_material(0)
		if active_material is StandardMaterial3D:
			material = (active_material as StandardMaterial3D).duplicate(true) as StandardMaterial3D
		else:
			material = StandardMaterial3D.new()
	else:
		material = material.duplicate(true) as StandardMaterial3D
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material_override = material
	_feedback_materials.append(material)
	_base_colors.append(material.albedo_color)

func _apply_knockback(hit_position: Vector3, hit_direction: Vector3, knockback_strength: float) -> void:
	if knockback_strength <= 0.0:
		return
	var direction := hit_direction
	if direction.is_zero_approx() and hit_position != Vector3.ZERO:
		direction = global_position - hit_position
	direction -= _plane_normal * direction.dot(_plane_normal)
	if direction.is_zero_approx():
		return
	_knockback_velocity += direction.normalized() * min(knockback_strength, 5.0)

func _spawn_death_effect() -> void:
	var shockwave := SHOCKWAVE_SCENE.instantiate() as Node3D
	if shockwave == null:
		return
	var effect_container := get_node_or_null(effect_container_path) as Node3D
	if effect_container == null:
		effect_container = get_parent() as Node3D
	if effect_container == null:
		return
	effect_container.add_child(shockwave)
	shockwave.global_position = global_position + Vector3(0.0, 0.05, 0.0)

func _spawn_xp_pickup() -> void:
	if xp_pickup_scene == null:
		return

	var pickup_container := get_node_or_null(pickup_container_path) as Node3D
	var xp_pickup := xp_pickup_scene.instantiate() as XPPickup
	if pickup_container == null or xp_pickup == null:
		return

	pickup_container.add_child(xp_pickup)
	xp_pickup.global_position = global_position
	if game_manager != null:
		xp_pickup.xp_amount = game_manager.get_scaled_xp_drop(xp_drop_amount)
	else:
		xp_pickup.xp_amount = xp_drop_amount
