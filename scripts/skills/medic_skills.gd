extends RefCounted

const SHOCKWAVE_SCENE := preload("res://scenes/effects/shockwave.tscn")

static func execute(skill: Dictionary, player: Player, manager: Node) -> bool:
	if player == null or manager == null:
		return false
	match str(skill.get("id", "")):
		"skill_medic_healing_pulse":
			return _healing_pulse(skill, player)
		"skill_medic_sonic_burst":
			return _sonic_burst(skill, player, manager)
		_:
			return false

static func _healing_pulse(skill: Dictionary, player: Player) -> bool:
	var heal_amount := maxi(_effect_int(skill, 1, 3), 1)
	player.restore_hp(heal_amount)
	player.call("_request_camera_shake", 0.04, 0.08)
	return true

static func _sonic_burst(skill: Dictionary, player: Player, manager: Node) -> bool:
	var radius := 4.5
	var damage := maxi(int(skill.get("damage", 2)), 1)
	var enemies: Array = manager.get_enemies_in_radius(player.global_position, radius)
	for enemy in enemies:
		var push_direction: Vector3 = enemy.global_position - player.global_position
		if push_direction.is_zero_approx():
			push_direction = Vector3.FORWARD
		enemy.take_damage(damage, enemy.global_position, push_direction.normalized(), 3.0)
	_spawn_shockwave(player, radius, damage)
	player.call("_request_camera_shake", 0.1, 0.12)
	return true

static func _spawn_shockwave(player: Player, radius: float, damage: int) -> void:
	var shockwave := SHOCKWAVE_SCENE.instantiate() as Node3D
	if shockwave == null:
		return
	var effect_container := player.call("_get_effect_container") as Node3D
	if effect_container == null:
		return
	effect_container.add_child(shockwave)
	if shockwave.has_method("setup"):
		shockwave.call("setup", player.global_position, radius, damage, 3.0)
	else:
		shockwave.global_position = player.global_position

static func _effect_int(skill: Dictionary, slice_index: int, fallback: int) -> int:
	var effect := str(skill.get("effect", ""))
	if effect.get_slice_count(":") <= slice_index:
		return fallback
	return int(effect.get_slice(":", slice_index))
