extends Node
class_name HomeScreenController

const SCREEN_MAIN_MENU = "MainMenuScreen"
const SCREEN_MODE_SELECT = "ModeSelectScreen"
const SCREEN_HERO_SELECT = "HeroSelectScreen"
const SCREEN_EQUIPMENT_SELECT = "EquipmentSelectScreen"
const SCREEN_PET_SELECT = "PetSelectScreen"
const SCREEN_GUARD_SELECT = "GuardSelectScreen"
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
const GUARD_SELECT_PANEL_SCRIPT := preload("res://scripts/ui/home/GuardSelectPanel.gd")
const INVENTORY_PANEL_SCRIPT := preload("res://scripts/ui/home/InventoryPanel.gd")
const HOME_UI_MANAGER_SCRIPT := preload("res://scripts/ui/home/HomeUIManager.gd")
const HOME_STATE_SCRIPT := preload("res://scripts/ui/home/HomeState.gd")
const HOME_UI_STYLE := preload("res://scripts/ui/home/HomeUIStyle.gd")
const HERO_PREVIEW_SPAWNER := preload("res://scripts/ui/home/HeroPreviewSpawner.gd")
const SHOP_SCENE := preload("res://scenes/ui/shop.tscn")
const HERO_PORTRAIT_TEXTURES := {
	"hero_knight": preload("res://assets/KayKit_Adventurers_2.0_FREE/KayKit_Adventurers_2.0_FREE/Samples/knight.png"),
	"hero_rogue": preload("res://assets/KayKit_Adventurers_2.0_FREE/KayKit_Adventurers_2.0_FREE/Samples/rogue.png"),
	"hero_mage": preload("res://assets/KayKit_Adventurers_2.0_FREE/KayKit_Adventurers_2.0_FREE/Samples/mage.png"),
}

@onready var screen_root: Control = get_node("../ScreenRoot")
@onready var background_art: TextureRect = get_node("../BackgroundArt")
@onready var main_menu_screen: Control = get_node("../ScreenRoot/MainMenuScreen")
@onready var mode_select_screen: Control = get_node("../ScreenRoot/ModeSelectScreen")
@onready var hero_select_screen: Control = get_node("../ScreenRoot/HeroSelectScreen")
@onready var equipment_select_screen: Control = get_node("../ScreenRoot/EquipmentSelectScreen")
@onready var pet_select_screen: Control = get_node("../ScreenRoot/PetSelectScreen")
@onready var inventory_screen: Control = get_node("../ScreenRoot/InventoryScreen")
@onready var settings_screen: SettingsScreen = get_node("../SettingsScreen")
@onready var placeholder_popup: PlaceholderPopup = get_node("../PlaceholderPopup")
@onready var scene_router: SceneRouter = get_node("/root/SceneRouter") as SceneRouter
@onready var game_manager: GameManager = get_node("/root/GameManager") as GameManager

@onready var play_button: Button = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/PlayButton")
@onready var equipment_button: Button = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/EquipmentButton")
@onready var inventory_button: Button = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/InventoryButton")
@onready var settings_button: Button = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/TopSettingsButton")
@onready var exit_button: Button = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/ExitButton")
@onready var quests_button: Button = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar/Margin/NavButtons/QuestsButton")
@onready var shop_button: Button = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar/Margin/NavButtons/ShopButton")
@onready var hub_profile_label: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin/ProfileRow/ProfileText/ProfileLabel")
@onready var hub_level_label: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin/ProfileRow/ProfileText/LevelLabel")
@onready var hub_profile_progress: ProgressBar = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock/ProfileMargin/ProfileRow/ProfileText/ProgressBar")
@onready var hub_energy_label: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/EnergyLabel")
@onready var hub_currency_label: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/CurrencyLabel")
@onready var hub_gems_label: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/GemsLabel")
@onready var hub_hero_stage: Control = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage")
@onready var hub_hero_image: TextureRect = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/HeroImage")
@onready var hub_character_label: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/CharacterPlaceholder")
@onready var hub_hero_name_label: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/HeroNameLabel")
@onready var hub_power_label: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/StatsPanel/StatsMargin/StatsLabel")
@onready var hub_power_value_label: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PowerCard/Margin/VBox/PowerValue")
@onready var hub_pet_portrait: Control = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/PetPanel/PetMargin/PetRow/PetPortrait")

@onready var survival_button: Button = get_node("../ScreenRoot/ModeSelectScreen/Layout/Root/Content/ModeList/SurvivalButton")
@onready var endless_button: Button = get_node("../ScreenRoot/ModeSelectScreen/Layout/Root/Content/ModeList/EndlessButton")
@onready var boss_rush_button: Button = get_node("../ScreenRoot/ModeSelectScreen/Layout/Root/Content/ModeList/BossRushButton")
@onready var mode_back_button: Button = get_node("../ScreenRoot/ModeSelectScreen/Layout/Root/Footer/BackButton")

@onready var hero_status_label: Label = get_node("../ScreenRoot/HeroSelectScreen/Layout/Root/Content/SelectionSummary/SummaryMargin/StatusLabel")
@onready var hero_continue_button: Button = get_node("../ScreenRoot/HeroSelectScreen/Layout/Root/Footer/ContinueButton")
@onready var hero_back_button: Button = get_node("../ScreenRoot/HeroSelectScreen/Layout/Root/Header/BackButton")
@onready var hero_knight_portrait: Control = get_node("../ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/Portrait")
@onready var hero_knight_button: Button = get_node("../ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/SelectButton")
@onready var hero_rogue_portrait: Control = get_node("../ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin/VBox/Portrait")
@onready var hero_rogue_button: Button = get_node("../ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin/VBox/SelectButton")
@onready var hero_mage_portrait: Control = get_node("../ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard/Margin/VBox/Portrait")
@onready var hero_mage_button: Button = get_node("../ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard/Margin/VBox/SelectButton")

