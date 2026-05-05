extends RefCounted
class_name DailyRewards

const QUEST_POOL := [
	{"id": "daily_kills", "label": "Kill 50 zombies", "stat": "kills", "target": 50, "reward_type": "gold", "reward_amount": 25},
	{"id": "daily_runs", "label": "Complete 3 runs", "stat": "runs", "target": 3, "reward_type": "gems", "reward_amount": 1},
	{"id": "daily_skills", "label": "Use 5 skills", "stat": "skills_used", "target": 5, "reward_type": "gold", "reward_amount": 15},
]
const DAILY_QUEST_COUNT := 3

var game_manager: GameManager

func setup(manager: GameManager) -> void:
	game_manager = manager
	if ensure_today() and game_manager.has_method("_save_progression"):
		game_manager.call("_save_progression")

func ensure_today() -> bool:
	if game_manager == null:
		return false
	var today := Time.get_date_string_from_system(false)
	if game_manager.last_login_date == today and game_manager.daily_quests.size() >= DAILY_QUEST_COUNT:
		return false
	game_manager.last_login_date = today
	game_manager.daily_quests = _generate_daily_quests()
	game_manager.daily_quest_progress = {}
	return true

func claim_login_reward() -> Dictionary:
	if game_manager == null:
		return {}
	ensure_today()
	var today := Time.get_date_string_from_system(false)
	if game_manager.claimed_daily_reward_date == today:
		return {}
	game_manager.login_streak = clampi(game_manager.login_streak + 1, 1, 7)
	game_manager.claimed_daily_reward_date = today
	var reward := _get_streak_reward(game_manager.login_streak)
	game_manager.add_currency(str(reward.get("type", "gold")), int(reward.get("amount", 0)))
	return reward

func record_progress(stat: String, amount: int = 1) -> void:
	if game_manager == null:
		return
	ensure_today()
	for quest in game_manager.daily_quests:
		if typeof(quest) != TYPE_DICTIONARY or str((quest as Dictionary).get("stat", "")) != stat:
			continue
		var quest_id := str((quest as Dictionary).get("id", ""))
		var target := int((quest as Dictionary).get("target", 1))
		var previous := int(game_manager.daily_quest_progress.get(quest_id, 0))
		var current := mini(maxi(previous, amount), target) if stat == "wave" else clampi(previous + max(amount, 0), 0, target)
		game_manager.daily_quest_progress[quest_id] = current

func get_summary() -> String:
	if game_manager == null:
		return ""
	ensure_today()
	var lines := PackedStringArray()
	for quest in game_manager.daily_quests:
		if typeof(quest) != TYPE_DICTIONARY:
			continue
		var quest_dictionary: Dictionary = quest
		var quest_id := str(quest_dictionary.get("id", ""))
		var target := int(quest_dictionary.get("target", 1))
		var value := int(game_manager.daily_quest_progress.get(quest_id, 0))
		lines.append("%s: %d/%d" % [str(quest_dictionary.get("label", "")), value, target])
	return "\n".join(lines)

func _get_streak_reward(streak: int) -> Dictionary:
	match clampi(streak, 1, 7):
		1, 2:
			return {"type": "gold", "amount": 25}
		3, 4:
			return {"type": "gems", "amount": 1}
		5, 6:
			return {"type": "shard:%s" % game_manager.selected_pet_id, "amount": 3}
		_:
			return {"type": "gems", "amount": 3}

func _generate_daily_quests() -> Array:
	var generated := []
	var missions := []
	if game_manager != null and game_manager.has_method("get_mission_definitions"):
		var mission_value: Variant = game_manager.call("get_mission_definitions")
		if typeof(mission_value) == TYPE_ARRAY:
			missions = mission_value

	for mission in missions:
		if generated.size() >= DAILY_QUEST_COUNT:
			break
		if typeof(mission) != TYPE_DICTIONARY:
			continue
		var quest := _daily_quest_from_mission(mission)
		if not quest.is_empty():
			generated.append(quest)

	for fallback in QUEST_POOL:
		if generated.size() >= DAILY_QUEST_COUNT:
			break
		generated.append((fallback as Dictionary).duplicate(true))

	return generated

func _daily_quest_from_mission(mission: Dictionary) -> Dictionary:
	var mission_id := str(mission.get("id", "")).strip_edges()
	var stat := str(mission.get("stat", "")).strip_edges()
	var target := int(mission.get("target", 0))
	if mission_id.is_empty() or stat.is_empty() or target <= 0:
		return {}
	return {
		"id": "daily_%s" % mission_id,
		"label": str(mission.get("label", mission_id.capitalize())),
		"stat": stat,
		"target": target,
		"reward_type": _reward_type_for_stat(stat),
		"reward_amount": _reward_amount_for_stat(stat, target),
	}

func _reward_type_for_stat(stat: String) -> String:
	match stat:
		"runs":
			return "gems"
		_:
			return "gold"

func _reward_amount_for_stat(stat: String, target: int) -> int:
	match stat:
		"runs":
			return 1
		"wave":
			return max(target * 5, 15)
		"xp":
			return max(target, 20)
		_:
			return max(target * 2, 15)
