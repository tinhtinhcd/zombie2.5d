extends HBoxContainer
class_name SkillHud

const SLOT_COUNT := 3
const SCI_FI_THEME := preload("res://scripts/ui/sci_fi_theme.gd")

var skill_manager: Node
var _skill_ids: Array[String] = []
var _buttons: Array[Button] = []
var _cooldowns: Dictionary = {}
var _durations: Dictionary = {}
var _pulse_tweens: Dictionary = {}

func _ready() -> void:
	custom_minimum_size = Vector2(0, 82)
	add_theme_constant_override("separation", 10)
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
		button.custom_minimum_size = Vector2(78, 78)
		button.text = "-"
		button.disabled = true
		button.clip_text = true
		SCI_FI_THEME.apply_button(button)
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
			_set_ready_state(button, true)
		else:
			button.text = "-"
			button.tooltip_text = ""
			button.disabled = true
			_set_ready_state(button, false)
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
		button.text = "%s\n%.0fs" % [_short_name(skill_id), ceilf(remaining)]
		_set_ready_state(button, false)
	else:
		button.text = "%s\nReady" % _short_name(skill_id)
		_set_ready_state(button, true)

func _on_slot_pressed(index: int) -> void:
	if skill_manager == null or index < 0 or index >= _skill_ids.size():
		return
	_play_press_tween(_buttons[index])
	skill_manager.try_use_skill(_skill_ids[index])

func _format_ready_text(skill: Dictionary) -> String:
	return "%s\nReady" % str(skill.get("name", "Skill"))

func _short_name(skill_id: String) -> String:
	for button_index in range(_skill_ids.size()):
		if _skill_ids[button_index] == skill_id and button_index < _buttons.size():
			var text := _buttons[button_index].text
			return text.get_slice("\n", 0)
	return skill_id.replace("skill_", "").replace("_", " ").capitalize()

func _set_ready_state(button: Button, is_ready: bool) -> void:
	if button == null:
		return
	if _pulse_tweens.has(button):
		var tween := _pulse_tweens[button] as Tween
		if tween != null and tween.is_valid():
			tween.kill()
		_pulse_tweens.erase(button)
	button.scale = Vector2.ONE
	button.modulate = Color.WHITE if is_ready else Color(0.62, 0.68, 0.74, 0.72)
	if not is_ready or button.disabled:
		return
	var pulse := button.create_tween()
	pulse.set_loops()
	pulse.tween_property(button, "modulate", Color(0.82, 1.0, 1.0, 1.0), 0.7)
	pulse.tween_property(button, "modulate", Color.WHITE, 0.7)
	_pulse_tweens[button] = pulse

func _play_press_tween(button: Button) -> void:
	if button == null:
		return
	var tween := button.create_tween()
	tween.tween_property(button, "scale", Vector2(0.94, 0.94), 0.05)
	tween.tween_property(button, "scale", Vector2.ONE, 0.08)
