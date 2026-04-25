extends Control

const SCREEN_MAIN_MENU = "MainMenuScreen"
const SCREEN_MODE_SELECT = "ModeSelectScreen"
const SCREEN_HERO_SELECT = "HeroSelectScreen"
const SCREEN_EQUIPMENT_SELECT = "EquipmentSelectScreen"
const SCREEN_PET_SELECT = "PetSelectScreen"
const SCREEN_INVENTORY = "InventoryScreen"
const LAYOUT_MOBILE = "mobile"
const LAYOUT_TABLET = "tablet"
const LAYOUT_DESKTOP = "desktop"
const MOBILE_MAX_WIDTH = 900.0
const MOBILE_MAX_HEIGHT = 620.0
const TABLET_MAX_WIDTH = 1180.0
const MOBILE_MARGIN = 10
const TABLET_MARGIN = 18
const DESKTOP_MARGIN = 32
const INVENTORY_MAX_CONTENT_WIDTH = 980.0
const INVENTORY_WIDE_SCREEN_RATIO = 0.82
const HUB_SUMMARY_PANEL_SCRIPT := preload("res://scripts/ui/home/HubSummaryPanel.gd")
const HERO_SELECT_PANEL_SCRIPT := preload("res://scripts/ui/home/HeroSelectPanel.gd")
const EQUIPMENT_PANEL_SCRIPT := preload("res://scripts/ui/home/EquipmentPanel.gd")
const PET_SELECT_PANEL_SCRIPT := preload("res://scripts/ui/home/PetSelectPanel.gd")
const INVENTORY_PANEL_SCRIPT := preload("res://scripts/ui/home/InventoryPanel.gd")
const HOME_UI_MANAGER_SCRIPT := preload("res://scripts/ui/home/HomeUIManager.gd")
const HOME_STATE_SCRIPT := preload("res://scripts/ui/home/HomeState.gd")
const HOME_UI_STYLE := preload("res://scripts/ui/home/HomeUIStyle.gd")
const HERO_PREVIEW_SPAWNER := preload("res://scripts/ui/home/HeroPreviewSpawner.gd")

@onready var screen_root: Control = $ScreenRoot
@onready var background_art: TextureRect = $BackgroundArt
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

@onready var play_button: Button = $ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/PlayButton
@onready var equipment_button: Button = $ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/EquipmentButton
@onready var inventory_button: Button = $ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/InventoryButton
@onready var settings_button: Button = $ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/TopSettingsButton
@onready var exit_button: Button = $ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/ExitButton
@onready var hub_profile_label: Label = $ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin/ProfileRow/ProfileText/ProfileLabel
@onready var hub_level_label: Label = $ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin/ProfileRow/ProfileText/LevelLabel
@onready var hub_profile_progress: ProgressBar = $ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin/ProfileRow/ProfileText/ProgressBar
@onready var hub_energy_label: Label = $ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/EnergyLabel
@onready var hub_currency_label: Label = $ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/CurrencyLabel
@onready var hub_gems_label: Label = $ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/GemsLabel
@onready var hub_hero_stage: Control = $ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage
@onready var hub_hero_image: TextureRect = $ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/HeroImage
@onready var hub_character_label: Label = $ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/CharacterPlaceholder
@onready var hub_hero_name_label: Label = $ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/HeroNameLabel
@onready var hub_power_label: Label = $ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/StatsPanel/StatsMargin/StatsLabel
@onready var hub_power_value_label: Label = $ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PowerCard/Margin/VBox/PowerValue

@onready var survival_button: Button = $ScreenRoot/ModeSelectScreen/Layout/Root/Content/ModeList/SurvivalButton
@onready var endless_button: Button = $ScreenRoot/ModeSelectScreen/Layout/Root/Content/ModeList/EndlessButton
@onready var boss_rush_button: Button = $ScreenRoot/ModeSelectScreen/Layout/Root/Content/ModeList/BossRushButton
@onready var mode_back_button: Button = $ScreenRoot/ModeSelectScreen/Layout/Root/Footer/BackButton

@onready var hero_status_label: Label = $ScreenRoot/HeroSelectScreen/Layout/Root/Content/SelectionSummary/SummaryMargin/StatusLabel
@onready var hero_continue_button: Button = $ScreenRoot/HeroSelectScreen/Layout/Root/Footer/ContinueButton
@onready var hero_back_button: Button = $ScreenRoot/HeroSelectScreen/Layout/Root/Header/BackButton
@onready var hero_knight_portrait: Control = $ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/Portrait
@onready var hero_knight_button: Button = $ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/SelectButton
@onready var hero_rogue_portrait: Control = $ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin/VBox/Portrait
@onready var hero_rogue_button: Button = $ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin/VBox/SelectButton
@onready var hero_mage_portrait: Control = $ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard/Margin/VBox/Portrait
@onready var hero_mage_button: Button = $ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard/Margin/VBox/SelectButton

