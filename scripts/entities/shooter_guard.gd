extends Node3D
class_name ShooterGuard

const COMBAT_UTILS := preload("res://scripts/utils/combat_utils.gd")

@export var target_path: NodePath = NodePath("../../Player")
@export var enemy_container_path: NodePath = NodePath("../../EnemyContainer")
@export var projectile_container_path: NodePath = NodePath("../../ProjectileContainer")
@export var guardian_id: String = "guard_shooter"
@export var projectile_scene: PackedScene
@export var follow_offset: Vector3 = Vector3(1.4, 0.6, 0.9)
@export var follow_speed: float = 7.0
@export var attack_interval: float = 1.0
@export var damage: int = 1
@export var attack_range: float = 16.0
@export var target_scan_interval: float = 0.2
@export var projectile_speed: float = 14.0

var _target: Node3D
var _attack_timer: float = 0.0
var _scan_timer: float = 0.0
var _cached_enemy: Enemy
var _skills: Array = []
var _cooldowns: Dictionary = {}
var game_manager: GameManager

func _ready() -> void:
	game_manager = get_node_or_null("/root/GameManager") as GameManager
	_target = get_node_or_null(target_path) as Node3D
	if projectile_scene == null:
		projectile_scene = load("res://scenes/effects/projectile.tscn") as PackedScene
	_load_definition()

func _process(delta: float) -> void:
	_tick_cooldowns(delta)
	if _target == null:
		_target = get_node_or_null(target_path) as Node3D
	if _target != null:
		var desired_position := _target.global_position + follow_offset
		global_position = global_position.lerp(desired_position, min(delta * follow_speed, 1.0))

	if game_manager != null and not game_manager.is_gameplay_active:
		return

	_attack_timer -= delta
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_cached_enemy = _find_nearest_enemy()
		_scan_timer = max(target_scan_interval, 0.05)

	if not _skills.is_empty():
		if _try_reload_drill():
			return
		if _try_focus_shot():
			return
		if _try_cover_fire():
			return
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
	var follow_distance := float(definition.get("follow_distance", follow_offset.length()))
	if follow_distance > 0.0:
		follow_offset = Vector3(1.0, 0.25, 0.7).normalized() * follow_distance
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

func _try_cover_fire() -> bool:
	var skill := _get_skill("Cover Fire")
	if skill.is_empty() or not _is_ready("Cover Fire"):
		return false
	if _cached_enemy == null or not is_instance_valid(_cached_enemy) or _cached_enemy.is_dead():
		return false
	var range := float(skill.get("range", attack_range))
	if range > 0.0 and global_position.distance_squared_to(_cached_enemy.global_position) > range * range:
		_cached_enemy = null
		return false
	_shoot_at(_cached_enemy, int(skill.get("damage", damage)), range, str(skill.get("effect", "projectile")))
	_start_cooldown("Cover Fire", float(skill.get("cooldown", attack_interval)))
	return true

func _try_focus_shot() -> bool:
	var skill := _get_skill("Focus Shot")
	if skill.is_empty() or not _is_ready("Focus Shot"):
		return false
	var target_enemy := _find_highest_hp_enemy(float(skill.get("range", 20.0)))
	if target_enemy == null and _cached_enemy != null and is_instance_valid(_cached_enemy) and not _cached_enemy.is_dead():
		target_enemy = _cached_enemy
	if target_enemy == null:
		return false
	_shoot_at(target_enemy, int(skill.get("damage", 3)), float(skill.get("range", 20.0)), str(skill.get("effect", "pierce")))
	_start_cooldown("Focus Shot", float(skill.get("cooldown", 6.0)))
	return true

func _try_reload_drill() -> bool:
	var skill := _get_skill("Reload Drill")
	if skill.is_empty() or not _is_ready("Reload Drill"):
		return false
	if _target == null:
		_target = get_node_or_null(target_path) as Node3D
	if _target is not Player:
		return false
	if _cached_enemy == null or not is_instance_valid(_cached_enemy) or _cached_enemy.is_dead():
		return false
	var player := _target as Player
	if bool(player.get_meta("reload_drill_active", false)):
		return false
	var effect := str(skill.get("effect", "fire_rate_buff:1.15:4.0"))
	var multiplier := _effect_float(effect, 1, 1.15)
	var duration := _effect_float(effect, 2, 4.0)
	var original_fire_interval := player.fire_interval
	player.set_meta("reload_drill_active", true)
	player.fire_interval = maxf(original_fire_interval / maxf(multiplier, 0.1), 0.12)
	_restore_player_fire_interval(player, original_fire_interval, duration)
	_start_cooldown("Reload Drill", float(skill.get("cooldown", 12.0)))
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

func _get_skill(skill_name: String) -> Dictionary:
	for skill in _skills:
		if typeof(skill) == TYPE_DICTIONARY and str((skill as Dictionary).get("name", "")) == skill_name:
			return (skill as Dictionary).duplicate(true)
	return {}

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
