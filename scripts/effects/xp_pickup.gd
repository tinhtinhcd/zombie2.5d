extends Area3D
class_name XPPickup

# Minimal experience pickup.
# Additional pickup types can follow the same collection pattern later.

@export var xp_amount: int = 1
@export var lifetime: float = 8.0

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
	if _collected:
		return
	if body is not Player:
		return

	_collected = true
	body.receive_experience(xp_amount)
	if audio_manager != null:
		audio_manager.play_sfx_event(&"pickup_reward")
	queue_free()
