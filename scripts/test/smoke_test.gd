extends SceneTree

const HOME_SCENE := "res://scenes/ui/home_screen.tscn"
const GAME_SCENE := "res://scenes/core/game.tscn"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(960, 540)
	var home_scene := load(HOME_SCENE) as PackedScene
	if home_scene == null:
		push_error("Smoke test failed: home scene did not load.")
		quit(1)
		return

	var home := home_scene.instantiate()
	root.add_child(home)
	await process_frame
	await process_frame
	if not _assert_home_hub_layout(home):
		quit(1)
		return
	home.call("_on_play_pressed")
	await process_frame
	if not bool(home.get_node("ScreenRoot/ModeSelectScreen").visible):
		push_error("Smoke test failed: home UI manager did not open mode select.")
		quit(1)
		return
	home.call("_on_survival_pressed")
	await process_frame
	if not bool(home.get_node("ScreenRoot/HeroSelectScreen").visible):
		push_error("Smoke test failed: home UI manager did not open hero select.")
		quit(1)
		return
	if not _assert_hero_carousel_layout(home):
		quit(1)
		return
	home.call("_on_knight_pressed")
	await process_frame
	var hero_cards := home.call("_get_ui_node", "ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards") as GridContainer
	var carousel_next := hero_cards.get_node_or_null("CarouselRightButton") as Button
	if carousel_next == null:
		push_error("Smoke test failed: hero carousel right navigation is missing.")
		quit(1)
		return
	carousel_next.pressed.emit()
	await process_frame
	var home_state: Variant = home.get("_home_state")
	if home_state == null or home_state.selected_hero_id != "hero_rogue":
		push_error("Smoke test failed: hero carousel right navigation did not update selected hero.")
		quit(1)
		return
	var home_preview_after_right := home.get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player") as Node3D
	if home_preview_after_right == null or str(home_preview_after_right.get_meta("hero_id", "")) != "hero_rogue":
		push_error("Smoke test failed: home hero preview did not track hero carousel selection.")
		quit(1)
		return
	var hero_confirm := home.call("_get_ui_node", "ScreenRoot/HeroSelectScreen/Layout/Root/Footer/ContinueButton") as Button
	var carousel_game_manager := root.get_node_or_null("/root/GameManager") as GameManager
	if hero_confirm == null or hero_confirm.disabled == carousel_game_manager.is_hero_unlocked("hero_rogue"):
		push_error("Smoke test failed: hero carousel confirm state does not match centered hero availability.")
		quit(1)
		return
	var carousel_left := hero_cards.get_node_or_null("CarouselLeftButton") as Button
	if carousel_left == null:
		push_error("Smoke test failed: hero carousel left navigation is missing.")
		quit(1)
		return
	carousel_left.pressed.emit()
	await process_frame
	if home_state.selected_hero_id != "hero_knight" or hero_confirm.disabled:
		push_error("Smoke test failed: hero carousel left navigation did not return to available hero.")
		quit(1)
		return
	var home_preview_after_left := home.get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player") as Node3D
	if home_preview_after_left == null or str(home_preview_after_left.get_meta("hero_id", "")) != "hero_knight":
		push_error("Smoke test failed: home hero preview did not return to the selected hero.")
		quit(1)
		return
	home.call("_on_knight_pressed")
	await process_frame
	if home_state == null or home_state.selected_hero_id != "hero_knight":
		push_error("Smoke test failed: selecting a hero did not update home state.")
		quit(1)
		return
	var hub_summary := home.call("_get_ui_node", "ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard/PreviewMargin/PreviewContent/PreviewNote") as Label
	if hub_summary == null or not hub_summary.text.contains("Knight"):
		push_error("Smoke test failed: hub summary did not react to hero selection.")
		quit(1)
		return
	home.call("_on_hero_continue_pressed")
	await process_frame
	if not bool(home.get_node("ScreenRoot/EquipmentSelectScreen").visible):
		push_error("Smoke test failed: home UI manager did not open equipment select.")
		quit(1)
		return
	home.call("_show_screen", "PetSelectScreen", false)
	await process_frame
	if not _assert_pet_carousel_layout(home):
		quit(1)
		return
	home.call("_on_drone_pressed")
	await process_frame
	var pet_cards := home.call("_get_ui_node", "ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards") as GridContainer
	var pet_next := pet_cards.get_node_or_null("CarouselRightButton") as Button
	if pet_next == null:
		push_error("Smoke test failed: pet carousel right navigation is missing.")
		quit(1)
		return
	pet_next.pressed.emit()
	await process_frame
	if home_state.selected_pet_id != "pet_sprite":
		push_error("Smoke test failed: pet carousel right navigation did not update selected pet.")
		quit(1)
		return
	var pet_confirm := home.call("_get_ui_node", "ScreenRoot/PetSelectScreen/Layout/Root/Footer/StartGameButton") as Button
	var pet_game_manager := root.get_node_or_null("/root/GameManager") as GameManager
	if pet_confirm == null or pet_confirm.disabled == pet_game_manager.is_pet_unlocked("pet_sprite"):
		push_error("Smoke test failed: pet carousel confirm state does not match centered pet availability.")
		quit(1)
		return
	var pet_left := pet_cards.get_node_or_null("CarouselLeftButton") as Button
	if pet_left == null:
		push_error("Smoke test failed: pet carousel left navigation is missing.")
		quit(1)
		return
	pet_left.pressed.emit()
	await process_frame
	if home_state.selected_pet_id != "pet_drone" or pet_confirm.disabled:
		push_error("Smoke test failed: pet carousel left navigation did not return to available pet.")
		quit(1)
		return
	home.call("_show_screen", "EquipmentSelectScreen", false)
	await process_frame
	home.call("_on_equipment_slot_requested", "armor")
	await process_frame
	if home_state.selected_equipment_slot != "armor" or not bool(home.get_node("ScreenRoot/InventoryScreen").visible):
		push_error("Smoke test failed: equipment slot selection did not open inventory for armor.")
		quit(1)
		return
	if not _assert_inventory_layout(home):
		quit(1)
		return
	if bool(home_state.equip_item("training_blade")):
		push_error("Smoke test failed: mismatched inventory item was equipped into armor slot.")
		quit(1)
		return
	var first_inventory_slot := home.call("_get_ui_node", "ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotA") as Button
	if first_inventory_slot == null:
		push_error("Smoke test failed: first inventory slot is missing.")
		quit(1)
		return
	first_inventory_slot.pressed.emit()
	await process_frame
	var inventory_name := home.call("_get_ui_node", "ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/NameLabel") as Label
	if inventory_name == null or inventory_name.text != "Leather Vest":
		push_error("Smoke test failed: selecting an inventory slot did not update the left detail panel.")
		quit(1)
		return
	home.call("_on_inventory_item_selected", "leather_vest")
	await process_frame
	var equipped_armor: Dictionary = home_state.get_equipped_item("armor")
	if str(equipped_armor.get("id", "")) != "leather_vest":
		push_error("Smoke test failed: selecting an inventory item did not equip armor.")
		quit(1)
		return
	var loadout_summary := home.call("_get_ui_node", "ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard/Margin/LoadoutSummary") as Label
	if loadout_summary == null or not loadout_summary.text.contains("Leather Vest"):
		push_error("Smoke test failed: equipment panel did not refresh after equipping armor.")
		quit(1)
		return
	if not hub_summary.text.contains("Leather Vest"):
		push_error("Smoke test failed: hub summary did not refresh after equipping armor.")
		quit(1)
		return
	home.call("_go_back")
	await process_frame
	if not bool(home.get_node("ScreenRoot/HeroSelectScreen").visible):
		push_error("Smoke test failed: home UI manager back navigation did not return to hero select.")
		quit(1)
		return
	home.queue_free()
	await process_frame

	var game_scene := load(GAME_SCENE) as PackedScene
	if game_scene == null:
		push_error("Smoke test failed: game scene did not load.")
		quit(1)
		return

	var game := game_scene.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	await process_frame

	var enemy_container := game.get_node_or_null("EnemyContainer")
	if enemy_container == null or enemy_container.get_child_count() == 0:
		push_error("Smoke test failed: gameplay scene did not spawn the first wave.")
		quit(1)
		return

	var repeated_tiles := game.get_node_or_null("LevelContainer/RepeatedTiles")
	if repeated_tiles == null or repeated_tiles.get_child_count() < 9:
		push_error("Smoke test failed: endless repeated map tiles were not created.")
		quit(1)
		return

	var player := game.get_node("Player") as Player
	var projectile_container := game.get_node_or_null("ProjectileContainer")
	var endless_map := game.get_node_or_null("LevelContainer") as EndlessMap
	var wave_manager := game.get_node_or_null("WaveManager")
	var game_manager := root.get_node_or_null("/root/GameManager") as GameManager
	var save_manager := root.get_node_or_null("/root/SaveManager") as SaveManager
	if projectile_container == null:
		push_error("Smoke test failed: projectile container is missing.")
		quit(1)
		return
	if game_manager == null:
		push_error("Smoke test failed: GameManager autoload is missing.")
		quit(1)
		return
	game.call("_toggle_pause_menu")
	var pause_menu := game.get_node("GameOverlayLayer/PauseMenu")
	if not paused or game_manager.is_gameplay_active or not bool(pause_menu.visible):
		push_error("Smoke test failed: pause menu did not pause gameplay.")
		quit(1)
		return
	game.call("_hide_pause_menu")
	if paused or not game_manager.is_gameplay_active or bool(pause_menu.visible):
		push_error("Smoke test failed: pause menu did not resume gameplay.")
		quit(1)
		return
	if save_manager == null:
		push_error("Smoke test failed: SaveManager autoload is missing.")
		quit(1)
		return
	if save_manager.DEFAULT_SAVE_DATA["unlocked_heroes"].size() != 1 or save_manager.DEFAULT_SAVE_DATA["unlocked_weapons"].size() != 1 or save_manager.DEFAULT_SAVE_DATA["unlocked_pets"].size() != 1:
		push_error("Smoke test failed: default save unlocks are not minimal.")
		quit(1)
		return
	var fallback_save: Dictionary = save_manager.call("_merge_with_defaults", {
		"selected_hero_id": "hero_mage",
		"selected_weapon_id": "weapon_heavy",
		"selected_pet_id": "pet_wisp",
		"unlocked_heroes": ["hero_knight"],
		"unlocked_weapons": ["weapon_basic"],
		"unlocked_pets": ["pet_drone"],
	})
	if fallback_save["selected_hero_id"] != "hero_knight" or fallback_save["selected_weapon_id"] != "weapon_basic" or fallback_save["selected_pet_id"] != "pet_drone":
		push_error("Smoke test failed: invalid selected loadout did not fallback to starter defaults.")
		quit(1)
		return
	if endless_map == null:
		push_error("Smoke test failed: endless map script is missing.")
		quit(1)
		return
	if not is_equal_approx(player.play_area_radius, 600.0):
		push_error("Smoke test failed: player map limit is not using the fixed physical radius.")
		quit(1)
		return
	if not is_equal_approx(endless_map.map_radius, player.play_area_radius):
		push_error("Smoke test failed: endless map limit does not match player play radius.")
		quit(1)
		return
	var up_direction := player.call("_get_move_direction", Vector2(0.0, -1.0)) as Vector3
	var down_direction := player.call("_get_move_direction", Vector2(0.0, 1.0)) as Vector3
	if up_direction.z >= -0.5 or down_direction.z <= 0.5:
		push_error("Smoke test failed: up/down input direction is inverted.")
		quit(1)
		return

	for enemy in enemy_container.get_children():
		if enemy is Node3D:
			(enemy as Node3D).global_position = player.global_position + Vector3(0.0, 0.0, -80.0)
	player.call("_face_direction", Vector3.FORWARD)
	player.call("_animate_visual", 0.2, Vector3.FORWARD)
	await process_frame
	if not is_equal_approx(player.get_node("ShootPoint").rotation.y, 0.0):
		push_error("Smoke test failed: player shoot direction did not rotate toward target direction.")
		quit(1)
		return
	if is_equal_approx(player.get_node("VisualRoot").position.y, 0.0):
		push_error("Smoke test failed: player visual animation did not move the visual root.")
		quit(1)
		return
	var player_animation := player.get_node_or_null("VisualRoot/HeroModel/KayKitAnimationPlayer") as AnimationPlayer
	if player_animation == null or not player_animation.is_playing():
		push_error("Smoke test failed: player hero animation player is not running.")
		quit(1)
		return
	player.call("_play_character_animation", "Jog_Fwd", 1.25)
	var player_running_animation := player_animation.get_animation("Jog_Fwd")
	if player_running_animation == null or player_running_animation.loop_mode != Animation.LOOP_LINEAR:
		push_error("Smoke test failed: player UAL1 jog animation is not configured to loop.")
		quit(1)
		return

	for enemy in enemy_container.get_children():
		if enemy is Node3D:
			(enemy as Node3D).global_position = player.global_position + Vector3(0.0, 0.0, -20.0)
	player.weapon_range = 10.0
	var enemy_for_facing := enemy_container.get_child(0) as Node3D
	enemy_for_facing.global_position = player.global_position + Vector3.RIGHT * 4.0
	player.call("_face_combat_target_or_movement", Vector3.FORWARD)
	await process_frame
	if not is_equal_approx(player.get_node("ShootPoint").rotation.y, -PI * 0.5):
		push_error("Smoke test failed: player did not face the nearest in-range enemy over movement direction.")
		quit(1)
		return
	player.weapon_range = 1.0
	player.call("_face_combat_target_or_movement", Vector3.FORWARD)
	await process_frame
	if not is_equal_approx(player.get_node("ShootPoint").rotation.y, 0.0):
		push_error("Smoke test failed: player did not face movement direction when enemies were out of weapon range.")
		quit(1)
		return

	var spread_weapon: Dictionary = game_manager.get_weapon_definition("weapon_spread")
	player.apply_weapon_definition(spread_weapon)
	var first_enemy_for_weapon := enemy_container.get_child(0) as Node3D
	first_enemy_for_weapon.global_position = player.global_position + Vector3(0.0, 0.0, -5.0)
	var projectile_count_before := projectile_container.get_child_count()
	player.spawn_projectile()
	await process_frame
	if projectile_container.get_child_count() - projectile_count_before != 3:
		push_error("Smoke test failed: spread weapon did not spawn three projectiles.")
		quit(1)
		return
	var first_projectile := projectile_container.get_child(projectile_count_before) as Projectile
	if first_projectile == null or not is_equal_approx(first_projectile.max_distance, player.weapon_range):
		push_error("Smoke test failed: projectile did not receive weapon range.")
		quit(1)
		return

	for child in projectile_container.get_children():
		child.queue_free()
	await process_frame
	player.weapon_range = 1.0
	for enemy in enemy_container.get_children():
		if enemy is Node3D:
			(enemy as Node3D).global_position = player.global_position + Vector3(0.0, 0.0, -12.0)
	player.spawn_projectile()
	await process_frame
	if projectile_container.get_child_count() != 0:
		push_error("Smoke test failed: weapon range did not prevent out-of-range firing.")
		quit(1)
		return
	player.apply_weapon_definition(spread_weapon)

	var original_level := game_manager.current_level
	game_manager.current_level = 3
	if game_manager.get_scaled_xp_drop(1) <= 1:
		push_error("Smoke test failed: XP drop did not increase by level.")
		quit(1)
		return
	game_manager.current_level = original_level

	var first_enemy := enemy_container.get_child(0)
	var enemy_before_recycle := first_enemy as Node3D
	enemy_before_recycle.global_position = player.global_position + Vector3(999.0, 0.0, 0.0)
	if wave_manager != null:
		wave_manager.call("_recycle_far_enemies")
	var recycled_distance := enemy_before_recycle.global_position.distance_to(player.global_position)
	if recycled_distance < 32.0 or recycled_distance > 70.0:
		push_error("Smoke test failed: far enemy was not recycled into the fixed physical spawn ring.")
		quit(1)
		return
	var enemy_animation := first_enemy.get_node_or_null("VisualRoot/SkeletonMinion/KayKitAnimationPlayer") as AnimationPlayer
	if enemy_animation == null or not enemy_animation.is_playing():
		push_error("Smoke test failed: enemy KayKit animation player is not running.")
		quit(1)
		return
	first_enemy.call("_play_character_animation", "Walking_A", 0.85)
	var enemy_walking_animation := enemy_animation.get_animation("Walking_A")
	if enemy_walking_animation == null or enemy_walking_animation.loop_mode != Animation.LOOP_LINEAR:
		push_error("Smoke test failed: enemy KayKit walking animation is not configured to loop.")
		quit(1)
		return

	game_manager.begin_upgrade_selection()
	await process_frame
	if not game_manager.is_upgrade_selection_active:
		push_error("Smoke test failed: upgrade selection did not activate.")
		quit(1)
		return

	game_manager.select_upgrade(player, &"projectile_damage")
	await process_frame
	if game_manager.is_upgrade_selection_active:
		push_error("Smoke test failed: upgrade selection did not close.")
		quit(1)
		return

	game_manager.trigger_game_over()
	await process_frame
	if not game_manager.is_game_over:
		push_error("Smoke test failed: game over did not activate.")
		quit(1)
		return

	game.queue_free()
	await process_frame

	print("Smoke test passed: home, gameplay, wave, upgrade, and game-over flow.")
	quit(0)

