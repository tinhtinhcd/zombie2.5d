extends Node3D
class_name PetCompanion

const HIT_SPARK_SCENE := preload("res://scenes/effects/hit_spark.tscn")
const SHOCKWAVE_SCENE := preload("res://scenes/effects/shockwave.tscn")

@export var target_path: NodePath = NodePath("../Player")
@export var enemy_container_path: NodePath = NodePath("../EnemyContainer")
@export var effect_container_path: NodePath = NodePath("../EffectContainer")
@export var follow_offset: Vector3 = Vector3(-1.2, 0.7, 0.8)
@export var follow_speed: float = 8.0
@export var attack_interval: float = 1.2
@export var damage: int = 1
@export var attack_range: float = 16.0
<<<<<<< ours
@export var shockwave_interval: float = 5.0
@export var shockwave_radius: float = 3.0
=======
@export var target_scan_interval: float = 0.2
@export var enable_active_attack: bool = false
>>>>>>> theirs

var _target: Node3D
var _attack_timer: float = 0.0
var _shockwave_timer: float = 1.0
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
	if not enable_active_attack:
		return

	_attack_timer -= delta
	_shockwave_timer -= delta
	if _attack_timer > 0.0:
		return

	var enemy := _find_nearest_enemy()
	if enemy == null:
		return

	enemy.take_damage(damage, enemy.global_position, enemy.global_position - global_position, 0.0)
	_spawn_hit_spark(enemy.global_position)
	if _shockwave_timer <= 0.0:
		_emit_pet_shockwave()
		_shockwave_timer = max(shockwave_interval, 0.5)
	_attack_timer = max(attack_interval, 0.2)

func apply_pet_definition(definition: Dictionary) -> void:
	damage = int(definition.get("damage", damage))
	attack_interval = float(definition.get("attack_interval", attack_interval))
	attack_range = float(definition.get("attack_range", attack_range))
	shockwave_interval = float(definition.get("shockwave_interval", shockwave_interval))
	shockwave_radius = float(definition.get("shockwave_radius", shockwave_radius))

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
		if enemy.current_hp <= 0:
			continue
		var distance := global_position.distance_squared_to(enemy.global_position)
		if attack_range > 0.0 and distance > range_squared:
			continue
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	return nearest_enemy

func _emit_pet_shockwave() -> void:
	var effect_container := _get_effect_container()
	var shockwave := SHOCKWAVE_SCENE.instantiate() as Node3D
	if shockwave != null:
		effect_container.add_child(shockwave)
		shockwave.global_position = global_position

	var enemy_container := get_node_or_null(enemy_container_path) as Node3D
	if enemy_container == null:
		return
	var radius_squared := shockwave_radius * shockwave_radius
	for child in enemy_container.get_children():
		if child is not Enemy:
			continue
		var enemy := child as Enemy
		var offset := enemy.global_position - global_position
		if offset.length_squared() <= radius_squared:
			enemy.take_damage(max(damage, 1), enemy.global_position, offset.normalized(), 1.0)

func _spawn_hit_spark(world_position: Vector3) -> void:
	var spark := HIT_SPARK_SCENE.instantiate() as Node3D
	if spark == null:
		return
	_get_effect_container().add_child(spark)
	spark.global_position = world_position

func _get_effect_container() -> Node3D:
	var effect_container := get_node_or_null(effect_container_path) as Node3D
	if effect_container != null:
		return effect_container
	if get_parent() is Node3D:
		return get_parent() as Node3D
	return self
