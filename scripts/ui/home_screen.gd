extends Control

const SCREEN_MAIN_MENU = "MainMenuScreen"
const SCREEN_MODE_SELECT = "ModeSelectScreen"
const SCREEN_HERO_SELECT = "HeroSelectScreen"
const SCREEN_EQUIPMENT_SELECT = "EquipmentSelectScreen"
const SCREEN_PET_SELECT = "PetSelectScreen"
const SCREEN_INVENTORY = "InventoryScreen"
const MOBILE_WIDTH_THRESHOLD = 700.0
const COMPACT_HEIGHT_THRESHOLD = 620.0
const MOBILE_MARGIN = 10
const DESKTOP_MARGIN = 32
const HUB_SUMMARY_PANEL_SCRIPT := preload("res://scripts/ui/home/HubSummaryPanel.gd")
const HERO_SELECT_PANEL_SCRIPT := preload("res://scripts/ui/home/HeroSelectPanel.gd")
const EQUIPMENT_PANEL_SCRIPT := preload("res://scripts/ui/home/EquipmentPanel.gd")
const PET_SELECT_PANEL_SCRIPT := preload("res://scripts/ui/home/PetSelectPanel.gd")
const INVENTORY_PANEL_SCRIPT := preload("res://scripts/ui/home/InventoryPanel.gd")
const HOME_UI_MANAGER_SCRIPT := preload("res://scripts/ui/home/HomeUIManager.gd")
const HOME_STATE_SCRIPT := preload("res://scripts/ui/home/HomeState.gd")
const HOME_UI_STYLE := preload("res://scripts/ui/home/HomeUIStyle.gd")

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
@onready var inventory_item_buttons: Array[Button] = [
	$ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Weapons/Grid/WeaponA,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Weapons/Grid/WeaponB,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Weapons/Grid/WeaponC,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Weapons/Grid/WeaponD,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Items/Grid/ItemA,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Items/Grid/ItemB,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Items/Grid/ItemC,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Pets/Grid/PetA,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Pets/Grid/PetB,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Materials/Grid/MaterialA,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Materials/Grid/MaterialB,
]

var _screen_lookup: Dictionary = {}
var _return_screen_after_settings: String = SCREEN_MAIN_MENU
var _selected_mode_id: String = "mode_survival"
var _selected_hero_id: String = "hero_knight"
var _selected_weapon_id: String = "weapon_basic"
var _selected_pet_id: String = "pet_drone"
var _home_ui_manager
var _home_state
var _hub_summary_panel
var _hero_select_panel
var _equipment_panel
var _pet_select_panel
var _inventory_panel
var _original_minimum_sizes: Dictionary = {}
var _scroll_containers: Dictionary = {}

func _ready() -> void:
	_screen_lookup = {
		"MainMenuScreen": main_menu_screen,
		"ModeSelectScreen": mode_select_screen,
		"HeroSelectScreen": hero_select_screen,
		"EquipmentSelectScreen": equipment_select_screen,
		"PetSelectScreen": pet_select_screen,
		"InventoryScreen": inventory_screen,
	}

	_home_ui_manager = HOME_UI_MANAGER_SCRIPT.new()
	_home_ui_manager.setup(_screen_lookup, SCREEN_MAIN_MENU)
	_home_ui_manager.panel_changed.connect(_on_home_panel_changed)
	_home_state = HOME_STATE_SCRIPT.new()
	_home_state.hero_changed.connect(_on_home_state_hero_changed)
	_home_state.weapon_changed.connect(_on_home_state_weapon_changed)
	_home_state.pet_changed.connect(_on_home_state_pet_changed)
	_home_state.equipment_slot_changed.connect(_on_home_state_equipment_slot_changed)
	_home_state.equipment_summary_changed.connect(_on_home_state_equipment_summary_changed)
	_home_state.inventory_summary_changed.connect(_on_home_state_inventory_summary_changed)

	_hub_summary_panel = HUB_SUMMARY_PANEL_SCRIPT.new()
	_hero_select_panel = HERO_SELECT_PANEL_SCRIPT.new()
	_equipment_panel = EQUIPMENT_PANEL_SCRIPT.new()
	_pet_select_panel = PET_SELECT_PANEL_SCRIPT.new()
	_inventory_panel = INVENTORY_PANEL_SCRIPT.new()

	_hub_summary_panel.setup(hub_preview_list, hub_preview_note, game_manager, _home_state)
	_hero_select_panel.setup(hero_status_label, hero_continue_button, hero_knight_button, hero_rogue_button, hero_mage_button, game_manager, _home_state)
	_equipment_panel.setup(equipment_summary_label, weapon_slot_button, armor_slot_button, accessory_slot_button, game_manager, _home_state)
	_pet_select_panel.setup(pet_status_label, pet_drone_button, pet_sprite_button, pet_wisp_button, game_manager, _home_state)
	_inventory_panel.setup(inventory_description_label, inventory_item_buttons, game_manager, _home_state)
	_equipment_panel.equip_slot_requested.connect(_on_equipment_slot_requested)
	_inventory_panel.item_selected.connect(_on_inventory_item_selected)

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

	_install_scroll_containers()
	_apply_home_visual_style()
	_apply_responsive_layout()
	_load_selection_from_manager()
	_refresh_hero_summary()
	_refresh_equipment_summary()
	_refresh_pet_summary()
	_refresh_hub_summary(game_manager.soft_currency)
	_refresh_inventory_summary(game_manager.inventory)
	_show_screen(SCREEN_MAIN_MENU, false)

