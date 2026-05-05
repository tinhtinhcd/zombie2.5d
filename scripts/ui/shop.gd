extends PanelContainer
class_name ShopUI

signal closed

const SCI_FI_THEME := preload("res://scripts/ui/sci_fi_theme.gd")

var game_manager: GameManager
var _body: VBoxContainer
var _wallet_label: Label
var _list: VBoxContainer
var _tabs: Dictionary = {}
var _active_tab: String = "Hero"

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
	custom_minimum_size = Vector2(620, 560)
	SCI_FI_THEME.apply_panel(self, Color(0.0705882, 0.101961, 0.141176, 0.96), Color(0.156863, 0.843137, 1.0, 0.45))
	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	add_child(margin)

	_body = VBoxContainer.new()
	_body.name = "Body"
	_body.add_theme_constant_override("separation", 12)
	margin.add_child(_body)

	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 10)
	_body.add_child(header)
	var title := Label.new()
	title.text = "ARMORY"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	SCI_FI_THEME.apply_label(title, false, 24)
	header.add_child(title)
	_wallet_label = Label.new()
	_wallet_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	SCI_FI_THEME.apply_label(_wallet_label, true, 15)
	header.add_child(_wallet_label)

	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 8)
	_body.add_child(tabs)
	for label in ["Hero", "Guards", "Permanent"]:
		var tab := Button.new()
		tab.text = label.to_upper()
		tab.toggle_mode = true
		tab.custom_minimum_size = Vector2(0, 64)
		tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		SCI_FI_THEME.apply_button(tab)
		tab.pressed.connect(_on_tab_pressed.bind(label))
		tabs.add_child(tab)
		_tabs[label] = tab

	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 360)
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_child(scroll)

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 10)
	scroll.add_child(_list)

	var close_button := Button.new()
	close_button.text = "CLOSE"
	close_button.custom_minimum_size = Vector2(0, 64)
	SCI_FI_THEME.apply_button(close_button)
	close_button.pressed.connect(_on_close_pressed)
	_body.add_child(close_button)

func _on_tab_pressed(label: String) -> void:
	_active_tab = label
	_refresh_active_tab()

func _refresh_active_tab() -> void:
	if game_manager == null or _list == null:
		return
	_wallet_label.text = "GOLD %d   GEMS %d" % [game_manager.gold, game_manager.gems]
	for tab_name in _tabs.keys():
		(_tabs[tab_name] as Button).button_pressed = tab_name == _active_tab
	_clear_list()
	match _active_tab:
		"Hero":
			_refresh_heroes()
		"Guards":
			_refresh_guards()
		"Permanent":
			_refresh_permanent_upgrades()

func _refresh_heroes() -> void:
	for hero_id_variant in game_manager.get_hero_ids():
		var hero_id := str(hero_id_variant)
		var hero := game_manager.get_hero_definition(hero_id)
		var owned := game_manager.is_hero_unlocked(hero_id)
		var level := game_manager.get_hero_level(hero_id)
		var cost := game_manager.get_hero_upgrade_cost(hero_id) if owned else game_manager.get_hero_unlock_cost(hero_id)
		var effect := "+HP and weapon damage scaling"
		var disabled_reason := _hero_disabled_reason(hero_id, owned)
		var action := "UPGRADE" if owned else "UNLOCK"
		if owned and level >= GameManager.HERO_UPGRADE_MAX_LEVEL:
			action = "MAXED"
		var button := _add_upgrade_card(game_manager.get_display_name(hero, hero_id), "LV %d / %d" % [level, GameManager.HERO_UPGRADE_MAX_LEVEL], effect, cost, action, disabled_reason)
		button.disabled = not disabled_reason.is_empty()
		button.pressed.connect(_on_hero_action_pressed.bind(hero_id, owned), CONNECT_ONE_SHOT)

func _refresh_guards() -> void:
	for guard_id_variant in game_manager.get_guardian_ids():
		var guard_id := str(guard_id_variant)
		var guard := game_manager.get_guardian(guard_id)
		var owned := game_manager.is_guardian_unlocked(guard_id)
		var level := game_manager.get_guard_level(guard_id)
		var cost := game_manager.get_guard_upgrade_cost(guard_id)
		var effect := str(guard.get("role", "support")).replace("_", " ").capitalize()
		var disabled_reason := _guard_disabled_reason(guard_id, owned)
		var action := "UPGRADE" if owned else "LOCKED"
		if owned and level >= GameManager.GUARD_UPGRADE_MAX_LEVEL:
			action = "MAXED"
		var button := _add_upgrade_card(game_manager.get_display_name(guard, guard_id), "LV %d / %d" % [level, GameManager.GUARD_UPGRADE_MAX_LEVEL], effect, cost, action, disabled_reason)
		button.disabled = not disabled_reason.is_empty()
		button.pressed.connect(_on_guard_upgrade_pressed.bind(guard_id), CONNECT_ONE_SHOT)

