extends SceneTree

const GAME_SCENE := preload("res://scenes/core/game.tscn")
const ENEMY_SCENE := preload("res://scenes/enemy/enemy.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game_manager := root.get_node_or_null("/root/GameManager") as GameManager
	if game_manager == null:
		push_error("Guardian test failed: GameManager missing.")
		quit(1)
		return

	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	if not game.call("spawn_guard", &"guard_bruiser"):
		push_error("Guardian test failed: Bruiser guard did not spawn.")
		quit(1)
		return
	var guard := game.get_node_or_null("GuardContainer/BruiserGuard") as Node3D
	var player := game.get_node_or_null("Player") as Player
	var enemy_container := game.get_node_or_null("EnemyContainer") as Node3D
	if guard == null or player == null or enemy_container == null:
		push_error("Guardian test failed: required gameplay nodes missing.")
		quit(1)
		return

	guard.global_position = player.global_position + Vector3(0.5, 0.0, 0.0)
	for index in range(min(enemy_container.get_child_count(), 2)):
		var enemy := enemy_container.get_child(index) as Enemy
		if enemy != null:
			enemy.global_position = guard.global_position + Vector3(0.4 + float(index) * 0.2, 0.0, 0.0)
			enemy.current_hp = enemy.max_hp
	guard.call("_evaluate_skills")
	if float(guard.get("_cooldowns").get("Slam", 0.0)) <= 0.0:
		push_error("Guardian test failed: Bruiser Slam did not trigger cooldown.")
		quit(1)
		return

	player.max_hp = 10
	player.current_hp = 3
	guard.set("_cooldowns", {"Emergency Heal": 0.0, "Slam": 5.0, "Cleave": 5.0})
	guard.call("_evaluate_skills")
	if player.current_hp <= 3:
		push_error("Guardian test failed: Bruiser Emergency Heal did not restore HP.")
		quit(1)
		return

	guard.queue_free()
	game.set("_active_guards", {})
	await process_frame
	if not game.call("spawn_guard", &"guard_shooter"):
		push_error("Guardian test failed: Shooter guard did not spawn.")
		quit(1)
		return
	var shooter := game.get_node_or_null("GuardContainer/ShooterGuard") as ShooterGuard
	if shooter == null:
		push_error("Guardian test failed: Shooter guard node missing.")
		quit(1)
		return
	var target_enemy := ENEMY_SCENE.instantiate() as Enemy
	if target_enemy == null:
		push_error("Guardian test failed: no enemy available for Shooter skills.")
		quit(1)
		return
	enemy_container.add_child(target_enemy)
	shooter.global_position = player.global_position + Vector3(0.7, 0.6, 0.0)
	target_enemy.global_position = shooter.global_position + Vector3(1.0, 0.0, 0.0)
	target_enemy.current_hp = target_enemy.max_hp
	shooter.set("_cached_enemy", target_enemy)
	if not bool(shooter.call("_try_cover_fire")):
		push_error("Guardian test failed: Shooter Cover Fire did not trigger from data.")
		quit(1)
		return
	if float(shooter.get("_cooldowns").get("Cover Fire", 0.0)) <= 0.0:
		push_error("Guardian test failed: Shooter Cover Fire cooldown did not start.")
		quit(1)
		return
	target_enemy.current_hp = target_enemy.max_hp
	target_enemy.global_position = shooter.global_position + Vector3(1.0, 0.0, 0.0)
	shooter.set("_cooldowns", {"Cover Fire": 5.0, "Focus Shot": 0.0, "Reload Drill": 0.0})
	if not bool(shooter.call("_try_focus_shot")):
		push_error("Guardian test failed: Shooter Focus Shot did not trigger from data.")
		quit(1)
		return
	player.fire_interval = 1.0
	shooter.set("_cached_enemy", target_enemy)
	shooter.set("_cooldowns", {"Cover Fire": 5.0, "Focus Shot": 5.0, "Reload Drill": 0.0})
	if not bool(shooter.call("_try_reload_drill")) or player.fire_interval >= 1.0:
		push_error("Guardian test failed: Shooter Reload Drill did not buff player fire rate.")
		quit(1)
		return

	print("Guardian test passed: Bruiser and Shooter guards load data-driven skills.")
	quit(0)