func _apply_home_visual_style() -> void:
	HOME_UI_STYLE.apply_tree(screen_root)
	HOME_UI_STYLE.apply_button_state(play_button, "selected")
	HOME_UI_STYLE.apply_button_state(inventory_button, "secondary")
	HOME_UI_STYLE.apply_button_state(settings_button, "secondary")
	HOME_UI_STYLE.apply_button_state(exit_button, "locked")
	HOME_UI_STYLE.apply_button_state(mode_back_button, "secondary")
	HOME_UI_STYLE.apply_button_state(hero_back_button, "secondary")
	HOME_UI_STYLE.apply_button_state(equipment_back_button, "secondary")
	HOME_UI_STYLE.apply_button_state(pet_back_button, "secondary")
	HOME_UI_STYLE.apply_button_state(inventory_back_button, "secondary")
	HOME_UI_STYLE.apply_button_state(equipment_continue_button, "selected")
	HOME_UI_STYLE.apply_button_state(pet_start_button, "selected")

func _show_screen(screen_name: String, add_to_history: bool = true) -> void:
	_home_ui_manager.open_panel(screen_name, add_to_history)

func _on_home_panel_changed(screen_name: String) -> void:
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
	_reset_scroll_position(screen_name)

func _go_back() -> void:
	_home_ui_manager.go_back()

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
	_home_state.sync_loadout(_selected_hero_id, _selected_weapon_id, _selected_pet_id, true)

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

func _on_equipment_slot_requested(slot_id: String) -> void:
	_home_state.set_selected_equipment_slot(slot_id)
	_refresh_inventory_summary(game_manager.inventory)
	_show_screen(SCREEN_INVENTORY)

func _on_inventory_item_selected(item_id: String) -> void:
	if _home_state.equip_item(item_id):
		_home_ui_manager.go_back()
		return
	_show_placeholder("Cannot Equip", "That item does not fit the selected equipment slot.")

func _on_home_state_hero_changed(_hero_id: String) -> void:
	_refresh_hero_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _on_home_state_weapon_changed(_weapon_id: String) -> void:
	_refresh_equipment_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _on_home_state_pet_changed(_pet_id: String) -> void:
	_refresh_pet_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _on_home_state_equipment_summary_changed(_summary: String) -> void:
	_refresh_equipment_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _on_home_state_inventory_summary_changed(_summary: String) -> void:
	_refresh_inventory_summary(game_manager.inventory)

func _on_home_state_equipment_slot_changed(_slot_id: String) -> void:
	_refresh_inventory_summary(game_manager.inventory)

