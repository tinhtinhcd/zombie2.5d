extends CharacterBody3D
class_name Player

# Minimal 2.5D movement controller.
# Change `movement_plane_normal` to move on a different plane later.
# Set `use_camera_relative_input` to false if you want fixed world-axis movement.

const DEBUG_WEAPON_ATTACH_TRACE := false
const MUZZLE_FLASH_SCENE := preload("res://scenes/effects/muzzle_flash.tscn")
const EXPLOSION_AOE_SCENE := preload("res://scenes/effects/explosion_aoe.tscn")

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
@export var weapon_attachment_fallback_offset: Vector3 = Vector3(0.45, 0.95, -0.35)

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
var _current_weapon_model_path: String = ""
var current_weapon_id: String = "weapon_basic"
var current_weapon_display_name: String = "Basic Gun"
var game_manager: GameManager
var audio_manager: AudioManager

func _ready() -> void:
<<<<<<< ours
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
	_warm_projectile_pool()
	hp_changed.emit(current_hp)
=======
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
	_setup_character_animation_player()
	_setup_feedback_material()
	_warm_projectile_pool()
	hp_changed.emit(current_hp)
>>>>>>> theirs

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
	_cache_nearest_enemy_for_frame()
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
<<<<<<< ours
	if projectile_scene == null:
		return

	_cache_nearest_enemy_for_frame()
	var target_enemy := _nearest_enemy_this_frame
	if target_enemy == null:
		return
	_face_direction(target_enemy.global_position - global_position)
	_trigger_shoot_feedback()

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
		projectile.damage = projectile_damage
		projectile.speed = projectile_speed
		projectile.weapon_id = current_weapon_id
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
=======
	if projectile_scene == null:
		return

	_cache_nearest_enemy_for_frame()
	var target_enemy := _nearest_enemy_this_frame
	if target_enemy == null:
		return
	_face_direction(target_enemy.global_position - global_position)
	_trigger_shoot_feedback()
	_spawn_muzzle_flash()
	if audio_manager != null:
		audio_manager.play_sfx_event(&"shoot")

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
		var projectile := _acquire_projectile(projectile_container)
		if projectile == null:
			continue
		projectile.global_transform = shoot_point.global_transform
		projectile.damage = projectile_damage
		projectile.speed = projectile_speed
		var shot_direction := base_direction
		if shot_count > 1:
			shot_direction = base_direction.rotated(_plane_normal, start_angle + angle_step * shot_index)
		projectile.setup(shot_direction, weapon_range)
>>>>>>> theirs

func _face_combat_target_or_movement(move_direction: Vector3) -> void:
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
	max_hp = max(max_hp + amount, 1)
	current_hp = clampi(current_hp + amount, 0, max_hp)
	hp_changed.emit(current_hp)

func restore_hp(amount: int) -> void:
	current_hp = min(current_hp + max(amount, 0), max_hp)
	hp_changed.emit(current_hp)

func apply_weapon_definition(weapon_definition: Dictionary, attach_visual: bool = true, preview_mode: bool = false) -> void:
	current_weapon_id = str(weapon_definition.get("id", current_weapon_id))
	current_weapon_display_name = str(weapon_definition.get("display_name", weapon_definition.get("name", current_weapon_display_name)))
	fire_interval = float(weapon_definition.get("fire_rate", weapon_definition.get("fire_interval", fire_interval)))
	projectile_damage = int(weapon_definition.get("damage", weapon_definition.get("projectile_damage", projectile_damage)))
	projectile_speed = float(weapon_definition.get("projectile_speed", projectile_speed))
	projectile_count = clampi(int(weapon_definition.get("projectile_count", projectile_count)), 1, 5)
	spread_angle_degrees = max(float(weapon_definition.get("spread_angle", spread_angle_degrees)), 0.0)
	weapon_range = max(float(weapon_definition.get("range", weapon_range)), 1.0)
	enable_auto_fire = true
	if attach_visual:
		_attach_weapon_visual(weapon_definition, preview_mode)

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
	_current_weapon_model_path = ""
	set_meta("hero_id", hero_id)
	set_meta("model_path", model_scene_path)
	set_meta("model_fallback_used", bool(hero_definition.get("model_fallback_used", false)))
	_setup_character_animation_player()

