extends Node
class_name SkillManager

signal skills_loaded(skills: Array)
signal skill_activated(skill_id: String)
signal skill_cooldown_updated(skill_id: String, remaining: float, cooldown: float)

const KNIGHT_SKILLS := preload("res://scripts/skills/knight_skills.gd")
const ROGUE_SKILLS := preload("res://scripts/skills/rogue_skills.gd")
const MAGE_SKILLS := preload("res://scripts/skills/mage_skills.gd")
const COMBAT_UTILS := preload("res://scripts/utils/combat_utils.gd")

var player: Player
var game_manager: GameManager
var hero_id: String = ""
var active_skills: Array = []
var passive_skills: Array = []
var cooldowns: Dictionary = {}
var cooldown_durations: Dictionary = {}
var incoming_damage_reduction: int = 0
var dodge_chance: float = 0.0
var projectile_damage_multiplier: float = 1.0
var temporary_damage_multiplier: float = 1.0

var _temporary_damage_timer: float = 0.0
var _rng := RandomNumberGenerator.new()

func setup(player_node: Player, manager: GameManager) -> void:
	player = player_node
	game_manager = manager
	_rng.randomize()

func load_skills(requested_hero_id: String) -> void:
	hero_id = requested_hero_id
	active_skills.clear()
	passive_skills.clear()
	cooldowns.clear()
	cooldown_durations.clear()
	incoming_damage_reduction = 0
	dodge_chance = 0.0
	projectile_damage_multiplier = 1.0
	temporary_damage_multiplier = 1.0
	_temporary_damage_timer = 0.0

	if game_manager == null:
		skills_loaded.emit([])
		return

	var hero_skills := game_manager.get_skills_for_hero(hero_id)
	for skill in hero_skills:
		if typeof(skill) != TYPE_DICTIONARY:
			continue
		var skill_type := str(skill.get("type", "active"))
		if skill_type == "passive":
			passive_skills.append(skill.duplicate(true))
			_apply_passive(skill)
			continue
		active_skills.append(skill.duplicate(true))
		var skill_id := str(skill.get("id", ""))
		cooldowns[skill_id] = 0.0
		cooldown_durations[skill_id] = maxf(float(skill.get("cooldown", 0.0)), 0.0)

	skills_loaded.emit(active_skills.duplicate(true))
	for skill in active_skills:
		var skill_id := str(skill.get("id", ""))
		skill_cooldown_updated.emit(skill_id, float(cooldowns.get(skill_id, 0.0)), float(cooldown_durations.get(skill_id, 0.0)))

func _process(delta: float) -> void:
	for skill_id in cooldowns.keys():
		var remaining := maxf(float(cooldowns.get(skill_id, 0.0)) - delta, 0.0)
		if not is_equal_approx(remaining, float(cooldowns.get(skill_id, 0.0))):
			cooldowns[skill_id] = remaining
			skill_cooldown_updated.emit(str(skill_id), remaining, float(cooldown_durations.get(skill_id, 0.0)))

	if _temporary_damage_timer > 0.0:
		_temporary_damage_timer = maxf(_temporary_damage_timer - delta, 0.0)
		if _temporary_damage_timer <= 0.0:
			temporary_damage_multiplier = 1.0

func has_active_skills() -> bool:
	return not active_skills.is_empty()

func try_use_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= active_skills.size():
		return false
	var skill: Dictionary = active_skills[slot_index]
	return try_use_skill(str(skill.get("id", "")))

func try_use_skill(skill_id: String) -> bool:
	var skill := _get_active_skill(skill_id)
	if skill.is_empty():
		return false
	if float(cooldowns.get(skill_id, 0.0)) > 0.0:
		return false

	var executed := _execute_skill(skill)
	if not executed:
		return false

	var cooldown := maxf(float(skill.get("cooldown", 0.0)), 0.0)
	cooldowns[skill_id] = cooldown
	cooldown_durations[skill_id] = cooldown
	if game_manager != null and game_manager.has_method("record_daily_quest_progress"):
		game_manager.record_daily_quest_progress("skills_used", 1)
	skill_activated.emit(skill_id)
	skill_cooldown_updated.emit(skill_id, cooldown, cooldown)
	return true

