extends Node3D
class_name ExplosionAoE

@export var radius: float = 4.0
@export var damage: int = 2
@export var knockback_strength: float = 1.5
@export var lifetime: float = 0.24
@export var enemy_container_path: NodePath = NodePath("../EnemyContainer")
@export var start_color: Color = Color(1.0, 0.72, 0.18, 0.55)
@export var end_color: Color = Color(1.0, 0.12, 0.02, 0.0)

var _has_applied_damage: bool = false
var _visual_started: bool = false
var _materials: Array[StandardMaterial3D] = []

func _ready() -> void:
	_collect_materials(self)
	scale = Vector3(0.2, 0.2, 0.2)
	_set_progress(0.0)
	call_deferred("_apply_damage")
	call_deferred("_start_visual")

func setup(origin: Vector3, effect_radius: float, effect_damage: int, effect_knockback: float = 1.5) -> void:
	global_position = origin
	radius = max(effect_radius, 0.1)
	damage = max(effect_damage, 0)
	knockback_strength = max(effect_knockback, 0.0)
	if is_inside_tree():
		_apply_damage()

func _start_visual() -> void:
	if _visual_started:
		return
	_visual_started = true

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ONE * max(radius, 0.1), max(lifetime, 0.01))
	tween.tween_method(_set_progress, 0.0, 1.0, max(lifetime, 0.01))
	tween.chain().tween_callback(queue_free)

func _apply_damage() -> void:
	if _has_applied_damage:
		return
	_has_applied_damage = true

	var enemy_container := get_node_or_null(enemy_container_path) as Node3D
	if enemy_container == null:
		return

	var radius_squared := radius * radius
	for child in enemy_container.get_children():
		if child is not Enemy:
			continue
		var enemy := child as Enemy
		var offset := enemy.global_position - global_position
		if offset.length_squared() > radius_squared:
			continue
		enemy.take_damage(damage, enemy.global_position, offset.normalized(), knockback_strength)

func _collect_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		var material := StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.emission_enabled = true
		mesh_instance.material_override = material
		_materials.append(material)

	for child in node.get_children():
		_collect_materials(child)

func _set_progress(progress: float) -> void:
	var color := start_color.lerp(end_color, clampf(progress, 0.0, 1.0))
	for material in _materials:
		material.albedo_color = color
		material.emission = Color(color.r, color.g, color.b, 1.0)
