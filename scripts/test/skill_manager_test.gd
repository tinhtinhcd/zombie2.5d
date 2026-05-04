extends SceneTree

const GAME_SCENE := preload("res://scenes/core/game.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game_manager := root.get_node_or_null("/root/GameManager") as GameManager
	if game_manager == null:
		push_error("SkillManager test failed: GameManager autoload missing.")
		quit(1)
		return

	if not await _run_hero_case(game_manager, "hero_knight", "skill_knight_war_cry"):
		quit(1)
		return
	if not await _run_hero_case(game_manager, "hero_rogue", "skill_rogue_smoke_bomb"):
		quit(1)
		return
	if not await _run_hero_case(game_manager, "hero_mage", "skill_mage_frost_nova"):
		quit(1)
		return
	if not await _run_hero_case(game_manager, "hero_engineer", "skill_engineer_overclock"):
		quit(1)
		return
	if not await _run_hero_case(game_manager, "hero_engineer", "skill_engineer_deploy_sentry"):
		quit(1)
		return
	if not await _run_hero_case(game_manager, "hero_engineer", "skill_engineer_turbo_boost"):
		quit(1)
		return
	if not await _run_hero_case(game_manager, "hero_medic", "skill_medic_healing_pulse"):
		quit(1)
		return
	if not await _run_hero_case(game_manager, "hero_medic", "skill_medic_sonic_burst"):
		quit(1)
		return

	print("SkillManager test passed: hero skills load, passives apply, and active cooldowns trigger.")
	quit(0)

func _run_hero_case(game_manager: GameManager, hero_id: String, active_skill_id: String) -> bool:
	game_manager.unlocked_heroes = ["hero_knight", "hero_rogue", "hero_mage", "hero_engineer", "hero_medic"]
	game_manager.unlocked_weapons = ["weapon_basic"]
	game_manager.unlocked_pets = ["pet_drone"]
	game_manager.selected_hero_id = hero_id
	game_manager.selected_weapon_id = "weapon_basic"
	game_manager.selected_pet_id = "pet_drone"

	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	var player := game.get_node_or_null("Player") as Player
	if player == null:
		push_error("SkillManager test failed: player missing for %s." % hero_id)
		game.queue_free()
		await process_frame
		return false

	var skill_manager := player.get_node_or_null("SkillManager")
	if skill_manager == null:
		push_error("SkillManager test failed: SkillManager missing for %s." % hero_id)
		game.queue_free()
		await process_frame
		return false
	if skill_manager.active_skills.size() < 2:
		push_error("SkillManager test failed: active skills missing for %s." % hero_id)
		game.queue_free()
		await process_frame
		return false

	if hero_id == "hero_knight":
		player.current_hp = 10
		player.max_hp = 10
		player.set("_damage_cooldown_timer", 0.0)
		player.take_damage(2)
		if player.current_hp != 9:
			push_error("SkillManager test failed: Knight Iron Skin did not reduce damage.")
			game.queue_free()
			await process_frame
			return false
	if hero_id == "hero_mage" and int(skill_manager.call("get_modified_projectile_damage", 10)) < 11:
		push_error("SkillManager test failed: Mage Arcane Amplify did not increase projectile damage.")
		game.queue_free()
		await process_frame
		return false
	if hero_id == "hero_engineer" and float(skill_manager.deployable_damage_multiplier) < 1.1:
		push_error("SkillManager test failed: Engineer Field Turret passive did not apply.")
		game.queue_free()
		await process_frame
		return false
	if hero_id == "hero_medic":
		player.current_hp = 5
		player.max_hp = 10

	if not bool(skill_manager.call("try_use_skill", active_skill_id)):
		push_error("SkillManager test failed: active skill %s did not trigger." % active_skill_id)
		game.queue_free()
		await process_frame
		return false
	if float(skill_manager.cooldowns.get(active_skill_id, 0.0)) <= 0.0:
		push_error("SkillManager test failed: active skill %s did not start cooldown." % active_skill_id)
		game.queue_free()
		await process_frame
		return false
	if active_skill_id == "skill_medic_healing_pulse" and player.current_hp < 9:
		push_error("SkillManager test failed: Medic Healing Pulse did not apply healing multiplier.")
		game.queue_free()
		await process_frame
		return false

	game.queue_free()
	await process_frame
	return true
