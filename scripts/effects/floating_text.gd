extends RefCounted
class_name FloatingText

static func spawn(parent: Node, origin: Vector3, text: String, color: Color) -> void:
	if parent == null:
		return
	var label := Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = color
	label.font_size = 24
	parent.add_child(label)
	label.global_position = origin + Vector3(0.0, 0.9, 0.0)
	var tween := label.create_tween()
	tween.tween_property(label, "global_position", label.global_position + Vector3(0.0, 0.8, 0.0), 0.55)
	tween.parallel().tween_property(label, "modulate", Color(color.r, color.g, color.b, 0.0), 0.55)
	tween.tween_callback(label.queue_free)
