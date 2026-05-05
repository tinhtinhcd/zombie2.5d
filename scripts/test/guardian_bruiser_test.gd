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
	player.weapon_range = 8.0
	shooter.global_position = player.global_position + Vector3(0.25, 0.6, 0.0)
	shooter.call("_update_combat_movement", 0.35)
	var close_distance := _flat_distance(shooter.global_position, player.global_position)
	if close_distance <= 1.5:
		push_error("Guardian test failed: Shooter guard stayed glued to the hero instead of orbiting.")
		quit(1)
		return
	shooter.global_position = player.global_position + Vector3(player.weapon_range + 4.0, 0.6, 0.0)
	var far_distance := _flat_distance(shooter.global_position, player.global_position)
	shooter.call("_update_combat_movement", 0.35)
	var returned_distance := _flat_distance(shooter.global_position, player.global_position)
	if returned_distance >= far_distance or str(shooter.get("movement_state")) != "return":
		push_error("Guardian test failed: Shooter guard did not enter return movement from outside shot range.")
		quit(1)
		return
	for _index in range(12):
		shooter.call("_update_combat_movement", 0.25)
	if _flat_distance(shooter.global_position, player.global_position) > player.weapon_range + 0.1:
		push_error("Guardian test failed: Shooter guard remained outside allowed combat radius.")
		quit(1)
		return

	var target_enemy := ENEMY_SCENE.instantiate() as Enemy
	if target_enemy == null:
		push_error("Guardian test failed: no enemy available for Shooter skills.")
		quit(1)
		return
	enemy_container.add_child(target_enemy)
	shooter.global_position = player.global_position + Vector3(3.4, 0.6, 0.0)
	target_enemy.global_position = shooter.global_position + Vector3(1.0, 0.0, 0.0)
	target_enemy.current_hp = target_enemy.max_hp
	shooter.set("_cached_enemy", target_enemy)
	shooter.set("_attack_timer", 0.0)
	shooter.set("_cooldowns", {"Cover Fire": 0.0, "Focus Shot": 5.0, "Reload Drill": 5.0})
	await _advance_frames(4)
	if float(shooter.get("_cooldowns").get("Cover Fire", 0.0)) <= 0.0 and float(shooter.get("_attack_timer")) <= 0.0:
		push_error("Guardian test failed: Shooter guard could not attack while using combat movement.")
		quit(1)
		return
	shooter.set("_cooldowns", {"Cover Fire": 0.0, "Focus Shot": 0.0, "Reload Drill": 0.0})
	if not bool(shooter.call("_try_skill", _get_skill(shooter, "Cover Fire"))):
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
	if not bool(shooter.call("_try_skill", _get_skill(shooter, "Focus Shot"))):
		push_error("Guardian test failed: Shooter Focus Shot did not trigger from data.")
		quit(1)
		return
	player.fire_interval = 1.0
	shooter.set("_cached_enemy", target_enemy)
	shooter.set("_cooldowns", {"Cover Fire": 5.0, "Focus Shot": 5.0, "Reload Drill": 0.0})
	if not bool(shooter.call("_try_skill", _get_skill(shooter, "Reload Drill"))) or player.fire_interval >= 1.0:
		push_error("Guardian test failed: Shooter Reload Drill did not buff player fire rate.")
		quit(1)
		return

	_clear_guards(game)
	await process_frame
	var medic := _spawn_support_guard(game, &"guard_medic")
	if medic == null:
		push_error("Guardian test failed: Medic guard did not spawn.")
		quit(1)
		return
	player.current_hp = 3
	medic.call("_try_skill", _get_skill(medic, "Patch Up"))
	if player.current_hp <= 3:
		push_error("Guardian test failed: Medic Patch Up did not heal.")
		quit(1)
		return
	_place_enemy_pair(enemy_container, medic.global_position)
	var original_speed := player.move_speed
	medic.call("_try_skill", _get_skill(medic, "Adrenaline"))
	if player.move_speed <= original_speed:
		push_error("Guardian test failed: Medic Adrenaline did not buff move speed.")
		quit(1)
		return
	var disinfect_enemy := enemy_container.get_child(0) as Enemy
	disinfect_enemy.current_hp = disinfect_enemy.max_hp
	medic.call("_try_skill", _get_skill(medic, "Disinfect"))
	if disinfect_enemy.current_hp >= disinfect_enemy.max_hp:
		push_error("Guardian test failed: Medic Disinfect did not damage nearby enemy.")
		quit(1)
		return

	_clear_guards(game)
	await process_frame
	var engineer := _spawn_support_guard(game, &"guard_engineer")
	if engineer == null:
		push_error("Guardian test failed: Engineer guard did not spawn.")
		quit(1)
		return
	_place_enemy_pair(enemy_container, engineer.global_position)
	engineer.set("_cached_enemy", enemy_container.get_child(0))
	var guard_count_before := (game.get_node("GuardContainer") as Node3D).get_child_count()
	engineer.call("_try_skill", _get_skill(engineer, "Mini Turret"))
	if (game.get_node("GuardContainer") as Node3D).get_child_count() <= guard_count_before:
		push_error("Guardian test failed: Engineer Mini Turret did not deploy.")
		quit(1)
		return
	var zap_enemy := enemy_container.get_child(0) as Enemy
	zap_enemy.current_hp = zap_enemy.max_hp
	engineer.call("_try_skill", _get_skill(engineer, "Zap Mine"))
	if zap_enemy.current_hp >= zap_enemy.max_hp:
		push_error("Guardian test failed: Engineer Zap Mine did not damage nearby enemy.")
		quit(1)
		return

	_clear_guards(game)
	await process_frame
	var sentinel := _spawn_support_guard(game, &"guard_sentinel")
	if sentinel == null:
		push_error("Guardian test failed: Sentinel guard did not spawn.")
		quit(1)
		return
	_place_enemy_pair(enemy_container, sentinel.global_position)
	var taunt_enemy := enemy_container.get_child(0) as Enemy
	sentinel.call("_try_skill", _get_skill(sentinel, "Taunt"))
	if taunt_enemy.target != sentinel:
		push_error("Guardian test failed: Sentinel Taunt did not redirect enemy.")
		quit(1)
		return
	var hp_before := int(sentinel.get("current_hp"))
	sentinel.call("_try_skill", _get_skill(sentinel, "Shield Wall"))
	sentinel.call("take_damage", 2)
	if int(sentinel.get("current_hp")) < hp_before - 1:
		push_error("Guardian test failed: Sentinel Shield Wall did not reduce incoming guard damage.")
		quit(1)
		return
	var boss := ENEMY_SCENE.instantiate() as Enemy
	enemy_container.add_child(boss)
	boss.apply_enemy_type(&"boss")
	boss.global_position = sentinel.global_position + Vector3(1.0, 0.0, 0.0)
	var boss_hp := boss.current_hp
	sentinel.call("_try_skill", _get_skill(sentinel, "Boss Breaker"))
	if boss.current_hp >= boss_hp:
		push_error("Guardian test failed: Sentinel Boss Breaker did not damage boss.")
		quit(1)
		return

	print("Guardian test passed: all guard runtime skills and health hooks work.")
	quit(0)

