extends HBoxContainer
class_name SkillHud

const SLOT_COUNT := 3

var skill_manager: Node
var _skill_ids: Array[String] = []
var _buttons: Array[Button] = []
var _cooldowns: Dictionary = {}
var _durations: Dictionary = {}

func _ready() -> void:
	custom_minimum_size = Vector2(0, 54)
	add_theme_constant_override("separation", 8)
	_build_slots()
	visible = false

func setup(manager: Node) -> void:
	if skill_manager != null:
		if skill_manager.is_connected("skills_loaded", _on_skills_loaded):
			skill_manager.disconnect("skills_loaded", _on_skills_loaded)
		if skill_manager.is_connected("skill_cooldown_updated", _on_skill_cooldown_updated):
			skill_manager.disconnect("skill_cooldown_updated", _on_skill_cooldown_updated)
	skill_manager = manager
	if skill_manager == null:
		visible = false
		return
	skill_manager.skills_loaded.connect(_on_skills_loaded)
	skill_manager.skill_cooldown_updated.connect(_on_skill_cooldown_updated)
	var existing_skills: Variant = skill_manager.get("active_skills")
	if typeof(existing_skills) == TYPE_ARRAY:
		_on_skills_loaded(existing_skills)

func _build_slots() -> void:
	for index in range(SLOT_COUNT):
		var button := Button.new()
		button.custom_minimum_size = Vector2(96, 48)
		button.text = "-"
		button.disabled = true
		button.pressed.connect(_on_slot_pressed.bind(index))
		add_child(button)
		_buttons.append(button)

func _on_skills_loaded(skills: Array) -> void:
	_skill_ids.clear()
	_cooldowns.clear()
	_durations.clear()
	for index in range(_buttons.size()):
		var button := _buttons[index]
		if index < skills.size() and typeof(skills[index]) == TYPE_DICTIONARY:
			var skill: Dictionary = skills[index]
			var skill_id := str(skill.get("id", ""))
			_skill_ids.append(skill_id)
			_durations[skill_id] = float(skill.get("cooldown", 0.0))
			_cooldowns[skill_id] = 0.0
			button.text = _format_ready_text(skill)
			button.tooltip_text = str(skill.get("description", ""))
			button.disabled = false
		else:
			button.text = "-"
			button.tooltip_text = ""
			button.disabled = true
	visible = not _skill_ids.is_empty()

func _on_skill_cooldown_updated(skill_id: String, remaining: float, cooldown: float) -> void:
	_cooldowns[skill_id] = remaining
	_durations[skill_id] = cooldown
	_refresh_slot(skill_id)

func _refresh_slot(skill_id: String) -> void:
	var index := _skill_ids.find(skill_id)
	if index < 0 or index >= _buttons.size():
		return
	var button := _buttons[index]
	var remaining := float(_cooldowns.get(skill_id, 0.0))
	button.disabled = remaining > 0.0
	if remaining > 0.0:
		button.text = "%s\n%.1fs" % [_short_name(skill_id), remaining]
	else:
		button.text = "%s\nReady" % _short_name(skill_id)

func _on_slot_pressed(index: int) -> void:
	if skill_manager == null or index < 0 or index >= _skill_ids.size():
		return
	skill_manager.try_use_skill(_skill_ids[index])

func _format_ready_text(skill: Dictionary) -> String:
	return "%s\nReady" % str(skill.get("name", "Skill"))

func _short_name(skill_id: String) -> String:
	for button_index in range(_skill_ids.size()):
		if _skill_ids[button_index] == skill_id and button_index < _buttons.size():
			var text := _buttons[button_index].text
			return text.get_slice("\n", 0)
	return skill_id.replace("skill_", "").replace("_", " ").capitalize()
