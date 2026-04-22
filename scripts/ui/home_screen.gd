extends Control

const SCREEN_MAIN_MENU = "MainMenuScreen"
const SCREEN_MODE_SELECT = "ModeSelectScreen"
const SCREEN_HERO_SELECT = "HeroSelectScreen"
const SCREEN_EQUIPMENT_SELECT = "EquipmentSelectScreen"
const SCREEN_PET_SELECT = "PetSelectScreen"
const SCREEN_INVENTORY = "InventoryScreen"
const MOBILE_WIDTH_THRESHOLD = 700.0
const COMPACT_HEIGHT_THRESHOLD = 520.0
const MOBILE_MARGIN = 14
const DESKTOP_MARGIN = 32
const HUB_SUMMARY_PANEL_SCRIPT := preload("res://scripts/ui/home/HubSummaryPanel.gd")
const HERO_SELECT_PANEL_SCRIPT := preload("res://scripts/ui/home/HeroSelectPanel.gd")
const EQUIPMENT_PANEL_SCRIPT := preload("res://scripts/ui/home/EquipmentPanel.gd")
const PET_SELECT_PANEL_SCRIPT := preload("res://scripts/ui/home/PetSelectPanel.gd")
const INVENTORY_PANEL_SCRIPT := preload("res://scripts/ui/home/InventoryPanel.gd")

@onready var screen_root: Control = $ScreenRoot
@onready var main_menu_screen: Control = $ScreenRoot/MainMenuScreen
@onready var mode_select_screen: Control = $ScreenRoot/ModeSelectScreen
@onready var hero_select_screen: Control = $ScreenRoot/HeroSelectScreen
@onready var equipment_select_screen: Control = $ScreenRoot/EquipmentSelectScreen
@onready var pet_select_screen: Control = $ScreenRoot/PetSelectScreen
@onready var inventory_screen: Control = $ScreenRoot/InventoryScreen
@onready var settings_screen: SettingsScreen = $SettingsScreen
@onready var placeholder_popup: PlaceholderPopup = $PlaceholderPopup
@onready var scene_router: SceneRouter = get_node("/root/SceneRouter") as SceneRouter
@onready var game_manager: GameManager = get_node("/root/GameManager") as GameManager

@onready var play_button: Button = $ScreenRoot/MainMenuScreen/Layout/Root/Footer/PrimaryActions/PlayButton
@onready var inventory_button: Button = $ScreenRoot/MainMenuScreen/Layout/Root/Footer/PrimaryActions/InventoryButton
@onready var settings_button: Button = $ScreenRoot/MainMenuScreen/Layout/Root/Footer/PrimaryActions/SecondaryActions/SettingsButton
@onready var exit_button: Button = $ScreenRoot/MainMenuScreen/Layout/Root/Footer/PrimaryActions/SecondaryActions/ExitButton

@onready var survival_button: Button = $ScreenRoot/ModeSelectScreen/Layout/Root/Content/ModeList/SurvivalButton
@onready var endless_button: Button = $ScreenRoot/ModeSelectScreen/Layout/Root/Content/ModeList/EndlessButton
@onready var boss_rush_button: Button = $ScreenRoot/ModeSelectScreen/Layout/Root/Content/ModeList/BossRushButton
@onready var mode_back_button: Button = $ScreenRoot/ModeSelectScreen/Layout/Root/Footer/BackButton

@onready var hero_status_label: Label = $ScreenRoot/HeroSelectScreen/Layout/Root/Content/SelectionSummary/SummaryMargin/StatusLabel
@onready var hero_continue_button: Button = $ScreenRoot/HeroSelectScreen/Layout/Root/Footer/ContinueButton
@onready var hero_back_button: Button = $ScreenRoot/HeroSelectScreen/Layout/Root/Footer/BackButton
@onready var hero_knight_button: Button = $ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/SelectButton
@onready var hero_rogue_button: Button = $ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin/VBox/SelectButton
@onready var hero_mage_button: Button = $ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard/Margin/VBox/SelectButton

@onready var equipment_summary_label: Label = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard/Margin/LoadoutSummary
@onready var equipment_inventory_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/InventoryButton
@onready var equipment_continue_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Footer/ContinueButton
@onready var equipment_back_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Footer/BackButton
@onready var weapon_slot_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/WeaponSlot/Margin/VBox/SlotButton
@onready var armor_slot_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/ArmorSlot/Margin/VBox/SlotButton
@onready var accessory_slot_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/AccessorySlot/Margin/VBox/SlotButton

