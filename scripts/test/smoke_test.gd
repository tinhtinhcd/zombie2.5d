extends SceneTree

const HOME_SCENE := "res://scenes/ui/home_screen.tscn"
const GAME_SCENE := "res://scenes/core/game.tscn"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var home_scene := load(HOME_SCENE) as PackedScene
	if home_scene == null:
		push_error("Smoke test failed: home scene did not load.")
		quit(1)
		return

	var home := home_scene.instantiate()
	root.add_child(home)
	await process_frame
	home.queue_free()
	await process_frame

	var game_scene := load(GAME_SCENE) as PackedScene
	if game_scene == null:
		push_error("Smoke test failed: game scene did not load.")
		quit(1)
		return

	var game := game_scene.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	await process_frame

	var enemy_container := game.get_node_or_null("EnemyContainer")
	if enemy_container == null or enemy_container.get_child_count() == 0:
		push_error("Smoke test failed: gameplay scene did not spawn the first wave.")
		quit(1)
		return

	var repeated_tiles := game.get_node_or_null("LevelContainer/RepeatedTiles")
	if repeated_tiles == null or repeated_tiles.get_child_count() < 9:
		push_error("Smoke test failed: endless repeated map tiles were not created.")
		quit(1)
		return

	var player := game.get_node("Player") as Player
	var projectile_container := game.get_node_or_null("ProjectileContainer")
	var endless_map := game.get_node_or_null("LevelContainer") as EndlessMap
	var wave_manager := game.get_node_or_null("WaveManager")
	var game_manager := root.get_node_or_null("/root/GameManager") as GameManager
	if projectile_container == null:
		push_error("Smoke test failed: projectile container is missing.")
		quit(1)
		return
	if game_manager == null:
		push_error("Smoke test failed: GameManager autoload is missing.")
		quit(1)
		return
	if endless_map == null:
		push_error("Smoke test failed: endless map script is missing.")
		quit(1)
		return
	if not is_equal_approx(player.play_area_radius, 600.0):
		push_error("Smoke test failed: player map limit is not using the fixed physical radius.")
		quit(1)
		return
	if not is_equal_approx(endless_map.map_radius, player.play_area_radius):
		push_error("Smoke test failed: endless map limit does not match player play radius.")
		quit(1)
		return
	var up_direction := player.call("_get_move_direction", Vector2(0.0, -1.0)) as Vector3
	var down_direction := player.call("_get_move_direction", Vector2(0.0, 1.0)) as Vector3
	if up_direction.z >= -0.5 or down_direction.z <= 0.5:
		push_error("Smoke test failed: up/down input direction is inverted.")
		quit(1)
		return

	player.call("_face_direction", Vector3.FORWARD)
	player.call("_animate_visual", 0.2, Vector3.FORWARD)
	await process_frame
	if not is_equal_approx(player.get_node("ShootPoint").rotation.y, 0.0):
		push_error("Smoke test failed: player shoot direction did not rotate toward target direction.")
		quit(1)
		return
	if is_equal_approx(player.get_node("VisualRoot").position.y, 0.0):
		push_error("Smoke test failed: player visual animation did not move the visual root.")
		quit(1)
		return
	var player_animation := player.get_node_or_null("VisualRoot/Knight/KayKitAnimationPlayer") as AnimationPlayer
	if player_animation == null or not player_animation.is_playing():
		push_error("Smoke test failed: player KayKit animation player is not running.")
		quit(1)
		return
	player.call("_play_character_animation", "Running_A", 1.25)
	var player_running_animation := player_animation.get_animation("Running_A")
	if player_running_animation == null or player_running_animation.loop_mode != Animation.LOOP_LINEAR:
		push_error("Smoke test failed: player KayKit running animation is not configured to loop.")
		quit(1)
		return

	for enemy in enemy_container.get_children():
		if enemy is Node3D:
			(enemy as Node3D).global_position = player.global_position + Vector3(0.0, 0.0, -20.0)
	var enemy_for_facing := enemy_container.get_child(0) as Node3D
	enemy_for_facing.global_position = player.global_position + Vector3.RIGHT * 4.0
	player.call("_face_combat_target_or_movement", Vector3.FORWARD)
	await process_frame
	if not is_equal_approx(player.get_node("ShootPoint").rotation.y, -PI * 0.5):
		push_error("Smoke test failed: player did not face the nearest enemy over movement direction.")
		quit(1)
		return

	var spread_weapon: Dictionary = game_manager.get_weapon_definition("weapon_spread")
	player.apply_weapon_definition(spread_weapon)
	var first_enemy_for_weapon := enemy_container.get_child(0) as Node3D
	first_enemy_for_weapon.global_position = player.global_position + Vector3(0.0, 0.0, -5.0)
	var projectile_count_before := projectile_container.get_child_count()
	player.spawn_projectile()
	await process_frame
	if projectile_container.get_child_count() - projectile_count_before != 3:
		push_error("Smoke test failed: spread weapon did not spawn three projectiles.")
		quit(1)
		return
	var first_projectile := projectile_container.get_child(projectile_count_before) as Projectile
	if first_projectile == null or not is_equal_approx(first_projectile.max_distance, player.weapon_range):
		push_error("Smoke test failed: projectile did not receive weapon range.")
		quit(1)
		return

	for child in projectile_container.get_children():
		child.queue_free()
	await process_frame
	player.weapon_range = 1.0
	for enemy in enemy_container.get_children():
		if enemy is Node3D:
			(enemy as Node3D).global_position = player.global_position + Vector3(0.0, 0.0, -12.0)
	player.spawn_projectile()
	await process_frame
	if projectile_container.get_child_count() != 0:
		push_error("Smoke test failed: weapon range did not prevent out-of-range firing.")
		quit(1)
		return
	player.apply_weapon_definition(spread_weapon)

	var original_level := game_manager.current_level
	game_manager.current_level = 3
	if game_manager.get_scaled_xp_drop(1) <= 1:
		push_error("Smoke test failed: XP drop did not increase by level.")
		quit(1)
		return
	game_manager.current_level = original_level

	var first_enemy := enemy_container.get_child(0)
	var enemy_before_recycle := first_enemy as Node3D
	enemy_before_recycle.global_position = player.global_position + Vector3(999.0, 0.0, 0.0)
	if wave_manager != null:
		wave_manager.call("_recycle_far_enemies")
	if enemy_before_recycle.global_position.distance_to(player.global_position) > player.weapon_range * 2.5:
		push_error("Smoke test failed: far enemy was not recycled near the player.")
		quit(1)
		return
	var enemy_animation := first_enemy.get_node_or_null("VisualRoot/SkeletonMinion/KayKitAnimationPlayer") as AnimationPlayer
	if enemy_animation == null or not enemy_animation.is_playing():
		push_error("Smoke test failed: enemy KayKit animation player is not running.")
		quit(1)
		return
	first_enemy.call("_play_character_animation", "Walking_A", 0.85)
	var enemy_walking_animation := enemy_animation.get_animation("Walking_A")
	if enemy_walking_animation == null or enemy_walking_animation.loop_mode != Animation.LOOP_LINEAR:
		push_error("Smoke test failed: enemy KayKit walking animation is not configured to loop.")
		quit(1)
		return

	game_manager.begin_upgrade_selection()
	await process_frame
	if not game_manager.is_upgrade_selection_active:
		push_error("Smoke test failed: upgrade selection did not activate.")
		quit(1)
		return

	game_manager.select_upgrade(player, &"projectile_damage")
	await process_frame
	if game_manager.is_upgrade_selection_active:
		push_error("Smoke test failed: upgrade selection did not close.")
		quit(1)
		return

	game_manager.trigger_game_over()
	await process_frame
	if not game_manager.is_game_over:
		push_error("Smoke test failed: game over did not activate.")
		quit(1)
		return

	game.queue_free()
	await process_frame

	print("Smoke test passed: home, gameplay, wave, upgrade, and game-over flow.")
	quit(0)