func _apply_responsive_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var is_narrow := viewport_size.x <= MOBILE_WIDTH_THRESHOLD
	var is_compact := is_narrow or viewport_size.y <= COMPACT_HEIGHT_THRESHOLD
	var margin := MOBILE_MARGIN if is_compact else DESKTOP_MARGIN
	var root_separation := 10 if is_compact else 20
	var content_separation := 8 if is_compact else 16
	var grid_separation := 8 if is_compact else 16
	var inner_margin := 10 if is_compact else 16
	var preview_margin := 12 if is_compact else 20

	for screen_name in _scroll_containers.keys():
		_set_scroll_container_enabled(str(screen_name), is_compact)

	for layout_path in [
		"ScreenRoot/MainMenuScreen/Layout",
		"ScreenRoot/ModeSelectScreen/Layout",
		"ScreenRoot/HeroSelectScreen/Layout",
		"ScreenRoot/EquipmentSelectScreen/Layout",
		"ScreenRoot/PetSelectScreen/Layout",
		"ScreenRoot/InventoryScreen/Layout",
	]:
		_set_margin(layout_path, margin)

	for root_path in [
		"ScreenRoot/MainMenuScreen/Layout/Root",
		"ScreenRoot/ModeSelectScreen/Layout/Root",
		"ScreenRoot/HeroSelectScreen/Layout/Root",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root",
		"ScreenRoot/PetSelectScreen/Layout/Root",
		"ScreenRoot/InventoryScreen/Layout/Root",
	]:
		_set_box_separation(root_path, root_separation)

	for content_path in [
		"ScreenRoot/ModeSelectScreen/Layout/Root/Content",
		"ScreenRoot/ModeSelectScreen/Layout/Root/Content/ModeList",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox",
	]:
		_set_box_separation(content_path, content_separation)

	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/Header", 4 if is_compact else 8)
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/Footer/PrimaryActions", content_separation)
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/Footer/PrimaryActions/SecondaryActions", 8 if is_compact else 12)
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/Footer/FeaturePreview/PreviewMargin/PreviewContent", 6 if is_compact else 10)
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/Spacer", Vector2(0.0, 4.0 if is_compact else 12.0))

	_set_grid_columns("ScreenRoot/MainMenuScreen/Layout/Root/Footer", 1 if is_narrow else 2)
	_set_grid_columns("ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards", 1 if is_narrow else 3)
	_set_grid_columns("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns", 1 if is_narrow else 2)
	_set_grid_columns("ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards", 1 if is_narrow else 3)
	_set_grid_columns("ScreenRoot/InventoryScreen/Layout/Root/Content", 1 if is_narrow else 2)
	_set_grid_separation("ScreenRoot/MainMenuScreen/Layout/Root/Footer", grid_separation, grid_separation)
	_set_grid_separation("ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards", grid_separation, grid_separation)
	_set_grid_separation("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns", grid_separation, grid_separation)
	_set_grid_separation("ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards", grid_separation, grid_separation)
	_set_grid_separation("ScreenRoot/InventoryScreen/Layout/Root/Content", grid_separation, grid_separation)

	for grid_path in [
		"ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Weapons/Grid",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Items/Grid",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Pets/Grid",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/TabContainer/Materials/Grid",
	]:
		_set_grid_columns(grid_path, 1 if is_narrow else 2)
		_set_grid_separation(grid_path, 6 if is_compact else 10, 6 if is_compact else 10)

	for inner_margin_path in [
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard/Margin",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/SelectionSummary/SummaryMargin",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/DroneCard/Margin",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/SpriteCard/Margin",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/WispCard/Margin",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/SelectionSummary/SummaryMargin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/WeaponSlot/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/ArmorSlot/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/AccessorySlot/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard/Margin",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin",
	]:
		_set_margin(inner_margin_path, inner_margin)
	_set_margin("ScreenRoot/MainMenuScreen/Layout/Root/Footer/FeaturePreview/PreviewMargin", preview_margin)

	var portrait_height := 72.0 if is_compact else 180.0
	for portrait_path in [
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/Portrait",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin/VBox/Portrait",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard/Margin/VBox/Portrait",
	]:
		_set_minimum_size(portrait_path, Vector2(0.0, portrait_height))

	var details_width := 0.0 if is_narrow else (220.0 if is_compact else 280.0)
	_set_minimum_size("ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel", Vector2(details_width, 0.0))
	_update_touch_targets(screen_root, is_compact)

