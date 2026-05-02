extends Node
class_name WaveManager

# Tracks placeholder wave data and delegates spawning to the enemy spawner.
# Replace the dictionaries in `wave_definitions` with richer wave configs later.

@export var spawner_path: NodePath = NodePath("../EnemySpawner")
@export var enemy_container_path: NodePath = NodePath("../EnemyContainer")
@export var projectile_container_path: NodePath = NodePath("../ProjectileContainer")
@export var pickup_container_path: NodePath = NodePath("../PickupContainer")
@export var enable_waves: bool = false
@export var spawn_count_increase_per_wave: int = 1
@export var speed_bonus_per_wave: float = 0.15
@export var boss_wave_interval: int = 5
@export var boss_support_spawn_count: int = 2
@export var enemy_recycle_distance: float = 160.0
@export var enemy_recycle_interval: float = 0.4
@export var wave_definitions: Array[Dictionary] = [
    {"spawn_count": 2, "enemy_types": ["normal"]},
    {"spawn_count": 3, "enemy_types": ["normal", "fast"]},
    {"spawn_count": 4, "enemy_types": ["normal", "fast", "tank"]},
]

var current_wave: int = 0
var _waiting_for_upgrade_selection: bool = false
var _active_level_data: LevelData
var game_manager: GameManager
var _enemy_container: Node3D
var _spawner: EnemySpawner
var _projectile_container: Node3D
var _pickup_container: Node3D
var _enemy_recycle_timer: float = 0.0

func _ready() -> void:
    game_manager = get_node("/root/GameManager") as GameManager
    _enemy_container = get_node_or_null(enemy_container_path) as Node3D
    _spawner = get_node_or_null(spawner_path) as EnemySpawner
    _projectile_container = get_node_or_null(projectile_container_path) as Node3D
    _pickup_container = get_node_or_null(pickup_container_path) as Node3D
    current_wave = 0
    if game_manager != null:
        game_manager.upgrade_selected.connect(_on_upgrade_selected)
        game_manager.level_changed.connect(_on_level_changed)

func _process(delta: float) -> void:
    if not enable_waves:
        return
    if game_manager == null or _enemy_container == null:
        return
    if not game_manager.is_gameplay_active or game_manager.is_game_over:
        return
    _enemy_recycle_timer -= delta
    if _enemy_recycle_timer <= 0.0:
        _recycle_far_enemies()
        _enemy_recycle_timer = max(enemy_recycle_interval, 0.05)
    if current_wave <= 0:
        return
    if _waiting_for_upgrade_selection:
        return
    # A wave is complete when no enemies remain in the container.
    if _enemy_container.get_child_count() > 0:
        return

    # All waves done -> advance to the next level or finish the run.
    if _is_level_complete():
        game_manager.grant_wave_clear_reward(current_wave)
        game_manager.complete_current_level()
        return

    # Offer an upgrade choice before starting the next wave.
    _waiting_for_upgrade_selection = true
    game_manager.grant_wave_clear_reward(current_wave)
    game_manager.begin_upgrade_selection()

func _recycle_far_enemies() -> void:
    if _spawner == null or _enemy_container == null or _spawner.player_target == null:
        return

    var recycle_distance: float = maxf(enemy_recycle_distance, 1.0)
    var recycle_distance_squared: float = recycle_distance * recycle_distance

    for child in _enemy_container.get_children():
        if child is not Node3D:
            continue
        var enemy := child as Node3D
        if enemy.global_position.distance_squared_to(_spawner.player_target.global_position) > recycle_distance_squared:
            _spawner.recycle_enemy(enemy)

func start_next_wave() -> void:
    if not enable_waves:
        return

    current_wave += 1

    if _spawner == null:
        return

    if game_manager != null:
        game_manager.set_wave(current_wave)
        game_manager.set_boss_wave(_is_boss_wave(current_wave))

    if _is_boss_wave(current_wave):
        _start_boss_wave(_spawner)
        return

    var wave_definition := _get_wave_definition(current_wave)
    var spawn_count := int(wave_definition.get("spawn_count", _spawner.default_spawn_count))
    spawn_count += max(current_wave - 1, 0) * spawn_count_increase_per_wave

    var speed_bonus := float(wave_definition.get("speed_bonus", 0.0))
    speed_bonus += float(max(current_wave - 1, 0)) * speed_bonus_per_wave
    var enemy_types: Array = wave_definition.get("enemy_types", ["normal"])

    _spawner.spawn_enemies(spawn_count, speed_bonus, enemy_types)

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
        var later_boss_wave_enemies := spawner.spawn_enemies(1 + active_support_spawn_count, speed_bonus, enemy_types)
        _apply_boss_health_scaling(later_boss_wave_enemies)
        return

    var boss_wave_enemies := spawner.spawn_enemies(1, speed_bonus, enemy_types)
    _apply_boss_health_scaling(boss_wave_enemies)

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
    _enemy_recycle_timer = 0.0
    _waiting_for_upgrade_selection = false
    _clear_runtime_nodes()
    if not enable_waves:
        game_manager.set_wave(current_wave)
        game_manager.set_boss_wave(false)
        return
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

func _apply_boss_health_scaling(spawned_enemies: Array[Node3D]) -> void:
    var health_multiplier := _get_boss_health_multiplier()
    if is_equal_approx(health_multiplier, 1.0):
        return

    for spawned_enemy in spawned_enemies:
        if spawned_enemy is Enemy and (spawned_enemy as Enemy).enemy_type == &"boss":
            (spawned_enemy as Enemy).apply_health_multiplier(health_multiplier)

func _get_boss_health_multiplier() -> float:
    var multiplier := 1.0
    var active_interval: int = maxi(_get_active_boss_interval(), 1)
    var boss_tier: int = maxi(int(floor(float(current_wave) / float(active_interval))) - 1, 0)
    multiplier += float(boss_tier) * 0.25

    if _active_level_data != null and _active_level_data.difficulty != null:
        multiplier *= maxf(_active_level_data.difficulty.health_multiplier, 0.1)
    return multiplier

func _clear_runtime_nodes() -> void:
    if _enemy_container != null:
        for child in _enemy_container.get_children():
            child.queue_free()

    if _projectile_container != null:
        for child in _projectile_container.get_children():
            child.queue_free()

    if _pickup_container != null:
        for child in _pickup_container.get_children():
            child.queue_free()
