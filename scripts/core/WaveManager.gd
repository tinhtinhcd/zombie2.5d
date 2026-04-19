extends Node
class_name WaveManager

# Tracks placeholder wave data and delegates spawning to the enemy spawner.
# Replace the dictionaries in `wave_definitions` with richer wave configs later.

@export var spawner_path: NodePath = NodePath("../EnemySpawner")
@export var enemy_container_path: NodePath = NodePath("../EnemyContainer")
@export var projectile_container_path: NodePath = NodePath("../ProjectileContainer")
@export var pickup_container_path: NodePath = NodePath("../PickupContainer")
@export var spawn_count_increase_per_wave: int = 1
@export var speed_bonus_per_wave: float = 0.15
@export var boss_wave_interval: int = 5
@export var boss_support_spawn_count: int = 2
@export var wave_definitions: Array[Dictionary] = [
    {"spawn_count": 2, "enemy_types": ["normal"]},
    {"spawn_count": 3, "enemy_types": ["normal", "fast"]},
    {"spawn_count": 4, "enemy_types": ["normal", "fast", "tank"]},
]

var current_wave: int = 0
var _waiting_for_upgrade_selection: bool = false
var _active_level_data: LevelData
var game_manager: GameManager

func _ready() -> void:
    game_manager = get_node("/root/GameManager") as GameManager
    current_wave = 0
    if game_manager != null:
        game_manager.upgrade_selected.connect(_on_upgrade_selected)
        game_manager.level_changed.connect(_on_level_changed)

func _process(_delta: float) -> void:
    var enemy_container := get_node_or_null(enemy_container_path) as Node3D
    if game_manager == null or enemy_container == null:
        return
    if not game_manager.is_gameplay_active or game_manager.is_game_over:
        return
    if current_wave <= 0:
        return
    if _waiting_for_upgrade_selection:
        return
    if enemy_container.get_child_count() > 0:
        return

    if _is_level_complete():
        game_manager.advance_to_next_level()
        return

    _waiting_for_upgrade_selection = true
    game_manager.begin_upgrade_selection()

func start_next_wave() -> void:
    current_wave += 1

    var spawner := get_node_or_null(spawner_path) as EnemySpawner
    if spawner == null:
        return

    if game_manager != null:
        game_manager.set_wave(current_wave)
        game_manager.set_boss_wave(_is_boss_wave(current_wave))

    if _is_boss_wave(current_wave):
        _start_boss_wave(spawner)
        return

    var wave_definition := _get_wave_definition(current_wave)
    var spawn_count := int(wave_definition.get("spawn_count", spawner.default_spawn_count))
    spawn_count += max(current_wave - 1, 0) * spawn_count_increase_per_wave

    var speed_bonus := float(wave_definition.get("speed_bonus", 0.0))
    speed_bonus += float(max(current_wave - 1, 0)) * speed_bonus_per_wave
    var enemy_types: Array = wave_definition.get("enemy_types", ["normal"])

    spawner.spawn_enemies(spawn_count, speed_bonus, enemy_types)

func _get_wave_definition(wave_number: int) -> Dictionary:
    var active_wave_definitions := _get_active_wave_definitions()
    if active_wave_definitions.is_empty():
        return {"spawn_count": 0}

    var definition_index := mini(wave_number - 1, active_wave_definitions.size() - 1)
    return active_wave_definitions[definition_index]

func _is_boss_wave(wave_number: int) -> bool:
    var active_boss_wave_interval := boss_wave_interval
    if _active_level_data != null and _active_level_data.boss_wave_interval > 0:
        active_boss_wave_interval = _active_level_data.boss_wave_interval
    return active_boss_wave_interval > 0 and wave_number > 0 and wave_number % active_boss_wave_interval == 0

func _start_boss_wave(spawner: EnemySpawner) -> void:
    var speed_bonus := float(max(current_wave - 1, 0)) * speed_bonus_per_wave
    var enemy_types: Array = ["boss"]
    var active_support_spawn_count := boss_support_spawn_count
    if _active_level_data != null and _active_level_data.boss_support_spawn_count > 0:
        active_support_spawn_count = _active_level_data.boss_support_spawn_count

    if current_wave >= max(_get_active_boss_interval(), 1) * 2:
        enemy_types.append_array(["normal", "fast"])
        spawner.spawn_enemies(1 + active_support_spawn_count, speed_bonus, enemy_types)
        return

    spawner.spawn_enemies(1, speed_bonus, enemy_types)

func _on_upgrade_selected(_upgrade_id: StringName) -> void:
    if not _waiting_for_upgrade_selection:
        return

    _waiting_for_upgrade_selection = false
    start_next_wave()

func _on_level_changed(_level_index: int, _level_id: StringName, _display_name: String) -> void:
    if game_manager == null:
        return

    _active_level_data = game_manager.current_level_data
    current_wave = 0
    _waiting_for_upgrade_selection = false
    _clear_runtime_nodes()
    call_deferred("start_next_wave")

func _is_level_complete() -> bool:
    return current_wave >= _get_active_wave_count()

func _get_active_wave_count() -> int:
    if _active_level_data != null:
        return max(_active_level_data.wave_count, 1)
    return max(wave_definitions.size(), 1)

func _get_active_wave_definitions() -> Array[Dictionary]:
    if _active_level_data != null and not _active_level_data.wave_definitions.is_empty():
        return _active_level_data.wave_definitions

    if _active_level_data != null and not _active_level_data.enemy_types.is_empty():
        return [{
            "spawn_count": 2,
            "enemy_types": _active_level_data.enemy_types,
        }]

    return wave_definitions

func _get_active_boss_interval() -> int:
    if _active_level_data != null and _active_level_data.boss_wave_interval > 0:
        return _active_level_data.boss_wave_interval
    return boss_wave_interval

func _clear_runtime_nodes() -> void:
    var enemy_container := get_node_or_null(enemy_container_path) as Node3D
    var projectile_container := get_node_or_null(projectile_container_path) as Node3D
    var pickup_container := get_node_or_null(pickup_container_path) as Node3D

    if enemy_container != null:
        for child in enemy_container.get_children():
            child.queue_free()

    if projectile_container != null:
        for child in projectile_container.get_children():
            child.queue_free()

    if pickup_container != null:
        for child in pickup_container.get_children():
            child.queue_free()
