extends RefCounted
class_name SciFiTheme

const BACKGROUND := Color("#0B0F14")
const PANEL := Color("#121A24")
const PANEL_TRANSLUCENT := Color(0.0705882, 0.101961, 0.141176, 0.82)
const ACCENT := Color("#28D7FF")
const DANGER := Color("#FF4D4D")
const WARNING := Color("#FFB020")
const SUCCESS := Color("#38D996")
const TEXT := Color("#E6F1FF")
const MUTED := Color("#8FA3B8")
const MIN_TOUCH := Vector2(64.0, 64.0)

static func apply_panel(control: Control, tint: Color = PANEL_TRANSLUCENT, border: Color = Color(0.156863, 0.843137, 1.0, 0.35)) -> void:
	if control == null:
		return
	control.add_theme_stylebox_override("panel", make_panel(tint, border))

static func apply_button(button: Button, accent: Color = ACCENT) -> void:
	if button == null:
		return
	button.custom_minimum_size = Vector2(maxf(button.custom_minimum_size.x, MIN_TOUCH.x), maxf(button.custom_minimum_size.y, MIN_TOUCH.y))
	button.add_theme_stylebox_override("normal", make_button(PANEL, accent.darkened(0.45)))
	button.add_theme_stylebox_override("hover", make_button(PANEL.lightened(0.08), accent))
	button.add_theme_stylebox_override("focus", make_button(PANEL.lightened(0.08), accent))
	button.add_theme_stylebox_override("pressed", make_button(PANEL.darkened(0.25), accent))
	button.add_theme_stylebox_override("disabled", make_button(PANEL.darkened(0.18), Color(0.14, 0.19, 0.24, 0.75)))
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", TEXT)
	button.add_theme_color_override("font_pressed_color", TEXT)
	button.add_theme_color_override("font_disabled_color", Color(MUTED.r, MUTED.g, MUTED.b, 0.55))

static func apply_label(label: Label, muted: bool = false, font_size: int = 17) -> void:
	if label == null:
		return
	label.add_theme_color_override("font_color", MUTED if muted else TEXT)
	label.add_theme_font_size_override("font_size", font_size)

static func apply_progress(progress: ProgressBar, fill: Color = ACCENT) -> void:
	if progress == null:
		return
	progress.custom_minimum_size.y = maxf(progress.custom_minimum_size.y, 10.0)
	progress.add_theme_stylebox_override("background", make_panel(Color(0.0431373, 0.0588235, 0.0784314, 0.96), Color(0.14, 0.19, 0.24, 1.0), 4))
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill
	fill_style.corner_radius_top_left = 4
	fill_style.corner_radius_top_right = 4
	fill_style.corner_radius_bottom_left = 4
	fill_style.corner_radius_bottom_right = 4
	progress.add_theme_stylebox_override("fill", fill_style)

static func make_panel(fill: Color = PANEL_TRANSLUCENT, border: Color = Color(0.156863, 0.843137, 1.0, 0.35), radius: int = 8) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style

static func make_button(fill: Color, border: Color) -> StyleBoxFlat:
	var style := make_panel(fill, border, 6)
	style.content_margin_left = 14
	style.content_margin_top = 10
	style.content_margin_right = 14
	style.content_margin_bottom = 10
	return style
