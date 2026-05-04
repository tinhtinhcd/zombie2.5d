extends RefCounted

const SHOOTER_GUARD_SCENE := preload("res://scenes/entities/shooter_guard.tscn")

static func execute(skill: Dictionary, player: Player, manager: Node) -> bool:
	if player == null or manager == null:
		return false
	match str(skill.get("id", "")):
		"skill_engineer_overclock":
			return _overclock(skill, player)
		"skill_engineer_deploy_sentry":
			return _deploy_sentry(skill, player, manager)
		"skill_engineer_turbo_boost":
			return _turbo_boost(skill, player)
		_:
			return false

static func _overclock(skill: Dictionary, player: Player) -> bool:
	var duration := _effect_float(skill, 2, 5.0)
	var multiplier := _effect_float(skill, 1, 1.35)
	var original_fire_interval := player.fire_interval
	player.fire_interval = maxf(original_fire_interval / maxf(multiplier, 0.1), 0.08)
	_restore_fire_interval(player, original_fire_interval, duration)
	return true

static func _deploy_sentry(skill: Dictionary, player: Player, manager: Node) -> bool:
	var game_root := player.get_parent()
	if game_root == null:
		return false
	var spawn_parent := game_root.get_node_or_null("GuardContainer") as Node3D
	var path_prefix := "../../"
	if spawn_parent == null:
		spawn_parent = game_root as Node3D
		path_prefix = "../"
	if spawn_parent == null:
		return false

	var existing := spawn_parent.get_node_or_null("EngineerSentry")
	if existing != null:
		existing.queue_free()

	var sentry := SHOOTER_GUARD_SCENE.instantiate() as ShooterGuard
	if sentry == null:
		return false
	sentry.name = "EngineerSentry"
	sentry.guardian_id = ""
	sentry.target_path = NodePath(path_prefix + "Player")
	sentry.enemy_container_path = NodePath(path_prefix + "EnemyContainer")
	sentry.projectile_container_path = NodePath(path_prefix + "ProjectileContainer")
	sentry.follow_speed = 0.0
	sentry.follow_offset = Vector3.ZERO
	sentry.attack_interval = 0.45
	sentry.attack_range = maxf(player.weapon_range, 14.0)
	var damage_multiplier := float(manager.get("deployable_damage_multiplier")) if manager != null else 1.0
	sentry.damage = maxi(roundi(float(maxi(int(skill.get("damage", 1)), 1)) * maxf(damage_multiplier, 0.1)), 1)
	sentry.set_meta("skill_id", str(skill.get("id", "")))
	spawn_parent.add_child(sentry)
	sentry.global_position = player.global_position + Vector3(1.5, 0.6, 0.8)
	_free_after_delay(sentry, _effect_float(skill, 1, 10.0))
	return true

static func _turbo_boost(skill: Dictionary, player: Player) -> bool:
	var duration := _effect_float(skill, 2, 4.0)
	var multiplier := _effect_float(skill, 1, 1.35)
	var original_move_speed := player.move_speed
	player.move_speed = maxf(original_move_speed * maxf(multiplier, 0.1), 0.1)
	_restore_move_speed(player, original_move_speed, duration)
	return true

static func _effect_float(skill: Dictionary, slice_index: int, fallback: float) -> float:
	var effect := str(skill.get("effect", ""))
	if effect.get_slice_count(":") <= slice_index:
		return fallback
	return float(effect.get_slice(":", slice_index))

static func _restore_fire_interval(player: Player, value: float, duration: float) -> void:
	var tree := player.get_tree()
	if tree == null:
		return
	await tree.create_timer(maxf(duration, 0.05), false).timeout
	if is_instance_valid(player):
		player.fire_interval = value

static func _restore_move_speed(player: Player, value: float, duration: float) -> void:
	var tree := player.get_tree()
	if tree == null:
		return
	await tree.create_timer(maxf(duration, 0.05), false).timeout
	if is_instance_valid(player):
		player.move_speed = value

static func _free_after_delay(node: Node, duration: float) -> void:
	var tree := node.get_tree()
	if tree == null:
		return
	await tree.create_timer(maxf(duration, 0.05), false).timeout
	if is_instance_valid(node):
		node.queue_free()