@onready var equipment_summary_label: Label = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard/Margin/LoadoutSummary")
@onready var equipment_inventory_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/InventoryButton")
@onready var equipment_unequip_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/UnequipButton")
@onready var equipment_upgrade_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/UpgradeButton")
@onready var equipment_continue_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Footer/ContinueButton")
@onready var equipment_back_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Header/BackButton")
@onready var weapon_slot_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/WeaponSlot/Margin/VBox/SlotButton")
@onready var armor_slot_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/ArmorSlot/Margin/VBox/SlotButton")
@onready var helmet_slot_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/HelmetSlot/Margin/VBox/SlotButton")
@onready var boots_slot_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/BootsSlot/Margin/VBox/SlotButton")
@onready var pet_equipment_slot_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/PetSlot/Margin/VBox/SlotButton")
@onready var accessory_slot_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/AccessorySlot/Margin/VBox/SlotButton")
@onready var equipment_hero_stage: Control = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/CharacterPanel")
@onready var equipment_character_placeholder: TextureRect = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/CharacterPanel/Center/CharacterPlaceholder")
@onready var equipment_weapon_filter_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/CategoryBar/Margin/Buttons/WeaponFilterButton")
@onready var equipment_armor_filter_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/CategoryBar/Margin/Buttons/ArmorFilterButton")
@onready var equipment_accessory_filter_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/CategoryBar/Margin/Buttons/AccessoryFilterButton")
@onready var equipment_pet_filter_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/CategoryBar/Margin/Buttons/PetFilterButton")
@onready var equipment_all_filter_button: Button = get_node("../ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/CategoryBar/Margin/Buttons/AllFilterButton")

@onready var pet_status_label: Label = get_node("../ScreenRoot/PetSelectScreen/Layout/Root/Content/SelectionSummary/SummaryMargin/StatusLabel")
@onready var pet_start_button: Button = get_node("../ScreenRoot/PetSelectScreen/Layout/Root/Footer/StartGameButton")
@onready var pet_back_button: Button = get_node("../ScreenRoot/PetSelectScreen/Layout/Root/Header/BackButton")
@onready var pet_drone_button: Button = get_node("../ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/DroneCard/Margin/VBox/SelectButton")
@onready var pet_sprite_button: Button = get_node("../ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/SpriteCard/Margin/VBox/SelectButton")
@onready var pet_wisp_button: Button = get_node("../ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/WispCard/Margin/VBox/SelectButton")
@onready var pet_drone_portrait: Control = get_node("../ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/DroneCard/Margin/VBox/PortraitLabel")
@onready var pet_sprite_portrait: Control = get_node("../ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/SpriteCard/Margin/VBox/PortraitLabel")
@onready var pet_wisp_portrait: Control = get_node("../ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/WispCard/Margin/VBox/PortraitLabel")

@onready var inventory_back_button: Button = get_node("../ScreenRoot/InventoryScreen/Layout/Root/Header/BackButton")
@onready var hub_preview_list: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin/PreviewContent/PreviewList")
@onready var hub_preview_note: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin/PreviewContent/PreviewNote")
@onready var hub_weapon_preview: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox/SummaryGrid/WeaponPreview")
@onready var hub_armor_preview: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox/SummaryGrid/ArmorPreview")
@onready var hub_defense_preview: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox/SummaryGrid/DefensePreview")
@onready var hub_pet_preview: Label = get_node("../ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox/SummaryGrid/PetPreview")
@onready var inventory_slot_target_label: Label = get_node("../ScreenRoot/InventoryScreen/Layout/Root/Header/SlotTargetLabel")
@onready var inventory_icon_label: Label = get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/IconPreview")
@onready var inventory_name_label: Label = get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/NameLabel")
@onready var inventory_type_label: Label = get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/TypeLabel")
@onready var inventory_stats_label: Label = get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/StatsLabel")
@onready var inventory_description_label: Label = get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/DescriptionLabel")
@onready var inventory_equip_button: Button = get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/ActionRow/EquipButton")
@onready var inventory_upgrade_button: Button = get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/ActionRow/UpgradeButton")
@onready var inventory_drop_button: Button = get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/ActionRow/DropButton")
@onready var inventory_item_buttons: Array[Button] = [
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotA"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotB"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotC"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotD"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotE"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotF"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotG"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotH"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotI"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotJ"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotK"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotL"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotM"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotN"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotO"),
	get_node("../ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotP"),
]

var _screen_lookup: Dictionary = {}
var _return_screen_after_settings: String = SCREEN_MAIN_MENU
var _selected_mode_id: String = "mode_survival"
var _selected_hero_id: String = "hero_knight"
var _selected_weapon_id: String = "weapon_basic"
var _selected_pet_id: String = "pet_drone"
var _selected_guard_id: String = "guard_shooter"
var _home_ui_manager
var _home_state
var _hub_summary_panel
var _hero_select_panel
var _equipment_panel
var _pet_select_panel
var _guard_select_panel
var _inventory_panel
var _shop_ui: Node
var _original_minimum_sizes: Dictionary = {}
var _scroll_containers: Dictionary = {}
var guard_select_screen: Control
var guard_status_label: Label
var guard_continue_button: Button
var guard_back_button: Button
var guard_preview_stage: Control
var guard_cards_grid: GridContainer
var guard_slot_button: Button
var guard_nav_button: Button
var hub_guard_preview: Label