func _assert_home_hub_layout(home: Node) -> bool:
	var viewport_size := home.get_viewport().get_visible_rect().size
	var required_paths := [
		"ScreenRoot/MainMenuScreen/Layout/Root/Header",
		"ScreenRoot/MainMenuScreen/Layout/Root/Header/ProfileBlock",
		"ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/EnergyLabel",
		"ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/CurrencyLabel",
		"ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/GemsLabel",
		"ScreenRoot/MainMenuScreen/Layout/Root/Header/ResourceBar/TopSettingsButton",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/PowerCard",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/LeftMenu/MissionCard",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/QuickEquipmentPanel",
		"ScreenRoot/MainMenuScreen/Layout/Root/MainContent/RightPanel/FeaturePreview",
		"ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar",
		"ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar",
		"ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar/Margin/NavButtons/MailButton",
		"ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar/Margin/NavButtons/EventsButton",
		"ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar/Margin/NavButtons/QuestsButton",
		"ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar/Margin/NavButtons/ShopButton",
		"ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar/Margin/NavButtons/RankingButton",
		"ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar/Margin/NavButtons/BottomSettingsButton",
	]
	for path in required_paths:
		var control := home.get_node_or_null(path) as Control
		if control == null:
			push_error("Smoke test failed: required home UI node is missing: %s" % path)
			return false
		if not control.is_visible_in_tree():
			push_error("Smoke test failed: required home UI node is hidden at runtime: %s" % path)
			return false
		var rect := control.get_global_rect()
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			push_error("Smoke test failed: required home UI node has no runtime layout size: %s" % path)
			return false
		if rect.position.y < -0.5 or rect.end.y > viewport_size.y + 0.5:
			push_error("Smoke test failed: required home UI node is clipped vertically at runtime: %s" % path)
			return false
		if rect.position.x < -0.5 or rect.end.x > viewport_size.x + 0.5:
			push_error("Smoke test failed: required home UI node is clipped horizontally at runtime: %s" % path)
			return false
	var header := home.get_node("ScreenRoot/MainMenuScreen/Layout/Root/Header") as Control
	var main_content := home.get_node("ScreenRoot/MainMenuScreen/Layout/Root/MainContent") as Control
	var primary_actions := home.get_node("ScreenRoot/MainMenuScreen/Layout/Root/PrimaryActionBar") as Control
	var bottom_nav := home.get_node("ScreenRoot/MainMenuScreen/Layout/Root/BottomNavBar") as Control
	if header.get_global_rect().end.y > main_content.get_global_rect().position.y + 0.5:
		push_error("Smoke test failed: home header overlaps main content at runtime.")
		return false
	if main_content.get_global_rect().end.y > primary_actions.get_global_rect().position.y + 0.5:
		push_error("Smoke test failed: home main content overlaps primary actions at runtime.")
		return false
	if primary_actions.get_global_rect().end.y > bottom_nav.get_global_rect().position.y + 0.5:
		push_error("Smoke test failed: home primary actions overlap secondary bottom nav at runtime.")
		return false
	var hero_stage := home.get_node("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage") as Control
	var hero_rect := hero_stage.get_global_rect()
	if header.get_global_rect().size.y > 44.0:
		push_error("Smoke test failed: home HUD header is too tall for 960x540.")
		return false
	if primary_actions.get_global_rect().size.y > 68.0:
		push_error("Smoke test failed: primary action bar exceeds the mobile landscape budget.")
		return false
	if bottom_nav.get_global_rect().size.y > 40.0:
		push_error("Smoke test failed: secondary nav exceeds the mobile landscape budget.")
		return false
	if hero_rect.size.x < viewport_size.x * 0.45 or hero_rect.size.y < viewport_size.y * 0.45:
		push_error("Smoke test failed: compact hub does not leave enough visible hero area.")
		return false
	var home_preview_player := home.get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player") as Node3D
	if home_preview_player == null:
		push_error("Smoke test failed: home hero preview did not spawn the gameplay player scene.")
		return false
	if str(home_preview_player.get_meta("source_scene_path", "")) != "res://scenes/player/player.tscn":
		push_error("Smoke test failed: home hero preview is not sourced from the gameplay player scene.")
		return false
	if home_preview_player.scale.x > 0.7 or abs(home_preview_player.rotation_degrees.y) > 0.5:
		push_error("Smoke test failed: home hero preview is not using the compact front-facing transform.")
		return false
	var home_preview_animation := home_preview_player.get_node_or_null("VisualRoot/HeroModel/KayKitAnimationPlayer") as AnimationPlayer
	if home_preview_animation == null or not home_preview_animation.is_playing():
		push_error("Smoke test failed: home hero preview walking animation is not running.")
		return false
	return true

