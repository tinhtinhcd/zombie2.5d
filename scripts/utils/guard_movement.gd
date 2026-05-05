extends RefCounted
class_name GuardMovement

const INNER_RADIUS := 1.5
const DEFAULT_PREFERRED_RADIUS := 3.6
const MAX_PREFERRED_RADIUS := 4.5
const RETURN_RADIUS_PADDING := 1.0
const GUARD_SEPARATION_RADIUS := 1.2
const HOLD_DEADZONE := 0.25

static func get_shot_range(anchor: Node3D) -> float:
	if anchor == null:
		return 8.0
	if anchor.has_method("get_guard_follow_radius"):
		return maxf(float(anchor.call("get_guard_follow_radius")), INNER_RADIUS + 1.0)
	if anchor.has_method("get_shot_range"):
		return maxf(float(anchor.call("get_shot_range")), INNER_RADIUS + 1.0)
	if anchor is Player:
		return maxf(float(anchor.get("weapon_range")), INNER_RADIUS + 1.0)
	return 8.0

static func get_orbit_angle_degrees(guard_id: String, fallback_offset: Vector3) -> float:
	if not fallback_offset.is_zero_approx():
		return rad_to_deg(atan2(fallback_offset.x, fallback_offset.z))
	var hash_value: int = absi(guard_id.hash())
	return float(hash_value % 360)

static func get_plan(
	guard: Node3D,
	anchor: Node3D,
	enemy: Variant,
	move_speed: float,
	delta: float,
	orbit_angle_degrees: float,
	preferred_radius: float,
	other_guards: Array
) -> Dictionary:
	if guard == null or anchor == null:
		return {"velocity": Vector3.ZERO, "state": "idle", "max_radius": 0.0, "return_radius": 0.0}

	var anchor_position := anchor.global_position
	var offset := guard.global_position - anchor_position
	offset.y = 0.0
	var distance := offset.length()
	var max_radius := get_shot_range(anchor)
	var return_radius := max_radius + RETURN_RADIUS_PADDING
	var desired_radius := clampf(preferred_radius, INNER_RADIUS + 0.2, minf(MAX_PREFERRED_RADIUS, max_radius - 0.25))
	if desired_radius <= INNER_RADIUS:
		desired_radius = minf(DEFAULT_PREFERRED_RADIUS, max_radius)

	var orbit_direction := Vector3(sin(deg_to_rad(orbit_angle_degrees)), 0.0, cos(deg_to_rad(orbit_angle_degrees))).normalized()
	var desired_position := anchor_position + orbit_direction * desired_radius
	var state := "hold"
	var enemy_node: Node3D = null
	if enemy is Node3D:
		enemy_node = enemy as Node3D

	if distance > return_radius:
		state = "return"
	elif distance > max_radius:
		state = "follow"
	elif distance < INNER_RADIUS:
		state = "spread"
		var away := offset.normalized() if not offset.is_zero_approx() else orbit_direction
		desired_position = anchor_position + away * desired_radius
	elif enemy_node != null and is_instance_valid(enemy_node):
		state = "combat"
		var enemy_offset := enemy_node.global_position - anchor_position
		enemy_offset.y = 0.0
		if not enemy_offset.is_zero_approx():
			var enemy_direction := enemy_offset.normalized()
			var strafe_direction := Vector3(-enemy_direction.z, 0.0, enemy_direction.x)
			desired_position = anchor_position + (enemy_direction * desired_radius * 0.72) + (strafe_direction * desired_radius * 0.45)

	if state == "return" or state == "follow":
		desired_position = anchor_position + orbit_direction * desired_radius

	desired_position += _separation_offset(guard, other_guards)
	var desired_offset := desired_position - anchor_position
	desired_offset.y = 0.0
	if desired_offset.length() > max_radius:
		desired_position = anchor_position + desired_offset.normalized() * max_radius

	var movement := desired_position - guard.global_position
	movement.y = 0.0
	if movement.length() <= HOLD_DEADZONE and state != "return":
		return {"velocity": Vector3.ZERO, "state": state, "max_radius": max_radius, "return_radius": return_radius}

	var velocity := movement.normalized() * maxf(move_speed, 0.0)
	if delta > 0.0 and velocity.length() * delta > movement.length():
		velocity = movement / delta
	return {"velocity": velocity, "state": state, "max_radius": max_radius, "return_radius": return_radius}

static func _separation_offset(guard: Node3D, other_guards: Array) -> Vector3:
	var offset := Vector3.ZERO
	for other in other_guards:
		if other == guard or other is not Node3D:
			continue
		var other_guard := other as Node3D
		if not is_instance_valid(other_guard):
			continue
		var away := guard.global_position - other_guard.global_position
		away.y = 0.0
		var distance := away.length()
		if distance <= 0.001 or distance >= GUARD_SEPARATION_RADIUS:
			continue
		offset += away.normalized() * (GUARD_SEPARATION_RADIUS - distance)
	return offset