@onready var equipment_summary_label: Label = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard/Margin/LoadoutSummary
@onready var equipment_inventory_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/InventoryButton
@onready var equipment_continue_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Footer/ContinueButton
@onready var equipment_back_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Header/BackButton
@onready var weapon_slot_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/WeaponSlot/Margin/VBox/SlotButton
@onready var armor_slot_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/ArmorSlot/Margin/VBox/SlotButton
@onready var pet_equipment_slot_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/PetSlot/Margin/VBox/SlotButton
@onready var accessory_slot_button: Button = $ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/AccessorySlot/Margin/VBox/SlotButton

@onready var pet_status_label: Label = $ScreenRoot/PetSelectScreen/Layout/Root/Content/SelectionSummary/SummaryMargin/StatusLabel
@onready var pet_start_button: Button = $ScreenRoot/PetSelectScreen/Layout/Root/Footer/StartGameButton
@onready var pet_back_button: Button = $ScreenRoot/PetSelectScreen/Layout/Root/Header/BackButton
@onready var pet_drone_button: Button = $ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/DroneCard/Margin/VBox/SelectButton
@onready var pet_sprite_button: Button = $ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/SpriteCard/Margin/VBox/SelectButton
@onready var pet_wisp_button: Button = $ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/WispCard/Margin/VBox/SelectButton

