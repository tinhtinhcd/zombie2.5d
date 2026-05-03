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
	home.call("_on_hub_hero_pressed")
	await process_frame
	if not bool(home.get_node("ScreenRoot/HeroSelectScreen").visible):
		push_error("Smoke test failed: home Hero button did not open hero select.")
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
	var rogue_preview_after_right := home.call("_get_ui_node", "ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin/VBox/Portrait/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player") as Node3D
	if rogue_preview_after_right == null or str(rogue_preview_after_right.get_meta("hero_id", "")) != "hero_rogue":
		push_error("Smoke test failed: hero carousel preview did not track the focused rogue.")
		quit(1)
		return
	if str(rogue_preview_after_right.get_meta("model_path", "")) != "res://assets/KayKit_Adventurers_2.0_FREE/KayKit_Adventurers_2.0_FREE/Characters/gltf/Rogue_Hooded.glb":
		push_error("Smoke test failed: rogue preview did not resolve the rogue model path.")
		quit(1)
		return
	if not _assert_weapon_visual(rogue_preview_after_right, "rogue hero select preview"):
		quit(1)
		return
	if home.call("_get_ui_node", "ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/Portrait/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player") != null:
		push_error("Smoke test failed: previous knight card kept a duplicate gameplay preview after focusing rogue.")
		quit(1)
		return
	if home.get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player") != null:
		push_error("Smoke test failed: hidden home hero preview stayed loaded while hero select was open.")
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
	var knight_preview_after_left := home.call("_get_ui_node", "ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/Portrait/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player") as Node3D
	if knight_preview_after_left == null or str(knight_preview_after_left.get_meta("hero_id", "")) != "hero_knight":
		push_error("Smoke test failed: hero carousel preview did not return to the focused knight.")
		quit(1)
		return
	if str(knight_preview_after_left.get_meta("model_path", "")) != "res://assets/KayKit_Adventurers_2.0_FREE/KayKit_Adventurers_2.0_FREE/Characters/gltf/Knight.glb":
		push_error("Smoke test failed: knight preview did not resolve the knight model path.")
		quit(1)
		return
	if not _assert_weapon_visual(knight_preview_after_left, "knight hero select preview"):
		quit(1)
		return
	if home.call("_get_ui_node", "ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin/VBox/Portrait/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player") != null:
		push_error("Smoke test failed: previous rogue card kept a duplicate gameplay preview after focusing knight.")
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
	if not bool(home.get_node("ScreenRoot/MainMenuScreen").visible):
		push_error("Smoke test failed: hero confirm did not return to the home hub.")
		quit(1)
		return
	home.call("_on_hub_pet_pressed")
	await process_frame
	if not bool(home.get_node("ScreenRoot/PetSelectScreen").visible):
		push_error("Smoke test failed: home Pet button did not open pet select.")
		quit(1)
		return
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
	var sprite_preview_after_right := home.call("_get_ui_node", "ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/SpriteCard/Margin/VBox/PortraitLabel/GameplayHeroPreview/PreviewViewport/PreviewWorld/PetCompanion") as Node3D
	if sprite_preview_after_right == null or str(sprite_preview_after_right.get_meta("pet_id", "")) != "pet_sprite":
		push_error("Smoke test failed: pet carousel preview did not track the focused sprite.")
		quit(1)
		return
	if str(sprite_preview_after_right.get_meta("model_path", "")) != "res://scenes/entities/pet_sprite.tscn":
		push_error("Smoke test failed: sprite pet preview did not resolve the sprite model path.")
		quit(1)
		return
	if home.call("_get_ui_node", "ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/DroneCard/Margin/VBox/PortraitLabel/GameplayHeroPreview/PreviewViewport/PreviewWorld/PetCompanion") != null:
		push_error("Smoke test failed: previous drone card kept a duplicate gameplay pet preview after focusing sprite.")
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
	var drone_preview_after_left := home.call("_get_ui_node", "ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/DroneCard/Margin/VBox/PortraitLabel/GameplayHeroPreview/PreviewViewport/PreviewWorld/PetCompanion") as Node3D
	if drone_preview_after_left == null or str(drone_preview_after_left.get_meta("pet_id", "")) != "pet_drone":
		push_error("Smoke test failed: pet carousel preview did not return to the focused drone.")
		quit(1)
		return
	if str(drone_preview_after_left.get_meta("model_path", "")) != "res://scenes/entities/pet_companion.tscn":
		push_error("Smoke test failed: drone pet preview did not resolve the drone model path.")
		quit(1)
		return
	if home.call("_get_ui_node", "ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/SpriteCard/Margin/VBox/PortraitLabel/GameplayHeroPreview/PreviewViewport/PreviewWorld/PetCompanion") != null:
		push_error("Smoke test failed: previous sprite card kept a duplicate gameplay pet preview after focusing drone.")
		quit(1)
		return
	pet_confirm.pressed.emit()
	await process_frame
	if not bool(home.get_node("ScreenRoot/MainMenuScreen").visible):
		push_error("Smoke test failed: pet confirm did not return to the home hub.")
		quit(1)
		return
	if root.get_node_or_null("GameRoot") != null:
		push_error("Smoke test failed: pet confirm started gameplay.")
		quit(1)
		return
	home.call("_show_screen", "EquipmentSelectScreen", false)
	await process_frame
	if not _assert_equipment_layout(home):
		quit(1)
		return
	var helmet_button := home.call("_get_ui_node", "ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/HelmetSlot/Margin/VBox/SlotButton") as Button
	if helmet_button == null:
		push_error("Smoke test failed: helmet gear slot button is missing.")
		quit(1)
		return
	helmet_button.pressed.emit()
	await process_frame
	var gear_change_button := home.call("_get_ui_node", "ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/InventoryButton") as Button
	var gear_detail := home.call("_get_ui_node", "ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard/Margin/LoadoutSummary") as Label
	if home_state.selected_equipment_slot != "helmet" or gear_change_button == null or not gear_change_button.disabled or gear_detail == null or not gear_detail.text.contains("HELMET"):
		push_error("Smoke test failed: locked helmet slot did not select safely with disabled Change.")
		quit(1)
		return
	home.call("_on_equipment_slot_requested", "armor")
	await process_frame
	if home_state.selected_equipment_slot != "armor" or not bool(home.get_node("ScreenRoot/EquipmentSelectScreen").visible):
		push_error("Smoke test failed: equipment slot selection did not stay on gear with armor selected.")
		quit(1)
		return
	if gear_detail == null or not gear_detail.text.contains("ARMOR"):
		push_error("Smoke test failed: equipment slot selection did not update gear detail panel.")
		quit(1)
		return
	if gear_change_button == null or gear_change_button.disabled:
		push_error("Smoke test failed: gear change button is not available for armor.")
		quit(1)
		return
	gear_change_button.pressed.emit()
	await process_frame
	if home_state.selected_equipment_slot != "armor" or not bool(home.get_node("ScreenRoot/InventoryScreen").visible):
		push_error("Smoke test failed: gear Change did not open inventory for armor.")
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
	var armor_button := home.call("_get_ui_node", "ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/ArmorSlot/Margin/VBox/SlotButton") as Button
	if armor_button == null or not armor_button.text.contains("Leather"):
		push_error("Smoke test failed: armor slot visual did not refresh after equipping armor.")
		quit(1)
		return
	if not hub_summary.text.contains("Leather Vest"):
		push_error("Smoke test failed: hub summary did not refresh after equipping armor.")
		quit(1)
		return
	home.call("_go_back")
	await process_frame
	if not bool(home.get_node("ScreenRoot/MainMenuScreen").visible):
		push_error("Smoke test failed: gear Back did not return to the home hub.")
		quit(1)
		return
	var home_preview_after_return := home.get_node_or_null("ScreenRoot/MainMenuScreen/Layout/Root/MainContent/CenterHero/Margin/HeroStage/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player") as Node3D
	if home_preview_after_return == null or str(home_preview_after_return.get_meta("hero_id", "")) != "hero_knight":
		push_error("Smoke test failed: home hero preview was not restored after returning to main menu.")
		quit(1)
		return
	if str(home_preview_after_return.get_meta("model_path", "")) != "res://assets/KayKit_Adventurers_2.0_FREE/KayKit_Adventurers_2.0_FREE/Characters/gltf/Knight.glb":
		push_error("Smoke test failed: home hero preview did not use the selected knight model path.")
		quit(1)
		return
	if not _assert_weapon_visual(home_preview_after_return, "home hero preview after return"):
		quit(1)
		return
	if home.call("_get_ui_node", "ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/Portrait/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player") != null:
		push_error("Smoke test failed: hidden hero select preview stayed loaded after returning home.")
		quit(1)
		return
	home.call("_on_play_pressed")
	await process_frame
	await process_frame
	await process_frame
	var game := root.get_node_or_null("GameRoot")
	if game == null:
		game = current_scene
	if game == null or game.name != "GameRoot":
		push_error("Smoke test failed: Home Start did not load gameplay.")
		quit(1)
		return
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
	var effect_container := game.get_node_or_null("EffectContainer")
	var endless_map := game.get_node_or_null("LevelContainer") as EndlessMap
	var wave_manager := game.get_node_or_null("WaveManager")
	var game_manager := root.get_node_or_null("/root/GameManager") as GameManager
	var save_manager := root.get_node_or_null("/root/SaveManager") as SaveManager
	if projectile_container == null:
		push_error("Smoke test failed: projectile container is missing.")
		quit(1)
		return
	if effect_container == null:
		push_error("Smoke test failed: effect container is missing.")
		quit(1)
		return
	if game_manager == null:
		push_error("Smoke test failed: GameManager autoload is missing.")
		quit(1)
		return