func _ready() -> void:
	_install_guard_screen()
	_install_guard_hub_widgets()
	_install_guard_equipment_slot()

	_screen_lookup = {
		"MainMenuScreen": main_menu_screen,
		"ModeSelectScreen": mode_select_screen,
		"HeroSelectScreen": hero_select_screen,
		"EquipmentSelectScreen": equipment_select_screen,
		"PetSelectScreen": pet_select_screen,
		"GuardSelectScreen": guard_select_screen,
		"InventoryScreen": inventory_screen,
	}

	_home_ui_manager = HOME_UI_MANAGER_SCRIPT.new()
	_home_ui_manager.setup(_screen_lookup, SCREEN_MAIN_MENU)
	_home_ui_manager.panel_changed.connect(_on_home_panel_changed)
	_home_state = HOME_STATE_SCRIPT.new()
	_home_state.hero_changed.connect(_on_home_state_hero_changed)
	_home_state.weapon_changed.connect(_on_home_state_weapon_changed)
	_home_state.pet_changed.connect(_on_home_state_pet_changed)
	_home_state.guard_changed.connect(_on_home_state_guard_changed)
	_home_state.equipment_slot_changed.connect(_on_home_state_equipment_slot_changed)
	_home_state.equipment_summary_changed.connect(_on_home_state_equipment_summary_changed)
	_home_state.inventory_summary_changed.connect(_on_home_state_inventory_summary_changed)

	_hub_summary_panel = HUB_SUMMARY_PANEL_SCRIPT.new()
	_hero_select_panel = HERO_SELECT_PANEL_SCRIPT.new()
	_equipment_panel = EQUIPMENT_PANEL_SCRIPT.new()
	_pet_select_panel = PET_SELECT_PANEL_SCRIPT.new()
	_guard_select_panel = GUARD_SELECT_PANEL_SCRIPT.new()
	_inventory_panel = INVENTORY_PANEL_SCRIPT.new()

	_hub_summary_panel.setup(hub_preview_list, hub_preview_note, game_manager, _home_state, hub_weapon_preview, hub_armor_preview, hub_pet_preview, hub_defense_preview, hub_guard_preview)
	_hero_select_panel.setup(hero_status_label, hero_continue_button, hero_knight_button, hero_rogue_button, hero_mage_button, game_manager, _home_state)
	_equipment_panel.setup(
		equipment_summary_label,
		{
			"weapon": weapon_slot_button,
			"armor": armor_slot_button,
			"helmet": helmet_slot_button,
			"boots": boots_slot_button,
			"accessory": accessory_slot_button,
			"pet_gear": pet_equipment_slot_button,
			"guard": guard_slot_button,
		},
		equipment_inventory_button,
		equipment_unequip_button,
		equipment_upgrade_button,
		game_manager,
		_home_state,
		{
			"weapon": equipment_weapon_filter_button,
			"armor": equipment_armor_filter_button,
			"accessory": equipment_accessory_filter_button,
			"pet": equipment_pet_filter_button,
			"all": equipment_all_filter_button,
		}
	)
	_pet_select_panel.setup(pet_status_label, pet_start_button, pet_drone_button, pet_sprite_button, pet_wisp_button, game_manager, _home_state)
	_guard_select_panel.setup(guard_status_label, guard_continue_button, guard_cards_grid, game_manager, _home_state)
	_inventory_panel.setup(inventory_description_label, inventory_item_buttons, game_manager, _home_state, inventory_name_label, inventory_type_label, inventory_stats_label, inventory_equip_button, inventory_drop_button, inventory_slot_target_label, inventory_upgrade_button, inventory_icon_label)
	_equipment_panel.slot_selected.connect(_on_equipment_slot_requested)
	_equipment_panel.change_requested.connect(_on_equipment_change_requested)
	_equipment_panel.unequip_requested.connect(_on_equipment_unequip_requested)
	_equipment_panel.upgrade_requested.connect(_on_equipment_upgrade_requested)
	_guard_select_panel.guard_focused.connect(_on_guard_focused)
	_guard_select_panel.guard_confirmed.connect(_on_guard_confirmed)
	_inventory_panel.equip_requested.connect(_on_inventory_item_selected)

	play_button.pressed.connect(_start_game)
	equipment_button.pressed.connect(_on_hub_equipment_pressed)
	inventory_button.pressed.connect(_on_inventory_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quests_button.pressed.connect(_on_quests_pressed)
	shop_button.pressed.connect(_on_shop_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	var hero_nav_button := get_parent().get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/HeroButton") as Button
	if hero_nav_button != null:
		hero_nav_button.pressed.connect(_on_hub_hero_pressed)
	var pet_nav_button := get_parent().get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/PetButton") as Button
	if pet_nav_button != null:
		pet_nav_button.pressed.connect(_on_hub_pet_pressed)
	if guard_nav_button != null:
		guard_nav_button.pressed.connect(_on_hub_guard_pressed)
	var map_nav_button := get_parent().get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/MapButton") as Button
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

	equipment_continue_button.pressed.connect(_on_equipment_continue_pressed)
	equipment_back_button.pressed.connect(_go_back)

	pet_drone_button.pressed.connect(_on_drone_pressed)
	pet_sprite_button.pressed.connect(_on_sprite_pressed)
	pet_wisp_button.pressed.connect(_on_wisp_pressed)
	pet_start_button.pressed.connect(_on_pet_confirm_pressed)
	pet_back_button.pressed.connect(_go_back)
	if guard_back_button != null:
		guard_back_button.pressed.connect(_go_back)

	inventory_back_button.pressed.connect(_go_back)
	settings_screen.back_requested.connect(_close_settings)
	placeholder_popup.closed.connect(_on_placeholder_closed)
	game_manager.currency_changed.connect(_refresh_hub_summary)
	game_manager.energy_changed.connect(_on_energy_changed)
	game_manager.wallet_changed.connect(_on_wallet_changed)
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
	_setup_shop_ui()
	call_deferred("_show_daily_reward_if_available")

func _install_guard_screen() -> void:
	if screen_root == null or screen_root.get_node_or_null(SCREEN_GUARD_SELECT) != null:
		guard_select_screen = screen_root.get_node_or_null(SCREEN_GUARD_SELECT) as Control
		return

	guard_select_screen = Control.new()
	guard_select_screen.name = SCREEN_GUARD_SELECT
	guard_select_screen.visible = false
	guard_select_screen.anchor_right = 1.0
	guard_select_screen.anchor_bottom = 1.0
	guard_select_screen.grow_horizontal = Control.GROW_DIRECTION_BOTH
	guard_select_screen.grow_vertical = Control.GROW_DIRECTION_BOTH
	screen_root.add_child(guard_select_screen)

	var layout := MarginContainer.new()
	layout.name = "Layout"
	layout.anchor_right = 1.0
	layout.anchor_bottom = 1.0
	layout.grow_horizontal = Control.GROW_DIRECTION_BOTH
	layout.grow_vertical = Control.GROW_DIRECTION_BOTH
	guard_select_screen.add_child(layout)

	var root := VBoxContainer.new()
	root.name = "Root"
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(root)

	var header := HBoxContainer.new()
	header.name = "Header"
	root.add_child(header)
	guard_back_button = Button.new()
	guard_back_button.name = "BackButton"
	guard_back_button.text = "Back"
	header.add_child(guard_back_button)
	var title_box := VBoxContainer.new()
	title_box.name = "TitleBox"
	title_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_box)
	var title := Label.new()
	title.name = "Title"
	title.text = "Guard"
	title_box.add_child(title)
	var subtitle := Label.new()
	subtitle.name = "Subtitle"
	subtitle.text = "Choose support for the next run"
	title_box.add_child(subtitle)

	var content := HBoxContainer.new()
	content.name = "Content"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(content)

	var preview_panel := PanelContainer.new()
	preview_panel.name = "PreviewPanel"
	preview_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(preview_panel)
	var preview_margin := MarginContainer.new()
	preview_margin.name = "Margin"
	preview_panel.add_child(preview_margin)
	guard_preview_stage = Control.new()
	guard_preview_stage.name = "GuardStage"
	guard_preview_stage.custom_minimum_size = Vector2(0.0, 260.0)
	guard_preview_stage.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	guard_preview_stage.size_flags_vertical = Control.SIZE_EXPAND_FILL
	preview_margin.add_child(guard_preview_stage)

	var cards_panel := PanelContainer.new()
	cards_panel.name = "CardsPanel"
	cards_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(cards_panel)
	var cards_margin := MarginContainer.new()
	cards_margin.name = "Margin"
	cards_panel.add_child(cards_margin)
	var cards_vbox := VBoxContainer.new()
	cards_vbox.name = "VBox"
	cards_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_margin.add_child(cards_vbox)
	guard_cards_grid = GridContainer.new()
	guard_cards_grid.name = "GuardCards"
	guard_cards_grid.columns = 5
	guard_cards_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	guard_cards_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cards_vbox.add_child(guard_cards_grid)
	var summary := PanelContainer.new()
	summary.name = "SelectionSummary"
	cards_vbox.add_child(summary)
	var summary_margin := MarginContainer.new()
	summary_margin.name = "SummaryMargin"
	summary.add_child(summary_margin)
	guard_status_label = Label.new()
	guard_status_label.name = "StatusLabel"
	guard_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_margin.add_child(guard_status_label)

	var footer := HBoxContainer.new()
	footer.name = "Footer"
	root.add_child(footer)
	var footer_spacer := Control.new()
	footer_spacer.name = "Spacer"
	footer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(footer_spacer)
	guard_continue_button = Button.new()
	guard_continue_button.name = "ContinueButton"
	guard_continue_button.text = "Confirm"
	guard_continue_button.custom_minimum_size = Vector2(160.0, 44.0)
	footer.add_child(guard_continue_button)

func _install_guard_hub_widgets() -> void:
	var actions := get_parent().get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions") as GridContainer
	if actions != null:
		guard_nav_button = actions.get_node_or_null("GuardButton") as Button
		if guard_nav_button == null:
			guard_nav_button = Button.new()
			guard_nav_button.name = "GuardButton"
			guard_nav_button.text = "R\nGuard"
			guard_nav_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			guard_nav_button.custom_minimum_size = Vector2(0.0, 46.0)
			var play_index := actions.get_children().find(play_button)
			actions.add_child(guard_nav_button)
			if play_index >= 0:
				actions.move_child(guard_nav_button, play_index)

	var summary_grid := get_parent().get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel/Margin/VBox/SummaryGrid") as GridContainer
	if summary_grid == null:
		return
	hub_guard_preview = summary_grid.get_node_or_null("GuardPreview") as Label
	if hub_guard_preview == null:
		hub_guard_preview = Label.new()
		hub_guard_preview.name = "GuardPreview"
		hub_guard_preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hub_guard_preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hub_guard_preview.text = "Guard"
		summary_grid.add_child(hub_guard_preview)

func _install_guard_equipment_slot() -> void:
	var left_column := get_parent().get_node_or_null("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn") as GridContainer
	if left_column == null:
		return
	var existing := left_column.get_node_or_null("GuardSlot") as PanelContainer
	if existing != null:
		guard_slot_button = existing.get_node_or_null("Margin/VBox/SlotButton") as Button
		return
	var slot := _create_equipment_slot("GuardSlot", "GUARD", "Run support companion")
	left_column.add_child(slot)
	guard_slot_button = slot.get_node_or_null("Margin/VBox/SlotButton") as Button

func _create_equipment_slot(node_name: String, title_text: String, description_text: String) -> PanelContainer:
	var slot := PanelContainer.new()
	slot.name = node_name
	var margin := MarginContainer.new()
	margin.name = "Margin"
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	slot.add_child(margin)
	var vbox := VBoxContainer.new()
	vbox.name = "VBox"
	margin.add_child(vbox)
	var title := Label.new()
	title.name = "TitleLabel"
	title.text = title_text
	vbox.add_child(title)
	var description := Label.new()
	description.name = "DescriptionLabel"
	description.text = description_text
	vbox.add_child(description)
	var button := Button.new()
	button.name = "SlotButton"
	button.text = "GRD\nShooter"
	button.custom_minimum_size = Vector2(0.0, 42.0)
	vbox.add_child(button)
	return slot

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
	HOME_UI_STYLE.apply_button_state(pet_back_button, "secondary")
	HOME_UI_STYLE.apply_button_state(guard_back_button, "secondary")
	HOME_UI_STYLE.apply_button_state(inventory_back_button, "secondary")
	HOME_UI_STYLE.apply_button_state(equipment_continue_button, "selected")
	HOME_UI_STYLE.apply_button_state(pet_start_button, "selected")
	HOME_UI_STYLE.apply_button_state(guard_continue_button, "selected")
	HOME_UI_STYLE.apply_button_state(guard_nav_button, "secondary")
	play_button.text = "Start"
	equipment_continue_button.text = "Done"
	pet_start_button.text = "Confirm"
	if guard_continue_button != null:
		guard_continue_button.text = "Confirm"

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
	elif screen_name == SCREEN_GUARD_SELECT:
		_refresh_guard_summary()
	_refresh_hero_preview_models()
	_refresh_pet_preview_models()
	_refresh_guard_preview_models()
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

func _setup_shop_ui() -> void:
	if _shop_ui != null:
		return
	_shop_ui = SHOP_SCENE.instantiate()
	if _shop_ui == null:
		return
	add_child(_shop_ui)
	if _shop_ui.has_method("setup"):
		_shop_ui.call("setup", game_manager)

func _show_daily_reward_if_available() -> void:
	if game_manager != null and game_manager.claim_daily_reward():
		_show_placeholder("Daily Reward", "Daily reward claimed. Check quests for today's goals.")

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

	if main_menu_screen != null and main_menu_screen.visible:
		_refresh_hub_hero_preview(selected_hero_id)
		_clear_hero_select_previews()
		return

	if hero_select_screen != null and hero_select_screen.visible:
		HERO_PREVIEW_SPAWNER.clear_preview(hub_hero_stage)
		HERO_PREVIEW_SPAWNER.clear_preview(equipment_hero_stage)
		_refresh_hero_select_previews(selected_hero_id)
		return

	if equipment_select_screen != null and equipment_select_screen.visible:
		HERO_PREVIEW_SPAWNER.clear_preview(hub_hero_stage)
		_clear_hero_select_previews()
		_refresh_equipment_hero_preview(selected_hero_id)
		return

	HERO_PREVIEW_SPAWNER.clear_preview(hub_hero_stage)
	HERO_PREVIEW_SPAWNER.clear_preview(equipment_hero_stage)
	_clear_hero_select_previews()

func _refresh_hub_hero_preview(selected_hero_id: String) -> void:
	HERO_PREVIEW_SPAWNER.clear_preview(equipment_hero_stage)
	if hub_hero_image != null:
		hub_hero_image.visible = false
	HERO_PREVIEW_SPAWNER.show_hero_preview(hub_hero_stage, selected_hero_id, _get_hero_definition_for_model(selected_hero_id), true, _get_weapon_definition_for_model(_get_selected_weapon_id_for_model()))

func _refresh_equipment_hero_preview(selected_hero_id: String) -> void:
	if equipment_character_placeholder != null:
		equipment_character_placeholder.visible = false
	HERO_PREVIEW_SPAWNER.show_hero_preview(equipment_hero_stage, selected_hero_id, _get_hero_definition_for_model(selected_hero_id), false, _get_weapon_definition_for_model(_get_selected_weapon_id_for_model()))

func _refresh_hero_select_previews(selected_hero_id: String) -> void:
	var portrait_slots := {
		"hero_knight": hero_knight_portrait,
		"hero_rogue": hero_rogue_portrait,
		"hero_mage": hero_mage_portrait,
	}
	for hero_id in portrait_slots.keys():
		var portrait := portrait_slots[hero_id] as Control
		if portrait == null:
			continue
		if str(hero_id) == selected_hero_id:
			HERO_PREVIEW_SPAWNER.show_hero_preview(portrait, str(hero_id), _get_hero_definition_for_model(str(hero_id)), true, _get_weapon_definition_for_model(_get_selected_weapon_id_for_model()))
		else:
			HERO_PREVIEW_SPAWNER.clear_preview(portrait)
			_set_hero_portrait_texture(portrait, str(hero_id))

func _clear_hero_select_previews() -> void:
	for portrait in [hero_knight_portrait, hero_rogue_portrait, hero_mage_portrait]:
		HERO_PREVIEW_SPAWNER.clear_preview(portrait)

func _set_hero_portrait_texture(portrait: Control, hero_id: String) -> void:
	if portrait is not TextureRect:
		return
	var texture_rect := portrait as TextureRect
	texture_rect.texture = HERO_PORTRAIT_TEXTURES.get(hero_id)

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
	_refresh_pet_preview_models()

func _refresh_pet_preview_models() -> void:
	var selected_pet_id := _selected_pet_id
	if _home_state != null:
		selected_pet_id = _home_state.selected_pet_id

	if pet_select_screen != null and pet_select_screen.visible:
		HERO_PREVIEW_SPAWNER.clear_preview(hub_pet_portrait)
		_refresh_pet_select_previews(selected_pet_id)
		return
	if main_menu_screen != null and main_menu_screen.visible:
		_clear_pet_select_previews()
		_refresh_hub_pet_preview(selected_pet_id)
		return
	HERO_PREVIEW_SPAWNER.clear_preview(hub_pet_portrait)
	_clear_pet_select_previews()

func _refresh_hub_pet_preview(selected_pet_id: String) -> void:
	if hub_pet_portrait == null:
		return
	HERO_PREVIEW_SPAWNER.show_pet_preview(hub_pet_portrait, selected_pet_id, _get_pet_definition_for_model(selected_pet_id))

func _refresh_pet_select_previews(selected_pet_id: String) -> void:
	var portrait_slots := {
		"pet_drone": pet_drone_portrait,
		"pet_sprite": pet_sprite_portrait,
		"pet_wisp": pet_wisp_portrait,
	}
	for pet_id in portrait_slots.keys():
		var portrait := portrait_slots[pet_id] as Control
		if portrait == null:
			continue
		if str(pet_id) == selected_pet_id:
			var preview := HERO_PREVIEW_SPAWNER.show_pet_preview(portrait, str(pet_id), _get_pet_definition_for_model(str(pet_id)))
			if preview != null and portrait is Label:
				(portrait as Label).text = ""
		else:
			HERO_PREVIEW_SPAWNER.clear_preview(portrait)

func _clear_pet_select_previews() -> void:
	for portrait in [pet_drone_portrait, pet_sprite_portrait, pet_wisp_portrait]:
		HERO_PREVIEW_SPAWNER.clear_preview(portrait)

func _select_guard(guard_id: String, available: bool) -> void:
	if not available:
		_show_placeholder("Guard Locked", "This guard is locked. Clear more runs to unlock the roster.")
		return

	_selected_guard_id = guard_id
	if not game_manager.set_selected_guard(_selected_guard_id):
		_show_placeholder("Guard Locked", "This guard cannot join the next run yet.")

func _focus_guard(guard_id: String) -> void:
	_selected_guard_id = guard_id
	if _home_state != null:
		_home_state.set_selected_guard(guard_id)
	else:
		_refresh_guard_summary()

func _refresh_guard_summary() -> void:
	if _guard_select_panel != null:
		_guard_select_panel.refresh(_selected_guard_id)
	_refresh_guard_preview_models()

func _refresh_guard_preview_models() -> void:
	var selected_guard_id := _selected_guard_id
	if _home_state != null:
		selected_guard_id = _home_state.selected_guard_id

	if guard_select_screen != null and guard_select_screen.visible:
		HERO_PREVIEW_SPAWNER.show_guard_preview(guard_preview_stage, selected_guard_id, _get_guard_definition_for_model(selected_guard_id))
		return
	if guard_preview_stage != null:
		HERO_PREVIEW_SPAWNER.clear_preview(guard_preview_stage)

func _get_hero_definition_for_model(hero_id: String) -> Dictionary:
	var definition := game_manager.get_hero_definition(hero_id)
	var raw_model_path := str(definition.get("model_scene_path", "")).strip_edges()
	definition["model_scene_path"] = game_manager.resolve_hero_model_path(hero_id)
	definition["model_fallback_used"] = raw_model_path != str(definition["model_scene_path"])
	return definition

func _get_pet_definition_for_model(pet_id: String) -> Dictionary:
	var definition := game_manager.get_pet_definition(pet_id)
	var raw_model_path := str(definition.get("model_scene_path", "")).strip_edges()
	definition["model_scene_path"] = game_manager.resolve_pet_model_path(pet_id)
	definition["model_fallback_used"] = raw_model_path != str(definition["model_scene_path"])
	return definition

func _get_guard_definition_for_model(guard_id: String) -> Dictionary:
	var definition := game_manager.get_guardian(guard_id)
	var model_path := str(definition.get("model_scene_path", "")).strip_edges()
	if model_path.is_empty():
		model_path = "res://scenes/entities/shooter_guard.tscn"
	definition["model_scene_path"] = model_path
	definition["model_fallback_used"] = false
	return definition

func _get_weapon_definition_for_model(weapon_id: String) -> Dictionary:
	var definition := game_manager.get_weapon_definition(weapon_id)
	var raw_model_path := str(definition.get("model_scene_path", "")).strip_edges()
	definition["model_scene_path"] = game_manager.resolve_weapon_model_path(weapon_id)
	definition["model_fallback_used"] = raw_model_path != str(definition["model_scene_path"])
	return definition

func _get_selected_weapon_id_for_model() -> String:
	if _home_state != null and not _home_state.selected_weapon_id.is_empty():
		return _home_state.selected_weapon_id
	return _selected_weapon_id

func _start_game() -> void:
	if scene_router != null:
		if not game_manager.try_start_run():
			_show_placeholder("No Energy", "Energy is recharging. Come back when one energy is ready.")
			_refresh_hub_summary(game_manager.soft_currency)
			return
		var selected_guard_id := _selected_guard_id
		if _home_state != null:
			selected_guard_id = _home_state.selected_guard_id
		game_manager.set_selected_loadout(_selected_hero_id, _selected_weapon_id, _selected_pet_id)
		game_manager.set_selected_guard(selected_guard_id)
		scene_router.go_to_game()

func _load_selection_from_manager() -> void:
	_selected_hero_id = game_manager.selected_hero_id
	_selected_weapon_id = game_manager.selected_weapon_id
	_selected_pet_id = game_manager.selected_pet_id
	_selected_guard_id = game_manager.selected_guard_id
	_equipment_panel.sync_selected_weapon(_selected_weapon_id)
	_home_state.sync_loadout(_selected_hero_id, _selected_weapon_id, _selected_pet_id, true, _selected_guard_id)

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
	var energy_value := game_manager.energy if game_manager != null else 0
	var gold_value := game_manager.gold if game_manager != null else currency
	var gems_value := game_manager.gems if game_manager != null else 0
	hub_energy_label.text = "EN %d/%d" % [energy_value, GameManager.ENERGY_MAX]
	hub_currency_label.text = "G %s" % _format_short_number(gold_value)
	hub_gems_label.text = "Gem %s" % _format_short_number(gems_value)

func _on_energy_changed(_energy: int, _seconds_to_next: int) -> void:
	_refresh_hub_summary(game_manager.soft_currency)

func _on_wallet_changed(_gold: int, _gems: int, _shards: Dictionary) -> void:
	_refresh_hub_summary(game_manager.soft_currency)

func _refresh_hub_focus(currency: int = 0) -> void:
	if game_manager == null:
		return

	var hero_id := _selected_hero_id
	var weapon_id := _selected_weapon_id
	var pet_id := _selected_pet_id
	var guard_id := _selected_guard_id
	if _home_state != null:
		hero_id = _home_state.selected_hero_id
		weapon_id = _home_state.selected_weapon_id
		pet_id = _home_state.selected_pet_id
		guard_id = _home_state.selected_guard_id

	var hero_definition := game_manager.get_hero_definition(hero_id)
	var weapon_definition := game_manager.get_weapon_definition(weapon_id)
	var pet_definition := game_manager.get_pet_definition(pet_id)
	var guard_definition := game_manager.get_guardian(guard_id)
	var hero_name := game_manager.get_display_name(hero_definition, "Hero")
	var pet_name := game_manager.get_display_name(pet_definition, "Pet")
	var guard_name := game_manager.get_display_name(guard_definition, "Guard")
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
	hub_power_label.text = "HP %s  ATK %s  DEF %s  PET %s  GRD %s" % [
		_format_short_number(hp),
		_format_short_number(attack),
		_format_short_number(defense),
		pet_name,
		guard_name,
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
	_start_game()

func _on_inventory_pressed() -> void:
	_show_screen(SCREEN_INVENTORY)

func _on_hub_hero_pressed() -> void:
	_show_screen(SCREEN_HERO_SELECT)

func _on_hub_pet_pressed() -> void:
	_show_screen(SCREEN_PET_SELECT)

func _on_hub_guard_pressed() -> void:
	_show_screen(SCREEN_GUARD_SELECT)

func _on_hub_equipment_pressed() -> void:
	_show_screen(SCREEN_EQUIPMENT_SELECT)

func _on_map_pressed() -> void:
	_show_placeholder("Map", "Map selection is planned for a later content step.")

func _on_settings_pressed() -> void:
	_open_settings(SCREEN_MAIN_MENU)

func _on_quests_pressed() -> void:
	_show_placeholder("Daily Quests", game_manager.get_daily_quest_summary())

func _on_shop_pressed() -> void:
	_setup_shop_ui()
	if _shop_ui != null and _shop_ui.has_method("open"):
		_shop_ui.call("open")

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
		_show_screen(SCREEN_MAIN_MENU, false)

func _on_equipment_continue_pressed() -> void:
	_show_screen(SCREEN_MAIN_MENU, false)

func _on_pet_confirm_pressed() -> void:
	_select_pet(_selected_pet_id, game_manager.is_pet_unlocked(_selected_pet_id))
	if game_manager.selected_pet_id == _selected_pet_id:
		_show_screen(SCREEN_MAIN_MENU, false)

func _on_guard_confirmed(guard_id: String) -> void:
	_select_guard(guard_id, game_manager.is_guardian_unlocked(guard_id))
	if game_manager.selected_guard_id == guard_id:
		_show_screen(SCREEN_MAIN_MENU, false)

func _on_guard_focused(guard_id: String) -> void:
	_focus_guard(guard_id)

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
	_refresh_equipment_summary()

func _on_equipment_change_requested(slot_id: String) -> void:
	_home_state.set_selected_equipment_slot(slot_id)
	if slot_id == "guard":
		_show_screen(SCREEN_GUARD_SELECT)
		return
	_refresh_inventory_summary(game_manager.inventory)
	_show_screen(SCREEN_INVENTORY)

func _on_equipment_unequip_requested(slot_id: String) -> void:
	if _home_state.unequip_item(slot_id):
		_refresh_equipment_summary()
		_refresh_hub_summary(game_manager.soft_currency)

func _on_equipment_upgrade_requested(weapon_id: String) -> void:
	if game_manager.upgrade_weapon(weapon_id):
		_refresh_equipment_summary()
		_refresh_hub_summary(game_manager.soft_currency)

func _on_inventory_item_selected(item_id: String) -> void:
	if _home_state.equip_item(item_id):
		_home_ui_manager.go_back()
		_refresh_equipment_summary()
		return
	_show_placeholder("Cannot Equip", "That item does not fit the selected equipment slot.")

func _on_home_state_hero_changed(_hero_id: String) -> void:
	_selected_hero_id = _hero_id
	_refresh_hero_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _on_home_state_weapon_changed(_weapon_id: String) -> void:
	_selected_weapon_id = _weapon_id
	_refresh_equipment_summary()
	_refresh_hero_preview_models()
	_refresh_hub_summary(game_manager.soft_currency)

func _on_home_state_pet_changed(_pet_id: String) -> void:
	_selected_pet_id = _pet_id
	_refresh_pet_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _on_home_state_guard_changed(_guard_id: String) -> void:
	_selected_guard_id = _guard_id
	_refresh_guard_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _on_home_state_equipment_summary_changed(_summary: String) -> void:
	_refresh_equipment_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _on_home_state_inventory_summary_changed(_summary: String) -> void:
	_refresh_inventory_summary(game_manager.inventory)

func _on_home_state_equipment_slot_changed(_slot_id: String) -> void:
	_refresh_equipment_summary()
	_refresh_inventory_summary(game_manager.inventory)

func _apply_responsive_layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
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
	var equipment_columns := 3
	var equipment_slot_columns := 2
	var inventory_content_columns := 2
	var inventory_item_columns := 6 if is_mobile else (7 if is_tablet else 8)

	for screen_name in _scroll_containers.keys():
		_set_scroll_container_enabled(str(screen_name), mobile_or_tablet and not [SCREEN_HERO_SELECT, SCREEN_PET_SELECT, SCREEN_GUARD_SELECT].has(str(screen_name)))

	for layout_path in [
		"ScreenRoot/MainMenuScreen/Layout",
		"ScreenRoot/ModeSelectScreen/Layout",
		"ScreenRoot/HeroSelectScreen/Layout",
		"ScreenRoot/EquipmentSelectScreen/Layout",
		"ScreenRoot/PetSelectScreen/Layout",
		"ScreenRoot/GuardSelectScreen/Layout",
	]:
		_set_margin(layout_path, margin)
	_set_inventory_layout_margin(margin, viewport_size.x, responsive_mode)

	for root_path in [
		"ScreenRoot/MainMenuScreen/Layout/Root",
		"ScreenRoot/ModeSelectScreen/Layout/Root",
		"ScreenRoot/HeroSelectScreen/Layout/Root",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root",
		"ScreenRoot/PetSelectScreen/Layout/Root",
		"ScreenRoot/GuardSelectScreen/Layout/Root",
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
		"ScreenRoot/GuardSelectScreen/Layout/Root/Content",
		"ScreenRoot/GuardSelectScreen/Layout/Root/Content/CardsPanel/Margin/VBox",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/CategoryBar/Margin/Buttons",
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
	_set_grid_columns("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions", 7)
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
	_set_grid_columns("ScreenRoot/GuardSelectScreen/Layout/Root/Content/CardsPanel/Margin/VBox/GuardCards", 5)
	_set_grid_columns("ScreenRoot/InventoryScreen/Layout/Root/Content", inventory_content_columns)
	_apply_inventory_layout_order()
	_set_grid_separation("ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards", 6 if is_mobile else grid_separation, 4 if is_mobile else grid_separation)
	_set_grid_separation("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns", grid_separation, grid_separation)
	_set_grid_separation("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn", grid_separation, grid_separation)
	_set_grid_separation("ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards", 6 if is_mobile else grid_separation, 4 if is_mobile else grid_separation)
	_set_grid_separation("ScreenRoot/GuardSelectScreen/Layout/Root/Content/CardsPanel/Margin/VBox/GuardCards", 6 if is_mobile else grid_separation, 4 if is_mobile else grid_separation)
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
		"ScreenRoot/GuardSelectScreen/Layout/Root/Content/PreviewPanel/Margin",
		"ScreenRoot/GuardSelectScreen/Layout/Root/Content/CardsPanel/Margin",
		"ScreenRoot/GuardSelectScreen/Layout/Root/Content/CardsPanel/Margin/VBox/SelectionSummary/SummaryMargin",
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
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/HelmetSlot/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/BootsSlot/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/GuardSlot/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/PetSlot/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/AccessorySlot/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard/Margin",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/CategoryBar/Margin",
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
	_set_minimum_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/GuardButton", Vector2(0.0, hub_action_height))
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
	_set_minimum_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/HelmetSlot", Vector2(0.0, 0.0))
	_set_minimum_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/BootsSlot", Vector2(0.0, 0.0))
	_set_minimum_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/GuardSlot", Vector2(0.0, 0.0))
	_set_minimum_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/PetSlot", Vector2(0.0, 0.0))
	_set_minimum_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/AccessorySlot", Vector2(0.0, 0.0))
	_set_minimum_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/CharacterPanel", Vector2(0.0, 300.0 if is_mobile else (320.0 if is_tablet else 340.0)))
	_set_minimum_size("ScreenRoot/GuardSelectScreen/Layout/Root/Content/PreviewPanel/Margin/GuardStage", Vector2(0.0, 210.0 if is_mobile else (260.0 if is_tablet else 320.0)))
	_set_minimum_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/CategoryBar", Vector2(0.0, 34.0 if is_short_landscape else 38.0))
	_set_control_font_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Header/Title", 18 if is_mobile else 22)
	_set_control_font_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Header/Subtitle", 12)
	_set_control_font_size("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard/Margin/LoadoutSummary", 12)
	_set_label_line_limit("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard/Margin/LoadoutSummary", 4)
	for gear_button_path in [
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/WeaponSlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/ArmorSlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/HelmetSlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/BootsSlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/GuardSlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/PetSlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/AccessorySlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/InventoryButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/UnequipButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/UpgradeButton",
	]:
		_set_control_font_size(gear_button_path, 12)
	_update_touch_targets(screen_root, responsive_mode)

func _install_scroll_containers() -> void:
	for screen_name in [
		SCREEN_MODE_SELECT,
		SCREEN_HERO_SELECT,
		SCREEN_PET_SELECT,
		SCREEN_GUARD_SELECT,
	]:
		_install_screen_scroll_container(screen_name)

func _install_screen_scroll_container(screen_name: String) -> void:
	var layout := get_parent().get_node_or_null("ScreenRoot/%s/Layout" % screen_name) as MarginContainer
	var root := get_parent().get_node_or_null("ScreenRoot/%s/Layout/Root" % screen_name) as Control
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
	var parent := get_parent()
	if parent == null:
		return null
	var node := parent.get_node_or_null(path)
	if node != null:
		return node
	if path.find("/Layout/Root") == -1:
		return null
	return parent.get_node_or_null(path.replace("/Layout/Root", "/Layout/RootScroll/Root"))

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
	_set_control_font_size("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar/Margin/PrimaryActions/GuardButton", 12)
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

	columns.move_child(left_column, 0)
	columns.move_child(character_panel, 1)
	columns.move_child(right_column, 2)

	var weapon_slot := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/WeaponSlot") as Control
	var armor_slot := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/ArmorSlot") as Control
	var helmet_slot := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/HelmetSlot") as Control
	var boots_slot := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/BootsSlot") as Control
	var guard_slot := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/GuardSlot") as Control
	var pet_slot := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/PetSlot") as Control
	var accessory_slot := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/AccessorySlot") as Control
	var loadout_card := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard") as Control
	var inventory_button := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/InventoryButton") as Control
	var unequip_button := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/UnequipButton") as Control
	var upgrade_button := _get_ui_node("ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/UpgradeButton") as Control
	if weapon_slot != null:
		left_column.move_child(weapon_slot, 0)
	if armor_slot != null:
		left_column.move_child(armor_slot, 1)
	if helmet_slot != null:
		left_column.move_child(helmet_slot, 2)
	if boots_slot != null:
		left_column.move_child(boots_slot, 3)
	if guard_slot != null:
		left_column.move_child(guard_slot, 4)
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
	if upgrade_button != null:
		right_column.move_child(upgrade_button, 5)

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
	var viewport_size := get_viewport().get_visible_rect().size
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
			elif button_path.find("EquipmentSelectScreen") != -1:
				local_touch_height = 34.0 if button_path.find("CategoryBar") != -1 else 40.0
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
