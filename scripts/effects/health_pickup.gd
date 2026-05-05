extends Area3D
class_name HealthPickup

const FLOATING_TEXT := preload("res://scripts/effects/floating_text.gd")

@export var heal_amount: int = 2
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
	(body as Player).restore_hp(heal_amount)
	FLOATING_TEXT.spawn(get_parent(), global_position, "+HP", Color(0.22, 0.85, 0.59, 1.0))
	if audio_manager != null:
		audio_manager.play_sfx_event(&"pickup_reward")
	queue_free()
