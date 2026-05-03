extends CharacterBody3D
class_name BruiserGuard

enum State { FOLLOW, EVALUATE, CAST, COOLDOWN }

const SHOCKWAVE_SCENE := preload("res://scenes/effects/shockwave.tscn")

@export var target_path: NodePath = NodePath("../../Player")
@export var enemy_container_path: NodePath = NodePath("../../EnemyContainer")
@export var effect_container_path: NodePath = NodePath("../../EffectContainer")
@export var move_speed: float = 5.0

var target: Player
var game_manager: GameManager
var state: State = State.FOLLOW
var follow_distance: float = 1.8
var scan_interval: float = 0.2
var _scan_timer: float = 0.0
var _cooldowns: Dictionary = {}
var _skills: Array = []

func _ready() -> void:
	game_manager = get_node("/root/GameManager") as GameManager
	target = get_node_or_null(target_path) as Player
	_load_definition()

func _physics_process(delta: float) -> void:
	if game_manager != null and not game_manager.is_gameplay_active:
		velocity = Vector3.ZERO
		return

	_tick_cooldowns(delta)
	_follow_player(delta)
	_scan_timer = maxf(_scan_timer - delta, 0.0)
	if _scan_timer <= 0.0:
		_scan_timer = maxf(scan_interval, 0.05)
		_evaluate_skills()

func _load_definition() -> void:
	if game_manager == null:
		return
	var definition := game_manager.get_guardian("guard_bruiser")
	follow_distance = float(definition.get("follow_distance", follow_distance))
	scan_interval = float(definition.get("scan_interval", scan_interval))
	var skills_value: Variant = definition.get("skills", [])
	if typeof(skills_value) == TYPE_ARRAY:
		_skills = skills_value.duplicate(true)
	for skill in _skills:
		if typeof(skill) == TYPE_DICTIONARY:
			_cooldowns[str((skill as Dictionary).get("name", ""))] = 0.0

func _follow_player(delta: float) -> void:
	if target == null:
		target = get_node_or_null(target_path) as Player
	if target == null:
		return
	var desired_offset := Vector3(1.4, 0.0, 1.0).normalized() * follow_distance
	var desired_position := target.global_position + desired_offset
	var offset := desired_position - global_position
	offset.y = 0.0
	if offset.length() <= 0.15:
		velocity = Vector3.ZERO
	else:
		velocity = offset.normalized() * move_speed
	move_and_slide()

func _evaluate_skills() -> void:
	state = State.EVALUATE
	if _try_emergency_heal():
		return
	if _try_slam():
		return
	if _try_cleave():
		return
	state = State.FOLLOW

func _try_slam() -> bool:
	var skill := _get_skill("Slam")
	if skill.is_empty() or not _is_ready("Slam"):
		return false
	var enemies := _get_enemies_in_radius(float(skill.get("range", 2.5)))
	if enemies.size() < 2:
		return false
	_spawn_shockwave()
	for enemy in enemies:
		var offset := enemy.global_position - global_position
		enemy.take_damage(int(skill.get("damage", 2)), enemy.global_position, offset.normalized(), 3.0)
	_start_cooldown("Slam", float(skill.get("cooldown", 5.0)))
	return true

func _try_cleave() -> bool:
	var skill := _get_skill("Cleave")
	if skill.is_empty() or not _is_ready("Cleave"):
		return false
	var enemies := _get_enemies_in_radius(float(skill.get("range", 1.5)))
	if enemies.is_empty():
		return false
	var forward := (target.global_position - global_position).normalized() if target != null else Vector3.FORWARD
	var did_hit := false
	for enemy in enemies:
		var offset := enemy.global_position - global_position
		if offset.is_zero_approx() or forward.dot(offset.normalized()) < 0.0:
			continue
		enemy.take_damage(int(skill.get("damage", 1)), enemy.global_position, offset.normalized(), 1.5)
		did_hit = true
	if not did_hit:
		return false
	_start_cooldown("Cleave", float(skill.get("cooldown", 2.5)))
	return true

func _try_emergency_heal() -> bool:
	var skill := _get_skill("Emergency Heal")
	if target == null or skill.is_empty() or not _is_ready("Emergency Heal"):
		return false
	if target.current_hp > roundi(float(target.max_hp) * 0.4):
		return false
	var heal_amount := 2
	var effect := str(skill.get("effect", "heal:2"))
	if effect.begins_with("heal:"):
		heal_amount = int(effect.get_slice(":", 1))
	target.restore_hp(heal_amount)
	_start_cooldown("Emergency Heal", float(skill.get("cooldown", 14.0)))
	return true

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

func _tick_cooldowns(delta: float) -> void:
	for key in _cooldowns.keys():
		_cooldowns[key] = maxf(float(_cooldowns.get(key, 0.0)) - delta, 0.0)

func _is_ready(skill_name: String) -> bool:
	return float(_cooldowns.get(skill_name, 0.0)) <= 0.0

func _start_cooldown(skill_name: String, cooldown: float) -> void:
	_cooldowns[skill_name] = maxf(cooldown, 0.05)
	state = State.COOLDOWN

func _get_skill(skill_name: String) -> Dictionary:
	for skill in _skills:
		if typeof(skill) == TYPE_DICTIONARY and str((skill as Dictionary).get("name", "")) == skill_name:
			return (skill as Dictionary).duplicate(true)
	return {}
