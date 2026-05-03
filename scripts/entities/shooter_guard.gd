extends Node3D
class_name ShooterGuard

const COMBAT_UTILS := preload("res://scripts/utils/combat_utils.gd")

@export var target_path: NodePath = NodePath("../Player")
@export var enemy_container_path: NodePath = NodePath("../EnemyContainer")
@export var projectile_container_path: NodePath = NodePath("../ProjectileContainer")
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
var game_manager: GameManager

func _ready() -> void:
	game_manager = get_node_or_null("/root/GameManager") as GameManager
	_target = get_node_or_null(target_path) as Node3D
	if projectile_scene == null:
		projectile_scene = load("res://scenes/effects/projectile.tscn") as PackedScene

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

	if _cached_enemy == null or not is_instance_valid(_cached_enemy) or _cached_enemy.is_dead():
		return
	if attack_range > 0.0 and global_position.distance_squared_to(_cached_enemy.global_position) > attack_range * attack_range:
		_cached_enemy = null
		return
	_shoot_at(_cached_enemy)
	_attack_timer = max(attack_interval, 0.2)

func _shoot_at(enemy: Enemy) -> void:
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
	projectile.damage = damage
	projectile.speed = projectile_speed
	projectile.setup(enemy.global_position - global_position, attack_range)

func _find_nearest_enemy() -> Enemy:
	var enemy_container := get_node_or_null(enemy_container_path) as Node3D
	if enemy_container == null:
		return null
	return COMBAT_UTILS.find_nearest_enemy(global_position, enemy_container.get_children(), attack_range)
