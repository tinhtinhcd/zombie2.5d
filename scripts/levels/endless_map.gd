extends Node3D
class_name EndlessMap

@export var target_path: NodePath = NodePath("../Player")
@export var tile_size: float = 28.0
@export_range(1, 4, 1) var visible_radius: int = 2
@export var map_radius: float = 600.0
@export var tile_color_variation: float = 0.08
@export var prop_scale_variation: float = 0.08
@export var show_map_bounds: bool = true
@export var boundary_thickness: float = 1.2
@export var boundary_height: float = 0.12

@onready var ground_template: MeshInstance3D = $Ground
@onready var props_template: Node3D = $LevelRoot/Props

var _target: Node3D
var _tiles: Array = []
var _last_center: Vector2i = Vector2i(999999, 999999)
var _boundary_root: Node3D
var _last_boundary_radius: float = -1.0

const _GROUND_BASE_COLOR := Color(0.22, 0.30, 0.23, 1.0)
const _GROUND_ALT_COLOR := Color(0.17, 0.22, 0.20, 1.0)
const _BOUNDARY_COLOR := Color(0.38, 0.12, 0.13, 1.0)

func _ready() -> void:
	_target = get_node_or_null(target_path) as Node3D
	_build_repeated_tiles()
	_rebuild_boundary()
	_update_tiles(true)

func _process(_delta: float) -> void:
	if not is_equal_approx(_last_boundary_radius, map_radius):
		_rebuild_boundary()
	_update_tiles(false)

func _build_repeated_tiles() -> void:
	if ground_template == null:
		return

	ground_template.visible = false
	if props_template != null:
		props_template.visible = false

	_tiles.clear()
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
				"ground": ground,
				"props": tile.get_child(tile.get_child_count() - 1) if props_template != null else null,
				"offset": Vector2i(x, z),
				"coord": Vector2i(999999, 999999),
			})
			tile_index += 1

func _update_tiles(force_update: bool) -> void:
	var center := Vector2i.ZERO
	if _target != null:
		center = Vector2i(
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
		if tile_data["coord"] != tile_coord:
			tile_data["coord"] = tile_coord
			_apply_tile_variation(tile_data, tile_coord)

func _apply_tile_variation(tile_data: Dictionary, tile_coord: Vector2i) -> void:
	var seed := _tile_seed(tile_coord)
	var ground := tile_data["ground"] as MeshInstance3D
	if ground != null:
		_apply_ground_variation(ground, seed)

	var props := tile_data["props"] as Node3D
	if props != null:
		var quarter_turns: int = abs(seed) % 4
		var scale_offset := (_hash_unit(seed + 31) * 2.0 - 1.0) * prop_scale_variation
		props.rotation.y = float(quarter_turns) * PI * 0.5
		props.scale = Vector3.ONE * maxf(0.8, 1.0 + scale_offset)

func _apply_ground_variation(ground: MeshInstance3D, seed: int) -> void:
	var material := _get_ground_material(ground)
	if material == null:
		return

	var blend := clampf(_hash_unit(seed + 17), 0.0, 1.0)
	var noise := (_hash_unit(seed + 53) * 2.0 - 1.0) * tile_color_variation
	var color := _GROUND_BASE_COLOR.lerp(_GROUND_ALT_COLOR, blend)
	color.r = clampf(color.r + noise, 0.0, 1.0)
	color.g = clampf(color.g + noise, 0.0, 1.0)
	color.b = clampf(color.b + noise, 0.0, 1.0)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color.darkened(0.55)
	material.emission_energy_multiplier = 0.45
	ground.material_override = material

func _get_ground_material(ground: MeshInstance3D) -> StandardMaterial3D:
	var active_material := ground.get_active_material(0) as StandardMaterial3D
	if active_material != null:
		return active_material.duplicate() as StandardMaterial3D

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.roughness = 0.9
	return material

func _rebuild_boundary() -> void:
	if _boundary_root != null:
		remove_child(_boundary_root)
		_boundary_root.queue_free()
		_boundary_root = null

	_last_boundary_radius = map_radius
	if not show_map_bounds or map_radius <= 0.0:
		return

	_boundary_root = Node3D.new()
	_boundary_root.name = "MapBounds"
	add_child(_boundary_root)

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = _BOUNDARY_COLOR
	material.emission_enabled = true
	material.emission = _BOUNDARY_COLOR.darkened(0.35)
	material.emission_energy_multiplier = 0.5
	material.roughness = 0.8

	var full_size := map_radius * 2.0 + boundary_thickness * 2.0
	_create_boundary_segment(
		"NorthBound",
		Vector3(0.0, boundary_height * 0.5, -map_radius),
		Vector3(full_size, boundary_height, boundary_thickness),
		material
	)
	_create_boundary_segment(
		"SouthBound",
		Vector3(0.0, boundary_height * 0.5, map_radius),
		Vector3(full_size, boundary_height, boundary_thickness),
		material
	)
	_create_boundary_segment(
		"WestBound",
		Vector3(-map_radius, boundary_height * 0.5, 0.0),
		Vector3(boundary_thickness, boundary_height, map_radius * 2.0),
		material
	)
	_create_boundary_segment(
		"EastBound",
		Vector3(map_radius, boundary_height * 0.5, 0.0),
		Vector3(boundary_thickness, boundary_height, map_radius * 2.0),
		material
	)

func _create_boundary_segment(segment_name: String, segment_position: Vector3, segment_size: Vector3, material: StandardMaterial3D) -> void:
	if _boundary_root == null:
		return

	var mesh := BoxMesh.new()
	mesh.size = segment_size

	var segment := MeshInstance3D.new()
	segment.name = segment_name
	segment.mesh = mesh
	segment.material_override = material
	segment.position = segment_position
	_boundary_root.add_child(segment)

func _tile_seed(tile_coord: Vector2i) -> int:
	return tile_coord.x * 928371 + tile_coord.y * 523131

func _hash_unit(seed: int) -> float:
	var value: int = abs((seed * 1103515245 + 12345) % 10000)
	return float(value) / 10000.0