func _assert_hero_carousel_layout(home: Node) -> bool:
	var viewport_size := home.get_viewport().get_visible_rect().size
	var required_paths := [
		"ScreenRoot/HeroSelectScreen/Layout/Root/Header",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Header/BackButton",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Header/Title",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/CarouselLeftButton",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/Portrait/GameplayHeroPreview",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin/VBox/Portrait/GameplayHeroPreview",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard/Margin/VBox/Portrait/GameplayHeroPreview",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/CarouselRightButton",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/SelectionSummary",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Footer",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Footer/ContinueButton",
	]
	for path in required_paths:
		var control := home.call("_get_ui_node", path) as Control
		if control == null:
			push_error("Smoke test failed: required hero carousel node is missing: %s" % path)
			return false
		if not control.is_visible_in_tree():
			push_error("Smoke test failed: required hero carousel node is hidden at runtime: %s" % path)
			return false
		var rect := control.get_global_rect()
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			push_error("Smoke test failed: required hero carousel node has no runtime layout size: %s" % path)
			return false
		if rect.position.y < -0.5 or rect.end.y > viewport_size.y + 0.5:
			push_error("Smoke test failed: required hero carousel node is clipped vertically: %s" % path)
			return false
		if rect.position.x < -0.5 or rect.end.x > viewport_size.x + 0.5:
			push_error("Smoke test failed: required hero carousel node is clipped horizontally: %s" % path)
			return false
	var header := home.call("_get_ui_node", "ScreenRoot/HeroSelectScreen/Layout/Root/Header") as Control
	var content := home.call("_get_ui_node", "ScreenRoot/HeroSelectScreen/Layout/Root/Content") as Control
	var footer := home.call("_get_ui_node", "ScreenRoot/HeroSelectScreen/Layout/Root/Footer") as Control
	if header.get_global_rect().end.y > content.get_global_rect().position.y + 0.5:
		push_error("Smoke test failed: hero select top bar overlaps carousel content.")
		return false
	if content.get_global_rect().end.y > footer.get_global_rect().position.y + 0.5:
		push_error("Smoke test failed: hero select carousel content overlaps confirm footer.")
		return false
	var selected_preview_player := home.call("_get_ui_node", "ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/Portrait/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player") as Node3D
	if selected_preview_player == null:
		push_error("Smoke test failed: selected hero card did not spawn the gameplay player scene.")
		return false
	if str(selected_preview_player.get_meta("source_scene_path", "")) != "res://scenes/player/player.tscn":
		push_error("Smoke test failed: hero select preview is not sourced from the gameplay player scene.")
		return false
	if selected_preview_player.scale.x > 0.7 or abs(selected_preview_player.rotation_degrees.y) > 0.5:
		push_error("Smoke test failed: hero select preview is not using the compact front-facing transform.")
		return false
	var selected_preview_animation := selected_preview_player.get_node_or_null("VisualRoot/HeroModel/KayKitAnimationPlayer") as AnimationPlayer
	if selected_preview_animation == null or not selected_preview_animation.is_playing():
		push_error("Smoke test failed: selected hero preview animation is not running.")
		return false
	return true

