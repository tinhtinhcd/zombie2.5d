extends Node3D
class_name EnemySpawner

# Spawns enemy placeholder scenes at configured marker points.
# Change the spawn point setup or enemy scene here when wave gameplay is added later.

@export var enemy_scene: PackedScene
@export var enemy_container_path: NodePath = NodePath("../EnemyContainer")
@export var spawn_points_path: NodePath = NodePath("SpawnPoints")
@export var player_target_path: NodePath = NodePath("../Player")
@export var default_spawn_count: int = 3

var player_target: Node3D

func _ready() -> void:
    player_target = get_node_or_null(player_target_path) as Node3D

func spawn_enemies(spawn_count: int = default_spawn_count, speed_bonus: float = 0.0, enemy_types: Array = ["normal"]) -> Array[Node3D]:
    var spawned_enemies: Array[Node3D] = []
    var enemy_container := get_node_or_null(enemy_container_path) as Node3D
    var spawn_points_root := get_node_or_null(spawn_points_path) as Node3D

    if enemy_scene == null or enemy_container == null or spawn_points_root == null:
        return spawned_enemies

    var spawn_points := _get_spawn_points(spawn_points_root)
    if spawn_points.is_empty():
        return spawned_enemies

    for index in range(max(spawn_count, 0)):
        var enemy_instance := enemy_scene.instantiate() as Node3D
        if enemy_instance == null:
            continue

        var spawn_point := spawn_points[index % spawn_points.size()]
        enemy_container.add_child(enemy_instance)
        enemy_instance.global_position = spawn_point.global_position
        enemy_instance.global_rotation = spawn_point.global_rotation
        if enemy_instance is Enemy:
            var enemy_type := "normal"
            if not enemy_types.is_empty():
                enemy_type = str(enemy_types[index % enemy_types.size()])
            enemy_instance.apply_enemy_type(enemy_type)
            enemy_instance.set_target(player_target)
            enemy_instance.move_speed += speed_bonus
        spawned_enemies.append(enemy_instance)

    return spawned_enemies

func _get_spawn_points(spawn_points_root: Node3D) -> Array[Marker3D]:
    var spawn_points: Array[Marker3D] = []

    for child in spawn_points_root.get_children():
        if child is Marker3D:
            spawn_points.append(child)

    return spawn_points
