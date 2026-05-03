extends RefCounted
class_name CombatUtils

static func find_nearest_enemy(from_position: Vector3, enemies: Array, max_range: float = -1.0) -> Enemy:
	var nearest_enemy: Enemy
	var nearest_distance := INF
	var range_squared := max_range * max_range
	for child in enemies:
		if child is not Enemy:
			continue
		var enemy := child as Enemy
		if enemy.is_dead():
			continue
		var distance := from_position.distance_squared_to(enemy.global_position)
		if max_range > 0.0 and distance > range_squared:
			continue
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	return nearest_enemy
