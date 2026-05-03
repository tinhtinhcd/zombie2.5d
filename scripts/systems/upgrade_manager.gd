extends RefCounted
class_name UpgradeManager

const TIER_ROLLS := [
	{"tier": "common", "weight": 60},
	{"tier": "rare", "weight": 30},
	{"tier": "epic", "weight": 10},
]

var game_manager: GameManager
var applied_stacks: Dictionary = {}
var _rng := RandomNumberGenerator.new()

func setup(manager: GameManager) -> void:
	game_manager = manager
	_rng.randomize()

func reset_run() -> void:
	applied_stacks.clear()

func roll_upgrades(count: int = 3) -> Array:
	var results := []
	if game_manager == null:
		return results
	var pool := _get_available_pool()
	var attempts := 0
	while results.size() < count and attempts < 40 and not pool.is_empty():
		attempts += 1
		var tier := _roll_tier()
		var candidates := _filter_pool_by_tier(pool, tier)
		if candidates.is_empty():
			candidates = pool
		var upgrade := _pick_weighted(candidates)
		var upgrade_id := str(upgrade.get("id", ""))
		if upgrade_id.is_empty() or _contains_upgrade(results, upgrade_id):
			continue
		upgrade["stack_count"] = int(applied_stacks.get(upgrade_id, 0))
		results.append(upgrade)
	if results.size() < count:
		for upgrade in pool:
			var upgrade_id := str(upgrade.get("id", ""))
			if _contains_upgrade(results, upgrade_id):
				continue
			upgrade["stack_count"] = int(applied_stacks.get(upgrade_id, 0))
			results.append(upgrade)
			if results.size() >= count:
				break
	return results

func apply_upgrade(player: Player, upgrade_id: String) -> bool:
	if player == null or game_manager == null:
		return false
	var upgrade := game_manager.get_upgrade_definition(upgrade_id)
	if upgrade.is_empty():
		return false
	var current_stack := int(applied_stacks.get(upgrade_id, 0))
	var max_stack := int(upgrade.get("max_stack", 1))
	if current_stack >= max_stack:
		return false

	var effect_type := str(upgrade.get("effect_type", upgrade_id))
	var effect_value: Variant = upgrade.get("effect_value", 1)
	var applied := _apply_effect(player, effect_type, effect_value)
	if applied:
		applied_stacks[upgrade_id] = current_stack + 1
	return applied

func _apply_effect(player: Player, effect_type: String, effect_value: Variant) -> bool:
	match effect_type:
		"projectile_damage", "damage_flat":
			player.increase_projectile_damage(int(effect_value))
		"damage_percent":
			player.support_damage_multiplier *= 1.0 + float(effect_value)
		"fire_rate":
			player.reduce_fire_interval(float(effect_value))
		"move_speed":
			player.move_speed += float(effect_value)
		"move_speed_percent":
			player.move_speed *= 1.0 + float(effect_value)
		"max_hp":
			player.increase_max_hp(int(effect_value))
		"restore_hp", "heal":
			player.restore_hp(int(effect_value))
		"projectile_speed":
			player.projectile_speed += float(effect_value)
		"weapon_range":
			player.increase_weapon_range(float(effect_value))
		"projectile_count":
			player.increase_projectile_count(int(effect_value))
		"explosion_skill_damage":
			player.explosion_skill_damage += int(effect_value)
		"explosion_skill_radius":
			player.explosion_skill_radius += float(effect_value)
		"skill_cooldown", "cooldown_reduction":
			player.skill_primary_cooldown = maxf(player.skill_primary_cooldown * float(effect_value), 1.0)
		"xp_magnet_range":
			player.set_meta("xp_magnet_range_bonus", float(player.get_meta("xp_magnet_range_bonus", 0.0)) + float(effect_value))
		"gold_bonus":
			player.set_meta("gold_bonus_multiplier", float(player.get_meta("gold_bonus_multiplier", 1.0)) + float(effect_value))
		"hire_guard":
			game_manager.request_hire_guard(StringName(str(effect_value)))
		_:
			push_warning("UpgradeManager unsupported effect_type: %s" % effect_type)
			return false
	return true

func _get_available_pool() -> Array:
	var available := []
	for upgrade in game_manager.get_upgrade_options_raw():
		if typeof(upgrade) != TYPE_DICTIONARY:
			continue
		var upgrade_dictionary: Dictionary = upgrade
		var upgrade_id := str(upgrade_dictionary.get("id", ""))
		var current_stack := int(applied_stacks.get(upgrade_id, 0))
		var max_stack := int(upgrade_dictionary.get("max_stack", 1))
		if current_stack < max_stack:
			available.append(upgrade_dictionary.duplicate(true))
	return available

func _roll_tier() -> String:
	var total_weight := 0
	for tier_data in TIER_ROLLS:
		total_weight += int(tier_data.get("weight", 0))
	var roll := _rng.randi_range(1, max(total_weight, 1))
	var cursor := 0
	for tier_data in TIER_ROLLS:
		cursor += int(tier_data.get("weight", 0))
		if roll <= cursor:
			return str(tier_data.get("tier", "common"))
	return "common"

func _filter_pool_by_tier(pool: Array, tier: String) -> Array:
	var filtered := []
	for upgrade in pool:
		if typeof(upgrade) == TYPE_DICTIONARY and str((upgrade as Dictionary).get("tier", "common")) == tier:
			filtered.append((upgrade as Dictionary).duplicate(true))
	return filtered

func _pick_weighted(candidates: Array) -> Dictionary:
	var total_weight := 0
	for upgrade in candidates:
		if typeof(upgrade) == TYPE_DICTIONARY:
			total_weight += max(int((upgrade as Dictionary).get("weight", 1)), 1)
	var roll := _rng.randi_range(1, max(total_weight, 1))
	var cursor := 0
	for upgrade in candidates:
		if typeof(upgrade) != TYPE_DICTIONARY:
			continue
		var upgrade_dictionary: Dictionary = upgrade
		cursor += max(int(upgrade_dictionary.get("weight", 1)), 1)
		if roll <= cursor:
			return upgrade_dictionary.duplicate(true)
	return (candidates[0] as Dictionary).duplicate(true) if not candidates.is_empty() and typeof(candidates[0]) == TYPE_DICTIONARY else {}

func _contains_upgrade(upgrades: Array, upgrade_id: String) -> bool:
	for upgrade in upgrades:
		if typeof(upgrade) == TYPE_DICTIONARY and str((upgrade as Dictionary).get("id", "")) == upgrade_id:
			return true
	return false
