extends RefCounted
class_name DailyRewards

const QUEST_POOL := [
	{"id": "daily_kills", "label": "Kill 50 zombies", "stat": "kills", "target": 50, "reward_type": "gold", "reward_amount": 25},
	{"id": "daily_runs", "label": "Complete 3 runs", "stat": "runs", "target": 3, "reward_type": "gems", "reward_amount": 1},
	{"id": "daily_skills", "label": "Use 5 skills", "stat": "skills_used", "target": 5, "reward_type": "gold", "reward_amount": 15},
]

var game_manager: GameManager

func setup(manager: GameManager) -> void:
	game_manager = manager
	ensure_today()

func ensure_today() -> void:
	if game_manager == null:
		return
	var today := Time.get_date_string_from_system(false)
	if game_manager.last_login_date == today and not game_manager.daily_quests.is_empty():
		return
	game_manager.last_login_date = today
	game_manager.daily_quests = QUEST_POOL.duplicate(true)
	game_manager.daily_quest_progress = {}

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
		var current := clampi(int(game_manager.daily_quest_progress.get(quest_id, 0)) + max(amount, 0), 0, target)
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
