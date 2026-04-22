extends RefCounted
class_name InventoryPanel

var _description_label: Label
var _game_manager: GameManager

func setup(description_label: Label, game_manager: GameManager) -> void:
	_description_label = description_label
	_game_manager = game_manager

func refresh(_inventory: Dictionary = {}) -> void:
	if _description_label == null or _game_manager == null:
		return

	var scrap_count := int(_game_manager.inventory.get("scrap", 0))
	_description_label.text = "Coins: %d\nScrap: %d\nEnemies can drop scrap during runs. Equipment depth stays intentionally light." % [
		_game_manager.soft_currency,
		scrap_count,
	]