func _refresh_permanent_upgrades() -> void:
	for upgrade_id_variant in game_manager.get_permanent_upgrade_ids():
		var upgrade_id := StringName(str(upgrade_id_variant))
		var definition := game_manager.get_permanent_upgrade_definition(upgrade_id)
		var rank := game_manager.get_permanent_upgrade_rank(upgrade_id)
		var max_rank := int(definition.get("max_rank", 1))
		var cost := game_manager.get_permanent_upgrade_cost(upgrade_id)
		var disabled_reason := _permanent_disabled_reason(upgrade_id)
		var action := "MAXED" if rank >= max_rank else "BUY"
		var button := _add_upgrade_card(str(definition.get("title", String(upgrade_id))), "RANK %d / %d" % [rank, max_rank], str(definition.get("description", "")), cost, action, disabled_reason)
		button.disabled = not disabled_reason.is_empty()
		button.pressed.connect(_on_permanent_upgrade_pressed.bind(upgrade_id), CONNECT_ONE_SHOT)

func _add_upgrade_card(title: String, level_text: String, effect: String, cost: int, action_text: String, disabled_reason: String) -> Button:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 124)
	SCI_FI_THEME.apply_panel(card)
	_list.add_child(card)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 12)
	card.add_child(margin)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	margin.add_child(row)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 4)
	row.add_child(text_box)

	var name_label := Label.new()
	name_label.text = title
	SCI_FI_THEME.apply_label(name_label, false, 19)
	text_box.add_child(name_label)

	var level_label := Label.new()
	level_label.text = level_text
	SCI_FI_THEME.apply_label(level_label, true, 14)
	text_box.add_child(level_label)

	var effect_label := Label.new()
	effect_label.text = effect
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	SCI_FI_THEME.apply_label(effect_label, true, 14)
	text_box.add_child(effect_label)

	var reason_label := Label.new()
	reason_label.text = disabled_reason if not disabled_reason.is_empty() else "Cost %d gold" % cost
	SCI_FI_THEME.apply_label(reason_label, not disabled_reason.is_empty(), 13)
	text_box.add_child(reason_label)

	var button := Button.new()
	button.text = action_text
	button.custom_minimum_size = Vector2(116, 72)
	SCI_FI_THEME.apply_button(button, SCI_FI_THEME.SUCCESS if disabled_reason.is_empty() else SCI_FI_THEME.MUTED)
	row.add_child(button)
	return button

func _hero_disabled_reason(hero_id: String, owned: bool) -> String:
	if owned and game_manager.get_hero_level(hero_id) >= GameManager.HERO_UPGRADE_MAX_LEVEL:
		return "MAXED"
	if owned and game_manager.gold < game_manager.get_hero_upgrade_cost(hero_id):
		return "Need %d gold" % game_manager.get_hero_upgrade_cost(hero_id)
	if not owned and game_manager.gold < game_manager.get_hero_unlock_cost(hero_id):
		return "Need %d gold" % game_manager.get_hero_unlock_cost(hero_id)
	return ""

func _guard_disabled_reason(guard_id: String, owned: bool) -> String:
	if not owned:
		return "Locked"
	if game_manager.get_guard_level(guard_id) >= GameManager.GUARD_UPGRADE_MAX_LEVEL:
		return "MAXED"
	if game_manager.gold < game_manager.get_guard_upgrade_cost(guard_id):
		return "Need %d gold" % game_manager.get_guard_upgrade_cost(guard_id)
	return ""

func _permanent_disabled_reason(upgrade_id: StringName) -> String:
	var definition := game_manager.get_permanent_upgrade_definition(upgrade_id)
	if game_manager.get_permanent_upgrade_rank(upgrade_id) >= int(definition.get("max_rank", 1)):
		return "MAXED"
	if game_manager.gold < game_manager.get_permanent_upgrade_cost(upgrade_id):
		return "Need %d gold" % game_manager.get_permanent_upgrade_cost(upgrade_id)
	return ""

func _clear_list() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()

func _flash_purchase() -> void:
	modulate = Color(0.75, 1.0, 0.92, 1.0)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.18)

func _on_permanent_upgrade_pressed(upgrade_id: StringName) -> void:
	if game_manager.unlock_permanent_upgrade(upgrade_id):
		_flash_purchase()
	_refresh_active_tab()

func _on_hero_action_pressed(hero_id: String, was_owned: bool) -> void:
	var purchased := game_manager.upgrade_hero(hero_id) if was_owned else game_manager.unlock_hero(hero_id)
	if purchased:
		_flash_purchase()
	_refresh_active_tab()

func _on_guard_upgrade_pressed(guard_id: String) -> void:
	if game_manager.upgrade_guard(guard_id):
		_flash_purchase()
	_refresh_active_tab()

func _on_close_pressed() -> void:
	visible = false
	closed.emit()
