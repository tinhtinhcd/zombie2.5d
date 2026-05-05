extends Node3D
class_name ShooterGuard

const COMBAT_UTILS := preload("res://scripts/utils/combat_utils.gd")
const GUARD_MOVEMENT := preload("res://scripts/utils/guard_movement.gd")
const SHOCKWAVE_SCENE := preload("res://scenes/effects/shockwave.tscn")
const SHOOTER_GUARD_SCENE := preload("res://scenes/entities/shooter_guard.tscn")

signal hp_changed(current_hp: int, max_hp: int)
signal died

@export var target_path: NodePath = NodePath("../../Player")
@export var enemy_container_path: NodePath = NodePath("../../EnemyContainer")
@export var projectile_container_path: NodePath = NodePath("../../ProjectileContainer")
@export var effect_container_path: NodePath = NodePath("../../EffectContainer")
@export var guardian_id: String = "guard_shooter"
@export var projectile_scene: PackedScene
@export var follow_offset: Vector3 = Vector3(1.4, 0.6, 0.9)
@export var follow_speed: float = 7.0
@export var attack_interval: float = 1.0
@export var damage: int = 1
@export var attack_range: float = 16.0
@export var target_scan_interval: float = 0.2
@export var projectile_speed: float = 14.0
@export var max_hp: int = 6
@export var preferred_combat_radius: float = 3.6
@export var orbit_angle_degrees: float = INF

var _target: Node3D
var _attack_timer: float = 0.0
var _scan_timer: float = 0.0
var _cached_enemy: Enemy
var _skills: Array = []
var _cooldowns: Dictionary = {}
var current_hp: int = 0
var _is_dead: bool = false
var _base_scale: Vector3 = Vector3.ONE
var _base_move_speed: float = 7.0
var _move_speed_timer: float = 0.0
var _damage_reduction_timer: float = 0.0
var _damage_reduction: int = 0
var game_manager: GameManager
var movement_state: String = "hold"
var combat_max_radius: float = 0.0
var combat_return_radius: float = 0.0

func _ready() -> void:
	game_manager = get_node_or_null("/root/GameManager") as GameManager
	_target = get_node_or_null(target_path) as Node3D
	if projectile_scene == null:
		projectile_scene = load("res://scenes/effects/projectile.tscn") as PackedScene
	_base_scale = scale
	_base_move_speed = follow_speed
	_load_definition()
	if is_inf(orbit_angle_degrees):
		orbit_angle_degrees = GUARD_MOVEMENT.get_orbit_angle_degrees(guardian_id, follow_offset)
	current_hp = max(max_hp, 1)
	add_to_group("guards")
	hp_changed.emit(current_hp, max_hp)

func _process(delta: float) -> void:
	if _is_dead:
		return
	_tick_cooldowns(delta)
	_tick_temporary_buffs(delta)
	if _target == null:
		_target = get_node_or_null(target_path) as Node3D
	if _target != null:
		_update_combat_movement(delta)

	if game_manager != null and not game_manager.is_gameplay_active:
		return

	_attack_timer -= delta
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_cached_enemy = _find_nearest_enemy()
		_scan_timer = max(target_scan_interval, 0.05)

	if _try_guard_skills():
		return

	if _attack_timer > 0.0:
		return
	if _cached_enemy == null or not is_instance_valid(_cached_enemy) or _cached_enemy.is_dead():
		return
	if attack_range > 0.0 and global_position.distance_squared_to(_cached_enemy.global_position) > attack_range * attack_range:
		_cached_enemy = null
		return
	_shoot_at(_cached_enemy, damage, attack_range)
	_attack_timer = max(attack_interval, 0.2)

func _load_definition() -> void:
	if game_manager == null or guardian_id.is_empty():
		return
	var definition := game_manager.get_guardian(guardian_id)
	if definition.is_empty():
		return
	target_scan_interval = float(definition.get("scan_interval", target_scan_interval))
	max_hp = int(definition.get("max_hp", max_hp))
	var follow_distance := float(definition.get("follow_distance", follow_offset.length()))
	if follow_distance > 0.0:
		follow_offset = Vector3(1.0, 0.25, 0.7).normalized() * follow_distance
		preferred_combat_radius = clampf(follow_distance + 1.4, 3.0, 4.5)
	var skills_value: Variant = definition.get("skills", [])
	if typeof(skills_value) == TYPE_ARRAY:
		_skills = skills_value.duplicate(true)
	for skill in _skills:
		if typeof(skill) != TYPE_DICTIONARY:
			continue
		var skill_dictionary: Dictionary = skill
		var skill_name := str(skill_dictionary.get("name", ""))
		_cooldowns[skill_name] = 0.0
		if skill_name == "Cover Fire":
			attack_interval = float(skill_dictionary.get("cooldown", attack_interval))
			damage = int(skill_dictionary.get("damage", damage))
			attack_range = float(skill_dictionary.get("range", attack_range))