@onready var pet_status_label: Label = $ScreenRoot/PetSelectScreen/Layout/Root/Content/SelectionSummary/SummaryMargin/StatusLabel
@onready var pet_start_button: Button = $ScreenRoot/PetSelectScreen/Layout/Root/Footer/StartGameButton
@onready var pet_back_button: Button = $ScreenRoot/PetSelectScreen/Layout/Root/Footer/BackButton
@onready var pet_drone_button: Button = $ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/DroneCard/Margin/VBox/SelectButton
@onready var pet_sprite_button: Button = $ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/SpriteCard/Margin/VBox/SelectButton
@onready var pet_wisp_button: Button = $ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/WispCard/Margin/VBox/SelectButton

@onready var inventory_back_button: Button = $ScreenRoot/InventoryScreen/Layout/Root/Footer/BackButton
@onready var hub_preview_list: Label = $ScreenRoot/MainMenuScreen/Layout/Root/Footer/FeaturePreview/PreviewMargin/PreviewContent/PreviewList
@onready var hub_preview_note: Label = $ScreenRoot/MainMenuScreen/Layout/Root/Footer/FeaturePreview/PreviewMargin/PreviewContent/PreviewNote
@onready var inventory_description_label: Label = $ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/DescriptionLabel

var _screen_lookup: Dictionary = {}
var _screen_history: Array = []
var _active_screen: String = SCREEN_MAIN_MENU
var _return_screen_after_settings: String = SCREEN_MAIN_MENU
var _selected_mode_id: String = "mode_survival"
var _selected_hero_id: String = "hero_knight"
var _selected_weapon_id: String = "weapon_basic"
var _selected_pet_id: String = "pet_drone"
var _hub_summary_panel
var _hero_select_panel
var _equipment_panel
var _pet_select_panel
var _inventory_panel