func _install_scroll_containers() -> void:
	for screen_name in [
		SCREEN_MAIN_MENU,
		SCREEN_MODE_SELECT,
		SCREEN_HERO_SELECT,
		SCREEN_EQUIPMENT_SELECT,
		SCREEN_PET_SELECT,
		SCREEN_INVENTORY,
	]:
		_install_screen_scroll_container(screen_name)

func _install_screen_scroll_container(screen_name: String) -> void:
	var layout := get_node_or_null("ScreenRoot/%s/Layout" % screen_name) as MarginContainer
	var root := get_node_or_null("ScreenRoot/%s/Layout/Root" % screen_name) as Control
	if layout == null or root == null:
		return
	if root.get_parent() != layout:
		return

	var scroll := ScrollContainer.new()
	scroll.name = "RootScroll"
	scroll.anchor_right = 1.0
	scroll.anchor_bottom = 1.0
	scroll.grow_horizontal = Control.GROW_DIRECTION_BOTH
	scroll.grow_vertical = Control.GROW_DIRECTION_BOTH
	scroll.follow_focus = true
	scroll.clip_contents = true
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var root_index := root.get_index()
	layout.add_child(scroll)
	layout.move_child(scroll, root_index)
	root.reparent(scroll)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll_containers[screen_name] = scroll

func _set_scroll_container_enabled(screen_name: String, is_enabled: bool) -> void:
	var scroll := _scroll_containers.get(screen_name) as ScrollContainer
	if scroll == null:
		return
	scroll.vertical_scroll_mode = 1 if is_enabled else 0
	scroll.horizontal_scroll_mode = 0

func _reset_scroll_position(screen_name: String) -> void:
	var scroll := _scroll_containers.get(screen_name) as ScrollContainer
	if scroll == null:
		return
	scroll.scroll_vertical = 0

func _get_ui_node(path: String) -> Node:
	var node := get_node_or_null(path)
	if node != null:
		return node
	if path.find("/Layout/Root") == -1:
		return null
	return get_node_or_null(path.replace("/Layout/Root", "/Layout/RootScroll/Root"))

func _set_grid_columns(path: String, columns: int) -> void:
	var grid := _get_ui_node(path) as GridContainer
	if grid == null:
		return
	grid.columns = max(columns, 1)

func _set_grid_separation(path: String, horizontal: int, vertical: int) -> void:
	var grid := _get_ui_node(path) as GridContainer
	if grid == null:
		return
	grid.add_theme_constant_override("h_separation", horizontal)
	grid.add_theme_constant_override("v_separation", vertical)
	grid.add_theme_constant_override("separation", max(horizontal, vertical))

func _set_box_separation(path: String, separation: int) -> void:
	var container := _get_ui_node(path) as BoxContainer
	if container == null:
		return
	container.add_theme_constant_override("separation", separation)

func _set_margin(path: String, margin: int) -> void:
	var margin_container := _get_ui_node(path) as MarginContainer
	if margin_container == null:
		return
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)

func _set_minimum_size(path: String, minimum_size: Vector2) -> void:
	var control := _get_ui_node(path) as Control
	if control == null:
		return
	control.custom_minimum_size = minimum_size

func _get_original_minimum_size(control: Control) -> Vector2:
	var id := control.get_instance_id()
	if not _original_minimum_sizes.has(id):
		_original_minimum_sizes[id] = control.custom_minimum_size
	return _original_minimum_sizes[id]

func _update_touch_targets(root: Node, is_compact: bool) -> void:
	for child in root.get_children():
		if child is Button:
			var button := child as Button
			var original_size := _get_original_minimum_size(button)
			var compact_height: float = min(max(original_size.y, 44.0), 46.0)
			button.custom_minimum_size = Vector2(0.0 if is_compact else original_size.x, compact_height if is_compact else original_size.y)
		elif child is CheckButton:
			var check_button := child as CheckButton
			var original_size := _get_original_minimum_size(check_button)
			var compact_height: float = min(max(original_size.y, 44.0), 46.0)
			check_button.custom_minimum_size = Vector2(0.0 if is_compact else original_size.x, compact_height if is_compact else original_size.y)
		_update_touch_targets(child, is_compact)