@onready var inventory_back_button: Button = $ScreenRoot/InventoryScreen/Layout/Root/Header/BackButton
@onready var hub_preview_list: Label = $ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin/PreviewContent/PreviewList
@onready var hub_preview_note: Label = $ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin/PreviewContent/PreviewNote
@onready var hub_weapon_preview: Label = $ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox/SummaryGrid/WeaponPreview
@onready var hub_armor_preview: Label = $ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox/SummaryGrid/ArmorPreview
@onready var hub_defense_preview: Label = $ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox/SummaryGrid/DefensePreview
@onready var hub_pet_preview: Label = $ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox/SummaryGrid/PetPreview
@onready var inventory_slot_target_label: Label = $ScreenRoot/InventoryScreen/Layout/Root/Header/SlotTargetLabel
@onready var inventory_icon_label: Label = $ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/IconPreview
@onready var inventory_name_label: Label = $ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/NameLabel
@onready var inventory_type_label: Label = $ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/TypeLabel
@onready var inventory_stats_label: Label = $ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/StatsLabel
@onready var inventory_description_label: Label = $ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/DescriptionLabel
@onready var inventory_equip_button: Button = $ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/ActionRow/EquipButton
@onready var inventory_upgrade_button: Button = $ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/ActionRow/UpgradeButton
@onready var inventory_drop_button: Button = $ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/ActionRow/DropButton
@onready var inventory_item_buttons: Array[Button] = [
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotA,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotB,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotC,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotD,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotE,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotF,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotG,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotH,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotI,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotJ,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotK,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotL,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotM,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotN,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotO,
	$ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotP,
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

	_hub_summary_panel.setup(hub_preview_list, hub_preview_note, game_manager, _home_state, hub_weapon_preview, hub_armor_preview, hub_pet_preview, hub_defense_preview)
	_hero_select_panel.setup(hero_status_label, hero_continue_button, hero_knight_button, hero_rogue_button, hero_mage_button, game_manager, _home_state)
	_equipment_panel.setup(equipment_summary_label, weapon_slot_button, armor_slot_button, accessory_slot_button, game_manager, _home_state)
	_pet_select_panel.setup(pet_status_label, pet_start_button, pet_drone_button, pet_sprite_button, pet_wisp_button, game_manager, _home_state)
	_inventory_panel.setup(inventory_description_label, inventory_item_buttons, game_manager, _home_state, inventory_name_label, inventory_type_label, inventory_stats_label, inventory_equip_button, inventory_drop_button, inventory_slot_target_label, inventory_upgrade_button, inventory_icon_label)
	_equipment_panel.equip_slot_requested.connect(_on_equipment_slot_requested)
	_inventory_panel.equip_requested.connect(_on_inventory_item_selected)

	play_button.pressed.connect(_on_play_pressed)
	equipment_button.pressed.connect(_on_hub_equipment_pressed)
	inventory_button.pressed.connect(_on_inventory_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	var hero_nav_button := get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/HeroButton") as Button
	if hero_nav_button != null:
		hero_nav_button.pressed.connect(_on_hub_hero_pressed)
	var pet_nav_button := get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/PetButton") as Button
	if pet_nav_button != null:
		pet_nav_button.pressed.connect(_on_hub_pet_pressed)
	var map_nav_button := get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/MapButton") as Button
	if map_nav_button != null:
		map_nav_button.pressed.connect(_on_map_pressed)

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
	pet_equipment_slot_button.pressed.connect(_on_hub_pet_pressed)

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
	var wenrexa_background := HOME_UI_STYLE.get_background_texture()
	if wenrexa_background != null:
		background_art.texture = wenrexa_background
	HOME_UI_STYLE.apply_tree(screen_root)
	HOME_UI_STYLE.apply_button_state(play_button, "selected")
	HOME_UI_STYLE.apply_button_state(equipment_button, "secondary")
	HOME_UI_STYLE.apply_button_state(inventory_button, "secondary")
	HOME_UI_STYLE.apply_button_state(settings_button, "secondary")
	HOME_UI_STYLE.apply_button_state(exit_button, "locked")
	HOME_UI_STYLE.apply_button_state(mode_back_button, "secondary")
	HOME_UI_STYLE.apply_button_state(hero_back_button, "secondary")
	HOME_UI_STYLE.apply_button_state(equipment_back_button, "secondary")
	HOME_UI_STYLE.apply_button_state(pet_equipment_slot_button, "secondary")
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

func _focus_hero(hero_id: String) -> void:
	_selected_hero_id = hero_id
	if _home_state != null:
		_home_state.set_selected_hero(hero_id)
	else:
		_refresh_hero_summary()

func _refresh_hero_summary() -> void:
	_hero_select_panel.refresh(_selected_hero_id)
	_refresh_hero_preview_models()

func _refresh_hero_preview_models() -> void:
	var selected_hero_id := _selected_hero_id
	if _home_state != null:
		selected_hero_id = _home_state.selected_hero_id
	if hub_hero_image != null:
		hub_hero_image.visible = false
	HERO_PREVIEW_SPAWNER.show_preview(hub_hero_stage, selected_hero_id, true)

	var portrait_slots := {
		"hero_knight": hero_knight_portrait,
		"hero_rogue": hero_rogue_portrait,
		"hero_mage": hero_mage_portrait,
	}
	for hero_id in portrait_slots.keys():
		var portrait := portrait_slots[hero_id] as Control
		if portrait == null:
			continue
		HERO_PREVIEW_SPAWNER.show_preview(portrait, str(hero_id), str(hero_id) == selected_hero_id)

func _refresh_equipment_summary() -> void:
	_equipment_panel.refresh(_selected_weapon_id)

func _select_pet(pet_id: String, implemented: bool) -> void:
	if not implemented:
		_show_placeholder("Pet Locked", "This pet is locked. Pet progression will unlock more companions later.")
		return

	_selected_pet_id = pet_id
	game_manager.set_selected_loadout(_selected_hero_id, _selected_weapon_id, _selected_pet_id)

func _focus_pet(pet_id: String) -> void:
	_selected_pet_id = pet_id
	if _home_state != null:
		_home_state.set_selected_pet(pet_id)
	else:
		_refresh_pet_summary()

func _refresh_pet_summary() -> void:
	_pet_select_panel.refresh(_selected_pet_id)

func _start_game() -> void:
	if scene_router != null:
		_select_pet(_selected_pet_id, game_manager.is_pet_unlocked(_selected_pet_id))
		if game_manager.selected_pet_id != _selected_pet_id:
			return
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
	_refresh_top_bar(_currency)
	_refresh_hub_focus(_currency)

func _refresh_top_bar(currency: int = 0) -> void:
	var unlocked_level := 1
	if game_manager != null:
		unlocked_level = game_manager.highest_unlocked_level

	hub_profile_label.text = "Alex Mercer"
	hub_level_label.text = "Lv.%d" % unlocked_level
	hub_profile_progress.value = clampf(float(unlocked_level % 10) * 10.0, 10.0, 100.0)
	hub_energy_label.text = "EN 48/60"
	hub_currency_label.text = "G %s" % _format_short_number(currency)
	hub_gems_label.text = "Gem 12"

func _refresh_hub_focus(currency: int = 0) -> void:
	if game_manager == null:
		return

	var hero_id := _selected_hero_id
	var weapon_id := _selected_weapon_id
	var pet_id := _selected_pet_id
	if _home_state != null:
		hero_id = _home_state.selected_hero_id
		weapon_id = _home_state.selected_weapon_id
		pet_id = _home_state.selected_pet_id

	var hero_definition := game_manager.get_hero_definition(hero_id)
	var weapon_definition := game_manager.get_weapon_definition(weapon_id)
	var pet_definition := game_manager.get_pet_definition(pet_id)
	var hero_name := game_manager.get_display_name(hero_definition, "Hero")
	var pet_name := game_manager.get_display_name(pet_definition, "Pet")
	var hp: int = 10 + int(hero_definition.get("max_hp_bonus", 0))
	var attack: int = int(weapon_definition.get("damage", 1)) + int(hero_definition.get("projectile_damage_bonus", 0))
	var defense: int = 0
	if _home_state != null:
		var armor_item: Dictionary = _home_state.get_equipped_item("armor")
		var armor_stats: Dictionary = {}
		if not armor_item.is_empty():
			var armor_stats_value: Variant = armor_item.get("stats", {})
			if typeof(armor_stats_value) == TYPE_DICTIONARY:
				armor_stats = armor_stats_value
		defense = _extract_first_stat_number(str(armor_stats.get("def", "0")))
	var power: int = max(hp + attack + defense, 1)

	hub_character_label.text = "SURVIVOR READY"
	hub_hero_name_label.text = "%s  Lv.%d  PWR %s" % [hero_name, game_manager.highest_unlocked_level, _format_short_number(power)]
	hub_power_label.text = "HP %s  ATK %s  DEF %s  PET %s" % [
		_format_short_number(hp),
		_format_short_number(attack),
		_format_short_number(defense),
		pet_name,
	]
	hub_power_value_label.text = _format_short_number(power)

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

func _refresh_inventory_summary(_inventory: Dictionary = {}) -> void:
	_inventory_panel.refresh(_inventory)

func _on_play_pressed() -> void:
	_show_screen(SCREEN_MODE_SELECT)

func _on_inventory_pressed() -> void:
	_show_screen(SCREEN_INVENTORY)

func _on_hub_hero_pressed() -> void:
	_show_screen(SCREEN_HERO_SELECT)

func _on_hub_pet_pressed() -> void:
	_show_screen(SCREEN_PET_SELECT)

func _on_hub_equipment_pressed() -> void:
	_show_screen(SCREEN_EQUIPMENT_SELECT)

func _on_map_pressed() -> void:
	_show_placeholder("Map", "Map selection is planned for a later content step.")

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
	_focus_hero("hero_knight")

func _on_rogue_pressed() -> void:
	_focus_hero("hero_rogue")

func _on_mage_pressed() -> void:
	_focus_hero("hero_mage")

func _on_hero_continue_pressed() -> void:
	_select_hero(_selected_hero_id, game_manager.is_hero_unlocked(_selected_hero_id))
	if game_manager.selected_hero_id == _selected_hero_id:
		_show_screen(SCREEN_EQUIPMENT_SELECT)

func _on_equipment_continue_pressed() -> void:
	_show_screen(SCREEN_PET_SELECT)

func _on_drone_pressed() -> void:
	_focus_pet("pet_drone")

func _on_sprite_pressed() -> void:
	_focus_pet("pet_sprite")

func _on_wisp_pressed() -> void:
	_focus_pet("pet_wisp")

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
	_selected_hero_id = _hero_id
	_refresh_hero_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _on_home_state_weapon_changed(_weapon_id: String) -> void:
	_refresh_equipment_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _on_home_state_pet_changed(_pet_id: String) -> void:
	_selected_pet_id = _pet_id
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
	var responsive_mode: String = _resolve_responsive_mode(viewport_size)
	var is_mobile: bool = responsive_mode == LAYOUT_MOBILE
	var is_tablet: bool = responsive_mode == LAYOUT_TABLET
	var is_short_landscape := is_mobile and viewport_size.y <= MOBILE_MAX_HEIGHT
	var margin := 6 if is_short_landscape else _get_layout_margin(responsive_mode)
	var root_separation := 3 if is_short_landscape else (4 if is_mobile else (10 if is_tablet else 16))
	var content_separation := 4 if is_short_landscape else (5 if is_mobile else (8 if is_tablet else 12))
	var grid_separation := 5 if is_short_landscape else (6 if is_mobile else (10 if is_tablet else 16))
	var inner_margin := 4 if is_short_landscape else (8 if is_mobile else (12 if is_tablet else 16))
	var mobile_or_tablet := is_mobile or is_tablet
	var hero_pet_columns := 1 if is_mobile else (2 if is_tablet else 3)
	var equipment_columns := 3 if responsive_mode == LAYOUT_DESKTOP and viewport_size.x >= 1400.0 else 1
	var equipment_slot_columns := 1
	var inventory_content_columns := 2
	var inventory_item_columns := 6 if is_mobile else (7 if is_tablet else 8)

	for screen_name in _scroll_containers.keys():
		_set_scroll_container_enabled(str(screen_name), mobile_or_tablet and not [SCREEN_HERO_SELECT, SCREEN_PET_SELECT].has(str(screen_name)))

	for layout_path in [
		"ScreenRoot/MainMenuScreen/Layout",
		"ScreenRoot/ModeSelectScreen/Layout",
		"ScreenRoot/HeroSelectScreen/Layout",
		"ScreenRoot/EquipmentSelectScreen/Layout",
		"ScreenRoot/PetSelectScreen/Layout",
	]:
		_set_margin(layout_path, margin)
	_set_inventory_layout_margin(margin, viewport_size.x, responsive_mode)

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
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu",
		"ScreenRoot/ModeSelectScreen/Layout/Root/Content",
		"ScreenRoot/ModeSelectScreen/Layout/Root/Content/ModeList",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid",
	]:
		_set_box_separation(content_path, content_separation)

	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/Header", 4 if is_short_landscape else (6 if is_mobile else 10))
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar", 4 if is_short_landscape else (6 if is_mobile else 8))
	_apply_hub_layout_order(responsive_mode)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock", true)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/EnergyLabel", true)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/CurrencyLabel", true)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/GemsLabel", true)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/TopSettingsButton", true)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/MenuSpacer", false)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/ExitButton", false)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/SettingsButton", false)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PowerCard", true)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard", true)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PackCard", true)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar", true)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar", true)
	_set_control_visible("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin/PreviewContent/PreviewNote", true)
	_set_control_size_flags("ScreenRoot/MainMenuScreen/Layout/Root/Header", Control.SIZE_EXPAND_FILL, Control.SIZE_FILL)
	_set_control_size_flags("ScreenRoot/MainMenuScreen/Layout/Root/MainContent", Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	_set_control_size_flags("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar", Control.SIZE_EXPAND_FILL, Control.SIZE_FILL)
	_set_control_size_flags("ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar", Control.SIZE_EXPAND_FILL, Control.SIZE_FILL)
	_set_control_size_flags("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu", Control.SIZE_EXPAND_FILL, Control.SIZE_FILL)
	_set_control_size_flags("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero", Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	_set_control_size_flags("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel", Control.SIZE_EXPAND_FILL, Control.SIZE_FILL)
	_set_grid_columns("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions", 6)
	_set_grid_separation("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions", 5 if is_short_landscape else (6 if is_mobile else 10), 5 if is_short_landscape else (6 if is_mobile else 10))
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar/Margin/NavButtons", 3 if is_short_landscape else (4 if is_mobile else 8))
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel", 4 if is_short_landscape else (5 if is_mobile else 10))
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox", 2 if is_short_landscape else (3 if is_mobile else 6))
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/FeaturePreview/PreviewMargin/PreviewContent", 2 if is_short_landscape else (3 if is_mobile else 5))
	_set_grid_columns("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox/SummaryGrid", 2)
	_set_grid_separation("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox/SummaryGrid", 4 if is_short_landscape else (5 if is_mobile else 8), 4 if is_short_landscape else (5 if is_mobile else 8))

	_set_grid_columns("ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards", 5)
	_set_grid_columns("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns", equipment_columns)
	_set_grid_columns("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn", equipment_slot_columns)
	_apply_equipment_layout_order()
	_set_grid_columns("ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards", 5)
	_set_grid_columns("ScreenRoot/InventoryScreen/Layout/Root/Content", inventory_content_columns)
	_apply_inventory_layout_order()
	_set_grid_separation("ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards", 6 if is_mobile else grid_separation, 4 if is_mobile else grid_separation)
	_set_grid_separation("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns", grid_separation, grid_separation)
	_set_grid_separation("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn", grid_separation, grid_separation)
	_set_grid_separation("ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards", 6 if is_mobile else grid_separation, 4 if is_mobile else grid_separation)
	_set_grid_separation("ScreenRoot/InventoryScreen/Layout/Root/Content", grid_separation, grid_separation)

	for grid_path in [
		"ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid",
	]:
		_set_grid_columns(grid_path, inventory_item_columns)
		_set_grid_separation(grid_path, 6 if is_mobile else 8, 6 if is_mobile else 8)

	for inner_margin_path in [
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard/Margin",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/SelectionSummary/SummaryMargin",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/DroneCard/Margin",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/SpriteCard/Margin",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/WispCard/Margin",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/SelectionSummary/SummaryMargin",
		"ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PowerCard/Margin",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PackCard/PackMargin",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/StatsPanel/StatsMargin",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/FeaturePreview/PreviewMargin",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/PetPanel/PetMargin",
		"ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin",
		"ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/WeaponSlot/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/ArmorSlot/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/PetSlot/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/AccessorySlot/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard/Margin",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin",
	]:
		_set_margin(inner_margin_path, inner_margin)

	if is_short_landscape:
		_apply_short_landscape_hub_budget()

	var portrait_height := 96.0 if is_mobile else (132.0 if is_tablet else 180.0)
	for portrait_path in [
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/Portrait",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin/VBox/Portrait",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard/Margin/VBox/Portrait",
	]:
		_set_minimum_size(portrait_path, Vector2(0.0, portrait_height))

	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/Header", Vector2(0.0, 40.0 if is_short_landscape else (42.0 if is_mobile else 52.0)))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock", Vector2(164.0 if is_short_landscape else (178.0 if is_mobile else 230.0), 0.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/EnergyLabel", Vector2(68.0 if is_short_landscape else 78.0, 30.0 if is_short_landscape else 36.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/CurrencyLabel", Vector2(78.0 if is_short_landscape else 90.0, 30.0 if is_short_landscape else 36.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/GemsLabel", Vector2(62.0 if is_short_landscape else 76.0, 30.0 if is_short_landscape else 36.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/TopSettingsButton", Vector2(52.0 if is_short_landscape else 62.0, 30.0 if is_short_landscape else 36.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu", Vector2(118.0 if is_short_landscape else (138.0 if is_mobile else 170.0), 0.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel", Vector2(152.0 if is_short_landscape else (170.0 if is_mobile else 210.0), 0.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage", Vector2(0.0, 230.0 if is_short_landscape else (260.0 if is_mobile else 300.0)))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar", Vector2(0.0, 58.0 if is_short_landscape else 64.0))
	var hub_action_height := 44.0 if is_short_landscape else (48.0 if is_mobile else 56.0)
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/HeroButton", Vector2(0.0, hub_action_height))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/EquipmentButton", Vector2(0.0, hub_action_height))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/InventoryButton", Vector2(0.0, hub_action_height))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/PetButton", Vector2(0.0, hub_action_height))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/MapButton", Vector2(0.0, hub_action_height))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/PlayButton", Vector2(0.0, hub_action_height))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar", Vector2(0.0, 34.0 if is_short_landscape else 38.0))
	_set_minimum_size("ScreenRoot/InventoryScreen/Layout/Root/Header", Vector2(0.0, 48.0 if is_mobile else 54.0))
	_set_minimum_size("ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel", Vector2(280.0 if is_mobile else 320.0, 0.0))
	_set_minimum_size("ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel", Vector2(0.0, 0.0))
	_set_minimum_size("ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/IconPreview", Vector2(0.0, 76.0 if is_mobile else 92.0))
	for inventory_button in inventory_item_buttons:
		if inventory_button != null:
			inventory_button.custom_minimum_size = Vector2(58.0 if is_mobile else 64.0, 58.0 if is_mobile else 64.0)
	_set_minimum_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/WeaponSlot", Vector2(0.0, 0.0))
	_set_minimum_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/ArmorSlot", Vector2(0.0, 0.0))
	_set_minimum_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/PetSlot", Vector2(0.0, 0.0))
	_set_minimum_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/AccessorySlot", Vector2(0.0, 0.0))
	_set_minimum_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/CharacterPanel", Vector2(0.0, 150.0 if is_mobile else (280.0 if responsive_mode == LAYOUT_DESKTOP and viewport_size.x >= 1400.0 else 190.0)))
	_update_touch_targets(screen_root, responsive_mode)

func _install_scroll_containers() -> void:
	for screen_name in [
		SCREEN_MODE_SELECT,
		SCREEN_HERO_SELECT,
		SCREEN_PET_SELECT,
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

func _resolve_responsive_mode(viewport_size: Vector2) -> String:
	if viewport_size.x <= MOBILE_MAX_WIDTH or viewport_size.y <= MOBILE_MAX_HEIGHT:
		return LAYOUT_MOBILE
	if viewport_size.x <= TABLET_MAX_WIDTH:
		return LAYOUT_TABLET
	return LAYOUT_DESKTOP

func _get_layout_margin(responsive_mode: String) -> int:
	if responsive_mode == LAYOUT_MOBILE:
		return MOBILE_MARGIN
	if responsive_mode == LAYOUT_TABLET:
		return TABLET_MARGIN
	return DESKTOP_MARGIN

func _apply_short_landscape_hub_budget() -> void:
	_set_margin_edges("ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin", 5, 2, 5, 2)
	_set_margin_edges("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PowerCard/Margin", 5, 3, 5, 3)
	_set_margin_edges("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin", 5, 3, 5, 3)
	_set_margin_edges("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PackCard/PackMargin", 5, 3, 5, 3)
	_set_margin_edges("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin", 3, 3, 3, 3)
	_set_margin_edges("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/StatsPanel/StatsMargin", 4, 3, 4, 3)
	_set_margin_edges("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin", 5, 3, 5, 3)
	_set_margin_edges("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/FeaturePreview/PreviewMargin", 5, 3, 5, 3)
	_set_margin_edges("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/PetPanel/PetMargin", 5, 3, 5, 3)
	_set_margin_edges("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin", 4, 2, 4, 2)
	_set_margin_edges("ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar/Margin", 4, 1, 4, 1)
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin/ProfileRow", 5)
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin/ProfileRow/ProfileText", 0)
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PowerCard/Margin/VBox", 1)
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin/PreviewContent", 1)
	_set_box_separation("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PackCard/PackMargin/PackContent", 1)
	_set_grid_separation("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/FeaturePreview/PreviewMargin/PreviewContent/EquipmentSlots", 3, 3)
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin/ProfileRow/Avatar", Vector2(28.0, 28.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin/ProfileRow/ProfileText/ProgressBar", Vector2(0.0, 3.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/PetPanel/PetMargin/PetRow/PetPortrait", Vector2(34.0, 34.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/FeaturePreview/PreviewMargin/PreviewContent/EquipmentSlots/SlotWeapon", Vector2(0.0, 34.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/FeaturePreview/PreviewMargin/PreviewContent/EquipmentSlots/SlotArmor", Vector2(0.0, 34.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/FeaturePreview/PreviewMargin/PreviewContent/EquipmentSlots/SlotBoots", Vector2(0.0, 34.0))
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/FeaturePreview/PreviewMargin/PreviewContent/EquipmentSlots/SlotPet", Vector2(0.0, 34.0))
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin/ProfileRow/ProfileText/ProfileLabel", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin/ProfileRow/ProfileText/LevelLabel", 11)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/EnergyLabel", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/CurrencyLabel", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/GemsLabel", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/TopSettingsButton", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PowerCard/Margin/VBox/TitleLabel", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PowerCard/Margin/VBox/PowerValue", 14)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin/PreviewContent/PreviewTitle", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin/PreviewContent/PreviewList", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin/PreviewContent/PreviewNote", 11)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PackCard/PackMargin/PackContent/TitleLabel", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PackCard/PackMargin/PackContent/PackText", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/HeroNameLabel", 13)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/StatsPanel/StatsMargin/StatsLabel", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox/TitleLabel", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/FeaturePreview/PreviewMargin/PreviewContent/PreviewTitle", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/HeroButton", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/EquipmentButton", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/InventoryButton", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/PetButton", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/MapButton", 12)
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/PlayButton", 12)
	_set_label_line_limit("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin/PreviewContent/PreviewList", 1)
	_set_label_line_limit("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin/PreviewContent/PreviewNote", 1)

