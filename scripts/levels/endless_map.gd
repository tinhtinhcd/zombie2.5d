extends Node3D
class_name EndlessMap

@export var target_path: NodePath = NodePath("../Player")
@export var tile_size: float = 28.0
@export_range(1, 3, 1) var visible_radius: int = 1
@export var map_radius: float = 600.0

@onready var ground_template: MeshInstance3D = $Ground
@onready var props_template: Node3D = $LevelRoot/Props

var _target: Node3D
var _tiles: Array = []
var _last_center: Vector2i = Vector2i(999999, 999999)

func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_build_repeated_tiles()
	_update_tiles(true)

func _process(_delta: float) -> void:
	_update_tiles(false)

func _build_repeated_tiles() -> void:
	if ground_template == null:
		return

	ground_template.visible = false
	if props_template != null:
		props_template.visible = false

	var tile_root := Node3D.new()
	tile_root.name = "RepeatedTiles"
	add_child(tile_root)

	var tile_index := 0
	for z in range(-visible_radius, visible_radius + 1):
		for x in range(-visible_radius, visible_radius + 1):
			var tile := Node3D.new()
			tile.name = "MapTile%d" % tile_index
			tile_root.add_child(tile)

			var ground := ground_template.duplicate() as MeshInstance3D
			ground.visible = true
			tile.add_child(ground)

			if props_template != null:
				var props := props_template.duplicate() as Node3D
				props.visible = true
				tile.add_child(props)

			_tiles.append({
				"node": tile,
				"offset": Vector2i(x, z),
			})
			tile_index += 1

func _update_tiles(force_update: bool) -> void:
	if _target == null:
		return

	var center := Vector2i(
		floori((_target.global_position.x + tile_size * 0.5) / tile_size),
		floori((_target.global_position.z + tile_size * 0.5) / tile_size)
	)
	if map_radius > 0.0:
		var max_tile := ceili(map_radius / tile_size)
		center.x = clampi(center.x, -max_tile, max_tile)
		center.y = clampi(center.y, -max_tile, max_tile)
	if not force_update and center == _last_center:
		return

	_last_center = center
	for tile_data in _tiles:
		var tile := tile_data["node"] as Node3D
		var offset := tile_data["offset"] as Vector2i
		var tile_coord := center + offset
		tile.position = Vector3(tile_coord.x * tile_size, 0.0, tile_coord.y * tile_size)
