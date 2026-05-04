extends RefCounted
class_name HeroPreviewSpawner

const PLAYER_SCENE_PATH := "res://scenes/player/player.tscn"
const PET_SCENE_PATH := "res://scenes/entities/pet_companion.tscn"
const ENEMY_SCENE_PATH := "res://scenes/enemy/enemy.tscn"
const PLAYER_SCENE := preload(PLAYER_SCENE_PATH)
const MODEL_NORMALIZER := preload("res://scripts/utils/model_normalizer.gd")
const PREVIEW_CONTAINER_NAME := "GameplayHeroPreview"
const VIEWPORT_NAME := "PreviewViewport"
const WORLD_NAME := "PreviewWorld"
const PLAYER_NAME := "Player"
const PET_NAME := "PetCompanion"
const GUARD_NAME := "GuardCompanion"
const PREVIEW_PLAYER_SCALE := Vector3(0.58, 0.58, 0.58)
const PREVIEW_PLAYER_POSITION := Vector3(0.0, -0.62, 0.0)
const PREVIEW_PLAYER_ROTATION := Vector3(0.0, 0.0, 0.0)
const PREVIEW_PET_SCALE := Vector3(1.85, 1.85, 1.85)
const PREVIEW_PET_POSITION := Vector3(0.0, 0.18, 0.0)
const PREVIEW_PET_ROTATION := Vector3(0.0, 0.0, 0.0)
const PREVIEW_GUARD_SCALE := Vector3(1.35, 1.35, 1.35)
const PREVIEW_GUARD_POSITION := Vector3(0.0, -0.08, 0.0)
const PREVIEW_GUARD_ROTATION := Vector3(0.0, 0.0, 0.0)
const DEBUG_PREVIEW_TRACE := false

const WALK_FALLBACKS: Array[String] = [
	"Jog_Fwd",
	"Walk",
	"Walking_A",
	"Running_A",
	"Sprint",
	"Idle",
	"A_TPose",
]

static func show_preview(slot: Control, hero_id: String, play_walk: bool = true) -> Node3D:
	return show_hero_preview(slot, hero_id, {}, play_walk, {})

static func show_hero_preview(slot: Control, hero_id: String, hero_definition: Dictionary = {}, play_walk: bool = true, weapon_definition: Dictionary = {}) -> Node3D:
	if slot == null:
		return null
	if slot is TextureRect:
		(slot as TextureRect).texture = null

	var container := _get_or_create_container(slot)
	if container == null:
		return null
	var viewport := container.get_node_or_null(VIEWPORT_NAME) as SubViewport
	var world_root: Node3D = null
	if viewport != null:
		world_root = viewport.get_node_or_null(WORLD_NAME) as Node3D
	if viewport == null or world_root == null:
		return null

	var model_path := str(hero_definition.get("model_scene_path", "")).strip_edges()
	var weapon_id := str(weapon_definition.get("id", ""))
	var weapon_model_path := str(weapon_definition.get("model_scene_path", "")).strip_edges()
	var player := world_root.get_node_or_null(PLAYER_NAME) as Node3D
	if player == null or str(player.get_meta("hero_id", "")) != hero_id or str(player.get_meta("model_path", "")) != model_path:
		_clear_preview_models(world_root)
		player = PLAYER_SCENE.instantiate() as Node3D
		if player == null:
			push_warning("Hero preview '%s' could not instantiate canonical scene: %s" % [hero_id, PLAYER_SCENE_PATH])
			return null
		player.name = PLAYER_NAME
		player.set_meta("hero_id", hero_id)
		player.set_meta("model_kind", "hero")
		player.set_meta("source_scene_path", PLAYER_SCENE_PATH)
		player.set_meta("model_path", model_path)
		player.position = PREVIEW_PLAYER_POSITION
		player.rotation_degrees = PREVIEW_PLAYER_ROTATION
		player.scale = PREVIEW_PLAYER_SCALE
		world_root.add_child(player)
		if player.has_method("apply_hero_definition"):
			player.call("apply_hero_definition", hero_definition)
			player.set_meta("model_path", str(hero_definition.get("model_scene_path", model_path)))
		player.set_meta("model_fallback_used", bool(hero_definition.get("model_fallback_used", false)))
		_configure_player_node(player)
		_warn_if_duplicate_preview_models(world_root)
		if DEBUG_PREVIEW_TRACE:
			print("Hero preview spawn: requested_id=%s resolved_model_path=%s fallback_used=%s" % [hero_id, str(player.get_meta("model_path", "")), str(player.get_meta("model_fallback_used", false))])
		_validate_full_hero_model(player, hero_id)
		var hero_model_root := player.get_node_or_null("VisualRoot/HeroModel") as Node3D
		MODEL_NORMALIZER.normalize(hero_model_root if hero_model_root != null else player, "hero", hero_id, str(player.get_meta("model_path", model_path)))

	if not weapon_definition.is_empty() and player.has_method("apply_weapon_definition"):
		player.call("apply_weapon_definition", weapon_definition, true, true)
		player.set_meta("weapon_id", weapon_id)
		player.set_meta("weapon_model_path", weapon_model_path)

	_start_preview_animation(player, play_walk)
	return player

