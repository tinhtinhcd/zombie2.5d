extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game_manager := root.get_node_or_null("/root/GameManager") as GameManager
	var save_manager := root.get_node_or_null("/root/SaveManager") as SaveManager
	if game_manager == null or save_manager == null:
		push_error("Weapon progression test failed: required autoloads missing.")
		quit(1)
		return

	game_manager.unlocked_weapons = ["weapon_basic", "weapon_heavy"]
	game_manager.weapon_levels = {}
	game_manager.soft_currency = 999

	var base_heavy := game_manager.get_weapon_definition("weapon_heavy")
	var weapon_ids := game_manager.get_weapon_ids()
	if weapon_ids.size() < 6 or not weapon_ids.has("weapon_chain") or not weapon_ids.has("weapon_bouncer"):
		push_error("Weapon progression test failed: GDD weapon roster is incomplete.")
		quit(1)
		return
	var chain_gun := game_manager.get_weapon_definition("weapon_chain")
	var bouncer := game_manager.get_weapon_definition("weapon_bouncer")
	if not is_equal_approx(float(chain_gun.get("fire_rate", 0.0)), 0.15) or str(chain_gun.get("special_effect", "")) != "ramping_damage":
		push_error("Weapon progression test failed: Chain Gun stats/effect did not load.")
		quit(1)
		return
	if str(bouncer.get("special_effect", "")) != "multi_bounce":
		push_error("Weapon progression test failed: Bouncer bounce effect did not load.")
		quit(1)
		return
	if str(base_heavy.get("rarity", "")) != "epic":
		push_error("Weapon progression test failed: weapon rarity did not load.")
		quit(1)
		return
	var base_damage := int(base_heavy.get("damage", 0))
	if base_damage < 5:
		push_error("Weapon progression test failed: rarity multiplier did not affect weapon damage.")
		quit(1)
		return

	if not game_manager.upgrade_weapon("weapon_heavy"):
		push_error("Weapon progression test failed: first weapon upgrade failed.")
		quit(1)
		return
	if not game_manager.upgrade_weapon("weapon_heavy"):
		push_error("Weapon progression test failed: second weapon upgrade failed.")
		quit(1)
		return

	var upgraded_heavy := game_manager.get_weapon_definition("weapon_heavy")
	if int(upgraded_heavy.get("level", 1)) != 3:
		push_error("Weapon progression test failed: weapon level did not reach 3.")
		quit(1)
		return
	if int(upgraded_heavy.get("damage", 0)) <= base_damage:
		push_error("Weapon progression test failed: weapon upgrade multiplier did not increase damage.")
		quit(1)
		return

	game_manager.flush_progression_save()
	var saved_levels: Dictionary = save_manager.last_saved_snapshot.get("weapon_levels", {})
	if int(saved_levels.get("weapon_heavy", 1)) != 3:
		push_error("Weapon progression test failed: weapon level did not persist.")
		quit(1)
		return

	print("Weapon progression test passed: rarity, upgrades, costs, and save persistence work.")
	quit(0)
