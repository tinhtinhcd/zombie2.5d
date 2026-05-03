extends Node
class_name WeaponVisuals

const DEBUG_WEAPON_ATTACH_TRACE := false

@export var weapon_attachment_fallback_offset: Vector3 = Vector3(0.45, 0.95, -0.35)

var host: Node3D
var visual_root: Node3D
var character_root: Node3D
var current_weapon_model_path: String = ""

func setup(host_node: Node3D, visual_root_node: Node3D, character_root_node: Node3D) -> void:
	host = host_node
	set_roots(visual_root_node, character_root_node)

func set_roots(visual_root_node: Node3D, character_root_node: Node3D) -> void:
	visual_root = visual_root_node
	character_root = character_root_node

func clear() -> void:
	_remove_existing_weapon_visuals()
	current_weapon_model_path = ""

func attach_weapon(weapon_definition: Dictionary, preview_mode: bool = false) -> bool:
	var weapon_id := _get_weapon_id(weapon_definition)
	var model_scene_path := str(weapon_definition.get("model_scene_path", "")).strip_edges()
	var trace := {
		"selected_hero_id": _host_meta("hero_id"),
		"selected_weapon_id": weapon_id,
		"resolved_weapon_definition": JSON.stringify(weapon_definition),
		"weapon_model_path": model_scene_path,
		"weapon_scene_loaded": false,
		"hero_instance_path": _host_path(),
		"found_weapon_socket_path": "",
		"final_attached_weapon_node_path": "",
	}
	if model_scene_path.is_empty():
		_remove_existing_weapon_visuals()
		if not preview_mode:
			push_warning("Player weapon %s has no model_scene_path; gameplay continues without weapon visual." % weapon_id)
			_set_host_weapon_meta(weapon_id, "")
			_log_weapon_attach_trace(trace)
			return false
		push_warning("Player weapon %s has no model_scene_path; attaching visible preview placeholder." % weapon_id)
		return _attach_placeholder_weapon(weapon_definition, weapon_id, "", trace)

	var existing_weapon := _find_existing_weapon_visual()
	if existing_weapon != null and str(existing_weapon.get_meta("weapon_id", "")) == weapon_id and str(existing_weapon.get_meta("weapon_model_path", existing_weapon.get_meta("model_path", ""))) == model_scene_path:
		_set_host_weapon_meta(weapon_id, model_scene_path)
		trace["weapon_scene_loaded"] = true
		trace["found_weapon_socket_path"] = str(existing_weapon.get_meta("attached_socket_path", ""))
		trace["final_attached_weapon_node_path"] = str(existing_weapon.get_path())
		_log_weapon_attach_trace(trace)
		_assert_attached_weapon_visible(existing_weapon, weapon_id)
		return true

	_remove_existing_weapon_visuals()
	var weapon_scene := load(model_scene_path) as PackedScene
	trace["weapon_scene_loaded"] = weapon_scene != null
	if weapon_scene == null:
		if not preview_mode:
			push_warning("Player weapon %s could not load model %s; gameplay continues without weapon visual." % [weapon_id, model_scene_path])
			current_weapon_model_path = ""
			_set_host_weapon_meta(weapon_id, model_scene_path)
			_log_weapon_attach_trace(trace)
			return false
		push_warning("Player weapon %s could not load model %s; attaching visible preview placeholder." % [weapon_id, model_scene_path])
		return _attach_placeholder_weapon(weapon_definition, weapon_id, model_scene_path, trace)

	var weapon_model := weapon_scene.instantiate() as Node3D
	if weapon_model == null:
		if not preview_mode:
			push_warning("Player weapon %s model %s did not instantiate as Node3D; gameplay continues without weapon visual." % [weapon_id, model_scene_path])
			current_weapon_model_path = ""
			_set_host_weapon_meta(weapon_id, model_scene_path)
			_log_weapon_attach_trace(trace)
			return false
		push_warning("Player weapon %s model %s did not instantiate as Node3D; attaching visible preview placeholder." % [weapon_id, model_scene_path])
		weapon_model = _create_placeholder_weapon_visual(weapon_id)

	weapon_model.name = "EquippedWeaponPreview"
	weapon_model.set_meta("model_kind", "weapon")
	weapon_model.set_meta("weapon_id", weapon_id)
	weapon_model.set_meta("model_path", model_scene_path)
	weapon_model.set_meta("weapon_model_path", model_scene_path)
	weapon_model.set_meta("source_scene_path", model_scene_path)

	var attachment_bone := str(weapon_definition.get("attachment_bone", "handslot.r")).strip_edges()
	var attachment_result := _get_or_create_weapon_attachment_parent(attachment_bone)
	var attachment_parent := attachment_result.get("node", null) as Node3D
	if attachment_parent == null:
		if not preview_mode:
			push_warning("Player weapon %s could not find attachment '%s'; gameplay continues without weapon visual." % [weapon_id, attachment_bone])
			weapon_model.free()
			current_weapon_model_path = ""
			_set_host_weapon_meta(weapon_id, model_scene_path)
			_log_weapon_attach_trace(trace)
			return false
		attachment_parent = _get_or_create_visible_weapon_socket()
		attachment_result["path"] = str(attachment_parent.get_path())
		attachment_result["fallback"] = true
		push_warning("Player weapon %s could not find attachment '%s'; using visible preview WeaponSocket fallback." % [weapon_id, attachment_bone])

	attachment_parent.add_child(weapon_model)
	var used_attachment_fallback := bool(attachment_result.get("fallback", false))
	weapon_model.position = _dictionary_vector3(weapon_definition, "attachment_position", Vector3.ZERO)
	if used_attachment_fallback:
		weapon_model.position = Vector3.ZERO
	weapon_model.rotation_degrees = _dictionary_vector3(weapon_definition, "attachment_rotation_degrees", Vector3(0.0, 90.0, 0.0))
	weapon_model.scale = _nonzero_vector3(_dictionary_vector3(weapon_definition, "attachment_scale", Vector3(0.18, 0.18, 0.18)), Vector3(0.18, 0.18, 0.18))
	weapon_model.visible = true
	weapon_model.set_meta("attached_socket_path", str(attachment_result.get("path", attachment_parent.get_path())))
	_configure_weapon_preview_node(weapon_model)
	_ensure_weapon_visible(weapon_model)

	current_weapon_model_path = model_scene_path
	_set_host_weapon_meta(weapon_id, model_scene_path)
	trace["found_weapon_socket_path"] = str(attachment_result.get("path", attachment_parent.get_path()))
	trace["final_attached_weapon_node_path"] = str(weapon_model.get_path())
	_log_weapon_attach_trace(trace)
	_assert_attached_weapon_visible(weapon_model, weapon_id)
	return true