<<<<<<< ours
<<<<<<< ours
	if not _assert_testing_unlocks(game_manager):
=======
=======
	var selected_hero_definition := game_manager.get_selected_hero_definition()
	var expected_player_max_hp := maxi(10 + int(selected_hero_definition.get("max_hp_bonus", 0)), 1)
	if player.max_hp != expected_player_max_hp:
		push_error("Smoke test failed: selected hero max_hp_bonus appears duplicated or missing. expected=%d actual=%d" % [expected_player_max_hp, player.max_hp])
		quit(1)
		return
>>>>>>> theirs
	var hp_probe := Player.new()
	hp_probe.max_hp = 10
	hp_probe.current_hp = 10
	hp_probe.increase_max_hp(4)
	if hp_probe.max_hp != 14 or hp_probe.current_hp != 14:
		push_error("Smoke test failed: knight max_hp_bonus was not applied exactly once.")
		quit(1)
		return
	var mage_probe := Player.new()
	mage_probe.max_hp = 10
	mage_probe.current_hp = 10
	mage_probe.increase_max_hp(-2)
	if mage_probe.max_hp != 8 or mage_probe.current_hp != 8:
		push_error("Smoke test failed: mage negative max_hp_bonus was not applied exactly once.")
		quit(1)
		return
	var low_hp_probe := Player.new()
	low_hp_probe.max_hp = 1
	low_hp_probe.current_hp = 1
	low_hp_probe.increase_max_hp(-4)
	if low_hp_probe.max_hp < 1 or low_hp_probe.current_hp < 0:
		push_error("Smoke test failed: max_hp clamping dropped below safe minimum.")
