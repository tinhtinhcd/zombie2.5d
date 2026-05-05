extends Area3D
class_name BuffPickup

@export var buff_type: String = "damage"
@export var multiplier: float = 1.25
@export var duration: float = 6.0
@export var lifetime: float = 10.0

var _life_timer: float = 0.0
var _collected: bool = false
var audio_manager: AudioManager

func _ready() -> void:
	audio_manager = get_node_or_null("/root/AudioManager") as AudioManager
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	_life_timer += delta
	if _life_timer >= lifetime:
		queue_free()

func _on_body_entered(body: Node) -> void:
	if _collected or body is not Player:
		return
	_collected = true
	_apply_buff(body as Player)
	if audio_manager != null:
		audio_manager.play_sfx_event(&"pickup_reward")
	queue_free()

func _apply_buff(player: Player) -> void:
	match buff_type:
		"move_speed":
			var original_speed := player.move_speed
			player.move_speed = original_speed * maxf(multiplier, 0.1)
			_restore_later(player, "move_speed", original_speed)
		"fire_rate":
			var original_interval := player.fire_interval
			player.fire_interval = maxf(original_interval / maxf(multiplier, 0.1), 0.12)
			_restore_later(player, "fire_interval", original_interval)
		_:
			var original_damage_multiplier := player.support_damage_multiplier
			player.support_damage_multiplier = maxf(original_damage_multiplier, multiplier)
			_restore_later(player, "support_damage_multiplier", original_damage_multiplier)

func _restore_later(player: Player, property_name: String, value: float) -> void:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = maxf(duration, 0.05)
	player.add_child(timer)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(player):
			player.set(property_name, value)
		timer.queue_free()
	)
	timer.start()
