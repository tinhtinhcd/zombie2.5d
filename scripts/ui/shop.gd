extends PanelContainer
class_name ShopUI

signal closed

var game_manager: GameManager
var _body: VBoxContainer
var _wallet_label: Label
var _list: VBoxContainer
var _active_tab: String = "Weapons"

func _ready() -> void:
	_build_ui()
	visible = false

func setup(manager: GameManager) -> void:
	game_manager = manager
	_refresh_active_tab()

func open() -> void:
	visible = true
	_refresh_active_tab()

func _build_ui() -> void:
	custom_minimum_size = Vector2(620, 500)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 10)
	margin.add_child(_body)

	var title := Label.new()
	title.text = "Shop"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.add_child(title)

	_wallet_label = Label.new()
	_body.add_child(_wallet_label)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 6)
	_body.add_child(tabs)
	for label in ["Weapons", "Upgrades", "Heroes", "Guards", "Pets", "Gems"]:
		var tab := Button.new()
		tab.text = label
		tab.pressed.connect(_on_tab_pressed.bind(label))
		tabs.add_child(tab)

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 320)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_child(scroll)

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_list)

	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(_on_close_pressed)
	_body.add_child(close_button)

func _on_tab_pressed(label: String) -> void:
	_active_tab = label
	_refresh_active_tab()

func _refresh_active_tab() -> void:
	if game_manager == null or _list == null:
		return
	_wallet_label.text = "Gold: %d   Gems: %d" % [game_manager.gold, game_manager.gems]
	_clear_list()
	match _active_tab:
		"Weapons":
			_refresh_weapons()
		"Upgrades":
			_refresh_permanent_upgrades()
		"Heroes":
			_refresh_heroes()
		"Guards":
			_refresh_guards()
		"Pets":
			_refresh_pets()
		"Gems":
			_add_message("Gem purchases are disabled for MVP. Earn gems from daily rewards and clear rewards.")

func _refresh_weapons() -> void:
	for weapon_id_variant in game_manager.get_weapon_ids():
		var weapon_id := str(weapon_id_variant)
		var weapon := game_manager.get_weapon_definition(weapon_id)
		var level := game_manager.get_weapon_level(weapon_id)
		var cost := game_manager.get_weapon_upgrade_cost(weapon_id)
		var detail := "Lv.%d / 10 | Damage %d | Cost %d gold" % [
			level,
			int(weapon.get("damage", 1)),
			cost,
		]
		var button := _add_shop_row(game_manager.get_display_name(weapon, weapon_id), detail, "Upgrade")
		button.disabled = not game_manager.can_upgrade_weapon(weapon_id)
		button.pressed.connect(_on_weapon_upgrade_pressed.bind(weapon_id), CONNECT_ONE_SHOT)

func _refresh_permanent_upgrades() -> void:
	for upgrade_id_variant in game_manager.get_permanent_upgrade_ids():
		var upgrade_id := StringName(str(upgrade_id_variant))
		var definition := game_manager.get_permanent_upgrade_definition(upgrade_id)
		var rank := game_manager.get_permanent_upgrade_rank(upgrade_id)
		var max_rank := int(definition.get("max_rank", 1))
		var cost := game_manager.get_permanent_upgrade_cost(upgrade_id)
		var detail := "Rank %d / %d | %s | Cost %d gold" % [
			rank,
			max_rank,
			str(definition.get("description", "")),
			cost,
		]
		var button := _add_shop_row(str(definition.get("title", String(upgrade_id))), detail, "Buy")
		button.text = "Maxed" if rank >= max_rank else "Buy"
		button.disabled = not game_manager.can_unlock_permanent_upgrade(upgrade_id)
		button.pressed.connect(_on_permanent_upgrade_pressed.bind(upgrade_id), CONNECT_ONE_SHOT)