func _attach_weapon_visual(weapon_definition: Dictionary, preview_mode: bool = false) -> bool:
	var weapon_id := str(weapon_definition.get("id", current_weapon_id))
	var model_scene_path := str(weapon_definition.get("model_scene_path", "")).strip_edges()
	var trace := {
		"selected_hero_id": str(get_meta("hero_id", "")),
		"selected_weapon_id": weapon_id,
		"resolved_weapon_definition": JSON.stringify(weapon_definition),
		"weapon_model_path": model_scene_path,
		"weapon_scene_loaded": false,
		"hero_instance_path": str(get_path()),
		"found_weapon_socket_path": "",
		"final_attached_weapon_node_path": "",
	}
	if model_scene_path.is_empty():
		_remove_existing_weapon_visuals()
		if not preview_mode:
			push_warning("Player weapon %s has no model_scene_path; gameplay continues without weapon visual." % weapon_id)
			_log_weapon_attach_trace(trace)
			return false
		push_warning("Player weapon %s has no model_scene_path; attaching visible preview placeholder." % weapon_id)
		var placeholder_socket := _get_or_create_visible_weapon_socket()
		var placeholder_weapon := _create_placeholder_weapon_visual(weapon_id)
		placeholder_socket.add_child(placeholder_weapon)
		placeholder_weapon.position = Vector3.ZERO
		placeholder_weapon.rotation_degrees = _dictionary_vector3(weapon_definition, "attachment_rotation_degrees", Vector3(0.0, 90.0, 0.0))
		placeholder_weapon.scale = _nonzero_vector3(_dictionary_vector3(weapon_definition, "attachment_scale", Vector3(0.18, 0.18, 0.18)), Vector3(0.18, 0.18, 0.18))
		placeholder_weapon.set_meta("weapon_model_path", "")
		placeholder_weapon.set_meta("attached_socket_path", str(placeholder_socket.get_path()))
		_configure_weapon_preview_node(placeholder_weapon)
		_ensure_weapon_visible(placeholder_weapon)
		_current_weapon_model_path = ""
		set_meta("weapon_id", weapon_id)
		set_meta("weapon_model_path", "")
		trace["found_weapon_socket_path"] = str(placeholder_socket.get_path())
		trace["final_attached_weapon_node_path"] = str(placeholder_weapon.get_path())
		_log_weapon_attach_trace(trace)
		_assert_attached_weapon_visible(placeholder_weapon, weapon_id)
		return true

	var existing_weapon := _find_existing_weapon_visual()
	if existing_weapon != null and str(existing_weapon.get_meta("weapon_id", "")) == weapon_id and str(existing_weapon.get_meta("weapon_model_path", existing_weapon.get_meta("model_path", ""))) == model_scene_path:
		set_meta("weapon_id", weapon_id)
		set_meta("weapon_model_path", model_scene_path)
		trace["weapon_scene_loaded"] = true
		trace["found_weapon_socket_path"] = str(existing_weapon.get_meta("attached_socket_path", ""))
		trace["final_attached_weapon_node_path"] = str(existing_weapon.get_path())
		_log_weapon_attach_trace(trace)
		_assert_attached_weapon_visible(existing_weapon, weapon_id)
		return true

	_remove_existing_weapon_visuals()
	var weapon_scene := load(model_scene_path) as PackedScene
	trace["weapon_scene_loaded"] = weapon_scene != null
	if weapon_scene == null:
		if not preview_mode:
			push_warning("Player weapon %s could not load model %s; gameplay continues without weapon visual." % [weapon_id, model_scene_path])
			_current_weapon_model_path = ""
			set_meta("weapon_id", weapon_id)
			set_meta("weapon_model_path", model_scene_path)
			_log_weapon_attach_trace(trace)
			return false
		push_warning("Player weapon %s could not load model %s; attaching visible preview placeholder." % [weapon_id, model_scene_path])
		var missing_socket := _get_or_create_visible_weapon_socket()
		var missing_weapon := _create_placeholder_weapon_visual(weapon_id)
		missing_socket.add_child(missing_weapon)
		missing_weapon.position = Vector3.ZERO
		missing_weapon.rotation_degrees = _dictionary_vector3(weapon_definition, "attachment_rotation_degrees", Vector3(0.0, 90.0, 0.0))
		missing_weapon.scale = _nonzero_vector3(_dictionary_vector3(weapon_definition, "attachment_scale", Vector3(0.18, 0.18, 0.18)), Vector3(0.18, 0.18, 0.18))
		missing_weapon.set_meta("weapon_model_path", model_scene_path)
		missing_weapon.set_meta("attached_socket_path", str(missing_socket.get_path()))
		_configure_weapon_preview_node(missing_weapon)
		_ensure_weapon_visible(missing_weapon)
		_current_weapon_model_path = model_scene_path
		set_meta("weapon_id", weapon_id)
		set_meta("weapon_model_path", model_scene_path)
		trace["found_weapon_socket_path"] = str(missing_socket.get_path())
		trace["final_attached_weapon_node_path"] = str(missing_weapon.get_path())
		_log_weapon_attach_trace(trace)
		_assert_attached_weapon_visible(missing_weapon, weapon_id)
		return true

	var weapon_model := weapon_scene.instantiate() as Node3D
	if weapon_model == null:
		if not preview_mode:
			push_warning("Player weapon %s model %s did not instantiate as Node3D; gameplay continues without weapon visual." % [weapon_id, model_scene_path])
			_current_weapon_model_path = ""
			set_meta("weapon_id", weapon_id)
			set_meta("weapon_model_path", model_scene_path)
			_log_weapon_attach_trace(trace)
			return false
		push_warning("Player weapon %s model %s did not instantiate as Node3D; attaching visible preview placeholder." % [weapon_id, model_scene_path])
		weapon_model = _create_placeholder_weapon_visual(weapon_id)

	weapon_model.name = "EquippedWeaponPreview"
	weapon_model.set_meta("model_kind", "weapon")
	weapon_model.set_meta("weapon_id", weapon_id)
	weapon_model.set_meta("model_path", model_scene_path)
	weapon_model.set_meta("weapon_model_path", model_scene_path)
	weapon_model.set_meta("source_scene_path", model_scene_path)

	var attachment_bone := str(weapon_definition.get("attachment_bone", "handslot.r")).strip_edges()
	var attachment_result := _get_or_create_weapon_attachment_parent(attachment_bone)
	var attachment_parent := attachment_result.get("node", null) as Node3D
	if attachment_parent == null:
		if not preview_mode:
			push_warning("Player weapon %s could not find attachment '%s'; gameplay continues without weapon visual." % [weapon_id, attachment_bone])
			weapon_model.free()
			_current_weapon_model_path = ""
			set_meta("weapon_id", weapon_id)
			set_meta("weapon_model_path", model_scene_path)
			_log_weapon_attach_trace(trace)
			return false
		attachment_parent = _get_or_create_visible_weapon_socket()
		attachment_result["path"] = str(attachment_parent.get_path())
		attachment_result["fallback"] = true
		push_warning("Player weapon %s could not find attachment '%s'; using visible preview WeaponSocket fallback." % [weapon_id, attachment_bone])

	attachment_parent.add_child(weapon_model)
	var used_attachment_fallback := bool(attachment_result.get("fallback", false))
	weapon_model.position = _dictionary_vector3(weapon_definition, "attachment_position", Vector3.ZERO)
	if used_attachment_fallback:
		weapon_model.position = Vector3.ZERO
	weapon_model.rotation_degrees = _dictionary_vector3(weapon_definition, "attachment_rotation_degrees", Vector3(0.0, 90.0, 0.0))
	weapon_model.scale = _nonzero_vector3(_dictionary_vector3(weapon_definition, "attachment_scale", Vector3(0.18, 0.18, 0.18)), Vector3(0.18, 0.18, 0.18))
	weapon_model.visible = true
	weapon_model.set_meta("attached_socket_path", str(attachment_result.get("path", attachment_parent.get_path())))
	_configure_weapon_preview_node(weapon_model)
	_ensure_weapon_visible(weapon_model)

	_current_weapon_model_path = model_scene_path
	set_meta("weapon_id", weapon_id)
	set_meta("weapon_model_path", model_scene_path)
	trace["found_weapon_socket_path"] = str(attachment_result.get("path", attachment_parent.get_path()))
	trace["final_attached_weapon_node_path"] = str(weapon_model.get_path())
	_log_weapon_attach_trace(trace)
	_assert_attached_weapon_visible(weapon_model, weapon_id)
	return true

