extends Node
class_name GameManager

# Central game state manager for session-level values.

signal score_changed(new_score: int)
signal xp_changed(new_xp: int)
signal level_changed(level_index: int, level_id: StringName, display_name: String)
signal wave_changed(new_wave: int)
signal boss_wave_changed(is_boss_wave_now: bool)
signal game_over_changed(is_game_over_now: bool)
signal upgrade_options_requested(options: Array)
signal upgrade_selection_closed
signal upgrade_selected(upgrade_id: StringName)
signal permanent_upgrades_changed(upgrades: Dictionary)
signal highest_unlocked_level_changed(new_highest_unlocked_level: int)

const UPGRADE_DEFINITIONS := [
    {
        "id": &"projectile_damage",
        "title": "Power Shot",
        "description": "Increase projectile damage by 1.",
    },
    {
        "id": &"fire_rate",
        "title": "Rapid Fire",
        "description": "Reduce fire interval slightly.",
    },
    {
        "id": &"max_hp",
        "title": "Vitality",
        "description": "Increase max HP by 2.",
    },
    {
        "id": &"restore_hp",
        "title": "Recover",
        "description": "Restore 4 HP.",
    },
]

const PERMANENT_UPGRADE_DEFINITIONS := {
    "perm_max_hp": {
        "title": "Vitality",
        "description": "Permanent +2 max HP per rank.",
        "max_rank": 5,
    },
    "perm_fire_rate": {
        "title": "Trigger Discipline",
        "description": "Permanent fire interval reduction per rank.",
        "max_rank": 5,
    },
    "perm_projectile_damage": {
        "title": "Sharpened Shot",
        "description": "Permanent +1 projectile damage per rank.",
        "max_rank": 5,
    },
}

var score: int = 0
var xp: int = 0
var current_level: int = 1
var current_level_id: StringName = &""
var current_level_display_name: String = ""
var current_wave: int = 0
var is_boss_wave: bool = false
var is_paused: bool = false
var is_game_over: bool = false
var is_upgrade_selection_active: bool = false
var is_gameplay_active: bool = true

var current_level_data: LevelData
var _levels: Array[LevelData] = []
var highest_unlocked_level: int = 1
var permanent_upgrades: Dictionary = {}
var _progression_loaded: bool = false

func _ready() -> void:
    # Only load data here. reset_game() is called by game.gd when
    # the gameplay scene starts, so we avoid duplicate signal emissions.
    _ensure_levels_loaded()
    _ensure_progression_loaded()

func reset_game() -> void:
    # Restore default session state for a fresh run.
    _ensure_levels_loaded()
    _ensure_progression_loaded()
    score = 0
    xp = 0
    current_wave = 0
    is_boss_wave = false
    is_paused = false
    is_game_over = false
    is_upgrade_selection_active = false
    load_level_by_index(1)
    _update_gameplay_active()
    score_changed.emit(score)
    xp_changed.emit(xp)
    boss_wave_changed.emit(is_boss_wave)
    game_over_changed.emit(is_game_over)
    upgrade_selection_closed.emit()

func pause_game() -> void:
    # Reserve engine pause and gameplay coordination for later systems.
    if is_game_over:
        return
    is_paused = true
    _update_gameplay_active()

func resume_game() -> void:
    # Clear the pause flag without affecting gameplay systems yet.
    if is_game_over:
        return
    is_paused = false
    _update_gameplay_active()

func add_score(amount: int) -> void:
    # Keep score changes centralized for future UI and progression hooks.
    score += max(amount, 0)
    score_changed.emit(score)

func add_xp(amount: int) -> void:
    xp += max(amount, 0)
    xp_changed.emit(xp)

func set_wave(wave: int) -> void:
    current_wave = max(wave, 0)
    wave_changed.emit(current_wave)

func set_boss_wave(is_boss_wave_now: bool) -> void:
    is_boss_wave = is_boss_wave_now
    boss_wave_changed.emit(is_boss_wave)

func trigger_game_over() -> void:
    if is_game_over:
        return
    is_game_over = true
    _update_gameplay_active()
    game_over_changed.emit(is_game_over)

func restart_game() -> void:
    # Intentional roguelike loop: restart always begins a fresh run from
    # level 1 with default session stats. Permanent upgrades are preserved
    # across runs via SaveManager.
    reset_game()
    var scene_router := get_node_or_null("/root/SceneRouter") as SceneRouter
    if scene_router != null:
        scene_router.go_to_game()

func unlock_permanent_upgrade(upgrade_id: StringName) -> bool:
    _ensure_progression_loaded()

    var definition: Dictionary = PERMANENT_UPGRADE_DEFINITIONS.get(String(upgrade_id), {})
    if definition.is_empty():
        return false

    var upgrade_key := String(upgrade_id)
    var current_rank := get_permanent_upgrade_rank(upgrade_id)
    var max_rank := int(definition.get("max_rank", 1))
    if current_rank >= max_rank:
        return false

    permanent_upgrades[upgrade_key] = current_rank + 1
    _save_progression()
    permanent_upgrades_changed.emit(permanent_upgrades.duplicate(true))
    return true