func _apply_hub_layout_order(_responsive_mode: String) -> void:
	var main_content := _get_ui_node("ScreenRoot/MainMenuScreen/Layout/Root/MainContent") as HBoxContainer
	var left_menu := _get_ui_node("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu") as Control
	var center_hero := _get_ui_node("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero") as Control
	var right_panel := _get_ui_node("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel") as Control
	if main_content == null or left_menu == null or center_hero == null or right_panel == null:
		return
	left_menu.size_flags_stretch_ratio = 0.13
	center_hero.size_flags_stretch_ratio = 0.7
	right_panel.size_flags_stretch_ratio = 0.17
	main_content.move_child(left_menu, 0)
	main_content.move_child(center_hero, 1)
	main_content.move_child(right_panel, 2)

func _apply_equipment_layout_order() -> void:
	var columns := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns") as GridContainer
	var left_column := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn") as GridContainer
	var character_panel := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/CharacterPanel") as Control
	var right_column := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn") as VBoxContainer
	if columns == null or left_column == null or character_panel == null or right_column == null:
		return

	var viewport_size := get_viewport_rect().size
	var use_split_layout := _resolve_responsive_mode(viewport_size) == LAYOUT_DESKTOP and viewport_size.x >= 1400.0
	if not use_split_layout:
		columns.move_child(character_panel, 0)
		columns.move_child(left_column, 1)
		columns.move_child(right_column, 2)
	else:
		columns.move_child(left_column, 0)
		columns.move_child(character_panel, 1)
		columns.move_child(right_column, 2)

	var weapon_slot := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/WeaponSlot") as Control
	var armor_slot := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/ArmorSlot") as Control
	var pet_slot := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/PetSlot") as Control
	var accessory_slot := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/AccessorySlot") as Control
	var loadout_card := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard") as Control
	var inventory_button := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/InventoryButton") as Control
	var unequip_button := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/UnequipButton") as Control
	if weapon_slot != null:
		left_column.move_child(weapon_slot, 0)
	if armor_slot != null:
		left_column.move_child(armor_slot, 1)
	if pet_slot != null:
		right_column.move_child(pet_slot, 0)
	if accessory_slot != null:
		right_column.move_child(accessory_slot, 1)
	if loadout_card != null:
		right_column.move_child(loadout_card, 2)
	if inventory_button != null:
		right_column.move_child(inventory_button, 3)
	if unequip_button != null:
		right_column.move_child(unequip_button, 4)

