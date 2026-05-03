extends RefCounted
class_name HomeUIStyle

const COLOR_TEXT := Color(0.902, 0.902, 0.902, 1.0)
const COLOR_MUTED := Color(0.655, 0.678, 0.71, 1.0)
const COLOR_PANEL := Color(0.035, 0.07, 0.08, 0.93)
const COLOR_PANEL_ALT := Color(0.055, 0.105, 0.12, 0.96)
const COLOR_BORDER := Color(0.18, 0.42, 0.46, 0.95)
const COLOR_SELECTED := Color(0.22, 0.72, 0.76, 1.0)
const COLOR_SELECTED_DARK := Color(0.025, 0.09, 0.105, 1.0)
const COLOR_TEAL := Color(0.42, 0.9, 0.95, 1.0)
const COLOR_LOCKED := Color(0.075, 0.09, 0.095, 0.95)
const COLOR_LOCKED_BORDER := Color(0.18, 0.26, 0.28, 0.9)
const RARITY_COLORS := {
	"common": Color(0.61, 0.64, 0.69, 1.0),
	"uncommon": Color(0.13, 0.77, 0.37, 1.0),
	"rare": Color(0.23, 0.51, 0.96, 1.0),
	"epic": Color(0.66, 0.33, 0.97, 1.0),
	"legendary": Color(0.98, 0.45, 0.09, 1.0),
}

const WENREXA_BACKGROUND_PATH := "res://assets/wenrexa_ui_sci_fi_01/common/Background.jpg"
const WENREXA_BTN_DEFAULT_PATH := "res://assets/wenrexa_ui_sci_fi_01/common/BtnDefault.png"
const WENREXA_BTN_BACK_PATH := "res://assets/wenrexa_ui_sci_fi_01/common/BtnBack.png"
const WENREXA_BTN_NEXT_PATH := "res://assets/wenrexa_ui_sci_fi_01/common/BtnNext.png"
const WENREXA_ITEM_ENABLE_PATH := "res://assets/wenrexa_ui_sci_fi_01/common/ItemEnable.png"
const WENREXA_ITEM_DISABLE_PATH := "res://assets/wenrexa_ui_sci_fi_01/common/ItemDisable.png"

static var _texture_cache: Dictionary = {}

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

static func get_background_texture() -> Texture2D:
	return _get_texture(WENREXA_BACKGROUND_PATH)

static func apply_panel(panel: PanelContainer, variant: String = "default") -> void:
	if panel == null:
		return
	var panel_path := str(panel.get_path())
	if panel_path.find("MainMenuScreen") != -1:
		if panel_path.find("CenterHero") != -1:
			panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.015, 0.025, 0.03, 0.2), Color(0.12, 0.28, 0.32, 0.45), 1))
			return
		panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.025, 0.055, 0.06, 0.78), Color(0.16, 0.38, 0.42, 0.75), 1))
		return
	var fill: Color = COLOR_PANEL_ALT if variant == "selected" else COLOR_PANEL
	var border: Color = COLOR_SELECTED if variant == "selected" else COLOR_BORDER
	panel.add_theme_stylebox_override("panel", _make_panel_style(fill, border, 2 if variant == "selected" else 1))