<<<<<<< ours
>>>>>>> theirs
=======
>>>>>>> theirs
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
	var saved_currency_before := int(save_manager.last_saved_snapshot.get("soft_currency", 0))
	game_manager.add_score(3)
	await process_frame
	if not bool(game_manager.get("_progression_save_dirty")):
		push_error("Smoke test failed: progression reward did not mark a debounced save dirty.")
		quit(1)
		return
	if int(save_manager.last_saved_snapshot.get("soft_currency", 0)) == game_manager.soft_currency and game_manager.soft_currency != saved_currency_before:
		push_error("Smoke test failed: progression reward saved immediately instead of batching.")
		quit(1)
		return
	game_manager.flush_progression_save()
	if int(save_manager.last_saved_snapshot.get("soft_currency", 0)) != game_manager.soft_currency:
		push_error("Smoke test failed: progression flush did not persist the dirty reward state.")
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
	var pet_companion := game.get_node_or_null("PetCompanion") as PetCompanion
	if pet_companion != null:
		if not _assert_visible_model(pet_companion, "gameplay pet companion"):
			quit(1)
			return
		pet_companion.attack_range = 3.0
		pet_companion.global_position = player.global_position
		for enemy in enemy_container.get_children():
			if enemy is Node3D:
				(enemy as Node3D).global_position = player.global_position + Vector3(0.0, 0.0, -12.0)
		if pet_companion.call("_find_nearest_enemy") != null:
			push_error("Smoke test failed: pet companion targeted an enemy outside attack range.")
			quit(1)
			return
		var pet_range_enemy := enemy_container.get_child(0) as Node3D
		pet_range_enemy.global_position = player.global_position + Vector3(0.0, 0.0, -2.0)
		if pet_companion.call("_find_nearest_enemy") == null:
			push_error("Smoke test failed: pet companion did not target an enemy inside attack range.")
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
	if str(player.get_meta("model_path", "")).is_empty():
		push_error("Smoke test failed: gameplay player did not record resolved model_path metadata.")
		quit(1)
		return
	if not _assert_full_hero_model(player, "gameplay player"):
		quit(1)
		return
	if not _assert_gameplay_weapon_safe(player, "gameplay player"):
		quit(1)
		return
	var run_animation_name := str(player.run_animation_name)
	player.call("_play_character_animation", run_animation_name, 1.25)
	var player_running_animation := player_animation.get_animation(run_animation_name)
	if player_running_animation == null or player_running_animation.loop_mode != Animation.LOOP_LINEAR:
		push_error("Smoke test failed: player run animation is not configured to loop.")
		quit(1)
		return

	for enemy in enemy_container.get_children():
		if enemy is Enemy:
			var typed_enemy := enemy as Enemy
			typed_enemy.current_hp = typed_enemy.max_hp
			typed_enemy.global_position = player.global_position + Vector3(0.0, 0.0, -20.0)
	player.weapon_range = 10.0
	var enemy_for_facing := enemy_container.get_child(0) as Enemy
	enemy_for_facing.current_hp = enemy_for_facing.max_hp
	enemy_for_facing.global_position = player.global_position + Vector3.RIGHT * 4.0
	player.call("_face_combat_target_or_movement", Vector3.FORWARD)
	if not is_equal_approx(player.get_node("ShootPoint").rotation.y, -PI * 0.5):
		push_error("Smoke test failed: player did not face the nearest in-range enemy over movement direction.")
		quit(1)
		return
	player.weapon_range = 1.0
	player.call("_face_combat_target_or_movement", Vector3.FORWARD)
	if not is_equal_approx(player.get_node("ShootPoint").rotation.y, 0.0):
		push_error("Smoke test failed: player did not face movement direction when enemies were out of weapon range.")
		quit(1)
		return

	var spread_weapon: Dictionary = game_manager.get_weapon_definition("weapon_spread")
	player.apply_weapon_definition(spread_weapon)
	if str(player.get_meta("weapon_id", "")) != "weapon_spread" or not str(player.get_meta("weapon_model_path", "")).ends_with("/shotgun.glb"):
		push_error("Smoke test failed: applying spread weapon did not update gameplay weapon metadata.")
		quit(1)
		return
	if not _assert_gameplay_weapon_safe(player, "gameplay player after weapon switch"):
		quit(1)
		return
	var first_enemy_for_weapon := enemy_container.get_child(0) as Node3D
	first_enemy_for_weapon.global_position = player.global_position + Vector3(0.0, 0.0, -5.0)
	var projectile_count_before := projectile_container.get_child_count()
	var effect_count_before_fire := effect_container.get_child_count()
	player.spawn_projectile()
	if effect_container.get_child_count() <= effect_count_before_fire:
		push_error("Smoke test failed: player shot did not spawn a muzzle/effect node.")
		quit(1)
		return
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
	var recycled_projectile := first_projectile
	recycled_projectile.recycle()
	await process_frame
	if projectile_container.get_children().has(recycled_projectile):
		push_error("Smoke test failed: recycled projectile stayed in the active projectile container.")
		quit(1)
		return
	player.projectile_count = 1
	player.spawn_projectile()
	await process_frame
	if not projectile_container.get_children().has(recycled_projectile):
		push_error("Smoke test failed: player did not reuse a pooled projectile.")
		quit(1)
		return
	player.apply_weapon_definition(spread_weapon)

	for child in projectile_container.get_children():
		child.queue_free()
	await process_frame
	await process_frame
	player.weapon_range = 1.0
	for enemy in enemy_container.get_children():
		if enemy is Enemy:
			var typed_enemy := enemy as Enemy
			typed_enemy.current_hp = typed_enemy.max_hp
			typed_enemy.global_position = player.global_position + Vector3(0.0, 0.0, -12.0)
	var projectile_count_before_range_check := projectile_container.get_child_count()
	player.spawn_projectile()
	await process_frame
	if projectile_container.get_child_count() > projectile_count_before_range_check:
		push_error("Smoke test failed: weapon range did not prevent out-of-range firing.")
		quit(1)
		return
	player.apply_weapon_definition(spread_weapon)

	var skill_enemy := enemy_container.get_child(0) as Enemy
	for enemy in enemy_container.get_children():
		if enemy is Enemy:
			var typed_enemy := enemy as Enemy
			typed_enemy.global_position = player.global_position + Vector3(0.0, 0.0, -14.0)
			typed_enemy.current_hp = typed_enemy.max_hp
	skill_enemy.global_position = player.global_position + Vector3(0.0, 0.0, -2.0)
	skill_enemy.current_hp = skill_enemy.max_hp
	player.explosion_skill_damage = 1
	player.projectile_damage = 1
	player.set("_skill_primary_timer", 0.0)
	var skill_hp_before := skill_enemy.current_hp
	if not player.activate_explosion_skill():
		push_error("Smoke test failed: explosion skill did not activate.")
		quit(1)
		return
	await process_frame
	if skill_enemy.current_hp >= skill_hp_before:
		push_error("Smoke test failed: explosion skill did not damage a nearby enemy.")
		quit(1)
		return

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
		var original_wave := int(wave_manager.get("current_wave"))
		wave_manager.set("current_wave", 5)
		var early_boss_multiplier := float(wave_manager.call("_get_boss_health_multiplier"))
		wave_manager.set("current_wave", 10)
		var later_boss_multiplier := float(wave_manager.call("_get_boss_health_multiplier"))
		wave_manager.set("current_wave", original_wave)
		if later_boss_multiplier <= early_boss_multiplier:
			push_error("Smoke test failed: later boss wave HP multiplier did not increase.")
			quit(1)
			return
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

