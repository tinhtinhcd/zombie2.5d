extends Area3D
class_name Projectile

# Minimal projectile scaffold.
# Add damage, collision responses, and ownership rules here later.

const HIT_SPARK_SCENE := preload("res://scenes/effects/hit_spark.tscn")

@export var speed: float = 14.0
@export var lifetime: float = 1.5
@export var damage: int = 1
@export var max_distance: float = 20.0
@export var effect_container_path: NodePath = NodePath("../../EffectContainer")

signal recycle_requested(projectile: Projectile, defer_pool: bool)

var direction: Vector3 = Vector3.FORWARD
var weapon_id: String = ""
var special_effect: String = "none"
var knockback_strength: float = 0.0
var _time_alive: float = 0.0
var _origin: Vector3 = Vector3.ZERO
var _has_hit: bool = false
var _is_recycling: bool = false
var audio_manager: AudioManager

func _ready() -> void:
	_origin = global_position
	audio_manager = get_node_or_null("/root/AudioManager") as AudioManager
	body_entered.connect(_on_body_entered)

func setup(move_direction: Vector3, travel_distance: float = -1.0) -> void:
	_time_alive = 0.0
	_has_hit = false
	_is_recycling = false
	_origin = global_position
	visible = true
	monitoring = true
	monitorable = true
	set_physics_process(true)
	if travel_distance > 0.0:
		max_distance = travel_distance
	var resolved_speed := maxf(speed, 0.001)
	if max_distance > 0.0:
		lifetime = maxf(lifetime, max_distance / resolved_speed)
	if move_direction.is_zero_approx():
		direction = Vector3.FORWARD
		return
	direction = move_direction.normalized()
	_face_direction(direction)

func deactivate(defer_collision_update: bool = false) -> void:
	visible = false
	if defer_collision_update:
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
	else:
		monitoring = false
		monitorable = false
	set_physics_process(false)

func recycle(defer_collision_update: bool = false) -> void:
	if _is_recycling:
		return

	_is_recycling = true
	deactivate(defer_collision_update)
	if recycle_requested.get_connections().is_empty():
		queue_free()
		return
	recycle_requested.emit(self, defer_collision_update)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

	_time_alive += delta
	if _time_alive >= lifetime:
		recycle()
		return

	if max_distance > 0.0 and global_position.distance_to(_origin) >= max_distance:
		recycle()

func _on_body_entered(body: Node) -> void:
	if _has_hit:
		return
	if body is not Enemy:
		return

	_has_hit = true
	_spawn_hit_spark()
	if audio_manager != null:
		audio_manager.play_sfx_event(&"hit")
	var enemy := body as Enemy
	enemy.take_damage(_get_effective_damage(), global_position, direction, knockback_strength)
	_apply_special_effect(enemy)
	recycle(true)

func _get_effective_damage() -> int:
	if special_effect == "overheat_burst":
		return damage + 1
	return damage

func _apply_special_effect(hit_enemy: Enemy) -> void:
	match special_effect:
		"ricochet":
			_apply_bounce(hit_enemy, 1)
		"multi_bounce":
			_apply_bounce(hit_enemy, 2)
		"cluster_bomb":
			_spawn_cluster_bomb()

func _apply_bounce(hit_enemy: Enemy, max_bounces: int) -> void:
	var enemy_container := hit_enemy.get_parent()
	if enemy_container == null:
		return
	var already_hit := [hit_enemy]
	var bounce_origin := hit_enemy.global_position
	for bounce_index in range(maxi(max_bounces, 1)):
		var nearest_enemy: Enemy
		var nearest_distance := 49.0
		for child in enemy_container.get_children():
			if child in already_hit or child is not Enemy:
				continue
			var enemy := child as Enemy
			if enemy.is_dead():
				continue
			var distance := enemy.global_position.distance_squared_to(bounce_origin)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_enemy = enemy
		if nearest_enemy == null:
			return
		var bounce_damage := maxi(roundi(float(damage) * (0.65 if special_effect == "multi_bounce" else 0.5)), 1)
		var bounce_direction := nearest_enemy.global_position - bounce_origin
		if bounce_direction.is_zero_approx():
			bounce_direction = direction
		nearest_enemy.take_damage(bounce_damage, nearest_enemy.global_position, bounce_direction.normalized(), 0.5)
		already_hit.append(nearest_enemy)
		bounce_origin = nearest_enemy.global_position

func _spawn_cluster_bomb() -> void:
	var explosion_scene := load("res://scenes/effects/explosion_aoe.tscn") as PackedScene
	if explosion_scene == null:
		return
	var explosion := explosion_scene.instantiate() as Node3D
	if explosion == null:
		return
	var effect_container := get_node_or_null(effect_container_path) as Node3D
	if effect_container == null:
		effect_container = get_parent() as Node3D
	if effect_container == null:
		return
	effect_container.add_child(explosion)
	if explosion.has_method("setup"):
		explosion.call("setup", global_position, 2.6, max(damage, 1), 1.8)
	else:
		explosion.global_position = global_position

func _spawn_hit_spark() -> void:
	var spark := HIT_SPARK_SCENE.instantiate() as Node3D
	if spark == null:
		return
	var effect_container := get_node_or_null(effect_container_path) as Node3D
	if effect_container == null:
		effect_container = get_parent() as Node3D
	if effect_container == null:
		return
	effect_container.add_child(spark)
	spark.global_position = global_position
	_orient_node_to_direction(spark, direction)

func _face_direction(world_direction: Vector3) -> void:
	_orient_node_to_direction(self, world_direction)

func _orient_node_to_direction(node: Node3D, world_direction: Vector3) -> void:
	if node == null or world_direction.is_zero_approx():
		return
	var normalized_direction := world_direction.normalized()
	var up_axis := Vector3.UP
	if absf(normalized_direction.dot(up_axis)) > 0.96:
		up_axis = Vector3.RIGHT
	node.look_at(node.global_position + normalized_direction, up_axis)