func _apply_inventory_layout_order() -> void:
	var content := _get_ui_node("ScreenRoot/InventoryScreen/Layout/Root/Content") as BoxContainer
	var details_panel := _get_ui_node("ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel") as Control
	var grid_panel := _get_ui_node("ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel") as Control
	if content == null or details_panel == null or grid_panel == null:
		return
	details_panel.size_flags_stretch_ratio = 0.32
	grid_panel.size_flags_stretch_ratio = 0.68
	content.move_child(details_panel, 0)
	content.move_child(grid_panel, 1)

func _set_control_visible(path: String, is_visible: bool) -> void:
	var control := _get_ui_node(path) as Control
	if control == null:
		return
	control.visible = is_visible

func _set_control_size_flags(path: String, horizontal: int, vertical: int) -> void:
	var control := _get_ui_node(path) as Control
	if control == null:
		return
	control.size_flags_horizontal = horizontal
	control.size_flags_vertical = vertical

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

func _set_margin_edges(path: String, left: int, top: int, right: int, bottom: int) -> void:
	var margin_container := _get_ui_node(path) as MarginContainer
	if margin_container == null:
		return
	margin_container.add_theme_constant_override("margin_left", left)
	margin_container.add_theme_constant_override("margin_top", top)
	margin_container.add_theme_constant_override("margin_right", right)
	margin_container.add_theme_constant_override("margin_bottom", bottom)

