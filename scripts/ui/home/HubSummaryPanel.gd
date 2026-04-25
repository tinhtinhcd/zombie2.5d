extends RefCounted
class_name HubSummaryPanel

var _preview_list: Label
var _preview_note: Label
var _weapon_preview: Label
var _armor_preview: Label
var _pet_preview: Label
var _defense_preview: Label
var _game_manager: GameManager
var _home_state

func setup(preview_list: Label, preview_note: Label, game_manager: GameManager, home_state = null, weapon_preview: Label = null, armor_preview: Label = null, pet_preview: Label = null, defense_preview: Label = null) -> void:
	_preview_list = preview_list
	_preview_note = preview_note
	_game_manager = game_manager
	_home_state = home_state
	_weapon_preview = weapon_preview
	_armor_preview = armor_preview
	_pet_preview = pet_preview
	_defense_preview = defense_preview

func refresh(_currency: int = 0) -> void:
	if _preview_list == null or _preview_note == null or _game_manager == null:
		return

	var hero_id := _game_manager.selected_hero_id
	var weapon_id := _game_manager.selected_weapon_id
	var pet_id := _game_manager.selected_pet_id
	if _home_state != null:
		hero_id = _home_state.selected_hero_id
		weapon_id = _home_state.selected_weapon_id
		pet_id = _home_state.selected_pet_id

	var hero_name := _game_manager.get_display_name(_game_manager.get_hero_definition(hero_id), "Hero")
	var hero_definition := _game_manager.get_hero_definition(hero_id)
	var weapon_definition := _game_manager.get_weapon_definition(weapon_id)
	var weapon_name := _game_manager.get_display_name(weapon_definition, "Weapon")
	var pet_name := _game_manager.get_display_name(_game_manager.get_pet_definition(pet_id), "Pet")
	var hp := 10 + int(hero_definition.get("max_hp_bonus", 0))
	var attack := int(weapon_definition.get("damage", 1)) + int(hero_definition.get("projectile_damage_bonus", 0))
	var defense := 0
	var gear_name := weapon_name
	if _home_state != null:
		var armor_item: Dictionary = _home_state.get_equipped_item("armor")
		if not armor_item.is_empty():
			gear_name = str(armor_item.get("name", gear_name))
			var armor_stats: Dictionary = armor_item.get("stats", {})
			defense = _extract_first_stat_number(str(armor_stats.get("def", "0")))
	_preview_list.text = "C3-10 7/10 >"
	_preview_note.text = "%s | %s | %s" % [hero_name, gear_name, pet_name]
	if _weapon_preview != null:
		_weapon_preview.text = "HP %s" % _format_short_number(hp)
	if _armor_preview != null:
		_armor_preview.text = "ATK %s" % _format_short_number(attack)
	if _defense_preview != null:
		_defense_preview.text = "DEF %s" % _format_short_number(defense)
	if _pet_preview != null:
		_pet_preview.text = "Pet %s" % pet_name

func _format_short_number(value: int) -> String:
	if abs(value) >= 1000:
		return "%.1fK" % (float(value) / 1000.0)
	return str(value)

func _extract_first_stat_number(value: String) -> int:
	var expression := RegEx.new()
	if expression.compile("-?\\d+") != OK:
		return 0
	var result := expression.search(value)
	if result == null:
		return 0
	return int(result.get_string())