func attach_gameplay_weapon_visual(weapon_definition: Dictionary) -> bool:
	return _attach_weapon_visual(weapon_definition, false)

func attach_preview_weapon_visual(weapon_definition: Dictionary) -> bool:
	return _attach_weapon_visual(weapon_definition, true)

func _get_or_create_weapon_attachment_parent(attachment_bone: String) -> Dictionary:
	var candidates: Array[String] = []
	if not attachment_bone.is_empty():
		candidates.append(attachment_bone)
	candidates.append_array(["WeaponSocket", "RightHandSocket", "weapon_socket", "handslot.r", "hand.r", "Hand.R", "hand_r", "Hand_R", "right_hand", "RightHand"])

	var search_root := character_root if character_root != null else visual_root
	if search_root != null:
		for candidate in candidates:
			var socket := _find_node3d_by_name(search_root, candidate)
			if socket != null:
				return {"node": socket, "path": str(socket.get_path()), "fallback": false}

	var skeleton := _find_skeleton(search_root)
	if skeleton != null:
		var matched_bone := _find_matching_bone_name(skeleton, candidates)
		if not matched_bone.is_empty():
			var bone_candidates: Array[String] = [matched_bone]
			bone_candidates.append_array(candidates)
			candidates = bone_candidates
		for candidate in candidates:
			var bone_index := skeleton.find_bone(candidate)
			if bone_index >= 0:
				var attachment := skeleton.get_node_or_null("EquippedWeaponAttachment") as BoneAttachment3D
				if attachment == null:
					attachment = BoneAttachment3D.new()
					attachment.name = "EquippedWeaponAttachment"
					skeleton.add_child(attachment)
				attachment.bone_name = candidate
				return {"node": attachment, "path": "%s:%s" % [str(attachment.get_path()), candidate], "fallback": false}
	return {"node": null, "path": "", "fallback": false}