func _attach_placeholder_weapon(weapon_definition: Dictionary, weapon_id: String, model_scene_path: String, trace: Dictionary) -> bool:
	var socket := _get_or_create_visible_weapon_socket()
	var placeholder_weapon := _create_placeholder_weapon_visual(weapon_id)
	socket.add_child(placeholder_weapon)
	placeholder_weapon.position = Vector3.ZERO
	placeholder_weapon.rotation_degrees = _dictionary_vector3(weapon_definition, "attachment_rotation_degrees", Vector3(0.0, 90.0, 0.0))
	placeholder_weapon.scale = _nonzero_vector3(_dictionary_vector3(weapon_definition, "attachment_scale", Vector3(0.18, 0.18, 0.18)), Vector3(0.18, 0.18, 0.18))
	placeholder_weapon.set_meta("weapon_model_path", model_scene_path)
	placeholder_weapon.set_meta("attached_socket_path", str(socket.get_path()))
	_configure_weapon_preview_node(placeholder_weapon)
	_ensure_weapon_visible(placeholder_weapon)
	current_weapon_model_path = model_scene_path
	_set_host_weapon_meta(weapon_id, model_scene_path)
	trace["found_weapon_socket_path"] = str(socket.get_path())
	trace["final_attached_weapon_node_path"] = str(placeholder_weapon.get_path())
	_log_weapon_attach_trace(trace)
	_assert_attached_weapon_visible(placeholder_weapon, weapon_id)
	return true

func _get_weapon_id(weapon_definition: Dictionary) -> String:
	var fallback := ""
	if host != null:
		fallback = str(host.get("current_weapon_id"))
	return str(weapon_definition.get("id", fallback))

func _set_host_weapon_meta(weapon_id: String, model_scene_path: String) -> void:
	if host == null:
		return
	host.set_meta("weapon_id", weapon_id)
	host.set_meta("weapon_model_path", model_scene_path)

func _host_meta(key: String) -> String:
	if host == null:
		return ""
	return str(host.get_meta(key, ""))

