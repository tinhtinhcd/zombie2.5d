extends Node3D
class_name CombatEffect

@export var lifetime: float = 0.18
@export var start_scale: Vector3 = Vector3.ONE
@export var end_scale: Vector3 = Vector3.ONE
@export var start_color: Color = Color(1.0, 0.9, 0.35, 1.0)
@export var end_color: Color = Color(1.0, 0.35, 0.05, 0.0)
@export var unshaded: bool = true

var _materials: Array[StandardMaterial3D] = []

func _ready() -> void:
	scale = start_scale
	_collect_materials(self)
	_set_progress(0.0)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", end_scale, max(lifetime, 0.01))
	tween.tween_method(_set_progress, 0.0, 1.0, max(lifetime, 0.01))
	tween.chain().tween_callback(queue_free)

func _collect_materials(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		var material := mesh_instance.material_override as StandardMaterial3D
		if material == null:
			var active_material := mesh_instance.get_active_material(0)
			if active_material is StandardMaterial3D:
				material = (active_material as StandardMaterial3D).duplicate(true) as StandardMaterial3D
			else:
				material = StandardMaterial3D.new()
		else:
			material = material.duplicate(true) as StandardMaterial3D
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.emission_enabled = true
		if unshaded:
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		mesh_instance.material_override = material
		_materials.append(material)

	for child in node.get_children():
		_collect_materials(child)

func _set_progress(progress: float) -> void:
	var color := start_color.lerp(end_color, clampf(progress, 0.0, 1.0))
	for material in _materials:
		material.albedo_color = color
		material.emission = Color(color.r, color.g, color.b, 1.0)