func _set_inventory_layout_margin(base_margin: int, viewport_width: float, responsive_mode: String) -> void:
	if responsive_mode != LAYOUT_DESKTOP:
		_set_margin_edges("ScreenRoot/InventoryScreen/Layout", base_margin, base_margin, base_margin, base_margin)
		return
	var target_content_width: float = min(INVENTORY_MAX_CONTENT_WIDTH, viewport_width * INVENTORY_WIDE_SCREEN_RATIO)
	var side_margin: int = max(base_margin, int((viewport_width - target_content_width) * 0.5))
	_set_margin_edges("ScreenRoot/InventoryScreen/Layout", side_margin, base_margin, side_margin, base_margin)

func _set_minimum_size(path: String, minimum_size: Vector2) -> void:
	var control := _get_ui_node(path) as Control
	if control == null:
		return
	control.custom_minimum_size = minimum_size

func _set_control_font_size(path: String, font_size: int) -> void:
	var control := _get_ui_node(path) as Control
	if control == null:
		return
	control.add_theme_font_size_override("font_size", font_size)

func _set_label_line_limit(path: String, max_lines: int) -> void:
	var label := _get_ui_node(path) as Label
	if label == null:
		return
	label.max_lines_visible = max_lines
	label.clip_text = max_lines > 0