func _get_or_create_visible_weapon_socket() -> Node3D:
	var parent := visual_root if visual_root != null else self
	var socket := parent.get_node_or_null("WeaponSocket") as Node3D
	if socket == null:
		socket = Marker3D.new()
		socket.name = "WeaponSocket"
		parent.add_child(socket)
	socket.position = weapon_attachment_fallback_offset
	socket.rotation_degrees = Vector3.ZERO
	socket.scale = Vector3.ONE
	socket.visible = true
	return socket

func _find_matching_bone_name(skeleton: Skeleton3D, candidates: Array[String]) -> String:
	for candidate in candidates:
		var normalized_candidate := _normalize_attachment_name(candidate)
		for bone_index in range(skeleton.get_bone_count()):
			var bone_name := skeleton.get_bone_name(bone_index)
			if _normalize_attachment_name(bone_name) == normalized_candidate:
				return bone_name
	for bone_index in range(skeleton.get_bone_count()):
		var lower_bone := skeleton.get_bone_name(bone_index).to_lower()
		if lower_bone.contains("right") and lower_bone.contains("hand"):
			return skeleton.get_bone_name(bone_index)
		if lower_bone.contains("hand") and (lower_bone.ends_with("_r") or lower_bone.ends_with(".r") or lower_bone.ends_with(" r")):
			return skeleton.get_bone_name(bone_index)
	return ""

