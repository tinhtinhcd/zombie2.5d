extends RefCounted
class_name HomeUIStyle

const COLOR_TEXT := Color(0.94, 0.95, 0.9, 1.0)
const COLOR_MUTED := Color(0.68, 0.73, 0.68, 1.0)
const COLOR_PANEL := Color(0.08, 0.095, 0.085, 0.88)
const COLOR_PANEL_ALT := Color(0.12, 0.14, 0.12, 0.92)
const COLOR_BORDER := Color(0.36, 0.42, 0.32, 0.9)
const COLOR_SELECTED := Color(0.93, 0.76, 0.34, 1.0)
const COLOR_SELECTED_DARK := Color(0.22, 0.17, 0.08, 1.0)
const COLOR_GREEN := Color(0.48, 0.72, 0.36, 1.0)
const COLOR_LOCKED := Color(0.27, 0.29, 0.28, 1.0)
const COLOR_LOCKED_BORDER := Color(0.43, 0.45, 0.43, 0.8)

static func apply_tree(root: Node) -> void:
	if root == null:
		return
	for child in root.get_children():
		if child is Label:
			_style_label(child as Label)
		elif child is PanelContainer:
			apply_panel(child as PanelContainer)
		elif child is Button:
			apply_button_state(child as Button, "default")
		apply_tree(child)

static func apply_panel(panel: PanelContainer, variant: String = "default") -> void:
	if panel == null:
		return
	var fill := COLOR_PANEL_ALT if variant == "selected" else COLOR_PANEL
	var border := COLOR_SELECTED if variant == "selected" else COLOR_BORDER
	panel.add_theme_stylebox_override("panel", _make_panel_style(fill, border, 2 if variant == "selected" else 1))

static func apply_button_state(button: Button, state: String = "default") -> void:
	if button == null:
		return
	var normal_fill := Color(0.34, 0.55, 0.28, 1.0)
	var hover_fill := Color(0.43, 0.66, 0.34, 1.0)
	var pressed_fill := Color(0.27, 0.43, 0.22, 1.0)
	var border := Color(0.62, 0.79, 0.48, 1.0)
	var font := Color(0.05, 0.08, 0.04, 1.0)
	if state == "selected":
		normal_fill = COLOR_SELECTED
		hover_fill = Color(1.0, 0.84, 0.42, 1.0)
		pressed_fill = Color(0.78, 0.58, 0.2, 1.0)
		border = Color(1.0, 0.9, 0.52, 1.0)
		font = COLOR_SELECTED_DARK
	elif state == "locked":
		normal_fill = COLOR_LOCKED
		hover_fill = Color(0.35, 0.37, 0.36, 1.0)
		pressed_fill = Color(0.22, 0.24, 0.23, 1.0)
		border = COLOR_LOCKED_BORDER
		font = Color(0.76, 0.79, 0.76, 1.0)
	elif state == "secondary":
		normal_fill = Color(0.22, 0.27, 0.22, 1.0)
		hover_fill = Color(0.29, 0.36, 0.29, 1.0)
		pressed_fill = Color(0.18, 0.23, 0.18, 1.0)
		border = Color(0.48, 0.58, 0.42, 1.0)
		font = COLOR_TEXT

	button.add_theme_stylebox_override("normal", _make_button_style(normal_fill, border))
	button.add_theme_stylebox_override("hover", _make_button_style(hover_fill, border))
	button.add_theme_stylebox_override("focus", _make_button_style(hover_fill, COLOR_SELECTED))
	button.add_theme_stylebox_override("pressed", _make_button_style(pressed_fill, border))
	button.add_theme_color_override("font_color", font)
	button.add_theme_color_override("font_hover_color", font)
	button.add_theme_color_override("font_pressed_color", font)
	button.add_theme_font_size_override("font_size", 15)

static func apply_item_button(button: Button, is_equipped: bool = false) -> void:
	apply_button_state(button, "selected" if is_equipped else "secondary")
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

static func apply_related_card_from_button(button: Button, is_selected: bool) -> void:
	if button == null:
		return
	var node: Node = button
	while node != null:
		if node is PanelContainer:
			apply_panel(node as PanelContainer, "selected" if is_selected else "default")
			return
		node = node.get_parent()

static func _style_label(label: Label) -> void:
	var name := label.name
	label.add_theme_color_override("font_color", COLOR_TEXT)
	if name == "Title":
		label.add_theme_font_size_override("font_size", 30)
		label.add_theme_color_override("font_color", Color(0.98, 0.88, 0.54, 1.0))
	elif name == "Subtitle":
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", COLOR_MUTED)
	elif name == "PreviewTitle" or name == "TitleLabel" or name == "NameLabel":
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", Color(0.96, 0.84, 0.48, 1.0))
	elif name == "DescriptionLabel" or name == "StatusLabel" or name == "PreviewNote":
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", COLOR_MUTED)

static func _make_panel_style(fill: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	style.content_margin_left = 2.0
	style.content_margin_top = 2.0
	style.content_margin_right = 2.0
	style.content_margin_bottom = 2.0
	return style

static func _make_button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 2
	style.corner_radius_top_left = 7
	style.corner_radius_top_right = 7
	style.corner_radius_bottom_right = 7
	style.corner_radius_bottom_left = 7
	style.content_margin_left = 12.0
	style.content_margin_top = 8.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 8.0
	return style