static func apply_button_state(button: Button, state: String = "default") -> void:
	if button == null:
		return
	var button_path := str(button.get_path())
	if button_path.find("MainMenuScreen") != -1 and (button_path.find("Header") != -1 or button_path.find("BottomNavBar") != -1):
		var compact_fill := Color(0.045, 0.085, 0.095, 0.88)
		var compact_border := COLOR_SELECTED if state == "selected" else COLOR_BORDER
		button.add_theme_stylebox_override("normal", _make_button_style(compact_fill, compact_border))
		button.add_theme_stylebox_override("hover", _make_button_style(Color(0.065, 0.12, 0.13, 0.95), compact_border))
		button.add_theme_stylebox_override("focus", _make_button_style(Color(0.065, 0.12, 0.13, 0.95), compact_border))
		button.add_theme_stylebox_override("pressed", _make_button_style(Color(0.09, 0.16, 0.17, 1.0), COLOR_SELECTED))
		button.add_theme_color_override("font_color", COLOR_TEXT)
		button.add_theme_color_override("font_hover_color", COLOR_TEXT)
		button.add_theme_color_override("font_pressed_color", COLOR_TEXT)
		button.add_theme_font_size_override("font_size", 13)
		return
	var texture: Texture2D = _get_texture(WENREXA_BTN_DEFAULT_PATH)
	var normal_modulate := Color(0.75, 0.95, 1.0, 0.96)
	var hover_modulate := Color(0.95, 1.0, 1.0, 1.0)
	var pressed_modulate := Color(0.42, 0.78, 0.86, 1.0)
	var disabled_modulate := Color(0.36, 0.44, 0.46, 0.72)
	var font := COLOR_TEXT
	if state == "selected":
		texture = _get_texture(WENREXA_BTN_NEXT_PATH)
		normal_modulate = Color(0.7, 1.0, 1.0, 1.0)
		hover_modulate = Color(1.0, 1.0, 1.0, 1.0)
		pressed_modulate = Color(0.48, 0.86, 0.92, 1.0)
		font = COLOR_TEXT
	elif state == "locked":
		texture = _get_texture(WENREXA_BTN_DEFAULT_PATH)
		normal_modulate = disabled_modulate
		hover_modulate = Color(0.42, 0.5, 0.52, 0.8)
		pressed_modulate = Color(0.3, 0.36, 0.38, 0.72)
		font = Color(0.62, 0.72, 0.74, 1.0)
	elif state == "secondary":
		texture = _get_texture(WENREXA_BTN_BACK_PATH)
		normal_modulate = Color(0.68, 0.88, 0.94, 0.94)
		hover_modulate = Color(0.86, 1.0, 1.0, 1.0)
		pressed_modulate = Color(0.4, 0.68, 0.74, 1.0)
		font = COLOR_TEXT

	button.add_theme_stylebox_override("normal", _make_button_texture_style(texture, normal_modulate))
	button.add_theme_stylebox_override("hover", _make_button_texture_style(texture, hover_modulate))
	button.add_theme_stylebox_override("focus", _make_button_texture_style(texture, hover_modulate))
	button.add_theme_stylebox_override("pressed", _make_button_texture_style(texture, pressed_modulate))
	button.add_theme_stylebox_override("disabled", _make_button_texture_style(texture, disabled_modulate))
	button.add_theme_color_override("font_color", font)
	button.add_theme_color_override("font_hover_color", font)
	button.add_theme_color_override("font_pressed_color", font)
	button.add_theme_color_override("font_disabled_color", Color(0.45, 0.56, 0.58, 1.0))
	button.add_theme_font_size_override("font_size", 15)

static func apply_compact_button_state(button: Button, state: String = "default") -> void:
	if button == null:
		return
	var fill := Color(0.045, 0.085, 0.095, 0.92)
	var border := COLOR_BORDER
	var font := COLOR_TEXT
	if state == "selected":
		fill = COLOR_SELECTED_DARK
		border = COLOR_SELECTED
	elif state == "locked":
		fill = COLOR_LOCKED
		border = COLOR_LOCKED_BORDER
		font = Color(0.58, 0.66, 0.68, 1.0)
	button.add_theme_stylebox_override("normal", _make_compact_button_style(fill, border))
	button.add_theme_stylebox_override("hover", _make_compact_button_style(fill.lightened(0.08), border))
	button.add_theme_stylebox_override("focus", _make_compact_button_style(fill.lightened(0.08), border))
	button.add_theme_stylebox_override("pressed", _make_compact_button_style(fill.lightened(0.13), COLOR_SELECTED))
	button.add_theme_stylebox_override("disabled", _make_compact_button_style(COLOR_LOCKED, COLOR_LOCKED_BORDER))
	button.add_theme_color_override("font_color", font)
	button.add_theme_color_override("font_hover_color", font)
	button.add_theme_color_override("font_pressed_color", font)
	button.add_theme_color_override("font_disabled_color", Color(0.45, 0.52, 0.54, 1.0))
	button.add_theme_font_size_override("font_size", 12)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER

static func apply_compact_button_rarity(button: Button, rarity: String, is_selected: bool = false) -> void:
	if button == null:
		return
	var rarity_color: Color = RARITY_COLORS.get(rarity.to_lower(), RARITY_COLORS["common"])
	var fill := Color(0.045, 0.085, 0.095, 0.92).lerp(rarity_color, 0.12)
	var border := rarity_color if is_selected else rarity_color.darkened(0.18)
	button.add_theme_stylebox_override("normal", _make_compact_button_style(fill, border))
	button.add_theme_stylebox_override("hover", _make_compact_button_style(fill.lightened(0.08), rarity_color))
	button.add_theme_stylebox_override("focus", _make_compact_button_style(fill.lightened(0.08), rarity_color))
	button.add_theme_stylebox_override("pressed", _make_compact_button_style(fill.lightened(0.13), rarity_color))
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_pressed_color", COLOR_TEXT)
	button.add_theme_font_size_override("font_size", 12)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER

