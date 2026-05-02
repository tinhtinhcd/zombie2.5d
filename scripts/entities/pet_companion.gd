extends Node3D
class_name PetCompanion

@export var target_path: NodePath = NodePath("../Player")
@export var enemy_container_path: NodePath = NodePath("../EnemyContainer")
@export var follow_offset: Vector3 = Vector3(-1.2, 0.7, 0.8)
@export var follow_speed: float = 8.0
@export var attack_interval: float = 1.2
@export var damage: int = 1
@export var attack_range: float = 16.0
@export var target_scan_interval: float = 0.2

var _target: Node3D
var _attack_timer: float = 0.0
var _scan_timer: float = 0.0
var _cached_enemy: Enemy
var game_manager: GameManager

func _ready() -> void:
	game_manager = get_node("/root/GameManager") as GameManager
	_target = get_node_or_null(target_path) as Node3D

func _process(delta: float) -> void:
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
	if _attack_timer > 0.0:
		return

	var enemy := _cached_enemy
	if enemy == null or not is_instance_valid(enemy):
		return
	if attack_range > 0.0 and global_position.distance_squared_to(enemy.global_position) > attack_range * attack_range:
		_cached_enemy = null
		return

	enemy.take_damage(damage)
	_attack_timer = max(attack_interval, 0.2)

func apply_pet_definition(definition: Dictionary) -> void:
	damage = int(definition.get("damage", damage))
	attack_interval = float(definition.get("attack_interval", attack_interval))
	attack_range = float(definition.get("attack_range", attack_range))
	_cached_enemy = null

func _find_nearest_enemy() -> Enemy:
	var enemy_container := get_node_or_null(enemy_container_path) as Node3D
	if enemy_container == null:
		return null

	var nearest_enemy: Enemy
	var nearest_distance := INF
	var range_squared := attack_range * attack_range
	for child in enemy_container.get_children():
		if child is not Enemy:
			continue
		var enemy := child as Enemy
		var distance := global_position.distance_squared_to(enemy.global_position)
		if attack_range > 0.0 and distance > range_squared:
			continue
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	return nearest_enemy
