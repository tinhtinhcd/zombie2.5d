extends Control

@onready var start_button: Button = $StartButton
@onready var unlock_hp_button: Button = $UnlockHPButton
@onready var unlock_fire_rate_button: Button = $UnlockFireRateButton
@onready var unlock_damage_button: Button = $UnlockDamageButton
@onready var permanent_upgrade_label: Label = $PermanentUpgradeLabel
@onready var game_manager: GameManager = get_node("/root/GameManager") as GameManager
@onready var scene_router: SceneRouter = get_node("/root/SceneRouter") as SceneRouter

func _ready() -> void:
    start_button.pressed.connect(_on_start_pressed)
    unlock_hp_button.pressed.connect(func() -> void: _unlock_upgrade(&"perm_max_hp"))
    unlock_fire_rate_button.pressed.connect(func() -> void: _unlock_upgrade(&"perm_fire_rate"))
    unlock_damage_button.pressed.connect(func() -> void: _unlock_upgrade(&"perm_projectile_damage"))
    game_manager.permanent_upgrades_changed.connect(_update_permanent_upgrade_label)
    game_manager.highest_unlocked_level_changed.connect(_on_highest_unlocked_level_changed)
    _update_permanent_upgrade_label(game_manager.permanent_upgrades)

func _on_start_pressed() -> void:
    scene_router.go_to_game()

func _unlock_upgrade(upgrade_id: StringName) -> void:
    game_manager.unlock_permanent_upgrade(upgrade_id)

func _update_permanent_upgrade_label(_upgrades: Dictionary) -> void:
    permanent_upgrade_label.text = "Permanent\nHP %d  Rate %d  Dmg %d\nUnlocked Lv %d" % [
        game_manager.get_permanent_upgrade_rank(&"perm_max_hp"),
        game_manager.get_permanent_upgrade_rank(&"perm_fire_rate"),
        game_manager.get_permanent_upgrade_rank(&"perm_projectile_damage"),
        game_manager.highest_unlocked_level,
    ]

func _on_highest_unlocked_level_changed(_highest_unlocked_level: int) -> void:
    _update_permanent_upgrade_label(game_manager.permanent_upgrades)
