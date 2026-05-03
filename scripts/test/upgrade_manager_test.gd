extends SceneTree

const GAME_SCENE := preload("res://scenes/core/game.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var game_manager := root.get_node_or_null("/root/GameManager") as GameManager
	if game_manager == null:
		push_error("UpgradeManager test failed: GameManager missing.")
		quit(1)
		return

	game_manager.reset_game()
	var options: Array = game_manager.call("_get_upgrade_options")
	if options.size() != 3:
		push_error("UpgradeManager test failed: did not roll three options.")
		quit(1)
		return
	var seen := {}
	for option in options:
		if typeof(option) != TYPE_DICTIONARY:
			push_error("UpgradeManager test failed: option is not a dictionary.")
			quit(1)
			return
		var id := str((option as Dictionary).get("id", ""))
		if id.is_empty() or seen.has(id):
			push_error("UpgradeManager test failed: options are missing ids or not distinct.")
			quit(1)
			return
		seen[id] = true

	var game := GAME_SCENE.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	var player := game.get_node_or_null("Player") as Player
	if player == null:
		push_error("UpgradeManager test failed: player missing.")
		quit(1)
		return
	var damage_before := player.projectile_damage
	game_manager.begin_upgrade_selection()
	game_manager.select_upgrade(player, &"projectile_damage")
	if player.projectile_damage <= damage_before:
		push_error("UpgradeManager test failed: damage upgrade did not apply.")
		quit(1)
		return
	if game_manager.is_upgrade_selection_active:
		push_error("UpgradeManager test failed: upgrade selection did not close after pick.")
		quit(1)
		return

	print("UpgradeManager test passed: weighted roll, distinct options, apply, and close flow work.")
	quit(0)
