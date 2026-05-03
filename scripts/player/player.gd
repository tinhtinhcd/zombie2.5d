extends CharacterBody3D
class_name Player

# Minimal 2.5D movement controller.
# Change `movement_plane_normal` to move on a different plane later.
# Set `use_camera_relative_input` to false if you want fixed world-axis movement.

const MUZZLE_FLASH_SCENE := preload("res://scenes/effects/muzzle_flash.tscn")
const EXPLOSION_AOE_SCENE := preload("res://scenes/effects/explosion_aoe.tscn")
const WEAPON_VISUALS_SCRIPT := preload("res://scripts/components/weapon_visuals.gd")
const COMBAT_UTILS := preload("res://scripts/utils/combat_utils.gd")

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
@export var effect_container_path: NodePath = NodePath("../EffectContainer")
@export var max_hp: int = 10
@export var projectile_damage: int = 1
@export var projectile_speed: float = 14.0
@export var projectile_count: int = 1
@export var spread_angle_degrees: float = 0.0
@export var weapon_range: float = 20.0
@export var projectile_pool_warmup_count: int = 8
@export var projectile_pool_max_size: int = 32
@export var play_area_radius: float = 600.0
@export var damage_cooldown: float = 0.45
@export var visual_yaw_offset_degrees: float = 180.0
@export var idle_bob_amount: float = 0.035
@export var run_bob_amount: float = 0.08
@export var run_lean_amount: float = 0.12
@export var shoot_recoil_amount: float = 0.08
@export var shoot_recoil_roll_amount: float = 0.025
@export var shoot_recoil_duration: float = 0.16
@export var skill_primary_cooldown: float = 7.0
@export var explosion_skill_radius: float = 4.5
@export var explosion_skill_damage: int = 3
@export var explosion_skill_knockback: float = 2.2
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
var _skill_primary_timer: float = 0.0
var _animation_player: AnimationPlayer
var _current_animation: String = ""
var _projectile_pool: Array[Projectile] = []
var _nearest_enemy_this_frame: Node3D
var _nearest_enemy_frame: int = -1
var _current_hero_model_path: String = ""
var current_weapon_id: String = "weapon_basic"
var current_weapon_display_name: String = "Basic Gun"
var current_weapon_special_effect: String = "none"
var support_damage_multiplier: float = 1.0
var weapon_visuals
var skill_manager: Node
var game_manager: GameManager
var audio_manager: AudioManager

func _ready() -> void:
	game_manager = get_node("/root/GameManager") as GameManager
	audio_manager = get_node_or_null("/root/AudioManager") as AudioManager
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
	_setup_weapon_visuals()
	_setup_character_animation_player()
	_setup_feedback_material()
	_warm_projectile_pool()
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
	if game_manager != null and not game_manager.is_gameplay_active:
		return

	_skill_primary_timer = max(_skill_primary_timer - delta, 0.0)
	if InputMap.has_action("skill_primary") and Input.is_action_just_pressed("skill_primary"):
		if skill_manager != null and skill_manager.has_method("has_active_skills") and skill_manager.call("has_active_skills"):
			skill_manager.call("try_use_slot", 0)
		else:
			activate_explosion_skill()

	if not enable_auto_fire:
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

	_cache_nearest_enemy_for_frame(true)
	var target_enemy := _nearest_enemy_this_frame
	if target_enemy == null:
		return
	_face_direction(target_enemy.global_position - global_position)
	_trigger_shoot_feedback()
	if audio_manager != null:
		audio_manager.play_sfx_event(&"shoot")

	var projectile_container := get_node_or_null(projectile_container_path) as Node3D
	if projectile_container == null:
		return

	var base_direction := target_enemy.global_position - shoot_point.global_position
	_spawn_muzzle_flash(base_direction)
	_request_camera_shake(0.08, 0.08)
	var shot_count := clampi(projectile_count, 1, 5)
	var angle_step := 0.0
	if shot_count > 1:
		angle_step = deg_to_rad(spread_angle_degrees) / float(shot_count - 1)
	var start_angle := -deg_to_rad(spread_angle_degrees) * 0.5

	for shot_index in range(shot_count):
		var projectile := _acquire_projectile(projectile_container)
		if projectile == null:
			continue
		projectile.global_transform = shoot_point.global_transform
		projectile.damage = _get_modified_projectile_damage()
		projectile.speed = projectile_speed
		projectile.weapon_id = current_weapon_id
		projectile.special_effect = current_weapon_special_effect
		projectile.knockback_strength = _get_projectile_knockback_strength()
		var shot_direction := base_direction
		if shot_count > 1:
			shot_direction = base_direction.rotated(_plane_normal, start_angle + angle_step * shot_index)
		projectile.setup(shot_direction, weapon_range)