func _assert_pet_carousel_layout(home: Node) -> bool:
	var viewport_size := home.get_viewport().get_visible_rect().size
	var required_paths := [
		"ScreenRoot/PetSelectScreen/Layout/Root/Header",
		"ScreenRoot/PetSelectScreen/Layout/Root/Header/BackButton",
		"ScreenRoot/PetSelectScreen/Layout/Root/Header/Title",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/CarouselLeftButton",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/DroneCard",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/SpriteCard",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/WispCard",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/CarouselRightButton",
		"ScreenRoot/PetSelectScreen/Layout/Root/Content/SelectionSummary",
		"ScreenRoot/PetSelectScreen/Layout/Root/Footer",
		"ScreenRoot/PetSelectScreen/Layout/Root/Footer/StartGameButton",
	]
	for path in required_paths:
		var control := home.call("_get_ui_node", path) as Control
		if control == null:
			push_error("Smoke test failed: required pet carousel node is missing: %s" % path)
			return false
		if not control.is_visible_in_tree():
			push_error("Smoke test failed: required pet carousel node is hidden at runtime: %s" % path)
			return false
		var rect := control.get_global_rect()
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			push_error("Smoke test failed: required pet carousel node has no runtime layout size: %s" % path)
			return false
		if rect.position.y < -0.5 or rect.end.y > viewport_size.y + 0.5:
			push_error("Smoke test failed: required pet carousel node is clipped vertically: %s" % path)
			return false
		if rect.position.x < -0.5 or rect.end.x > viewport_size.x + 0.5:
			push_error("Smoke test failed: required pet carousel node is clipped horizontally: %s" % path)
			return false
	var header := home.call("_get_ui_node", "ScreenRoot/PetSelectScreen/Layout/Root/Header") as Control
	var content := home.call("_get_ui_node", "ScreenRoot/PetSelectScreen/Layout/Root/Content") as Control
	var footer := home.call("_get_ui_node", "ScreenRoot/PetSelectScreen/Layout/Root/Footer") as Control
	if header.get_global_rect().end.y > content.get_global_rect().position.y + 0.5:
		push_error("Smoke test failed: pet select top bar overlaps carousel content.")
		return false
	if content.get_global_rect().end.y > footer.get_global_rect().position.y + 0.5:
		push_error("Smoke test failed: pet select carousel content overlaps confirm footer.")
		return false
	return true