func _assert_full_hero_model(root_node: Node, context: String) -> bool:
	var parts := {
		"has_body": false,
		"has_head": false,
		"visible_mesh_count": 0,
		"mesh_names": [],
	}
	_collect_full_hero_parts(root_node, parts)
	var mesh_names: Array = parts["mesh_names"]
	if int(parts["visible_mesh_count"]) == 0:
		push_error("Smoke test failed: %s has no visible mesh nodes." % context)
		return false
	if not bool(parts["has_body"]):
		push_error("Smoke test failed: %s is missing a visible body mesh. Visible meshes: %s" % [context, ", ".join(mesh_names)])
		return false
	if not bool(parts["has_head"]):
		push_error("Smoke test failed: %s is missing a visible human head mesh. Visible meshes: %s" % [context, ", ".join(mesh_names)])
		return false
	return true

func _assert_visible_model(root_node: Node, context: String) -> bool:
	var parts := {
		"has_body": false,
		"has_head": false,
		"visible_mesh_count": 0,
		"mesh_names": [],
	}
	_collect_full_hero_parts(root_node, parts)
	if int(parts["visible_mesh_count"]) == 0:
		push_error("Smoke test failed: %s has no visible mesh nodes." % context)
		return false
	return true

func _assert_weapon_visual(player_node: Node, context: String) -> bool:
	var weapon_id := str(player_node.get_meta("weapon_id", ""))
	var weapon_model_path := str(player_node.get_meta("weapon_model_path", ""))
	if weapon_id.is_empty():
		push_error("Smoke test failed: %s did not record weapon_id metadata." % context)
		return false
	if weapon_model_path.is_empty():
		push_error("Smoke test failed: %s did not record weapon_model_path metadata." % context)
		return false
	var weapon_count := _count_weapon_visuals(player_node)
	if weapon_count != 1:
		push_error("Smoke test failed: %s has %d attached weapon visuals." % [context, weapon_count])
		return false
	var weapon_node := _find_weapon_visual(player_node)
	if weapon_node == null:
		push_error("Smoke test failed: %s weapon visual could not be found." % context)
		return false
	if str(weapon_node.get_meta("weapon_id", "")) != weapon_id:
		push_error("Smoke test failed: %s weapon visual metadata does not match selected weapon." % context)
		return false
	if weapon_node.name != "EquippedWeaponPreview":
		push_error("Smoke test failed: %s weapon visual is not named EquippedWeaponPreview." % context)
		return false
	if str(weapon_node.get_meta("weapon_model_path", weapon_node.get_meta("model_path", ""))) != weapon_model_path:
		push_error("Smoke test failed: %s weapon visual model path does not match player metadata." % context)
		return false
	if str(weapon_node.get_meta("attached_socket_path", "")).is_empty():
		push_error("Smoke test failed: %s weapon visual did not record attached_socket_path metadata." % context)
		return false
	if not _assert_visible_model(weapon_node, "%s weapon visual" % context):
		return false
	return true