func get_permanent_upgrade_rank(upgrade_id: StringName) -> int:
    _ensure_progression_loaded()
    return int(permanent_upgrades.get(String(upgrade_id), 0))

func apply_permanent_upgrades(player: Player) -> void:
    _ensure_progression_loaded()
    if player == null:
        return

    var max_hp_rank := get_permanent_upgrade_rank(&"perm_max_hp")
    if max_hp_rank > 0:
        player.increase_max_hp(max_hp_rank * 2)

    var fire_rate_rank := get_permanent_upgrade_rank(&"perm_fire_rate")
    if fire_rate_rank > 0:
        player.reduce_fire_interval(0.04 * fire_rate_rank)

    var projectile_damage_rank := get_permanent_upgrade_rank(&"perm_projectile_damage")
    if projectile_damage_rank > 0:
        player.increase_projectile_damage(projectile_damage_rank)

func load_level_by_index(level_index: int) -> void:
    _ensure_levels_loaded()
    if _levels.is_empty():
        current_level = 1
        current_level_id = &"level_001"
        current_level_display_name = "Level 1"
        current_level_data = null
        level_changed.emit(current_level, current_level_id, current_level_display_name)
        wave_changed.emit(current_wave)
        return

    var resolved_index := clampi(level_index, 1, _levels.size())
    current_level = resolved_index
    current_level_data = _levels[resolved_index - 1]
    current_level_id = current_level_data.level_id
    current_level_display_name = current_level_data.display_name if not current_level_data.display_name.is_empty() else "Level %d" % current_level
    current_wave = 0
    is_boss_wave = false
    level_changed.emit(current_level, current_level_id, current_level_display_name)
    wave_changed.emit(current_wave)
    boss_wave_changed.emit(is_boss_wave)

func load_level_by_id(level_id: StringName) -> void:
    _ensure_levels_loaded()
    for index in range(_levels.size()):
        var level_data := _levels[index]
        if level_data.level_id == level_id:
            load_level_by_index(index + 1)
            return

func advance_to_next_level() -> void:
    _ensure_levels_loaded()
    if _levels.is_empty():
        load_level_by_index(1)
        return

    unlock_level(current_level + 1)

    var next_level := current_level + 1
    if next_level > _levels.size():
        next_level = 1
    load_level_by_index(next_level)

func unlock_level(level_index: int) -> void:
    _ensure_levels_loaded()
    _ensure_progression_loaded()

    var resolved_level: int = max(level_index, 1)
    if not _levels.is_empty():
        resolved_level = clampi(resolved_level, 1, _levels.size())

    if resolved_level <= highest_unlocked_level:
        return

    highest_unlocked_level = resolved_level
    _save_progression()
    highest_unlocked_level_changed.emit(highest_unlocked_level)

func begin_upgrade_selection() -> void:
    if is_game_over:
        return

    is_upgrade_selection_active = true
    _update_gameplay_active()
    upgrade_options_requested.emit(_get_upgrade_options())

func select_upgrade(player: Player, upgrade_id: StringName) -> void:
    if not is_upgrade_selection_active:
        return

    _apply_upgrade(player, upgrade_id)
    is_upgrade_selection_active = false
    _update_gameplay_active()
    upgrade_selection_closed.emit()
    upgrade_selected.emit(upgrade_id)

func _update_gameplay_active() -> void:
    is_gameplay_active = not is_paused and not is_game_over and not is_upgrade_selection_active

func _ensure_levels_loaded() -> void:
    if not _levels.is_empty():
        return
    _levels = LevelLibrary.load_all_levels()

func _ensure_progression_loaded() -> void:
    if _progression_loaded:
        return

    var save_manager := get_node_or_null("/root/SaveManager") as SaveManager
    if save_manager != null:
        var save_data: Dictionary = save_manager.load_game()
        highest_unlocked_level = max(int(save_data.get("highest_unlocked_level", 1)), 1)
        var permanent_upgrades_value: Variant = save_data.get("permanent_upgrades", {})
        if typeof(permanent_upgrades_value) == TYPE_DICTIONARY:
            permanent_upgrades = permanent_upgrades_value
    _progression_loaded = true
    highest_unlocked_level_changed.emit(highest_unlocked_level)
    permanent_upgrades_changed.emit(permanent_upgrades.duplicate(true))

func _save_progression() -> void:
    var save_manager := get_node_or_null("/root/SaveManager") as SaveManager
    if save_manager != null:
        save_manager.save_game({
            "highest_unlocked_level": highest_unlocked_level,
            "permanent_upgrades": permanent_upgrades,
        })

func _get_upgrade_options() -> Array:
    var options := UPGRADE_DEFINITIONS.duplicate(true)
    options.shuffle()
    return options.slice(0, 3)

func _apply_upgrade(player: Player, upgrade_id: StringName) -> void:
    if player == null:
        return

    match upgrade_id:
        &"projectile_damage":
            player.increase_projectile_damage(1)
        &"fire_rate":
            player.reduce_fire_interval(0.08)
        &"max_hp":
            player.increase_max_hp(2)
        &"restore_hp":
            player.restore_hp(4)