func _update_combat_movement(delta: float) -> void:
	if _cached_enemy != null and not is_instance_valid(_cached_enemy):
		_cached_enemy = null
	var plan: Dictionary = GUARD_MOVEMENT.get_plan(
		self,
		_target,
		_cached_enemy,
		follow_speed,
		delta,
		orbit_angle_degrees,
		preferred_combat_radius,
		get_tree().get_nodes_in_group("guards")
	)
	var velocity: Vector3 = plan.get("velocity", Vector3.ZERO)
	global_position += velocity * delta
	movement_state = str(plan.get("state", "hold"))
	combat_max_radius = float(plan.get("max_radius", combat_max_radius))
	combat_return_radius = float(plan.get("return_radius", combat_return_radius))

func take_damage(amount: int) -> void:
	if _is_dead:
		return
	var resolved_amount := maxi(amount - _damage_reduction, 0)
	if resolved_amount <= 0:
		return
	current_hp = max(current_hp - resolved_amount, 0)
	hp_changed.emit(current_hp, max_hp)
	_flash_hit()
	if current_hp <= 0:
		_die()

func is_dead() -> bool:
	return _is_dead

func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	remove_from_group("guards")
	visible = false
	died.emit()
	queue_free()

func _try_guard_skills() -> bool:
	if _skills.is_empty():
		return false
	for skill in _skills:
		if typeof(skill) != TYPE_DICTIONARY:
			continue
		if _try_skill(skill as Dictionary):
			return true
	return false

func _try_skill(skill: Dictionary) -> bool:
	var skill_name := str(skill.get("name", ""))
	if skill_name.is_empty() or not _is_ready(skill_name):
		return false
	var effect := str(skill.get("effect", "projectile"))
	match effect.get_slice(":", 0):
		"projectile", "pierce":
			return _try_projectile_skill(skill, effect)
		"fire_rate_buff":
			return _try_fire_rate_buff(skill, effect)
		"heal":
			return _try_heal_skill(skill, effect)
		"move_speed_buff":
			return _try_move_speed_buff(skill, effect)
		"slow", "stun":
			return _try_area_damage_skill(skill, effect, 0.0)
		"temporary_turret":
			return _try_temporary_turret(skill)
		"temporary_damage_reduction", "damage_reduction_aura":
			return _try_damage_reduction_skill(skill, effect)
		"redirect_enemies":
			return _try_taunt_skill(skill)
		"stagger":
			return _try_boss_breaker(skill)
	return false

func _try_projectile_skill(skill: Dictionary, shot_effect: String) -> bool:
	var skill_name := str(skill.get("name", ""))
	if _cached_enemy == null or not is_instance_valid(_cached_enemy) or _cached_enemy.is_dead():
		return false
	var range := float(skill.get("range", attack_range))
	if range > 0.0 and global_position.distance_squared_to(_cached_enemy.global_position) > range * range:
		_cached_enemy = null
		return false
	_shoot_at(_cached_enemy, int(skill.get("damage", damage)), range, shot_effect)
	_start_cooldown(skill_name, float(skill.get("cooldown", attack_interval)))
	return true

func _try_fire_rate_buff(skill: Dictionary, effect: String) -> bool:
	var skill_name := str(skill.get("name", ""))
	if _target == null:
		_target = get_node_or_null(target_path) as Node3D
	if _target is not Player:
		return false
	if _cached_enemy == null or not is_instance_valid(_cached_enemy) or _cached_enemy.is_dead():
		return false
	var player := _target as Player
	if bool(player.get_meta("reload_drill_active", false)):
		return false
	var multiplier := _effect_float(effect, 1, 1.15)
	var duration := _effect_float(effect, 2, 4.0)
	var original_fire_interval := player.fire_interval
	player.set_meta("reload_drill_active", true)
	player.fire_interval = maxf(original_fire_interval / maxf(multiplier, 0.1), 0.12)
	_restore_player_fire_interval(player, original_fire_interval, duration)
	_start_cooldown(skill_name, float(skill.get("cooldown", 12.0)))
	return true

