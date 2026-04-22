extends RefCounted
class_name HubSummaryPanel

var _preview_list: Label
var _preview_note: Label
var _game_manager: GameManager

func setup(preview_list: Label, preview_note: Label, game_manager: GameManager) -> void:
	_preview_list = preview_list
	_preview_note = preview_note
	_game_manager = game_manager

func refresh(_currency: int = 0) -> void:
	if _preview_list == null or _preview_note == null or _game_manager == null:
		return

	var hero_name := _game_manager.get_display_name(_game_manager.get_selected_hero_definition(), "Hero")
	var weapon_name := _game_manager.get_display_name(_game_manager.get_selected_weapon_definition(), "Weapon")
	var pet_name := _game_manager.get_display_name(_game_manager.get_selected_pet_definition(), "Pet")
	var weapon_definition := _game_manager.get_selected_weapon_definition()
	_preview_list.text = "Coins: %d\nHero: %s\nWeapon: %s\nWeapon Range: %.1f\nPet: %s\nHighest Level: %d" % [
		_game_manager.soft_currency,
		hero_name,
		weapon_name,
		float(weapon_definition.get("range", 20.0)),
		pet_name,
		_game_manager.highest_unlocked_level,
	]
	_preview_note.text = "Survival is playable now. Other long-term systems are represented with simple readable UI."