func _refresh_heroes() -> void:
	for hero_id_variant in game_manager.get_hero_ids():
		var hero_id := str(hero_id_variant)
		var hero := game_manager.get_hero_definition(hero_id)
		var owned := game_manager.is_hero_unlocked(hero_id)
		var level := game_manager.get_hero_level(hero_id)
		var detail := "Owned" if owned else "Unowned"
		if owned:
			detail = "Lv.%d / %d | +HP and damage per level | Cost %d gold" % [
				level,
				GameManager.HERO_UPGRADE_MAX_LEVEL,
				game_manager.get_hero_upgrade_cost(hero_id),
			]
		else:
			detail = "Unlock cost %d gold" % game_manager.get_hero_unlock_cost(hero_id)
		var button := _add_shop_row(game_manager.get_display_name(hero, hero_id), detail, "Upgrade" if owned else "Unlock")
		button.disabled = (not game_manager.can_upgrade_hero(hero_id)) if owned else (not game_manager.can_unlock_hero(hero_id))
		button.pressed.connect(_on_hero_action_pressed.bind(hero_id, owned), CONNECT_ONE_SHOT)

func _refresh_guards() -> void:
	for guard_id_variant in game_manager.get_guardian_ids():
		var guard_id := str(guard_id_variant)
		var guard := game_manager.get_guardian(guard_id)
		var owned := game_manager.is_guardian_unlocked(guard_id)
		var level := game_manager.get_guard_level(guard_id)
		var detail := "Locked by %s" % str(guard.get("unlock_condition", "progress"))
		if owned:
			detail = "Lv.%d / %d | %s | Cost %d gold" % [
				level,
				GameManager.GUARD_UPGRADE_MAX_LEVEL,
				str(guard.get("role", "support")),
				game_manager.get_guard_upgrade_cost(guard_id),
			]
		var button := _add_shop_row(game_manager.get_display_name(guard, guard_id), detail, "Upgrade")
		button.disabled = not owned or not game_manager.can_upgrade_guard(guard_id)
		button.pressed.connect(_on_guard_upgrade_pressed.bind(guard_id), CONNECT_ONE_SHOT)

func _refresh_pets() -> void:
	for pet_id_variant in game_manager.get_pet_ids():
		var pet_id := str(pet_id_variant)
		var pet := game_manager.get_pet_definition(pet_id)
		var stage := game_manager.get_pet_evolution_stage(pet_id)
		var cost := game_manager.get_pet_next_evolution_cost(pet_id)
		var shards := int(game_manager.shards.get(pet_id, game_manager.pet_evolution_shards))
		var detail := "Stage %d / 3 | Cost %d shards | Shards %d" % [stage, cost, shards]
		var button := _add_shop_row(game_manager.get_display_name(pet, pet_id), detail, "Evolve")
		button.disabled = stage >= 3 or shards < cost
		button.pressed.connect(_on_pet_evolve_pressed.bind(pet_id), CONNECT_ONE_SHOT)

func _add_shop_row(title: String, detail: String, action_text: String) -> Button:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	_list.add_child(row)

	var labels := VBoxContainer.new()
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(labels)

	var title_label := Label.new()
	title_label.text = title
	labels.add_child(title_label)

	var detail_label := Label.new()
	detail_label.text = detail
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	labels.add_child(detail_label)

	var button := Button.new()
	button.text = action_text
	button.custom_minimum_size = Vector2(96, 36)
	row.add_child(button)
	return button

func _add_message(message: String) -> void:
	var label := Label.new()
	label.text = message
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_list.add_child(label)

func _clear_list() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()

func _on_weapon_upgrade_pressed(weapon_id: String) -> void:
	game_manager.upgrade_weapon(weapon_id)
	_refresh_active_tab()

func _on_permanent_upgrade_pressed(upgrade_id: StringName) -> void:
	game_manager.unlock_permanent_upgrade(upgrade_id)
	_refresh_active_tab()

func _on_hero_action_pressed(hero_id: String, was_owned: bool) -> void:
	if was_owned:
		game_manager.upgrade_hero(hero_id)
	else:
		game_manager.unlock_hero(hero_id)
	_refresh_active_tab()

func _on_guard_upgrade_pressed(guard_id: String) -> void:
	game_manager.upgrade_guard(guard_id)
	_refresh_active_tab()

func _on_pet_evolve_pressed(pet_id: String) -> void:
	game_manager.evolve_pet(pet_id)
	_refresh_active_tab()

func _on_close_pressed() -> void:
	visible = false
	closed.emit()
