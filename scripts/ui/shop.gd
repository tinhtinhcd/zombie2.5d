extends PanelContainer
class_name ShopUI

signal closed

var game_manager: GameManager
var _body: VBoxContainer
var _message_label: Label

func _ready() -> void:
	_build_ui()
	visible = false

func setup(manager: GameManager) -> void:
	game_manager = manager
	_refresh_weapons()

func open() -> void:
	visible = true
	_refresh_weapons()

func _build_ui() -> void:
	custom_minimum_size = Vector2(520, 420)
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
	var tabs := HBoxContainer.new()
	_body.add_child(tabs)
	for label in ["Weapons", "Heroes", "Pets", "Gems"]:
		var tab := Button.new()
		tab.text = label
		tab.pressed.connect(_on_tab_pressed.bind(label))
		tabs.add_child(tab)
	_message_label = Label.new()
	_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.add_child(_message_label)
	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(_on_close_pressed)
	_body.add_child(close_button)

func _on_tab_pressed(label: String) -> void:
	match label:
		"Weapons":
			_refresh_weapons()
		"Pets":
			_refresh_pets()
		"Heroes":
			_message_label.text = "Hero leveling is ready for future data. Gold wallet: %d" % game_manager.gold
		"Gems":
			_message_label.text = "Gem purchases are placeholder only. Current gems: %d" % game_manager.gems

func _refresh_weapons() -> void:
	if game_manager == null or _message_label == null:
		return
	var weapon_id := game_manager.selected_weapon_id
	var weapon := game_manager.get_weapon_definition(weapon_id)
	var level := game_manager.get_weapon_level(weapon_id)
	var cost := game_manager.get_weapon_upgrade_cost(weapon_id)
	_message_label.text = "%s Lv.%d\nDamage %d\nUpgrade cost: %d gold\nGold: %d" % [
		game_manager.get_display_name(weapon, "Weapon"),
		level,
		int(weapon.get("damage", 1)),
		cost,
		game_manager.gold,
	]
	var buy_button := _get_or_create_buy_button("WeaponUpgradeButton", "Upgrade Weapon")
	buy_button.disabled = not game_manager.can_upgrade_weapon(weapon_id)
	buy_button.pressed.connect(_on_weapon_upgrade_pressed, CONNECT_ONE_SHOT)

func _refresh_pets() -> void:
	if game_manager == null:
		return
	var pet_id := game_manager.selected_pet_id
	var cost := game_manager.get_pet_next_evolution_cost(pet_id)
	_message_label.text = "Pet stage %d\nEvolve cost: %d shards\nShards: %d" % [
		game_manager.get_pet_evolution_stage(pet_id),
		cost,
		int(game_manager.shards.get(pet_id, game_manager.pet_evolution_shards)),
	]
	var buy_button := _get_or_create_buy_button("PetEvolveButton", "Evolve Pet")
	buy_button.disabled = game_manager.get_pet_evolution_stage(pet_id) >= 3 or int(game_manager.shards.get(pet_id, game_manager.pet_evolution_shards)) < cost
	buy_button.pressed.connect(_on_pet_evolve_pressed, CONNECT_ONE_SHOT)

func _get_or_create_buy_button(node_name: String, label: String) -> Button:
	var existing := _body.get_node_or_null(node_name) as Button
	if existing != null:
		existing.text = label
		return existing
	var button := Button.new()
	button.name = node_name
	button.text = label
	_body.add_child(button)
	return button

func _on_weapon_upgrade_pressed() -> void:
	if game_manager.upgrade_weapon(game_manager.selected_weapon_id):
		_refresh_weapons()

func _on_pet_evolve_pressed() -> void:
	if game_manager.evolve_pet(game_manager.selected_pet_id):
		_refresh_pets()

func _on_close_pressed() -> void:
	visible = false
	closed.emit()