func _assert_gameplay_weapon_safe(player_node: Node, context: String) -> bool:
	var weapon_id := str(player_node.get_meta("weapon_id", ""))
	var weapon_model_path := str(player_node.get_meta("weapon_model_path", ""))
	if weapon_id.is_empty():
		push_error("Smoke test failed: %s did not record weapon_id metadata." % context)
		return false
	if weapon_model_path.is_empty():
		push_error("Smoke test failed: %s did not record weapon_model_path metadata." % context)
		return false
	var weapon_node := _find_weapon_visual(player_node)
	if weapon_node == null:
		push_warning("Smoke test warning: %s has no weapon visual, but gameplay remains valid with weapon metadata." % context)
		return true
	return _assert_weapon_visual(player_node, context)

func _assert_testing_unlocks(game_manager: GameManager) -> bool:
	var levels: Array = game_manager.get("_levels")
	if not levels.is_empty() and game_manager.highest_unlocked_level < levels.size():
		push_error("Smoke test failed: testing unlocks did not unlock every level.")
		return false
	for hero_id in game_manager.get_hero_ids():
		if not game_manager.is_hero_unlocked(str(hero_id)):
			push_error("Smoke test failed: testing unlocks did not unlock hero %s." % str(hero_id))
			return false
	for weapon_id in game_manager.get_weapon_ids():
		if not game_manager.is_weapon_unlocked(str(weapon_id)):
			push_error("Smoke test failed: testing unlocks did not unlock weapon %s." % str(weapon_id))
			return false
	for pet_id in game_manager.get_pet_ids():
		if not game_manager.is_pet_unlocked(str(pet_id)):
			push_error("Smoke test failed: testing unlocks did not unlock pet %s." % str(pet_id))
			return false
	return true

