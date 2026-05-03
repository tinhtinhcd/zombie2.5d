extends SceneTree

const GAME_SCENE := preload("res://scenes/core/game.tscn")

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

	print("Guardian test passed: Bruiser spawns, slams nearby enemies, and emergency heals.")
	quit(0)
