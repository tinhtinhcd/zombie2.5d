extends RefCounted

static func execute(skill: Dictionary, player: Player, manager: Node) -> bool:
	if player == null or manager == null:
		return false
	match str(skill.get("id", "")):
		"skill_knight_shield_bash":
			return _shield_bash(skill, player, manager)
		"skill_knight_war_cry":
			manager.activate_temporary_damage_multiplier(1.3, 6.0)
			return true
		_:
			return false

static func _shield_bash(skill: Dictionary, player: Player, manager: Node) -> bool:
	var enemies: Array = manager.get_enemies_in_radius(player.global_position, 3.0)
	if enemies.is_empty():
		return false
	var forward := -player.shoot_point.global_transform.basis.z.normalized()
	var did_hit := false
	for enemy in enemies:
		var offset: Vector3 = enemy.global_position - player.global_position
		if offset.is_zero_approx():
			continue
		var direction := offset.normalized()
		if forward.dot(direction) < 0.35:
			continue
		enemy.take_damage(int(skill.get("damage", 2)), enemy.global_position, direction, 3.0)
		did_hit = true
	if did_hit:
		player.call("_request_camera_shake", 0.12, 0.12)
	return did_hit
