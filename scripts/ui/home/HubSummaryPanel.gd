extends RefCounted
class_name HubSummaryPanel

var _preview_list: Label
var _preview_note: Label
var _game_manager: GameManager
var _home_state

func setup(preview_list: Label, preview_note: Label, game_manager: GameManager, home_state = null) -> void:
	_preview_list = preview_list
	_preview_note = preview_note
	_game_manager = game_manager
	_home_state = home_state

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
	var weapon_definition := _game_manager.get_weapon_definition(weapon_id)
	var weapon_name := _game_manager.get_display_name(weapon_definition, "Weapon")
	var pet_name := _game_manager.get_display_name(_game_manager.get_pet_definition(pet_id), "Pet")
	var gear_summary := "Gear: Empty"
	if _home_state != null:
		gear_summary = "Gear\n%s" % _home_state.equipped_items_summary
	_preview_list.text = "Coins: %d\nHero: %s\nWeapon: %s\nWeapon Range: %.1f\nPet: %s\nHighest Level: %d\n%s" % [
		_game_manager.soft_currency,
		hero_name,
		weapon_name,
		float(weapon_definition.get("range", 20.0)),
		pet_name,
		_game_manager.highest_unlocked_level,
		gear_summary,
	]
	_preview_note.text = "Survival is playable now. Other long-term systems are represented with simple readable UI."