func _host_path() -> String:
	if host == null:
		return ""
	return str(host.get_path())

func _get_or_create_weapon_attachment_parent(attachment_bone: String) -> Dictionary:
	var candidates: Array[String] = []
	if not attachment_bone.is_empty():
		candidates.append(attachment_bone)
	candidates.append_array(["WeaponSocket", "RightHandSocket", "weapon_socket", "handslot.r", "hand.r", "Hand.R", "hand_r", "Hand_R", "right_hand", "RightHand"])

	var search_root := character_root if character_root != null else visual_root
	if search_root != null:
		for candidate in candidates:
			var socket := _find_node3d_by_name(search_root, candidate)
			if socket != null:
				return {"node": socket, "path": str(socket.get_path()), "fallback": false}

	var skeleton := _find_skeleton(search_root)
	if skeleton != null:
		var matched_bone := _find_matching_bone_name(skeleton, candidates)
		if not matched_bone.is_empty():
			var bone_candidates: Array[String] = [matched_bone]
			bone_candidates.append_array(candidates)
			candidates = bone_candidates
		for candidate in candidates:
			var bone_index := skeleton.find_bone(candidate)
			if bone_index >= 0:
				var attachment := skeleton.get_node_or_null("EquippedWeaponAttachment") as BoneAttachment3D
				if attachment == null:
					attachment = BoneAttachment3D.new()
					attachment.name = "EquippedWeaponAttachment"
					skeleton.add_child(attachment)
				attachment.bone_name = candidate
				return {"node": attachment, "path": "%s:%s" % [str(attachment.get_path()), candidate], "fallback": false}
	return {"node": null, "path": "", "fallback": false}

func _get_or_create_visible_weapon_socket() -> Node3D:
	var parent: Node = visual_root if visual_root != null else host
	if parent == null:
		parent = self
	var socket := parent.get_node_or_null("WeaponSocket") as Node3D
	if socket == null:
		socket = Marker3D.new()
		socket.name = "WeaponSocket"
		parent.add_child(socket)
	socket.position = weapon_attachment_fallback_offset
	socket.rotation_degrees = Vector3.ZERO
	socket.scale = Vector3.ONE
	socket.visible = true
	return socket

func _find_matching_bone_name(skeleton: Skeleton3D, candidates: Array[String]) -> String:
	for candidate in candidates:
		var normalized_candidate := _normalize_attachment_name(candidate)
		for bone_index in range(skeleton.get_bone_count()):
			var bone_name := skeleton.get_bone_name(bone_index)
			if _normalize_attachment_name(bone_name) == normalized_candidate:
				return bone_name
	for bone_index in range(skeleton.get_bone_count()):
		var lower_bone := skeleton.get_bone_name(bone_index).to_lower()
		if lower_bone.contains("right") and lower_bone.contains("hand"):
			return skeleton.get_bone_name(bone_index)
		if lower_bone.contains("hand") and (lower_bone.ends_with("_r") or lower_bone.ends_with(".r") or lower_bone.ends_with(" r")):
			return skeleton.get_bone_name(bone_index)
	return ""

func _normalize_attachment_name(value: String) -> String:
	return value.to_lower().replace("_", "").replace(".", "").replace(" ", "").replace("-", "")

func _find_node3d_by_name(root: Node, node_name: String) -> Node3D:
	if root is Node3D and root.name == node_name:
		return root as Node3D
	for child in root.get_children():
		var found := _find_node3d_by_name(child, node_name)
		if found != null:
			return found
	return null

func _find_skeleton(root: Node) -> Skeleton3D:
	if root == null:
		return null
	if root is Skeleton3D:
		return root as Skeleton3D
	for child in root.get_children():
		var found := _find_skeleton(child)
		if found != null:
			return found
	return null

func _find_existing_weapon_visual() -> Node3D:
	var search_root: Node = host if host != null else self
	return _find_weapon_visual(search_root)

func _find_weapon_visual(root: Node) -> Node3D:
	if root is Node3D and (root.name == "EquippedWeaponPreview" or root.name == "EquippedWeapon" or str(root.get_meta("model_kind", "")) == "weapon"):
		return root as Node3D
	for child in root.get_children():
		var found := _find_weapon_visual(child)
		if found != null:
			return found
	return null

func _remove_existing_weapon_visuals() -> void:
	var existing := _find_existing_weapon_visual()
	while existing != null:
		var parent := existing.get_parent()
		if parent != null:
			parent.remove_child(existing)
		existing.free()
		existing = _find_existing_weapon_visual()

