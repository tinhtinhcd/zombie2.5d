extends SceneTree

const HERO_PATHS := [
	"res://assets/KayKit_Adventurers_2.0_FREE/KayKit_Adventurers_2.0_FREE/Characters/gltf/Knight.glb",
	"res://assets/KayKit_Adventurers_2.0_FREE/KayKit_Adventurers_2.0_FREE/Characters/gltf/Rogue_Hooded.glb",
	"res://assets/KayKit_Adventurers_2.0_FREE/KayKit_Adventurers_2.0_FREE/Characters/gltf/Mage.glb",
]
const PLAYER_PATH := "res://scenes/player/player.tscn"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	for hero_path in HERO_PATHS:
		_inspect_hero(hero_path)
	await _inspect_player_attach()
	quit()

func _inspect_hero(hero_path: String) -> void:
	var scene := load(hero_path) as PackedScene
	print("HERO ", hero_path)
	if scene == null:
		print("  load failed")
		return
	var root := scene.instantiate()
	if root == null:
		print("  instantiate failed")
		return
	_print_matching_nodes(root, "")
	_print_skeleton_bones(root)
	root.free()

func _print_matching_nodes(node: Node, prefix: String) -> void:
	var lower_name := node.name.to_lower()
	if lower_name.contains("hand") or lower_name.contains("slot") or lower_name.contains("weapon"):
		print("  node ", prefix, node.name, " type=", node.get_class())
	for child in node.get_children():
		_print_matching_nodes(child, "%s%s/" % [prefix, node.name])

func _print_skeleton_bones(node: Node) -> void:
	if node is Skeleton3D:
		var skeleton := node as Skeleton3D
		print("  skeleton ", skeleton.name, " bones=", skeleton.get_bone_count())
		for bone_index in range(skeleton.get_bone_count()):
			var bone_name := skeleton.get_bone_name(bone_index)
			var lower_name := bone_name.to_lower()
			if lower_name.contains("hand") or lower_name.contains("slot") or lower_name.contains("weapon"):
				print("    bone ", bone_index, " ", bone_name, " parent=", skeleton.get_bone_parent(bone_index))
	for child in node.get_children():
		_print_skeleton_bones(child)

func _inspect_player_attach() -> void:
	var player_scene := load(PLAYER_PATH) as PackedScene
	var weapon_scene := load("res://assets/Styloo Guns Asset Pack GLTF FBX V1.1/Styloo Guns Asset Pack GLTF FBX V1.1/Normal version Color and NormalMap/GLB/pew.glb") as PackedScene
	print("PLAYER_ATTACH")
	if player_scene == null or weapon_scene == null:
		print("  scene load failed player=", player_scene != null, " weapon=", weapon_scene != null)
		return
	var player := player_scene.instantiate()
	root.add_child(player)
	await process_frame
	if player.has_method("apply_weapon_definition"):
		player.call("apply_weapon_definition", {
			"id": "weapon_basic",
			"display_name": "Basic Gun",
			"model_scene_path": "res://assets/Styloo Guns Asset Pack GLTF FBX V1.1/Styloo Guns Asset Pack GLTF FBX V1.1/Normal version Color and NormalMap/GLB/pew.glb",
			"attachment_bone": "handslot.r",
			"attachment_position": [0.08, 0.02, -0.18],
			"attachment_rotation_degrees": [0.0, 90.0, -12.0],
			"attachment_scale": [3.0, 3.0, 3.0],
		}, true, false)
	await process_frame
	_print_weapon_nodes(player)
	player.queue_free()

func _print_weapon_nodes(node: Node) -> void:
	if node.name == "EquippedWeaponPreview" or str(node.get_meta("model_kind", "")) == "weapon":
		print("  weapon node=", node.get_path(), " parent=", node.get_parent().get_path(), " socket=", str(node.get_meta("attached_socket_path", "")))
		if node is Node3D:
			print("    local=", (node as Node3D).transform, " global_origin=", (node as Node3D).global_position, " scale=", (node as Node3D).scale)
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if _has_weapon_parent(node):
			var aabb := mesh_instance.get_aabb()
			print("    mesh=", node.get_path(), " visible=", mesh_instance.visible, " mesh=", mesh_instance.mesh != null, " aabb=", aabb)
	for child in node.get_children():
		_print_weapon_nodes(child)

func _has_weapon_parent(node: Node) -> bool:
	var current := node
	while current != null:
		if current.name == "EquippedWeaponPreview" or str(current.get_meta("model_kind", "")) == "weapon":
			return true
		current = current.get_parent()
	return false
