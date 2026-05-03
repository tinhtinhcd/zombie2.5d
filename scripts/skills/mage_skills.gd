extends RefCounted

static func execute(skill: Dictionary, player: Player, manager: Node) -> bool:
	if player == null or manager == null:
		return false
	match str(skill.get("id", "")):
		"skill_mage_frost_nova":
			return _frost_nova(skill, player, manager)
		"skill_mage_meteor_strike":
			return _meteor_strike(skill, player, manager)
		_:
			return false

static func _frost_nova(skill: Dictionary, player: Player, manager: Node) -> bool:
	var center := player.global_position
	var enemies: Array = manager.get_enemies_in_radius(center, 4.0)
	for enemy in enemies:
		manager.slow_enemy(enemy, 0.0, 2.0)
	manager.spawn_explosion(center, 4.0, int(skill.get("damage", 2)), 1.0)
	return true

static func _meteor_strike(skill: Dictionary, player: Player, manager: Node) -> bool:
	var target: Enemy = manager.get_nearest_enemy(max(player.weapon_range, 10.0))
	var center := player.global_position
	if target != null:
		center = target.global_position
	_meteor_after_delay(center, int(skill.get("damage", 6)), manager)
	return true

static func _meteor_after_delay(center: Vector3, damage: int, manager: Node) -> void:
	var tree := manager.get_tree()
	if tree == null:
		return
	await tree.create_timer(0.45, false).timeout
	if is_instance_valid(manager):
		manager.spawn_explosion(center, 5.5, damage, 2.4)