func _collect_full_hero_parts(node: Node, parts: Dictionary) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		if mesh_instance.is_visible_in_tree() and mesh_instance.mesh != null:
			parts["visible_mesh_count"] = int(parts["visible_mesh_count"]) + 1
			var mesh_name := mesh_instance.name.to_lower()
			var mesh_names: Array = parts["mesh_names"]
			mesh_names.append(mesh_instance.name)
			if mesh_name.contains("body"):
				parts["has_body"] = true
			if mesh_name.contains("head"):
				parts["has_head"] = true
	for child in node.get_children():
		_collect_full_hero_parts(child, parts)

func _find_weapon_visual(root_node: Node) -> Node3D:
	if root_node is Node3D and (root_node.name == "EquippedWeaponPreview" or root_node.name == "EquippedWeapon" or str(root_node.get_meta("model_kind", "")) == "weapon"):
		return root_node as Node3D
	for child in root_node.get_children():
		var found := _find_weapon_visual(child)
		if found != null:
			return found
	return null

func _count_weapon_visuals(root_node: Node) -> int:
	var count := 0
	if root_node is Node3D and (root_node.name == "EquippedWeaponPreview" or root_node.name == "EquippedWeapon" or str(root_node.get_meta("model_kind", "")) == "weapon"):
		count += 1
	for child in root_node.get_children():
		count += _count_weapon_visuals(child)
	return count

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
	if not _assert_full_hero_model(home_preview_player, "home hero preview"):
		return false
	if not _assert_weapon_visual(home_preview_player, "home hero preview"):
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
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard",
		"ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard",
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
	var home_state: Variant = home.get("_home_state")
	var selected_hero_id := "hero_knight"
	if home_state != null:
		selected_hero_id = str(home_state.selected_hero_id)
	var hero_preview_paths := {
		"hero_knight": "ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/KnightCard/Margin/VBox/Portrait/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player",
		"hero_rogue": "ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/RogueCard/Margin/VBox/Portrait/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player",
		"hero_mage": "ScreenRoot/HeroSelectScreen/Layout/Root/Content/HeroCards/MageCard/Margin/VBox/Portrait/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player",
	}
	var selected_preview_player := home.call("_get_ui_node", str(hero_preview_paths.get(selected_hero_id, hero_preview_paths["hero_knight"]))) as Node3D
	if selected_preview_player == null:
		push_error("Smoke test failed: selected hero card did not spawn the gameplay player scene.")
		return false
	if str(selected_preview_player.get_meta("hero_id", "")) != selected_hero_id:
		push_error("Smoke test failed: selected hero preview metadata does not match focused hero.")
		return false
	if str(selected_preview_player.get_meta("source_scene_path", "")) != "res://scenes/player/player.tscn":
		push_error("Smoke test failed: hero select preview is not sourced from the gameplay player scene.")
		return false
	if str(selected_preview_player.get_meta("model_path", "")).is_empty():
		push_error("Smoke test failed: hero select preview did not record resolved model_path metadata.")
		return false
	if not _assert_full_hero_model(selected_preview_player, "hero select preview"):
		return false
	if not _assert_weapon_visual(selected_preview_player, "hero select preview"):
		return false
	if selected_preview_player.scale.x > 0.7 or abs(selected_preview_player.rotation_degrees.y) > 0.5:
		push_error("Smoke test failed: hero select preview is not using the compact front-facing transform.")
		return false
	var selected_preview_animation := selected_preview_player.get_node_or_null("VisualRoot/HeroModel/KayKitAnimationPlayer") as AnimationPlayer
	if selected_preview_animation == null or not selected_preview_animation.is_playing():
		push_error("Smoke test failed: selected hero preview animation is not running.")
		return false
	for hero_id in hero_preview_paths.keys():
		if str(hero_id) == selected_hero_id:
			continue
		if home.call("_get_ui_node", str(hero_preview_paths[hero_id])) != null:
			push_error("Smoke test failed: non-centered %s card spawned a duplicate gameplay preview." % hero_id)
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
	var home_state: Variant = home.get("_home_state")
	var selected_pet_id := "pet_drone"
	if home_state != null:
		selected_pet_id = str(home_state.selected_pet_id)
	var pet_preview_paths := {
		"pet_drone": "ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/DroneCard/Margin/VBox/PortraitLabel/GameplayHeroPreview/PreviewViewport/PreviewWorld/PetCompanion",
		"pet_sprite": "ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/SpriteCard/Margin/VBox/PortraitLabel/GameplayHeroPreview/PreviewViewport/PreviewWorld/PetCompanion",
		"pet_wisp": "ScreenRoot/PetSelectScreen/Layout/Root/Content/PetCards/WispCard/Margin/VBox/PortraitLabel/GameplayHeroPreview/PreviewViewport/PreviewWorld/PetCompanion",
	}
	var selected_pet_preview := home.call("_get_ui_node", str(pet_preview_paths.get(selected_pet_id, pet_preview_paths["pet_drone"]))) as Node3D
	if selected_pet_preview == null:
		push_error("Smoke test failed: selected pet card did not spawn the gameplay pet scene.")
		return false
	if str(selected_pet_preview.get_meta("model_path", "")).is_empty():
		push_error("Smoke test failed: pet select preview did not record resolved model_path metadata.")
		return false
	if not _assert_visible_model(selected_pet_preview, "pet select preview"):
		return false
	return true