static func apply_item_button(button: Button, is_equipped: bool = false) -> void:
	var texture: Texture2D = _get_texture(WENREXA_ITEM_ENABLE_PATH if is_equipped else WENREXA_ITEM_DISABLE_PATH)
	var normal_modulate := Color(0.75, 1.0, 1.0, 1.0) if is_equipped else Color(0.65, 0.82, 0.88, 0.92)
	var hover_modulate := Color(0.95, 1.0, 1.0, 1.0)
	button.add_theme_stylebox_override("normal", _make_item_texture_style(texture, normal_modulate))
	button.add_theme_stylebox_override("hover", _make_item_texture_style(texture, hover_modulate))
	button.add_theme_stylebox_override("focus", _make_item_texture_style(_get_texture(WENREXA_ITEM_ENABLE_PATH), hover_modulate))
	button.add_theme_stylebox_override("pressed", _make_item_texture_style(_get_texture(WENREXA_ITEM_ENABLE_PATH), Color(0.5, 0.85, 0.9, 1.0)))
	button.add_theme_stylebox_override("disabled", _make_item_texture_style(_get_texture(WENREXA_ITEM_DISABLE_PATH), Color(0.35, 0.42, 0.44, 0.75)))
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_pressed_color", COLOR_TEXT)
	button.add_theme_font_size_override("font_size", 14)
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
	var name := str(label.name)
	label.add_theme_color_override("font_color", COLOR_TEXT)
	if name == "Title":
		label.add_theme_font_size_override("font_size", 28)
		label.add_theme_color_override("font_color", COLOR_TEXT)
	elif name == "Subtitle":
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", COLOR_MUTED)
	elif name == "PreviewTitle" or name == "TitleLabel" or name == "NameLabel":
		label.add_theme_font_size_override("font_size", 18)
		label.add_theme_color_override("font_color", COLOR_TEAL)
	elif name == "DescriptionLabel" or name == "StatusLabel" or name == "PreviewNote":
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", COLOR_MUTED)
	elif name == "EnergyLabel" or name == "CurrencyLabel" or name == "GemsLabel":
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_stylebox_override("normal", _make_panel_style(Color(0.055, 0.105, 0.12, 0.88), COLOR_BORDER, 1))
	elif name.begins_with("Slot"):
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_stylebox_override("normal", _make_panel_style(Color(0.035, 0.07, 0.08, 0.9), COLOR_LOCKED_BORDER, 1))
	elif name == "PowerValue":
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", COLOR_TEAL)

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

static func _get_texture(path: String) -> Texture2D:
	if _texture_cache.has(path):
		return _texture_cache[path] as Texture2D
	var texture := load(path) as Texture2D
	if texture == null:
		push_warning("HomeUIStyle warning: failed to load UI texture %s" % path)
		return null
	_texture_cache[path] = texture
	return texture

static func _make_button_texture_style(texture: Texture2D, modulate: Color) -> StyleBox:
	if texture == null:
		return _make_button_style(Color(0.08, 0.14, 0.16, 1.0), COLOR_BORDER)
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 28.0
	style.texture_margin_top = 14.0
	style.texture_margin_right = 28.0
	style.texture_margin_bottom = 14.0
	style.modulate_color = modulate
	style.content_margin_left = 16.0
	style.content_margin_top = 10.0
	style.content_margin_right = 16.0
	style.content_margin_bottom = 10.0
	return style

static func _make_item_texture_style(texture: Texture2D, modulate: Color) -> StyleBox:
	if texture == null:
		return _make_button_style(Color(0.08, 0.14, 0.16, 1.0), COLOR_BORDER)
	var style := StyleBoxTexture.new()
	style.texture = texture
	style.texture_margin_left = 20.0
	style.texture_margin_top = 16.0
	style.texture_margin_right = 20.0
	style.texture_margin_bottom = 16.0
	style.modulate_color = modulate
	style.content_margin_left = 10.0
	style.content_margin_top = 8.0
	style.content_margin_right = 10.0
	style.content_margin_bottom = 8.0
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

static func _make_compact_button_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 2
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	style.content_margin_left = 5.0
	style.content_margin_top = 3.0
	style.content_margin_right = 5.0
	style.content_margin_bottom = 3.0
	return style