func _assert_inventory_layout(home: Node) -> bool:
	var viewport_size := home.get_viewport().get_visible_rect().size
	var required_paths := [
		"ScreenRoot/InventoryScreen/Layout/Root/Header",
		"ScreenRoot/InventoryScreen/Layout/Root/Header/BackButton",
		"ScreenRoot/InventoryScreen/Layout/Root/Header/Title",
		"ScreenRoot/InventoryScreen/Layout/Root/Content",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/IconPreview",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/NameLabel",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/StatsLabel",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel/Margin/VBox/ActionRow/EquipButton",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotA",
		"ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotP",
	]
	for path in required_paths:
		var control := home.call("_get_ui_node", path) as Control
		if control == null:
			push_error("Smoke test failed: required inventory node is missing: %s" % path)
			return false
		if not control.is_visible_in_tree():
			push_error("Smoke test failed: required inventory node is hidden at runtime: %s" % path)
			return false
		var rect := control.get_global_rect()
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			push_error("Smoke test failed: required inventory node has no runtime layout size: %s" % path)
			return false
		if rect.position.y < -0.5 or rect.end.y > viewport_size.y + 0.5:
			push_error("Smoke test failed: required inventory node is clipped vertically: %s" % path)
			return false
		if rect.position.x < -0.5 or rect.end.x > viewport_size.x + 0.5:
			push_error("Smoke test failed: required inventory node is clipped horizontally: %s" % path)
			return false
	var header := home.call("_get_ui_node", "ScreenRoot/InventoryScreen/Layout/Root/Header") as Control
	var content := home.call("_get_ui_node", "ScreenRoot/InventoryScreen/Layout/Root/Content") as Control
	var details_panel := home.call("_get_ui_node", "ScreenRoot/InventoryScreen/Layout/Root/Content/DetailsPanel") as Control
	var grid_panel := home.call("_get_ui_node", "ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel") as Control
	var slot_a := home.call("_get_ui_node", "ScreenRoot/InventoryScreen/Layout/Root/Content/GridPanel/Margin/GridScroll/ItemGrid/SlotA") as Control
	if header.get_global_rect().end.y > content.get_global_rect().position.y + 0.5:
		push_error("Smoke test failed: inventory top bar overlaps main content.")
		return false
	if details_panel.get_global_rect().position.x > grid_panel.get_global_rect().position.x:
		push_error("Smoke test failed: inventory detail panel is not on the left of the grid.")
		return false
	if details_panel.get_global_rect().size.x > viewport_size.x * 0.38:
		push_error("Smoke test failed: inventory detail panel is too wide for landscape mobile.")
		return false
	if slot_a.get_global_rect().size.y > 72.0:
		push_error("Smoke test failed: inventory slots are still too large.")
		return false
	return true
