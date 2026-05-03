extends SceneTree

const GAME_SCENE := preload("res://scenes/core/game.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game_manager := root.get_node_or_null("/root/GameManager") as GameManager
	var save_manager := root.get_node_or_null("/root/SaveManager") as SaveManager
	if game_manager == null or save_manager == null:
		push_error("Pet buff test failed: required autoloads missing.")
		quit(1)
		return

	game_manager.unlocked_pets = ["pet_drone", "pet_sprite", "pet_wisp"]
	game_manager.pet_evolution_stages = {}
	game_manager.pet_evolution_shards = 100
	game_manager.pet_accessories = {"pet_drone": "pet_charm_damage"}
	game_manager.selected_pet_id = "pet_drone"

	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	var player := game.get_node_or_null("Player") as Player
	var pet := game.get_node_or_null("PetCompanion") as PetCompanion
	if player == null or pet == null:
		push_error("Pet buff test failed: player or pet missing.")
		quit(1)
		return
	if pet.get_node_or_null("BuffProvider") == null:
		push_error("Pet buff test failed: BuffProvider missing.")
		quit(1)
		return
	if float(player.support_damage_multiplier) <= 1.0:
		push_error("Pet buff test failed: drone damage buff did not apply to player.")
		quit(1)
		return
	if not game_manager.evolve_pet("pet_drone"):
		push_error("Pet buff test failed: pet evolution did not consume shards.")
		quit(1)
		return
	game_manager.flush_progression_save()
	var saved_stages: Dictionary = save_manager.last_saved_snapshot.get("pet_evolution_stages", {})
	if int(saved_stages.get("pet_drone", 1)) != 2:
		push_error("Pet buff test failed: evolved pet stage did not persist.")
		quit(1)
		return

	print("Pet buff test passed: BuffProvider, accessory bonus, evolution, and save persistence work.")
	quit(0)
