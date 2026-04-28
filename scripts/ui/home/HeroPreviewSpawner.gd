extends RefCounted
class_name HeroPreviewSpawner

const PLAYER_SCENE_PATH := "res://scenes/player/player.tscn"
const PLAYER_SCENE := preload(PLAYER_SCENE_PATH)
const PREVIEW_CONTAINER_NAME := "GameplayHeroPreview"
const VIEWPORT_NAME := "PreviewViewport"
const WORLD_NAME := "PreviewWorld"
const PLAYER_NAME := "Player"
const PREVIEW_PLAYER_SCALE := Vector3(0.58, 0.58, 0.58)
const PREVIEW_PLAYER_POSITION := Vector3(0.0, -0.62, 0.0)
const PREVIEW_PLAYER_ROTATION := Vector3(0.0, 0.0, 0.0)

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

	var player := world_root.get_node_or_null(PLAYER_NAME) as Node3D
	if player == null or str(player.get_meta("hero_id", "")) != hero_id:
		_clear_player(world_root)
		player = PLAYER_SCENE.instantiate() as Node3D
		if player == null:
			return null
		player.name = PLAYER_NAME
		player.set_meta("hero_id", hero_id)
		player.set_meta("source_scene_path", PLAYER_SCENE_PATH)
		player.position = PREVIEW_PLAYER_POSITION
		player.rotation_degrees = PREVIEW_PLAYER_ROTATION
		player.scale = PREVIEW_PLAYER_SCALE
		world_root.add_child(player)
		_configure_player_node(player)

	_start_preview_animation(player, play_walk)
	return player

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

static func _configure_player_node(player: Node3D) -> void:
	player.set_process(false)
	player.set_physics_process(false)
	player.set_process_input(false)
	if player.has_method("set_process_unhandled_input"):
		player.set_process_unhandled_input(false)
	if player.has_method("set_process_unhandled_key_input"):
		player.set_process_unhandled_key_input(false)

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

	var animation_player := _find_animation_player(player)
	if animation_player == null:
		return
	if not animation_player.has_animation(animation_name):
		animation_name = _get_first_available_animation(animation_player)
	if animation_name.is_empty() or not animation_player.has_animation(animation_name):
		return
	var animation := animation_player.get_animation(animation_name)
	if animation != null:
		animation.loop_mode = Animation.LOOP_LINEAR
	if not animation_player.is_playing() or animation_player.current_animation != animation_name:
		animation_player.play(animation_name, 0.0, 0.8 if play_walk else 0.45)
	else:
		animation_player.speed_scale = 0.8 if play_walk else 0.45

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

static func _clear_player(world_root: Node3D) -> void:
	var existing := world_root.get_node_or_null(PLAYER_NAME)
	if existing != null:
		world_root.remove_child(existing)
		existing.free()