func _try_heal_skill(skill: Dictionary, effect: String) -> bool:
	var skill_name := str(skill.get("name", ""))
	if _target is not Player:
		return false
	var player := _target as Player
	if player.current_hp > roundi(float(player.max_hp) * 0.6):
		return false
	var heal_amount := _effect_int(effect, 1, int(skill.get("damage", 2)))
	player.restore_hp(maxi(heal_amount, 1))
	_start_cooldown(skill_name, float(skill.get("cooldown", 10.0)))
	return true

func _try_move_speed_buff(skill: Dictionary, effect: String) -> bool:
	var skill_name := str(skill.get("name", ""))
	if _target is not Player:
		return false
	if _get_enemies_in_radius(float(skill.get("range", 5.0))).size() < 2:
		return false
	var player := _target as Player
	var multiplier := _effect_float(effect, 1, 1.2)
	var duration := _effect_float(effect, 2, 4.0)
	var original_speed := player.move_speed
	player.move_speed = original_speed * maxf(multiplier, 0.1)
	_restore_player_move_speed(player, original_speed, duration)
	_start_cooldown(skill_name, float(skill.get("cooldown", 14.0)))
	return true

func _try_area_damage_skill(skill: Dictionary, effect: String, knockback: float = 0.0) -> bool:
	var skill_name := str(skill.get("name", ""))
	var enemies := _get_enemies_in_radius(float(skill.get("range", 3.0)))
	if enemies.is_empty():
		return false
	_spawn_shockwave()
	for enemy in enemies:
		var offset := enemy.global_position - global_position
		enemy.take_damage(int(skill.get("damage", 1)), enemy.global_position, offset.normalized(), 2.5 if effect == "stun" else knockback)
	_start_cooldown(skill_name, float(skill.get("cooldown", 7.0)))
	return true

func _try_temporary_turret(skill: Dictionary) -> bool:
	var skill_name := str(skill.get("name", ""))
	if _cached_enemy == null or not is_instance_valid(_cached_enemy) or _cached_enemy.is_dead():
		return false
	var parent := get_parent() as Node3D
	if parent == null:
		return false
	var turret := SHOOTER_GUARD_SCENE.instantiate() as ShooterGuard
	if turret == null:
		return false
	turret.name = "EngineerMiniTurret"
	turret.guardian_id = ""
	turret.follow_speed = 0.0
	turret.attack_interval = 0.8
	turret.damage = int(skill.get("damage", 1))
	turret.attack_range = float(skill.get("range", 12.0))
	turret.max_hp = 3
	parent.add_child(turret)
	turret.global_position = global_position + Vector3(0.8, 0.0, 0.2)
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = 8.0
	turret.add_child(timer)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(turret):
			turret.queue_free()
	)
	timer.start()
	_start_cooldown(skill_name, float(skill.get("cooldown", 16.0)))
	return true

func _try_damage_reduction_skill(skill: Dictionary, effect: String) -> bool:
	var skill_name := str(skill.get("name", ""))
	if _target is not Player:
		return false
	var player := _target as Player
	if effect == "temporary_damage_reduction" and player.current_hp > roundi(float(player.max_hp) * 0.7):
		return false
	var skill_manager := player.skill_manager
	if skill_manager != null and skill_manager.has_method("resolve_incoming_damage"):
		skill_manager.set("incoming_damage_reduction", max(int(skill_manager.get("incoming_damage_reduction")), 1))
	_damage_reduction = max(_damage_reduction, 1)
	_damage_reduction_timer = 4.0
	_spawn_shockwave()
	_start_cooldown(skill_name, float(skill.get("cooldown", 15.0)))
	return true

func _try_taunt_skill(skill: Dictionary) -> bool:
	var skill_name := str(skill.get("name", ""))
	var enemies := _get_enemies_in_radius(float(skill.get("range", 5.0)))
	if enemies.is_empty():
		return false
	for enemy in enemies:
		enemy.set_target(self)
	_spawn_shockwave()
	_start_cooldown(skill_name, float(skill.get("cooldown", 10.0)))
	return true

func _try_boss_breaker(skill: Dictionary) -> bool:
	var skill_name := str(skill.get("name", ""))
	var enemy := _find_highest_hp_enemy(float(skill.get("range", 2.0)))
	if enemy == null or enemy.enemy_type != &"boss":
		return false
	var offset := enemy.global_position - global_position
	enemy.take_damage(int(skill.get("damage", 4)), enemy.global_position, offset.normalized(), 2.0)
	_start_cooldown(skill_name, float(skill.get("cooldown", 12.0)))
	return true

