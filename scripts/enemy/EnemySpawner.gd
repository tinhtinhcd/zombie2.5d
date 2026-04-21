extends Node3D
class_name EnemySpawner

# Spawns enemy placeholder scenes at configured marker points.
# Change the spawn point setup or enemy scene here when wave gameplay is added later.

@export var enemy_scene: PackedScene
@export var enemy_container_path: NodePath = NodePath("../EnemyContainer")
@export var spawn_points_path: NodePath = NodePath("SpawnPoints")
@export var player_target_path: NodePath = NodePath("../Player")
@export var default_spawn_count: int = 3
@export var spawn_distance_multiplier: float = 1.6
@export var minimum_spawn_distance: float = 10.0

var player_target: Node3D
var _enemy_container: Node3D
var _spawn_points: Array[Marker3D] = []
var _spawn_cursor: int = 0

func _ready() -> void:
    player_target = get_node_or_null(player_target_path) as Node3D
    _enemy_container = get_node_or_null(enemy_container_path) as Node3D
    var spawn_points_root := get_node_or_null(spawn_points_path) as Node3D
    if spawn_points_root != null:
        _spawn_points = _get_spawn_points(spawn_points_root)

func spawn_enemies(spawn_count: int = default_spawn_count, speed_bonus: float = 0.0, enemy_types: Array = ["normal"]) -> Array[Node3D]:
    var spawned_enemies: Array[Node3D] = []

    if enemy_scene == null or _enemy_container == null:
        return spawned_enemies

    for index in range(max(spawn_count, 0)):
        var enemy_instance := enemy_scene.instantiate() as Node3D
        if enemy_instance == null:
            continue

        _enemy_container.add_child(enemy_instance)
        enemy_instance.global_position = get_spawn_position(index)
        if enemy_instance is Enemy:
            var enemy_type := "normal"
            if not enemy_types.is_empty():
                enemy_type = str(enemy_types[index % enemy_types.size()])
            enemy_instance.apply_enemy_type(enemy_type)
            enemy_instance.set_target(player_target)
            enemy_instance.move_speed += speed_bonus
        spawned_enemies.append(enemy_instance)

    return spawned_enemies

func recycle_enemy(enemy: Node3D) -> void:
    if enemy == null:
        return
    enemy.global_position = get_spawn_position(_spawn_cursor)
    _spawn_cursor += 1
    if enemy is Enemy:
        (enemy as Enemy).set_target(player_target)

func get_spawn_position(spawn_index: int = 0) -> Vector3:
    if player_target == null:
        if _spawn_points.is_empty():
            return global_position
        return _spawn_points[spawn_index % _spawn_points.size()].global_position

    var weapon_range: float = 20.0
    if player_target is Player:
        weapon_range = max((player_target as Player).weapon_range, 1.0)

    var spawn_distance: float = max(weapon_range * spawn_distance_multiplier, minimum_spawn_distance)
    var angle: float = float(spawn_index) * 2.399963
    if not _spawn_points.is_empty():
        var spawn_point: Marker3D = _spawn_points[spawn_index % _spawn_points.size()]
        var spawn_offset: Vector3 = spawn_point.global_position - global_position
        if not spawn_offset.is_zero_approx():
            angle = atan2(spawn_offset.z, spawn_offset.x)

    var offset: Vector3 = Vector3(cos(angle), 0.0, sin(angle)) * spawn_distance
    return player_target.global_position + offset

func _get_spawn_points(spawn_points_root: Node3D) -> Array[Marker3D]:
    var spawn_points: Array[Marker3D] = []

    for child in spawn_points_root.get_children():
        if child is Marker3D:
            spawn_points.append(child)

    return spawn_points