static func show_pet_preview(slot: Control, pet_id: String, pet_definition: Dictionary = {}) -> Node3D:
	if slot == null:
		return null

	var container := _get_or_create_container(slot)
	if container == null:
		return null
	var viewport := container.get_node_or_null(VIEWPORT_NAME) as SubViewport
	var world_root: Node3D = null
	if viewport != null:
		world_root = viewport.get_node_or_null(WORLD_NAME) as Node3D
	if viewport == null or world_root == null:
		return null

	var model_path := str(pet_definition.get("model_scene_path", PET_SCENE_PATH)).strip_edges()
	var pet := world_root.get_node_or_null(PET_NAME) as Node3D
	if pet == null or str(pet.get_meta("pet_id", "")) != pet_id or str(pet.get_meta("model_path", "")) != model_path:
		_clear_preview_models(world_root)
		var pet_scene := load(model_path) as PackedScene
		if pet_scene == null:
			push_warning("Pet preview '%s' could not load resolved model scene: %s" % [pet_id, model_path])
			return null
		pet = pet_scene.instantiate() as Node3D
		if pet == null:
			push_warning("Pet preview '%s' could not instantiate canonical scene: %s" % [pet_id, model_path])
			return null
		pet.name = PET_NAME
		pet.set_meta("pet_id", pet_id)
		pet.set_meta("model_kind", "pet")
		pet.set_meta("source_scene_path", model_path)
		pet.set_meta("model_path", model_path)
		pet.set_meta("model_fallback_used", bool(pet_definition.get("model_fallback_used", false)))
		pet.position = PREVIEW_PET_POSITION
		pet.rotation_degrees = PREVIEW_PET_ROTATION
		pet.scale = PREVIEW_PET_SCALE
		world_root.add_child(pet)
		_configure_preview_node(pet)
		if pet.has_method("apply_pet_definition"):
			pet.call("apply_pet_definition", pet_definition)
		_warn_if_duplicate_preview_models(world_root)
		if DEBUG_PREVIEW_TRACE:
			print("Pet preview spawn: requested_id=%s resolved_model_path=%s fallback_used=%s" % [pet_id, model_path, str(pet.get_meta("model_fallback_used", false))])
		_validate_visible_model(pet, "Pet preview '%s'" % pet_id)
		MODEL_NORMALIZER.normalize(pet, "pet", pet_id, model_path)

	_start_named_animation(pet, "Idle", 0.45, false)
	return pet

static func show_guard_preview(slot: Control, guard_id: String, guard_definition: Dictionary = {}) -> Node3D:
	if slot == null:
		return null

	var container := _get_or_create_container(slot)
	if container == null:
		return null
	var viewport := container.get_node_or_null(VIEWPORT_NAME) as SubViewport
	var world_root: Node3D = null
	if viewport != null:
		world_root = viewport.get_node_or_null(WORLD_NAME) as Node3D
	if viewport == null or world_root == null:
		return null

	var model_path := str(guard_definition.get("model_scene_path", "res://scenes/entities/shooter_guard.tscn")).strip_edges()
	if model_path.is_empty():
		model_path = "res://scenes/entities/shooter_guard.tscn"
	var guard := world_root.get_node_or_null(GUARD_NAME) as Node3D
	if guard == null or str(guard.get_meta("guard_id", "")) != guard_id or str(guard.get_meta("model_path", "")) != model_path:
		_clear_preview_models(world_root)
		var guard_scene := load(model_path) as PackedScene
		if guard_scene == null:
			push_warning("Guard preview '%s' could not load resolved model scene: %s" % [guard_id, model_path])
			return null
		guard = guard_scene.instantiate() as Node3D
		if guard == null:
			push_warning("Guard preview '%s' could not instantiate scene: %s" % [guard_id, model_path])
			return null
		guard.name = GUARD_NAME
		guard.set_meta("guard_id", guard_id)
		guard.set_meta("model_kind", "guard")
		guard.set_meta("source_scene_path", model_path)
		guard.set_meta("model_path", model_path)
		guard.set_meta("model_fallback_used", bool(guard_definition.get("model_fallback_used", false)))
		guard.position = PREVIEW_GUARD_POSITION
		guard.rotation_degrees = PREVIEW_GUARD_ROTATION
		guard.scale = PREVIEW_GUARD_SCALE
		if _has_property(guard, "guardian_id"):
			guard.set("guardian_id", guard_id)
		world_root.add_child(guard)
		_configure_preview_node(guard)
		_warn_if_duplicate_preview_models(world_root)
		if DEBUG_PREVIEW_TRACE:
			print("Guard preview spawn: requested_id=%s resolved_model_path=%s fallback_used=%s" % [guard_id, model_path, str(guard.get_meta("model_fallback_used", false))])
		_validate_visible_model(guard, "Guard preview '%s'" % guard_id)
		MODEL_NORMALIZER.normalize(guard, "guard", guard_id, model_path)

	_start_named_animation(guard, "Idle", 0.45, false)
	return guard

