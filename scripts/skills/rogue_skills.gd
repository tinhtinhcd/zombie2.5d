extends RefCounted

static func execute(skill: Dictionary, player: Player, manager: Node) -> bool:
	if player == null or manager == null:
		return false
	match str(skill.get("id", "")):
		"skill_rogue_backstab":
			return _backstab(player, manager)
		"skill_rogue_smoke_bomb":
			return _smoke_bomb(player, manager)
		_:
			return false

static func _backstab(player: Player, manager: Node) -> bool:
	var enemy: Enemy = manager.get_nearest_enemy(max(player.weapon_range, 8.0))
	if enemy == null:
		return false
	var behind := (enemy.global_position - player.global_position).normalized()
	if behind.is_zero_approx():
		behind = Vector3.FORWARD
	player.global_position = enemy.global_position + behind * 0.9
	enemy.take_damage(maxi(player.projectile_damage * 3, 1), enemy.global_position, behind, 2.0)
	player.call("_request_camera_shake", 0.08, 0.08)
	return true

static func _smoke_bomb(player: Player, manager: Node) -> bool:
	var enemies: Array = manager.get_enemies_in_radius(player.global_position, 5.0)
	for enemy in enemies:
		manager.slow_enemy(enemy, 0.45, 3.0)
	player.set("_damage_cooldown_timer", max(float(player.get("_damage_cooldown_timer")), 3.0))
	return true
