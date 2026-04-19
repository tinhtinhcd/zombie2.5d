extends Resource
class_name LevelData

# One editable resource per level keeps progression data typed and scalable.

@export var level_id: StringName
@export var display_name: String = ""
@export_range(1, 999, 1) var wave_count: int = 1
@export var enemy_types: PackedStringArray = PackedStringArray()
@export var wave_definitions: Array[Dictionary] = []
@export var boss_wave_interval: int = 0
@export var boss_support_spawn_count: int = 0
@export var environment_scene: PackedScene
@export var difficulty: LevelDifficultyData
