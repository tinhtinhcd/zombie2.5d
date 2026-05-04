extends RefCounted

const MIN_VISIBLE_SCALE := 0.001
const MIN_LUMINANCE := 0.08
const MIN_ALPHA := 0.08

static func normalize(model_root: Node3D, entity_type: String, model_id: String, model_path: String) -> bool:
	if model_root == null:
		return false

	model_root.set_meta("model_id", model_id)
	model_root.set_meta("entity_type", entity_type)
	model_root.set_meta("model_path", model_path)
	model_root.set_meta("material_fallback_used", false)

	_ensure_node_visible(model_root)
	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(model_root, model_root, meshes)
	if meshes.is_empty():
		push_warning("Model normalizer found zero meshes: type=%s id=%s path=%s" % [entity_type, model_id, model_path])
		return false

	var visible_mesh_count := 0
	var fallback_count := 0
	for mesh_instance in meshes:
		_ensure_visible_chain(mesh_instance, model_root)
		if mesh_instance.mesh == null:
			continue
		if _is_visible_in_model(mesh_instance, model_root):
			visible_mesh_count += 1
		fallback_count += _normalize_mesh_materials(mesh_instance, entity_type, model_id, model_path)

	if fallback_count > 0:
		model_root.set_meta("material_fallback_used", true)
	if visible_mesh_count == 0:
		push_warning("Model normalizer found zero visible meshes after normalization: type=%s id=%s path=%s" % [entity_type, model_id, model_path])
	return visible_mesh_count > 0

static func _collect_meshes(node: Node, model_root: Node3D, meshes: Array[MeshInstance3D]) -> void:
	if node is Node3D:
		_ensure_node_visible(node as Node3D)
	if node is MeshInstance3D:
		meshes.append(node as MeshInstance3D)
	for child in node.get_children():
		_collect_meshes(child, model_root, meshes)

static func _ensure_visible_chain(node: Node3D, model_root: Node3D) -> void:
	var current: Node = node
	while current != null:
		if current is Node3D:
			_ensure_node_visible(current as Node3D)
		if current == model_root:
			return
		current = current.get_parent()

static func _is_visible_in_model(node: Node3D, model_root: Node3D) -> bool:
	var current: Node = node
	while current != null:
		if current is Node3D and not (current as Node3D).visible:
			return false
		if current == model_root:
			return true
		current = current.get_parent()
	return node.visible

static func _ensure_node_visible(node: Node3D) -> void:
	node.visible = true
	var fixed_scale := node.scale
	if absf(fixed_scale.x) < MIN_VISIBLE_SCALE:
		fixed_scale.x = 1.0
	if absf(fixed_scale.y) < MIN_VISIBLE_SCALE:
		fixed_scale.y = 1.0
	if absf(fixed_scale.z) < MIN_VISIBLE_SCALE:
		fixed_scale.z = 1.0
	node.scale = fixed_scale

static func _normalize_mesh_materials(mesh_instance: MeshInstance3D, entity_type: String, model_id: String, model_path: String) -> int:
	var mesh := mesh_instance.mesh
	if mesh == null:
		return 0
	var fallback_count := 0
	for surface_index in range(mesh.get_surface_count()):
		var material := mesh_instance.get_surface_override_material(surface_index)
		if material == null:
			material = mesh.surface_get_material(surface_index)
		var reason := _diagnose_material(material)
		if reason.is_empty():
			continue
		mesh_instance.set_surface_override_material(surface_index, _create_fallback_material(entity_type, model_id))
		fallback_count += 1
		push_warning("Model material fallback: type=%s id=%s path=%s mesh=%s surface=%d reason=%s" % [entity_type, model_id, model_path, mesh_instance.name, surface_index, reason])
	return fallback_count

static func _diagnose_material(material: Material) -> String:
	if material == null:
		return "missing_material"
	if material is ShaderMaterial:
		return ""
	if material is not BaseMaterial3D:
		return ""

	var base_material := material as BaseMaterial3D
	var albedo := base_material.albedo_color
	if albedo.a < MIN_ALPHA:
		return "near_zero_alpha"
	var has_albedo_texture := base_material.albedo_texture != null
	var has_emission := base_material.emission_enabled or base_material.emission_texture != null
	if _luminance(albedo) < MIN_LUMINANCE and not has_albedo_texture and not has_emission:
		return "near_black_albedo_without_texture"
	return ""

static func _create_fallback_material(entity_type: String, model_id: String) -> StandardMaterial3D:
	var color := _get_fallback_color(entity_type, model_id)
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.62
	material.emission_enabled = true
	material.emission = color * 0.15
	return material

static func _get_fallback_color(entity_type: String, model_id: String) -> Color:
	match model_id:
		"hero_knight":
			return Color(0.28, 0.48, 0.72, 1.0)
		"hero_engineer":
			return Color(0.95, 0.58, 0.18, 1.0)
		"hero_rogue":
			return Color(0.34, 0.20, 0.52, 1.0)
		"hero_medic":
			return Color(0.25, 0.70, 0.42, 1.0)
		"hero_mage":
			return Color(0.82, 0.26, 0.78, 1.0)
		"pet_drone":
			return Color(0.42, 0.72, 0.95, 1.0)
		"pet_sprite":
			return Color(1.00, 0.48, 0.78, 1.0)
		"guard_shooter":
			return Color(0.48, 0.56, 0.26, 1.0)
		"guard_bruiser":
			return Color(0.66, 0.24, 0.18, 1.0)
		_:
			match entity_type:
				"hero":
					return Color(0.52, 0.62, 0.82, 1.0)
				"pet":
					return Color(0.45, 0.78, 0.92, 1.0)
				"guard":
					return Color(0.62, 0.58, 0.36, 1.0)
				_:
					return Color(0.72, 0.72, 0.72, 1.0)

static func _luminance(color: Color) -> float:
	return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722