static func clear_preview(slot: Control) -> void:
	if slot == null:
		return
	var container := slot.get_node_or_null(PREVIEW_CONTAINER_NAME)
	if container != null:
		slot.remove_child(container)
		container.free()

static func _get_or_create_container(slot: Control) -> SubViewportContainer:
	var container := slot.get_node_or_null(PREVIEW_CONTAINER_NAME) as SubViewportContainer
	if container != null:
		return container

	container = SubViewportContainer.new()
	container.name = PREVIEW_CONTAINER_NAME
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	container.stretch = true
	container.anchors_preset = Control.PRESET_FULL_RECT
	container.anchor_right = 1.0
	container.anchor_bottom = 1.0
	container.grow_horizontal = Control.GROW_DIRECTION_BOTH
	container.grow_vertical = Control.GROW_DIRECTION_BOTH
	slot.add_child(container)
	if slot.name == "HeroStage":
		slot.move_child(container, min(2, slot.get_child_count() - 1))

	var viewport := SubViewport.new()
	viewport.name = VIEWPORT_NAME
	viewport.size = Vector2i(512, 512)
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(viewport)

	var world_root := Node3D.new()
	world_root.name = WORLD_NAME
	viewport.add_child(world_root)
	_add_preview_camera(world_root)
	_add_preview_light(world_root)
	return container

static func _add_preview_camera(world_root: Node3D) -> void:
	var camera := Camera3D.new()
	camera.name = "PreviewCamera"
	camera.position = Vector3(0.0, 0.78, 4.7)
	camera.fov = 36.0
	camera.current = true
	world_root.add_child(camera)
	camera.look_at(Vector3(0.0, 0.45, 0.0), Vector3.UP)

static func _add_preview_light(world_root: Node3D) -> void:
	var key_light := DirectionalLight3D.new()
	key_light.name = "PreviewKeyLight"
	key_light.rotation_degrees = Vector3(-45.0, -35.0, 0.0)
	key_light.light_energy = 2.2
	world_root.add_child(key_light)

	var fill_light := OmniLight3D.new()
	fill_light.name = "PreviewFillLight"
	fill_light.position = Vector3(0.8, 1.4, 1.8)
	fill_light.light_energy = 1.8
	fill_light.omni_range = 4.0
	world_root.add_child(fill_light)

	var rim_light := DirectionalLight3D.new()
	rim_light.name = "PreviewRimLight"
	rim_light.rotation_degrees = Vector3(-28.0, 160.0, 0.0)
	rim_light.light_energy = 1.0
	world_root.add_child(rim_light)

	var world_environment := WorldEnvironment.new()
	world_environment.name = "PreviewWorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.0, 0.0, 0.0, 0.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color.WHITE
	environment.ambient_light_energy = 0.35
	world_environment.environment = environment
	world_root.add_child(world_environment)

static func _configure_player_node(player: Node3D) -> void:
	_configure_preview_node(player)

static func _configure_preview_node(node: Node3D) -> void:
	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)
	if node.has_method("set_process_unhandled_input"):
		node.set_process_unhandled_input(false)
	if node.has_method("set_process_unhandled_key_input"):
		node.set_process_unhandled_key_input(false)