func _shoot_at(enemy: Enemy, shot_damage: int, shot_range: float, shot_effect: String = "projectile") -> void:
	if projectile_scene == null:
		return
	var projectile_container := get_node_or_null(projectile_container_path) as Node3D
	if projectile_container == null:
		return
	var projectile := projectile_scene.instantiate() as Projectile
	if projectile == null:
		return
	projectile_container.add_child(projectile)
	projectile.global_position = global_position
	projectile.damage = maxi(shot_damage, 1)
	projectile.speed = projectile_speed
	projectile.special_effect = shot_effect
	projectile.setup(enemy.global_position - global_position, shot_range)

func _get_enemies_in_radius(radius: float) -> Array[Enemy]:
	var enemies: Array[Enemy] = []
	var enemy_container := get_node_or_null(enemy_container_path) as Node3D
	if enemy_container == null:
		return enemies
	var radius_squared := radius * radius
	for child in enemy_container.get_children():
		if child is not Enemy:
			continue
		var enemy := child as Enemy
		if enemy.is_dead():
			continue
		if enemy.global_position.distance_squared_to(global_position) <= radius_squared:
			enemies.append(enemy)
	return enemies

func _spawn_shockwave() -> void:
	var shockwave := SHOCKWAVE_SCENE.instantiate() as Node3D
	if shockwave == null:
		return
	var effect_container := get_node_or_null(effect_container_path) as Node3D
	if effect_container == null:
		effect_container = get_parent() as Node3D
	if effect_container == null:
		return
	effect_container.add_child(shockwave)
	shockwave.global_position = global_position

func _flash_hit() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", _base_scale * 1.08, 0.06)
	tween.tween_property(self, "scale", _base_scale, 0.08)

func _tick_temporary_buffs(delta: float) -> void:
	if _move_speed_timer > 0.0:
		_move_speed_timer = maxf(_move_speed_timer - delta, 0.0)
		if _move_speed_timer <= 0.0:
			follow_speed = _base_move_speed
	if _damage_reduction_timer > 0.0:
		_damage_reduction_timer = maxf(_damage_reduction_timer - delta, 0.0)
		if _damage_reduction_timer <= 0.0:
			_damage_reduction = 0

func _restore_player_move_speed(player: Player, value: float, duration: float) -> void:
	if player == null:
		return
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = maxf(duration, 0.05)
	player.add_child(timer)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(player):
			player.move_speed = value
		timer.queue_free()
	)
	timer.start()

func _effect_int(effect: String, slice_index: int, fallback: int) -> int:
	if effect.get_slice_count(":") <= slice_index:
		return fallback
	return int(effect.get_slice(":", slice_index))

func _find_nearest_enemy() -> Enemy:
	var enemy_container := get_node_or_null(enemy_container_path) as Node3D
	if enemy_container == null:
		return null
	return COMBAT_UTILS.find_nearest_enemy(global_position, enemy_container.get_children(), attack_range)

func _find_highest_hp_enemy(range: float) -> Enemy:
	var enemy_container := get_node_or_null(enemy_container_path) as Node3D
	if enemy_container == null:
		return null
	var best_enemy: Enemy
	var best_hp := -1
	var range_squared := range * range
	for child in enemy_container.get_children():
		if child is not Enemy:
			continue
		var enemy := child as Enemy
		if enemy.is_dead():
			continue
		if range > 0.0 and global_position.distance_squared_to(enemy.global_position) > range_squared:
			continue
		if enemy.current_hp > best_hp:
			best_hp = enemy.current_hp
			best_enemy = enemy
	return best_enemy

func _tick_cooldowns(delta: float) -> void:
	for key in _cooldowns.keys():
		_cooldowns[key] = maxf(float(_cooldowns.get(key, 0.0)) - delta, 0.0)

func _is_ready(skill_name: String) -> bool:
	return float(_cooldowns.get(skill_name, 0.0)) <= 0.0

func _start_cooldown(skill_name: String, cooldown: float) -> void:
	_cooldowns[skill_name] = maxf(cooldown, 0.05)

func _effect_float(effect: String, slice_index: int, fallback: float) -> float:
	if effect.get_slice_count(":") <= slice_index:
		return fallback
	return float(effect.get_slice(":", slice_index))

func _restore_player_fire_interval(player: Player, value: float, duration: float) -> void:
	if player == null:
		return
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = maxf(duration, 0.05)
	player.add_child(timer)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(player):
			player.fire_interval = value
			player.set_meta("reload_drill_active", false)
		timer.queue_free()
	)
	timer.start()