func activate_explosion_skill() -> bool:
	if _skill_primary_timer > 0.0:
		return false

	var target_enemy := _find_nearest_enemy(false)
	var skill_position := global_position
	if target_enemy != null:
		var target_offset := target_enemy.global_position - global_position
		if target_offset.length() <= max(weapon_range, explosion_skill_radius):
			skill_position = target_enemy.global_position
	var explosion := EXPLOSION_AOE_SCENE.instantiate() as Node3D
	if explosion == null:
		return false
	var effect_container := _get_effect_container()
	effect_container.add_child(explosion)
	if explosion.has_method("setup"):
		explosion.call("setup", skill_position, explosion_skill_radius, max(explosion_skill_damage + projectile_damage - 1, 1), explosion_skill_knockback)
	else:
		explosion.global_position = skill_position
	_skill_primary_timer = max(skill_primary_cooldown, 0.1)
	_request_camera_shake(0.16, 0.16)
	return true

func _face_combat_target_or_movement(move_direction: Vector3) -> void:
	_cache_nearest_enemy_for_frame(true)
	var target_enemy := _nearest_enemy_this_frame
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
	var resolved_amount: int = max(amount, 0)
	if skill_manager != null and skill_manager.has_method("resolve_incoming_damage"):
		resolved_amount = int(skill_manager.call("resolve_incoming_damage", resolved_amount))
	if resolved_amount <= 0:
		_damage_cooldown_timer = damage_cooldown
		return

	current_hp -= resolved_amount
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
	max_hp = max(max_hp + amount, 1)
	current_hp = clampi(current_hp + amount, 0, max_hp)
	hp_changed.emit(current_hp)

func restore_hp(amount: int) -> void:
	current_hp = min(current_hp + max(amount, 0), max_hp)
	hp_changed.emit(current_hp)

func _get_modified_projectile_damage() -> int:
	var base_damage := maxi(roundi(float(projectile_damage) * maxf(support_damage_multiplier, 0.1)), 1)
	if skill_manager != null and skill_manager.has_method("get_modified_projectile_damage"):
		return int(skill_manager.call("get_modified_projectile_damage", base_damage))
	return base_damage

func apply_weapon_definition(weapon_definition: Dictionary, attach_visual: bool = true, preview_mode: bool = false) -> void:
	current_weapon_id = str(weapon_definition.get("id", current_weapon_id))
	current_weapon_display_name = str(weapon_definition.get("display_name", weapon_definition.get("name", current_weapon_display_name)))
	current_weapon_special_effect = str(weapon_definition.get("special_effect", "none"))
	fire_interval = float(weapon_definition.get("fire_rate", weapon_definition.get("fire_interval", fire_interval)))
	projectile_damage = int(weapon_definition.get("damage", weapon_definition.get("projectile_damage", projectile_damage)))
	projectile_speed = float(weapon_definition.get("projectile_speed", projectile_speed))
	projectile_count = clampi(int(weapon_definition.get("projectile_count", projectile_count)), 1, 5)
	spread_angle_degrees = max(float(weapon_definition.get("spread_angle", spread_angle_degrees)), 0.0)
	weapon_range = max(float(weapon_definition.get("range", weapon_range)), 1.0)
	enable_auto_fire = true
	if attach_visual:
		if preview_mode:
			attach_preview_weapon_visual(weapon_definition)
		else:
			attach_gameplay_weapon_visual(weapon_definition)

func apply_hero_definition(hero_definition: Dictionary) -> void:
	if hero_definition.has("max_hp_bonus"):
		increase_max_hp(int(hero_definition.get("max_hp_bonus", 0)))
	var hero_id := str(hero_definition.get("id", ""))
	var model_scene_path := str(hero_definition.get("model_scene_path", "")).strip_edges()
	if model_scene_path.is_empty():
		push_warning("Player hero %s has no model_scene_path; keeping current visual model." % hero_id)
		return
	if _current_hero_model_path == model_scene_path:
		set_meta("hero_id", hero_id)
		set_meta("model_path", model_scene_path)
		set_meta("model_fallback_used", bool(hero_definition.get("model_fallback_used", false)))
		return

	var model_scene := load(model_scene_path) as PackedScene
	if model_scene == null:
		push_warning("Player hero %s could not load model %s; keeping current visual model." % [hero_id, model_scene_path])
		return

	var new_model := model_scene.instantiate() as Node3D
	if new_model == null:
		push_warning("Player hero %s model %s did not instantiate as Node3D." % [hero_id, model_scene_path])
		return
	var old_model := visual_root.get_node_or_null("HeroModel") as Node3D
	if old_model != null:
		visual_root.remove_child(old_model)
		old_model.free()
	new_model.name = "HeroModel"
	new_model.set_meta("hero_id", hero_id)
	new_model.set_meta("model_path", model_scene_path)
	visual_root.add_child(new_model)
	visual_root.move_child(new_model, 0)
	character_root_path = NodePath("VisualRoot/HeroModel")
	character_root = new_model
	_animation_player = null
	_current_animation = ""
	_current_hero_model_path = model_scene_path
	set_meta("hero_id", hero_id)
	set_meta("model_path", model_scene_path)
	set_meta("model_fallback_used", bool(hero_definition.get("model_fallback_used", false)))
	if weapon_visuals != null:
		weapon_visuals.set_roots(visual_root, character_root)
		weapon_visuals.clear()
	_setup_character_animation_player()