func _spawn_support_guard(game: Node, guard_id: StringName) -> ShooterGuard:
	if not game.call("spawn_guard", guard_id):
		return null
	var guard_container := game.get_node("GuardContainer") as Node3D
	for child in guard_container.get_children():
		if child is ShooterGuard and StringName((child as ShooterGuard).guardian_id) == guard_id:
			return child as ShooterGuard
	return null

func _clear_guards(game: Node) -> void:
	var guard_container := game.get_node("GuardContainer") as Node3D
	for child in guard_container.get_children():
		child.queue_free()
	game.set("_active_guards", {})

func _get_skill(guard: ShooterGuard, skill_name: String) -> Dictionary:
	var skills: Array = guard.get("_skills")
	for skill in skills:
		if typeof(skill) == TYPE_DICTIONARY and str((skill as Dictionary).get("name", "")) == skill_name:
			return (skill as Dictionary).duplicate(true)
	return {}

func _place_enemy_pair(enemy_container: Node3D, center: Vector3) -> void:
	for child in enemy_container.get_children():
		enemy_container.remove_child(child)
		child.free()
	for index in range(2):
		enemy_container.add_child(ENEMY_SCENE.instantiate())
	for index in range(2):
		var enemy := enemy_container.get_child(index) as Enemy
		enemy.global_position = center + Vector3(0.6 + float(index) * 0.25, 0.0, 0.0)
		enemy.current_hp = enemy.max_hp

func _advance_frames(count: int) -> void:
	for _index in range(count):
		await process_frame

func _flat_distance(a: Vector3, b: Vector3) -> float:
	a.y = 0.0
	b.y = 0.0
	return a.distance_to(b)