func get_modified_projectile_damage(base_damage: int) -> int:
	var multiplier := projectile_damage_multiplier * temporary_damage_multiplier
	return maxi(roundi(float(maxi(base_damage, 0)) * multiplier), 1)

func resolve_incoming_damage(amount: int) -> int:
	var incoming: int = max(amount, 0)
	if incoming <= 0:
		return 0
	if dodge_chance > 0.0 and _rng.randf() < dodge_chance:
		return 0
	if incoming_damage_reduction > 0:
		incoming = max(incoming - incoming_damage_reduction, 1)
	return incoming

func activate_temporary_damage_multiplier(multiplier: float, duration: float) -> void:
	temporary_damage_multiplier = maxf(multiplier, 0.1)
	_temporary_damage_timer = maxf(duration, 0.0)

func get_nearest_enemy(max_range: float = -1.0) -> Enemy:
	if player == null:
		return null
	var enemy_container := player.get_node_or_null(player.enemy_container_path) as Node3D
	if enemy_container == null:
		return null
	return COMBAT_UTILS.find_nearest_enemy(player.global_position, enemy_container.get_children(), max_range)

func get_enemies_in_radius(center: Vector3, radius: float) -> Array[Enemy]:
	var enemies: Array[Enemy] = []
	if player == null:
		return enemies
	var enemy_container := player.get_node_or_null(player.enemy_container_path) as Node3D
	if enemy_container == null:
		return enemies
	var radius_squared := radius * radius
	for child in enemy_container.get_children():
		if child is not Enemy:
			continue
		var enemy := child as Enemy
		if enemy.is_dead():
			continue
		if enemy.global_position.distance_squared_to(center) <= radius_squared:
			enemies.append(enemy)
	return enemies

func spawn_explosion(center: Vector3, radius: float, damage: int, knockback: float) -> bool:
	if player == null:
		return false
	var explosion_scene := load("res://scenes/effects/explosion_aoe.tscn") as PackedScene
	if explosion_scene == null:
		return false
	var explosion := explosion_scene.instantiate() as Node3D
	if explosion == null:
		return false
	var effect_container := player.call("_get_effect_container") as Node3D
	if effect_container == null:
		return false
	effect_container.add_child(explosion)
	if explosion.has_method("setup"):
		explosion.call("setup", center, radius, damage, knockback)
	else:
		explosion.global_position = center
	return true

func slow_enemy(enemy: Enemy, multiplier: float, duration: float) -> void:
	if enemy == null or enemy.is_dead():
		return
	var original_speed := enemy.move_speed
	enemy.move_speed = maxf(original_speed * multiplier, 0.0)
	var tree := enemy.get_tree()
	if tree == null:
		return
	await tree.create_timer(maxf(duration, 0.05), false).timeout
	if is_instance_valid(enemy) and not enemy.is_dead():
		enemy.move_speed = original_speed

func _apply_passive(skill: Dictionary) -> void:
	var effect := str(skill.get("effect", ""))
	match str(skill.get("id", "")):
		"skill_knight_iron_skin":
			incoming_damage_reduction = max(incoming_damage_reduction, 1)
		"skill_rogue_shadow_step":
			dodge_chance = maxf(dodge_chance, 0.12)
		"skill_mage_arcane_amplify":
			projectile_damage_multiplier = maxf(projectile_damage_multiplier, 1.15)
		_:
			if effect.begins_with("projectile_damage_multiplier:"):
				projectile_damage_multiplier = maxf(projectile_damage_multiplier, float(effect.get_slice(":", 1)))

func _execute_skill(skill: Dictionary) -> bool:
	match str(skill.get("hero_id", hero_id)):
		"hero_knight":
			return KNIGHT_SKILLS.execute(skill, player, self)
		"hero_rogue":
			return ROGUE_SKILLS.execute(skill, player, self)
		"hero_mage":
			return MAGE_SKILLS.execute(skill, player, self)
		_:
			return player.activate_explosion_skill() if player != null else false

func _get_active_skill(skill_id: String) -> Dictionary:
	for skill in active_skills:
		if typeof(skill) == TYPE_DICTIONARY and str(skill.get("id", "")) == skill_id:
			return skill.duplicate(true)
	return {}
