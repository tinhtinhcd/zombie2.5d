extends Area3D
class_name Projectile

# Minimal projectile scaffold.
# Add damage, collision responses, and ownership rules here later.

@export var speed: float = 14.0
@export var lifetime: float = 1.5
@export var damage: int = 1

var direction: Vector3 = Vector3.FORWARD
var _time_alive: float = 0.0
var _has_hit: bool = false

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func setup(move_direction: Vector3) -> void:
    if move_direction.is_zero_approx():
        direction = Vector3.FORWARD
        return
    direction = move_direction.normalized()

func _physics_process(delta: float) -> void:
    global_position += direction * speed * delta

    _time_alive += delta
    if _time_alive >= lifetime:
        queue_free()

func _on_body_entered(body: Node) -> void:
    if _has_hit:
        return
    if body is not Enemy:
        return

    _has_hit = true
    body.take_damage(damage)
    queue_free()