func _ready() -> void:
	_screen_lookup = {
		"MainMenuScreen": main_menu_screen,
		"ModeSelectScreen": mode_select_screen,
		"HeroSelectScreen": hero_select_screen,
		"EquipmentSelectScreen": equipment_select_screen,
		"PetSelectScreen": pet_select_screen,
		"InventoryScreen": inventory_screen,
	}

	_hub_summary_panel = HUB_SUMMARY_PANEL_SCRIPT.new()
	_hero_select_panel = HERO_SELECT_PANEL_SCRIPT.new()
	_equipment_panel = EQUIPMENT_PANEL_SCRIPT.new()
	_pet_select_panel = PET_SELECT_PANEL_SCRIPT.new()
	_inventory_panel = INVENTORY_PANEL_SCRIPT.new()

	_hub_summary_panel.setup(hub_preview_list, hub_preview_note, game_manager)
	_hero_select_panel.setup(hero_status_label, hero_continue_button, hero_knight_button, hero_rogue_button, hero_mage_button, game_manager)
	_equipment_panel.setup(equipment_summary_label, weapon_slot_button, armor_slot_button, accessory_slot_button, game_manager)
	_pet_select_panel.setup(pet_status_label, pet_drone_button, pet_sprite_button, pet_wisp_button, game_manager)
	_inventory_panel.setup(inventory_description_label, game_manager)

	play_button.pressed.connect(_on_play_pressed)
	inventory_button.pressed.connect(_on_inventory_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

	survival_button.pressed.connect(_on_survival_pressed)
	endless_button.pressed.connect(_on_endless_pressed)
	boss_rush_button.pressed.connect(_on_boss_rush_pressed)
	mode_back_button.pressed.connect(_go_back)

	hero_knight_button.pressed.connect(_on_knight_pressed)
	hero_rogue_button.pressed.connect(_on_rogue_pressed)
	hero_mage_button.pressed.connect(_on_mage_pressed)
	hero_continue_button.pressed.connect(_on_hero_continue_pressed)
	hero_back_button.pressed.connect(_go_back)

	weapon_slot_button.pressed.connect(_on_weapon_slot_pressed)
	armor_slot_button.pressed.connect(_on_armor_slot_pressed)
	accessory_slot_button.pressed.connect(_on_accessory_slot_pressed)
	equipment_inventory_button.pressed.connect(_on_inventory_pressed)
	equipment_continue_button.pressed.connect(_on_equipment_continue_pressed)
	equipment_back_button.pressed.connect(_go_back)

	pet_drone_button.pressed.connect(_on_drone_pressed)
	pet_sprite_button.pressed.connect(_on_sprite_pressed)
	pet_wisp_button.pressed.connect(_on_wisp_pressed)
	pet_start_button.pressed.connect(_start_game)
	pet_back_button.pressed.connect(_go_back)

	inventory_back_button.pressed.connect(_go_back)
	settings_screen.back_requested.connect(_close_settings)
	placeholder_popup.closed.connect(_on_placeholder_closed)
	game_manager.currency_changed.connect(_refresh_hub_summary)
	game_manager.inventory_changed.connect(_refresh_inventory_summary)
	game_manager.loadout_changed.connect(_load_selection_from_manager)
	get_viewport().size_changed.connect(_apply_responsive_layout)

	_apply_responsive_layout()
	_load_selection_from_manager()
	_refresh_hero_summary()
	_refresh_equipment_summary()
	_refresh_pet_summary()
	_refresh_hub_summary(game_manager.soft_currency)
	_refresh_inventory_summary(game_manager.inventory)
	_show_screen(SCREEN_MAIN_MENU, false)

func _show_screen(screen_name: String, add_to_history: bool = true) -> void:
	if add_to_history and screen_name != _active_screen:
		_screen_history.append(_active_screen)

	for name in _screen_lookup.keys():
		var screen := _screen_lookup[name] as Control
		screen.visible = name == screen_name

	_active_screen = screen_name
	settings_screen.visible = false
	placeholder_popup.visible = false
	screen_root.mouse_filter = Control.MOUSE_FILTER_PASS

	if screen_name == SCREEN_HERO_SELECT:
		_refresh_hero_summary()
	elif screen_name == SCREEN_EQUIPMENT_SELECT:
		_refresh_equipment_summary()
	elif screen_name == SCREEN_PET_SELECT:
		_refresh_pet_summary()
	_apply_responsive_layout()

func _go_back() -> void:
	if _screen_history.is_empty():
		_show_screen(SCREEN_MAIN_MENU, false)
		return

	var previous_screen: String = str(_screen_history.pop_back())
	_show_screen(previous_screen, false)

func _open_settings(return_screen: String) -> void:
	_return_screen_after_settings = return_screen
	settings_screen.visible = true
	screen_root.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _close_settings() -> void:
	settings_screen.visible = false
	screen_root.mouse_filter = Control.MOUSE_FILTER_PASS
	_show_screen(_return_screen_after_settings, false)

func _show_placeholder(title: String, message: String) -> void:
	screen_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	placeholder_popup.show_message(title, message)

func _select_hero(hero_id: String, available: bool) -> void:
	if not available:
		_show_placeholder("Hero Locked", "This hero is locked. Keep playing to unlock more heroes later.")
		return

	_selected_hero_id = hero_id
	game_manager.set_selected_loadout(_selected_hero_id, _selected_weapon_id, _selected_pet_id)
	_refresh_hero_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _refresh_hero_summary() -> void:
	_hero_select_panel.refresh(_selected_hero_id)

func _refresh_equipment_summary() -> void:
	_equipment_panel.refresh(_selected_weapon_id)

func _select_pet(pet_id: String, implemented: bool) -> void:
	if not implemented:
		_show_placeholder("Pet Locked", "This pet is locked. Pet progression will unlock more companions later.")
		return

	_selected_pet_id = pet_id
	game_manager.set_selected_loadout(_selected_hero_id, _selected_weapon_id, _selected_pet_id)
	_refresh_pet_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _refresh_pet_summary() -> void:
	_pet_select_panel.refresh(_selected_pet_id)

func _start_game() -> void:
	if scene_router != null:
		game_manager.set_selected_loadout(_selected_hero_id, _selected_weapon_id, _selected_pet_id)
		scene_router.go_to_game()

func _load_selection_from_manager() -> void:
	_selected_hero_id = game_manager.selected_hero_id
	_selected_weapon_id = game_manager.selected_weapon_id
	_selected_pet_id = game_manager.selected_pet_id
	_equipment_panel.sync_selected_weapon(_selected_weapon_id)

func _refresh_hub_summary(_currency: int = 0) -> void:
	_hub_summary_panel.refresh(_currency)

func _refresh_inventory_summary(_inventory: Dictionary = {}) -> void:
	_inventory_panel.refresh(_inventory)

func _on_play_pressed() -> void:
	_show_screen(SCREEN_MODE_SELECT)

func _on_inventory_pressed() -> void:
	_show_screen(SCREEN_INVENTORY)

func _on_settings_pressed() -> void:
	_open_settings(SCREEN_MAIN_MENU)

func _on_exit_pressed() -> void:
	_show_placeholder("Exit", "Use the platform close action for now.")

func _on_survival_pressed() -> void:
	_selected_mode_id = "mode_survival"
	_show_screen(SCREEN_HERO_SELECT)

func _on_endless_pressed() -> void:
	_show_placeholder("Coming Soon", "Endless mode is visible in the shell but not available in MVP.")

func _on_boss_rush_pressed() -> void:
	_show_placeholder("Coming Soon", "Boss Rush is planned after the MVP loop is stable.")

func _on_knight_pressed() -> void:
	_select_hero("hero_knight", true)

func _on_rogue_pressed() -> void:
	_select_hero("hero_rogue", game_manager.is_hero_unlocked("hero_rogue"))

func _on_mage_pressed() -> void:
	_select_hero("hero_mage", game_manager.is_hero_unlocked("hero_mage"))

func _on_hero_continue_pressed() -> void:
	_show_screen(SCREEN_EQUIPMENT_SELECT)

func _on_weapon_slot_pressed() -> void:
	var next_weapon_id: String = _equipment_panel.cycle_weapon(_selected_weapon_id)
	if next_weapon_id == _selected_weapon_id:
		return
	_selected_weapon_id = next_weapon_id
	game_manager.set_selected_loadout(_selected_hero_id, _selected_weapon_id, _selected_pet_id)
	_refresh_equipment_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _on_armor_slot_pressed() -> void:
	_show_placeholder("Not Available In MVP", "Armor remains visible in the shell but has no gameplay logic yet.")

func _on_accessory_slot_pressed() -> void:
	_show_placeholder("Not Available In MVP", "Accessories stay visible as product structure but are not implemented yet.")

func _on_equipment_continue_pressed() -> void:
	_show_screen(SCREEN_PET_SELECT)

func _on_drone_pressed() -> void:
	_select_pet("pet_drone", true)

func _on_sprite_pressed() -> void:
	_select_pet("pet_sprite", game_manager.is_pet_unlocked("pet_sprite"))

func _on_wisp_pressed() -> void:
	_select_pet("pet_wisp", game_manager.is_pet_unlocked("pet_wisp"))

func _on_placeholder_closed() -> void:
	screen_root.mouse_filter = Control.MOUSE_FILTER_PASS

func _apply_responsive_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var is_narrow := viewport_size.x <= MOBILE_WIDTH_THRESHOLD
	var is_compact := is_narrow or viewport_size.y <= COMPACT_HEIGHT_THRESHOLD
	var margin := MOBILE_MARGIN if is_compact else DESKTOP_MARGIN

	for layout_path in [
		"ScreenRoot/MainMenuScreen/Layout",
		"ScreenRoot/ModeSelectScreen/Layout",
		"ScreenRoot/HeroSelectScreen/Layout",
		"ScreenRoot/EquipmentSelectScreen/Layout",
		"ScreenRoot/PetSelectScreen/Layout",
		"ScreenRoot/InventoryScreen/Layout",
	]:
		_set_margin(layout_path, margin)

	_set_grid_columns("ScreenRoot/MainMenuScreen/Layout/Root/Footer", 1 if is_narrow else 2)
	_set_grid_columns("ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards", 1 if is_narrow else 3)
	_set_grid_columns("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns", 1 if is_narrow else 2)
	_set_grid_columns("ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards", 1 if is_narrow else 3)
	_set_grid_columns("ScreenRoot/InventoryScreen/Layout/Root/Content", 1 if is_narrow else 2)

	for grid_path in [
		"ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Weapons/Grid",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Items/Grid",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Pets/Grid",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Materials/Grid",
	]:
		_set_grid_columns(grid_path, 1 if is_narrow else 2)

	var portrait_height := 96.0 if is_compact else 180.0
	for portrait_path in [
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/Portrait",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin/VBox/Portrait",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard/Margin/VBox/Portrait",
	]:
		_set_minimum_size(portrait_path, Vector2(0.0, portrait_height))

	_set_minimum_size("ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel", Vector2(0.0 if is_narrow else 280.0, 0.0))
	_update_touch_targets(screen_root, is_compact)

func _set_grid_columns(path: String, columns: int) -> void:
	var grid := get_node_or_null(path) as GridContainer
	if grid == null:
		return
	grid.columns = max(columns, 1)

func _set_margin(path: String, margin: int) -> void:
	var margin_container := get_node_or_null(path) as MarginContainer
	if margin_container == null:
		return
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)

func _set_minimum_size(path: String, minimum_size: Vector2) -> void:
	var control := get_node_or_null(path) as Control
	if control == null:
		return
	control.custom_minimum_size = minimum_size

func _update_touch_targets(root: Node, is_compact: bool) -> void:
	for child in root.get_children():
		if child is Button:
			var button := child as Button
			button.custom_minimum_size = Vector2(0.0 if is_compact else button.custom_minimum_size.x, max(button.custom_minimum_size.y, 52.0))
		elif child is CheckButton:
			var check_button := child as CheckButton
			check_button.custom_minimum_size = Vector2(0.0 if is_compact else check_button.custom_minimum_size.x, max(check_button.custom_minimum_size.y, 52.0))
		_update_touch_targets(child, is_compact)