func _get_original_minimum_size(control: Control) -> Vector2:
	var id := control.get_instance_id()
	if not _original_minimum_sizes.has(id):
		_original_minimum_sizes[id] = control.custom_minimum_size
	return _original_minimum_sizes[id]

func _update_touch_targets(root: Node, responsive_mode: String) -> void:
	var uses_touch_targets := responsive_mode != LAYOUT_DESKTOP
	var touch_height := 54.0 if responsive_mode == LAYOUT_MOBILE else 50.0
	var viewport_size := get_viewport_rect().size
	var is_short_landscape := responsive_mode == LAYOUT_MOBILE and viewport_size.y <= MOBILE_MAX_HEIGHT
	for child in root.get_children():
		if child is Button:
			var button := child as Button
			var original_size := _get_original_minimum_size(button)
			var local_touch_height := touch_height
			var button_path := str(button.get_path())
			if button_path.find("MainMenuScreen") != -1:
				if button_path.find("BottomNavBar") != -1:
					local_touch_height = 34.0
				elif button_path.find("Header") != -1:
					local_touch_height = 38.0
				elif button_path.find("PrimaryActionBar") != -1:
					local_touch_height = 44.0 if is_short_landscape else 50.0
			var target_height: float = max(original_size.y, local_touch_height)
			button.custom_minimum_size = Vector2(0.0 if uses_touch_targets else original_size.x, target_height if uses_touch_targets else original_size.y)
			if uses_touch_targets:
				button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		elif child is CheckButton:
			var check_button := child as CheckButton
			var original_size := _get_original_minimum_size(check_button)
			var target_height: float = max(original_size.y, touch_height)
			check_button.custom_minimum_size = Vector2(0.0 if uses_touch_targets else original_size.x, target_height if uses_touch_targets else original_size.y)
			if uses_touch_targets:
				check_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		_update_touch_targets(child, responsive_mode)