func _assert_equipment_layout(home: Node) -> bool:
	var viewport_size := home.get_viewport().get_visible_rect().size
	var required_paths := [
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Header",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Header/BackButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Header/Title",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/WeaponSlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/ArmorSlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/HelmetSlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/LeftColumn/BootsSlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/CharacterPanel/GameplayHeroPreview",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/PetSlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/AccessorySlot/Margin/VBox/SlotButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/LoadoutCard",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/InventoryButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/UnequipButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/RightColumn/UpgradeButton",
		"ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/CategoryBar",
	]
	for path in required_paths:
		var control := home.call("_get_ui_node", path) as Control
		if control == null:
			push_error("Smoke test failed: required equipment node is missing: %s" % path)
			return false
		if not control.is_visible_in_tree():
			push_error("Smoke test failed: required equipment node is hidden: %s" % path)
			return false
		var rect := control.get_global_rect()
		if rect.size.x <= 0.0 or rect.size.y <= 0.0:
			push_error("Smoke test failed: required equipment node has no layout size: %s" % path)
			return false
		if rect.position.y < -0.5 or rect.end.y > viewport_size.y + 0.5:
			push_error("Smoke test failed: required equipment node is clipped vertically: %s" % path)
			return false
		if rect.position.x < -0.5 or rect.end.x > viewport_size.x + 0.5:
			push_error("Smoke test failed: required equipment node is clipped horizontally: %s" % path)
			return false
	var columns := home.call("_get_ui_node", "ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns") as GridContainer
	var character_panel := home.call("_get_ui_node", "ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/CharacterPanel") as Control
	if columns == null or columns.columns != 3:
		push_error("Smoke test failed: equipment screen is not using a three-column landscape layout.")
		return false
	if character_panel == null or character_panel.get_index() != 1:
		push_error("Smoke test failed: equipment hero is not centered between gear columns.")
		return false
	var preview_player := home.call("_get_ui_node", "ScreenRoot/EquipmentSelectScreen/Layout/Root/Content/Columns/CharacterPanel/GameplayHeroPreview/PreviewViewport/PreviewWorld/Player") as Node3D
	if preview_player == null:
		push_error("Smoke test failed: equipment hero preview did not spawn gameplay player.")
		return false
	if str(preview_player.get_meta("source_scene_path", "")) != "res://scenes/player/player.tscn":
		push_error("Smoke test failed: equipment hero preview is not sourced from gameplay player scene.")
		return false
	if str(preview_player.get_meta("model_path", "")).is_empty():
		push_error("Smoke test failed: equipment hero preview did not record resolved model_path metadata.")
		return false
	if not _assert_full_hero_model(preview_player, "equipment hero preview"):
		return false
	if not _assert_weapon_visual(preview_player, "equipment hero preview"):
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
