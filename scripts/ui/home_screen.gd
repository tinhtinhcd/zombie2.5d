extends Control

const SCREEN_MAIN_MENU = "MainMenuScreen"
const SCREEN_MODE_SELECT = "ModeSelectScreen"
const SCREEN_HERO_SELECT = "HeroSelectScreen"
const SCREEN_EQUIPMENT_SELECT = "EquipmentSelectScreen"
const SCREEN_PET_SELECT = "PetSelectScreen"
const SCREEN_INVENTORY = "InventoryScreen"

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
var _weapon_cycle_index: int = 0

func _ready() -> void:
	_screen_lookup = {
		"MainMenuScreen": main_menu_screen,
		"ModeSelectScreen": mode_select_screen,
		"HeroSelectScreen": hero_select_screen,
		"EquipmentSelectScreen": equipment_select_screen,
		"PetSelectScreen": pet_select_screen,
		"InventoryScreen": inventory_screen,
	}

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
		_show_placeholder("Hero Locked", "Only one hero is playable in the MVP. Locked and future heroes stay visible here on purpose.")
		return

	_selected_hero_id = hero_id
	game_manager.set_selected_loadout(_selected_hero_id, _selected_weapon_id, _selected_pet_id)
	_refresh_hero_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _refresh_hero_summary() -> void:
	var has_selection := _selected_hero_id != ""
	hero_continue_button.disabled = not has_selection
	hero_knight_button.text = "Selected" if _selected_hero_id == "hero_knight" else "Select"
	hero_rogue_button.text = "Selected" if _selected_hero_id == "hero_rogue" else "Select"
	hero_mage_button.text = "Selected" if _selected_hero_id == "hero_mage" else "Select"
	if has_selection:
		var hero_definition := game_manager.get_hero_definition(_selected_hero_id)
		hero_status_label.text = "Selected hero: %s\nStats apply when the run starts." % game_manager.get_display_name(hero_definition, "Hero")
	else:
		hero_status_label.text = "Select a hero to continue. Each hero changes basic run stats."

func _refresh_equipment_summary() -> void:
	var weapon_definition := game_manager.get_weapon_definition(_selected_weapon_id)
	var weapon_name := game_manager.get_display_name(weapon_definition, "Basic Gun")
	equipment_summary_label.text = "Selected loadout\nWeapon: %s\nDamage: %d\nFire: %.2fs\nProjectiles: %d\nRange: %.1f\nArmor: Placeholder\nAccessory: Placeholder" % [
		weapon_name,
		int(weapon_definition.get("damage", weapon_definition.get("projectile_damage", 1))),
		float(weapon_definition.get("fire_rate", weapon_definition.get("fire_interval", 0.6))),
		int(weapon_definition.get("projectile_count", 1)),
		float(weapon_definition.get("range", 20.0)),
	]
	weapon_slot_button.text = "Change Weapon"
	armor_slot_button.text = "Locked"
	accessory_slot_button.text = "Locked"

func _select_pet(pet_id: String, implemented: bool) -> void:
	if not implemented:
		_show_placeholder("Coming Soon", "Pet systems remain visible in the UI but are intentionally not implemented in MVP.")
		return

	_selected_pet_id = pet_id
	game_manager.set_selected_loadout(_selected_hero_id, _selected_weapon_id, _selected_pet_id)
	_refresh_pet_summary()
	_refresh_hub_summary(game_manager.soft_currency)

func _refresh_pet_summary() -> void:
	pet_drone_button.text = "Selected" if _selected_pet_id == "pet_drone" else "Select"
	pet_sprite_button.text = "Selected" if _selected_pet_id == "pet_sprite" else "Select"
	pet_wisp_button.text = "Selected" if _selected_pet_id == "pet_wisp" else "Select"
	if _selected_pet_id == "":
		pet_status_label.text = "No pet selected.\nThis is intentional for MVP, and Start Game still works."
	else:
		var pet_definition := game_manager.get_pet_definition(_selected_pet_id)
		pet_status_label.text = "Selected pet: %s\nPet assists with light automatic damage." % game_manager.get_display_name(pet_definition, "Pet")

func _start_game() -> void:
	if scene_router != null:
		game_manager.set_selected_loadout(_selected_hero_id, _selected_weapon_id, _selected_pet_id)
		scene_router.go_to_game()

func _load_selection_from_manager() -> void:
	_selected_hero_id = game_manager.selected_hero_id
	_selected_weapon_id = game_manager.selected_weapon_id
	_selected_pet_id = game_manager.selected_pet_id
	var weapon_ids := game_manager.get_weapon_ids()
	_weapon_cycle_index = max(weapon_ids.find(_selected_weapon_id), 0)

func _refresh_hub_summary(_currency: int = 0) -> void:
	var hero_name := game_manager.get_display_name(game_manager.get_selected_hero_definition(), "Hero")
	var weapon_name := game_manager.get_display_name(game_manager.get_selected_weapon_definition(), "Weapon")
	var pet_name := game_manager.get_display_name(game_manager.get_selected_pet_definition(), "Pet")
	var weapon_definition := game_manager.get_selected_weapon_definition()
	hub_preview_list.text = "Coins: %d\nHero: %s\nWeapon: %s\nWeapon Range: %.1f\nPet: %s\nHighest Level: %d" % [
		game_manager.soft_currency,
		hero_name,
		weapon_name,
		float(weapon_definition.get("range", 20.0)),
		pet_name,
		game_manager.highest_unlocked_level,
	]
	hub_preview_note.text = "Survival is playable now. Other long-term systems are represented with simple readable UI."

func _refresh_inventory_summary(_inventory: Dictionary = {}) -> void:
	var scrap_count := int(game_manager.inventory.get("scrap", 0))
	inventory_description_label.text = "Coins: %d\nScrap: %d\nEnemies can drop scrap during runs. Equipment depth stays intentionally light." % [
		game_manager.soft_currency,
		scrap_count,
	]

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
	_select_hero("hero_rogue", true)

func _on_mage_pressed() -> void:
	_select_hero("hero_mage", true)

func _on_hero_continue_pressed() -> void:
	_show_screen(SCREEN_EQUIPMENT_SELECT)

func _on_weapon_slot_pressed() -> void:
	var weapon_ids := game_manager.get_weapon_ids()
	if weapon_ids.is_empty():
		return
	_weapon_cycle_index = (_weapon_cycle_index + 1) % weapon_ids.size()
	_selected_weapon_id = str(weapon_ids[_weapon_cycle_index])
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
	_select_pet("pet_sprite", true)

func _on_wisp_pressed() -> void:
	_select_pet("pet_wisp", true)

func _on_placeholder_closed() -> void:
	screen_root.mouse_filter = Control.MOUSE_FILTER_PASS