func _normalize_attachment_name(value: String) -> String:
	return value.to_lower().replace("_", "").replace(".", "").replace(" ", "").replace("-", "")

func _find_node3d_by_name(root: Node, node_name: String) -> Node3D:
	if root is Node3D and root.name == node_name:
		return root as Node3D
	for child in root.get_children():
		var found := _find_node3d_by_name(child, node_name)
		if found != null:
			return found
	return null

func _find_skeleton(root: Node) -> Skeleton3D:
	if root == null:
		return null
	if root is Skeleton3D:
		return root as Skeleton3D
	for child in root.get_children():
		var found := _find_skeleton(child)
		if found != null:
			return found
	return null

func _find_existing_weapon_visual() -> Node3D:
	return _find_weapon_visual(self)

func _find_weapon_visual(root: Node) -> Node3D:
	if root is Node3D and (root.name == "EquippedWeaponPreview" or root.name == "EquippedWeapon" or str(root.get_meta("model_kind", "")) == "weapon"):
		return root as Node3D
	for child in root.get_children():
		var found := _find_weapon_visual(child)
		if found != null:
			return found
	return null

func _remove_existing_weapon_visuals() -> void:
	var existing := _find_existing_weapon_visual()
	while existing != null:
		var parent := existing.get_parent()
		if parent != null:
			parent.remove_child(existing)
		existing.free()
		existing = _find_existing_weapon_visual()

func _configure_weapon_preview_node(node: Node) -> void:
	node.set_process(false)
	node.set_physics_process(false)
	if node.has_method("set_process_input"):
		node.set_process_input(false)
	for child in node.get_children():
		_configure_weapon_preview_node(child)

func _create_placeholder_weapon_visual(weapon_id: String) -> Node3D:
	var root := Node3D.new()
	root.name = "EquippedWeaponPreview"
	root.set_meta("model_kind", "weapon")
	root.set_meta("weapon_id", weapon_id)
	root.set_meta("model_path", "")
	root.set_meta("source_scene_path", "placeholder://weapon")
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "VisibleWeaponPlaceholder"
	var box := BoxMesh.new()
	box.size = Vector3(0.16, 0.12, 0.75)
	mesh_instance.mesh = box
	mesh_instance.position = Vector3(0.0, 0.0, -0.25)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.95, 0.75, 0.2, 1.0)
	material.metallic = 0.25
	material.roughness = 0.45
	mesh_instance.material_override = material
	root.add_child(mesh_instance)
	return root

func _ensure_weapon_visible(node: Node) -> int:
	var visible_mesh_count := 0
	if node is Node3D:
		var node3d := node as Node3D
		node3d.visible = true
		node3d.scale = _nonzero_vector3(node3d.scale, Vector3.ONE)
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		mesh_instance.visible = true
		if mesh_instance.mesh != null:
			visible_mesh_count += 1
	for child in node.get_children():
		visible_mesh_count += _ensure_weapon_visible(child)
	return visible_mesh_count

func _nonzero_vector3(value: Vector3, fallback: Vector3) -> Vector3:
	if is_zero_approx(value.x) or is_zero_approx(value.y) or is_zero_approx(value.z):
		return fallback
	return value

