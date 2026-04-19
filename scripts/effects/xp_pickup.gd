extends Area3D
class_name XPPickup

# Minimal experience pickup.
# Additional pickup types can follow the same collection pattern later.

@export var xp_amount: int = 1
@export var lifetime: float = 8.0

var _life_timer: float = 0.0
var _collected: bool = false

func _ready() -> void:
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
    queue_free()
