extends RefCounted
class_name HubSummaryPanel

var _preview_list: Label
var _preview_note: Label
var _weapon_preview: Label
var _armor_preview: Label
var _pet_preview: Label
var _game_manager: GameManager
var _home_state

func setup(preview_list: Label, preview_note: Label, game_manager: GameManager, home_state = null, weapon_preview: Label = null, armor_preview: Label = null, pet_preview: Label = null) -> void:
	_preview_list = preview_list
	_preview_note = preview_note
	_game_manager = game_manager
	_home_state = home_state
	_weapon_preview = weapon_preview
	_armor_preview = armor_preview
	_pet_preview = pet_preview

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
	_preview_list.text = "Current Run\nHero: %s\nWeapon: %s  %.1fm\nPet: %s\n\nProgress\nCoins: %d\nHighest Level: %d\n\n%s" % [
		hero_name,
		weapon_name,
		float(weapon_definition.get("range", 20.0)),
		pet_name,
		_game_manager.soft_currency,
		_game_manager.highest_unlocked_level,
		gear_summary,
	]
	_preview_note.text = "Survival is playable now. Other long-term systems are represented with simple readable UI."
	if _weapon_preview != null:
		_weapon_preview.text = "Weapon: %s" % weapon_name
	if _armor_preview != null:
		var armor_name := "Empty"
		if _home_state != null:
			var armor_item: Dictionary = _home_state.get_equipped_item("armor")
			if not armor_item.is_empty():
				armor_name = str(armor_item.get("name", armor_name))
		_armor_preview.text = "Armor: %s" % armor_name
	if _pet_preview != null:
		_pet_preview.text = "Pet: %s" % pet_name