static func _start_preview_animation(player: Node3D, play_walk: bool) -> void:
	var animation_name := ""
	if play_walk:
		animation_name = str(player.get("run_animation_name"))
	else:
		animation_name = str(player.get("idle_animation_name"))
	if animation_name.is_empty() or animation_name == "<null>":
		animation_name = "Jog_Fwd" if play_walk else "Idle"

	if player.has_method("_play_character_animation"):
		player.call("_play_character_animation", animation_name, 0.8 if play_walk else 0.45)

	_start_named_animation(player, animation_name, 0.8 if play_walk else 0.45, true)

static func _start_named_animation(root: Node3D, animation_name: String, speed: float, warn_if_missing: bool = true) -> void:
	var animation_player := _find_animation_player(root)
	if animation_player == null:
		if warn_if_missing:
			push_warning("Preview model '%s' has no AnimationPlayer for '%s'." % [root.name, animation_name])
		return
	if not animation_player.has_animation(animation_name):
		animation_name = _get_first_available_animation(animation_player)
	if animation_name.is_empty() or not animation_player.has_animation(animation_name):
		if warn_if_missing:
			push_warning("Preview model '%s' has no usable animation." % root.name)
		return
	var animation := animation_player.get_animation(animation_name)
	if animation != null:
		animation.loop_mode = Animation.LOOP_LINEAR
	if not animation_player.is_playing() or animation_player.current_animation != animation_name:
		animation_player.play(animation_name, 0.0, speed)
	else:
		animation_player.speed_scale = speed

static func _get_first_available_animation(animation_player: AnimationPlayer) -> String:
	for animation_name in WALK_FALLBACKS:
		if animation_player.has_animation(animation_name):
			return animation_name
	var names := animation_player.get_animation_list()
	if names.is_empty():
		return ""
	return str(names[0])

static func _find_animation_player(root: Node) -> AnimationPlayer:
	if root is AnimationPlayer:
		return root as AnimationPlayer
	for child in root.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null

static func _has_property(node: Object, property_name: String) -> bool:
	if node == null:
		return false
	for property in node.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false

static func _validate_full_hero_model(player: Node3D, hero_id: String) -> void:
	var parts := {
		"has_body": false,
		"has_head": false,
		"visible_mesh_count": 0,
		"mesh_names": [],
	}
	_collect_full_hero_parts(player, parts)
	if int(parts["visible_mesh_count"]) == 0:
		push_warning("Hero preview '%s' has no visible mesh nodes. Check preview cleanup and player scene visibility." % hero_id)
		return
	var mesh_names: Array = parts["mesh_names"]
	if not bool(parts["has_body"]):
		push_warning("Hero preview '%s' is missing a visible body mesh. Visible meshes: %s" % [hero_id, ", ".join(mesh_names)])
	if not bool(parts["has_head"]):
		push_warning("Hero preview '%s' is missing a visible human head mesh. Visible meshes: %s" % [hero_id, ", ".join(mesh_names)])

static func _validate_visible_model(model_root: Node3D, context: String) -> void:
	var parts := {
		"has_body": false,
		"has_head": false,
		"visible_mesh_count": 0,
		"mesh_names": [],
	}
	_collect_full_hero_parts(model_root, parts)
	if int(parts["visible_mesh_count"]) == 0:
		push_warning("%s has no visible mesh nodes." % context)

static func _collect_full_hero_parts(node: Node, parts: Dictionary) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.is_visible_in_tree() and mesh_instance.mesh != null:
			parts["visible_mesh_count"] = int(parts["visible_mesh_count"]) + 1
			var mesh_name := mesh_instance.name.to_lower()
			var mesh_names: Array = parts["mesh_names"]
			mesh_names.append(mesh_instance.name)
			if mesh_name.contains("body"):
				parts["has_body"] = true
			if mesh_name.contains("head"):
				parts["has_head"] = true
	for child in node.get_children():
		_collect_full_hero_parts(child, parts)

static func _warn_if_duplicate_preview_models(world_root: Node3D) -> void:
	var preview_model_count := 0
	for child in world_root.get_children():
		if child is Node3D and str(child.get_meta("source_scene_path", "")).begins_with("res://scenes/"):
			preview_model_count += 1
	if preview_model_count > 1:
		push_warning("Preview viewport has %d model instances. Old preview cleanup may have failed." % preview_model_count)

static func _clear_model(world_root: Node3D, model_name: String) -> void:
	var existing := world_root.get_node_or_null(model_name)
	if existing != null:
		world_root.remove_child(existing)
		existing.free()

static func _clear_preview_models(world_root: Node3D) -> void:
	for child in world_root.get_children():
		if child is Node3D and str(child.get_meta("source_scene_path", "")).begins_with("res://scenes/"):
			world_root.remove_child(child)
			child.free()