func _configure_weapon_preview_node(node: Node) -> void:
	node.set_process(false)
	node.set_physics_process(false)
	if node.has_method("set_process_input"):
		node.set_process_input(false)
	for child in node.get_children():
		_configure_weapon_preview_node(child)

func _create_placeholder_weapon_visual(weapon_id: String) -> Node3D:
	var root := Node3D.new()
	root.name = "EquippedWeaponPreview"
	root.set_meta("model_kind", "weapon")
	root.set_meta("weapon_id", weapon_id)
	root.set_meta("model_path", "")
	root.set_meta("source_scene_path", "placeholder://weapon")
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "VisibleWeaponPlaceholder"
	var box := BoxMesh.new()
	box.size = Vector3(0.16, 0.12, 0.75)
	mesh_instance.mesh = box
	mesh_instance.position = Vector3(0.0, 0.0, -0.25)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.95, 0.75, 0.2, 1.0)
	material.metallic = 0.25
	material.roughness = 0.45
	mesh_instance.material_override = material
	root.add_child(mesh_instance)
	return root

func _ensure_weapon_visible(node: Node) -> int:
	var visible_mesh_count := 0
	if node is Node3D:
		var node3d := node as Node3D
		node3d.visible = true
		node3d.scale = _nonzero_vector3(node3d.scale, Vector3.ONE)
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		mesh_instance.visible = true
		if mesh_instance.mesh != null:
			visible_mesh_count += 1
	for child in node.get_children():
		visible_mesh_count += _ensure_weapon_visible(child)
	return visible_mesh_count

func _nonzero_vector3(value: Vector3, fallback: Vector3) -> Vector3:
	if is_zero_approx(value.x) or is_zero_approx(value.y) or is_zero_approx(value.z):
		return fallback
	return value

func _assert_attached_weapon_visible(weapon_node: Node3D, weapon_id: String) -> void:
	if weapon_node == null:
		push_warning("Weapon attach assertion failed: EquippedWeaponPreview node is missing for %s." % weapon_id)
		return
	if weapon_node.name != "EquippedWeaponPreview":
		push_warning("Weapon attach assertion failed: attached weapon is named %s, expected EquippedWeaponPreview." % weapon_node.name)
	if str(weapon_node.get_meta("weapon_id", "")) != weapon_id:
		push_warning("Weapon attach assertion failed: weapon metadata mismatch for %s." % weapon_id)
	var visible_mesh_count := _count_visible_weapon_meshes(weapon_node)
	if visible_mesh_count == 0:
		push_warning("Weapon attach assertion failed: EquippedWeaponPreview for %s has no visible MeshInstance3D children." % weapon_id)
	elif DEBUG_WEAPON_ATTACH_TRACE:
		print("Weapon attach assertion passed: weapon_id=%s visible_mesh_count=%d node=%s" % [weapon_id, visible_mesh_count, str(weapon_node.get_path())])

func _count_visible_weapon_meshes(node: Node) -> int:
	var count := 0
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.visible and mesh_instance.mesh != null:
			count += 1
	for child in node.get_children():
		count += _count_visible_weapon_meshes(child)
	return count

func _log_weapon_attach_trace(trace: Dictionary) -> void:
	if not DEBUG_WEAPON_ATTACH_TRACE:
		return
	print("Weapon attach debug: selected_hero_id=%s selected_weapon_id=%s weapon_model_path=%s scene_loaded=%s hero_instance_path=%s socket_path=%s attached_weapon_path=%s resolved_weapon_definition=%s" % [
		str(trace.get("selected_hero_id", "")),
		str(trace.get("selected_weapon_id", "")),
		str(trace.get("weapon_model_path", "")),
		str(trace.get("weapon_scene_loaded", false)),
		str(trace.get("hero_instance_path", "")),
		str(trace.get("found_weapon_socket_path", "")),
		str(trace.get("final_attached_weapon_node_path", "")),
		str(trace.get("resolved_weapon_definition", "")),
	])

func _dictionary_vector3(source: Dictionary, key: String, fallback: Vector3) -> Vector3:
	var value: Variant = source.get(key, fallback)
	if value is Vector3:
		return value as Vector3
	if typeof(value) == TYPE_ARRAY:
		var values: Array = value
		if values.size() >= 3:
			return Vector3(float(values[0]), float(values[1]), float(values[2]))
	return fallback