func _assert_attached_weapon_visible(weapon_node: Node3D, weapon_id: String) -> void:
	if weapon_node == null:
		push_warning("Weapon attach assertion failed: EquippedWeaponPreview node is missing for %s." % weapon_id)
		return
	if weapon_node.name != "EquippedWeaponPreview":
		push_warning("Weapon attach assertion failed: attached weapon is named %s, expected EquippedWeaponPreview." % weapon_node.name)
	if str(weapon_node.get_meta("weapon_id", "")) != weapon_id:
		push_warning("Weapon attach assertion failed: weapon metadata mismatch for %s." % weapon_id)
	var visible_mesh_count := _count_visible_weapon_meshes(weapon_node)
	if visible_mesh_count == 0:
		push_warning("Weapon attach assertion failed: EquippedWeaponPreview for %s has no visible MeshInstance3D children." % weapon_id)
	elif DEBUG_WEAPON_ATTACH_TRACE:
		print("Weapon attach assertion passed: weapon_id=%s visible_mesh_count=%d node=%s" % [weapon_id, visible_mesh_count, str(weapon_node.get_path())])

func _count_visible_weapon_meshes(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.visible and mesh_instance.mesh != null:
			count += 1
	for child in node.get_children():
		count += _count_visible_weapon_meshes(child)
	return count

func _log_weapon_attach_trace(trace: Dictionary) -> void:
	if not DEBUG_WEAPON_ATTACH_TRACE:
		return
	print("Weapon attach debug: selected_hero_id=%s selected_weapon_id=%s weapon_model_path=%s scene_loaded=%s hero_instance_path=%s socket_path=%s attached_weapon_path=%s resolved_weapon_definition=%s" % [
		str(trace.get("selected_hero_id", "")),
		str(trace.get("selected_weapon_id", "")),
		str(trace.get("weapon_model_path", "")),
		str(trace.get("weapon_scene_loaded", false)),
		str(trace.get("hero_instance_path", "")),
		str(trace.get("found_weapon_socket_path", "")),
		str(trace.get("final_attached_weapon_node_path", "")),
		str(trace.get("resolved_weapon_definition", "")),
	])

func _dictionary_vector3(source: Dictionary, key: String, fallback: Vector3) -> Vector3:
	var value: Variant = source.get(key, fallback)
	if value is Vector3:
		return value as Vector3
	if typeof(value) == TYPE_ARRAY:
		var values: Array = value
		if values.size() >= 3:
			return Vector3(float(values[0]), float(values[1]), float(values[2]))
	return fallback

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
		if enemy.current_hp <= 0:
			continue
		var distance := global_position.distance_squared_to(enemy.global_position)
		if require_weapon_range and weapon_range > 0.0 and distance > weapon_range * weapon_range:
			continue
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	return nearest_enemy

func _cache_nearest_enemy_for_frame() -> void:
	var frame := Engine.get_physics_frames()
	if _nearest_enemy_frame == frame:
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

func _on_projectile_recycle_requested(projectile: Projectile) -> void:
	call_deferred("_pool_projectile", projectile)

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
<<<<<<< ours
	if _feedback_material == null:
		return
	_feedback_material.albedo_color = _base_color.lerp(Color(1.0, 0.35, 0.35, 1.0), strength)
=======
	if _feedback_material == null:
		return
	_feedback_material.albedo_color = _base_color.lerp(Color(1.0, 0.35, 0.35, 1.0), strength)


func _spawn_muzzle_flash() -> void:
	if shoot_point == null:
		return
	var flash := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.12
	mesh.height = 0.24
	flash.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = Color(1.0, 0.85, 0.35, 1.0)
	material.emission_energy_multiplier = 2.0
	material.albedo_color = Color(1.0, 0.9, 0.5, 1.0)
	flash.material_override = material
	shoot_point.add_child(flash)
	var tween := create_tween()
	tween.tween_property(flash, "scale", Vector3(0.05, 0.05, 0.05), 0.06)
	tween.finished.connect(flash.queue_free)
>>>>>>> theirs
