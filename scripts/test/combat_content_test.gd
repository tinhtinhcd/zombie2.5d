extends SceneTree

const ENEMY_SCENE := preload("res://scenes/enemy/enemy.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const HEALTH_PICKUP_SCENE := preload("res://scenes/effects/health_pickup.tscn")
const BUFF_PICKUP_SCENE := preload("res://scenes/effects/buff_pickup.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var root_node := Node3D.new()
	root.add_child(root_node)
	var pickup_container := Node3D.new()
	pickup_container.name = "PickupContainer"
	root_node.add_child(pickup_container)
	var effect_container := Node3D.new()
	effect_container.name = "EffectContainer"
	root_node.add_child(effect_container)
	var enemy_container := Node3D.new()
	enemy_container.name = "EnemyContainer"
	root_node.add_child(enemy_container)
	var player := PLAYER_SCENE.instantiate() as Player
	if player == null:
		push_error("Combat content test failed: player scene did not instantiate.")
		quit(1)
		return
	player.name = "Player"
	root_node.add_child(player)
	await process_frame

	var health_pickup := HEALTH_PICKUP_SCENE.instantiate()
	pickup_container.add_child(health_pickup)
	player.max_hp = 10
	player.current_hp = 5
	health_pickup.call("_on_body_entered", player)
	if player.current_hp <= 5:
		push_error("Combat content test failed: health pickup did not heal player.")
		quit(1)
		return
	await process_frame

	var buff_pickup := BUFF_PICKUP_SCENE.instantiate()
	pickup_container.add_child(buff_pickup)
	buff_pickup.set("buff_type", "fire_rate")
	buff_pickup.set("multiplier", 2.0)
	player.fire_interval = 1.0
	buff_pickup.call("_on_body_entered", player)
	if player.fire_interval >= 1.0:
		push_error("Combat content test failed: buff pickup did not apply fire-rate buff.")
		quit(1)
		return
	await process_frame

	var boss := ENEMY_SCENE.instantiate() as Enemy
	enemy_container.add_child(boss)
	boss.pickup_container_path = NodePath("../../PickupContainer")
	boss.effect_container_path = NodePath("../../EffectContainer")
	boss.health_pickup_scene = HEALTH_PICKUP_SCENE
	boss.buff_pickup_scene = BUFF_PICKUP_SCENE
	boss.apply_enemy_type(&"boss")
	boss.prepare_spawn(player)
	boss.global_position = Vector3.ZERO
	player.global_position = Vector3(1.0, 0.0, 0.0)
	player.current_hp = player.max_hp
	boss.call("_begin_boss_attack", "slam", 0.05)
	boss.call("_execute_boss_attack")
	if player.current_hp >= player.max_hp:
		push_error("Combat content test failed: boss slam did not damage nearby player.")
		quit(1)
		return

	var enemy_count_before := enemy_container.get_child_count()
	boss.call("_boss_summon")
	if enemy_container.get_child_count() <= enemy_count_before:
		push_error("Combat content test failed: boss summon did not add minions.")
		quit(1)
		return

	var drops_before := pickup_container.get_child_count()
	boss.call("_try_spawn_bonus_pickup")
	if pickup_container.get_child_count() <= drops_before:
		push_error("Combat content test failed: boss bonus pickup did not spawn.")
		quit(1)
		return

	print("Combat content test passed: pickups and boss attacks work.")
	quit(0)