func _setup_weapon_visuals() -> void:
	weapon_visuals = get_node_or_null("WeaponVisuals")
	if weapon_visuals == null:
		weapon_visuals = Node.new()
		weapon_visuals.set_script(WEAPON_VISUALS_SCRIPT)
		weapon_visuals.name = "WeaponVisuals"
		add_child(weapon_visuals)
	weapon_visuals.setup(self, visual_root, character_root)

func attach_gameplay_weapon_visual(weapon_definition: Dictionary) -> bool:
	if weapon_visuals == null:
		_setup_weapon_visuals()
	return weapon_visuals.attach_weapon(weapon_definition, false)

func attach_preview_weapon_visual(weapon_definition: Dictionary) -> bool:
	if weapon_visuals == null:
		_setup_weapon_visuals()
	return weapon_visuals.attach_weapon(weapon_definition, true)

func receive_experience(amount: int) -> void:

	if game_manager != null:
		game_manager.add_xp(amount)

func _find_nearest_enemy(require_weapon_range: bool = true) -> Node3D:
	var enemy_container := get_node_or_null(enemy_container_path) as Node3D
	if enemy_container == null:
		return null

	return COMBAT_UTILS.find_nearest_enemy(global_position, enemy_container.get_children(), weapon_range if require_weapon_range else -1.0)

func _cache_nearest_enemy_for_frame(force_refresh: bool = false) -> void:
	var frame := Engine.get_physics_frames()
	if not force_refresh and _nearest_enemy_frame == frame:
		return
	_nearest_enemy_this_frame = _find_nearest_enemy()
	_nearest_enemy_frame = frame

func _warm_projectile_pool() -> void:
	if projectile_scene == null:
		return
	if get_node_or_null(projectile_container_path) == null:
		return

	for index in range(max(projectile_pool_warmup_count, 0)):
		if _projectile_pool.size() >= projectile_pool_max_size:
			return
		var projectile := _create_projectile()
		if projectile == null:
			continue
		add_child(projectile)
		projectile.deactivate()
		_projectile_pool.append(projectile)

func _acquire_projectile(projectile_container: Node3D) -> Projectile:
	while not _projectile_pool.is_empty():
		var pooled_projectile: Projectile = _projectile_pool.pop_back()
		if not is_instance_valid(pooled_projectile):
			continue
		_move_projectile_to_container(pooled_projectile, projectile_container)
		return pooled_projectile

	var projectile := _create_projectile()
	if projectile == null:
		return null
	projectile_container.add_child(projectile)
	return projectile

func _create_projectile() -> Projectile:
	var projectile := projectile_scene.instantiate() as Projectile
	if projectile == null:
		return null
	projectile.recycle_requested.connect(_on_projectile_recycle_requested)
	return projectile

func _move_projectile_to_container(projectile: Projectile, projectile_container: Node3D) -> void:
	var current_parent := projectile.get_parent()
	if current_parent != null:
		current_parent.remove_child(projectile)
	projectile_container.add_child(projectile)

func _on_projectile_recycle_requested(projectile: Projectile, defer_pool: bool = false) -> void:
	if defer_pool:
		call_deferred("_pool_projectile", projectile)
		return
	_pool_projectile(projectile)

func _pool_projectile(projectile: Projectile) -> void:
	if not is_instance_valid(projectile):
		return

	var current_parent := projectile.get_parent()
	if current_parent != null:
		current_parent.remove_child(projectile)

	if _projectile_pool.size() >= max(projectile_pool_max_size, 0):
		projectile.queue_free()
		return

	add_child(projectile)
	projectile.deactivate()
	_projectile_pool.append(projectile)

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

func _spawn_muzzle_flash(world_direction: Vector3) -> void:
	var flash := MUZZLE_FLASH_SCENE.instantiate() as Node3D
	if flash == null:
		return
	_get_effect_container().add_child(flash)
	flash.global_position = shoot_point.global_position
	_orient_node_to_direction(flash, world_direction)

func _get_effect_container() -> Node3D:
	var effect_container := get_node_or_null(effect_container_path) as Node3D
	if effect_container != null:
		return effect_container
	if get_parent() is Node3D:
		return get_parent() as Node3D
	return self

func _orient_node_to_direction(node: Node3D, world_direction: Vector3) -> void:
	if node == null or world_direction.is_zero_approx():
		return
	var direction := world_direction.normalized()
	var up_axis := Vector3.UP
	if absf(direction.dot(up_axis)) > 0.96:
		up_axis = Vector3.RIGHT
	node.look_at(node.global_position + direction, up_axis)

func _request_camera_shake(amount: float, duration: float) -> void:
	get_tree().call_group("camera_rigs", "shake", amount, duration)

func _get_projectile_knockback_strength() -> float:
	if current_weapon_id == "weapon_heavy":
		return 2.6
	if current_weapon_special_effect == "stagger":
		return 1.4
	return 0.0

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
