extends SceneTree

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const SHOP_SCENE := preload("res://scenes/ui/shop.tscn")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(390, 844)
	var game_manager := root.get_node_or_null("/root/GameManager") as GameManager
	if game_manager == null:
		push_error("UI redesign test failed: GameManager missing.")
		quit(1)
		return

	var hud := HUD_SCENE.instantiate() as HUD
	root.add_child(hud)
	await process_frame
	if hud.get_node_or_null("HUDRoot/MobileSciFiHUD") == null:
		push_error("UI redesign test failed: mobile HUD layer missing.")
		quit(1)
		return
	if hud.get_node_or_null("HUDRoot/MobileSciFiHUD/BottomControls/JoystickZone") == null:
		push_error("UI redesign test failed: joystick zone missing.")
		quit(1)
		return
	if hud.get_node_or_null("HUDRoot/MobileSciFiHUD/BottomControls/ActionCluster") == null:
		push_error("UI redesign test failed: action cluster missing.")
		quit(1)
		return
	var fire_button := hud.get_node_or_null("HUDRoot/MobileSciFiHUD/BottomControls/ActionCluster/FireButton") as Button
	if fire_button == null or fire_button.custom_minimum_size.y < 64.0:
		push_error("UI redesign test failed: mobile fire button is below touch target size.")
		quit(1)
		return
	hud.set_active_guard("guard_shooter", "Shooter Guard")
	hud.set_guard_hp(3, 6)
	var guard_card := hud.get_node_or_null("HUDRoot/MobileSciFiHUD/BottomControls/GuardMiniCard") as Control
	if guard_card == null or not guard_card.visible:
		push_error("UI redesign test failed: guard mini-card did not become visible.")
		quit(1)
		return
	hud.call("_on_boss_telegraph_started", "slam", 0.5)
	var telegraph := hud.get_node_or_null("HUDRoot/MobileSciFiHUD/BossTelegraph") as Control
	if telegraph == null or not telegraph.visible:
		push_error("UI redesign test failed: boss telegraph panel did not show.")
		quit(1)
		return

	var shop := SHOP_SCENE.instantiate() as ShopUI
	root.add_child(shop)
	shop.setup(game_manager)
	shop.open()
	await process_frame
	if shop.get_node_or_null("Margin/Body") == null:
		push_error("UI redesign test failed: shop body missing.")
		quit(1)
		return
	for tab_text in ["HERO", "GUARDS", "PERMANENT"]:
		if not _has_button_with_text(shop, tab_text):
			push_error("UI redesign test failed: shop tab missing: %s" % tab_text)
			quit(1)
			return

	print("UI redesign test passed: mobile HUD, guard card, telegraph, and shop tabs exist.")
	quit(0)

func _has_button_with_text(root_node: Node, text: String) -> bool:
	for child in root_node.get_children():
		if child is Button and (child as Button).text == text:
			return true
		if _has_button_with_text(child, text):
			return true
	return false
