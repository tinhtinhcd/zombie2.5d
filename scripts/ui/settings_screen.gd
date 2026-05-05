extends Control
class_name SettingsScreen

signal back_requested

const MOBILE_WIDTH_THRESHOLD = 700.0
const MOBILE_MARGIN = 14

@onready var panel_container: PanelContainer = $CenterContainer/PanelContainer
@onready var margin_container: MarginContainer = $CenterContainer/PanelContainer/MarginContainer
@onready var sound_toggle: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/SoundToggle
@onready var music_toggle: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/MusicToggle
@onready var vibration_toggle: CheckButton = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Content/VibrationToggle
@onready var back_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/Footer/BackButton

var _save_manager: SaveManager
var _audio_manager: AudioManager
var _is_loading_settings: bool = false

func _ready() -> void:
	visible = false
	_save_manager = get_node_or_null("/root/SaveManager") as SaveManager
	_audio_manager = get_node_or_null("/root/AudioManager") as AudioManager
	_load_settings()
	sound_toggle.toggled.connect(_on_setting_toggled)
	music_toggle.toggled.connect(_on_setting_toggled)
	vibration_toggle.toggled.connect(_on_setting_toggled)
	back_button.pressed.connect(_on_back_pressed)
	get_viewport().size_changed.connect(_apply_responsive_layout)
	_apply_responsive_layout()

func _on_back_pressed() -> void:
	back_requested.emit()

func _on_setting_toggled(_enabled: bool) -> void:
	if _is_loading_settings:
		return
	_save_settings()

func _load_settings() -> void:
	_is_loading_settings = true
	var settings := {
		"sound_enabled": true,
		"music_enabled": true,
		"vibration_enabled": false,
	}
	if _save_manager != null:
		var save_data := _save_manager.last_saved_snapshot.duplicate(true)
		if save_data.is_empty():
			save_data = _save_manager.load_game()
		var settings_value: Variant = save_data.get("settings", {})
		if typeof(settings_value) == TYPE_DICTIONARY:
			settings.merge(settings_value as Dictionary, true)
	sound_toggle.button_pressed = bool(settings.get("sound_enabled", true))
	music_toggle.button_pressed = bool(settings.get("music_enabled", true))
	vibration_toggle.button_pressed = bool(settings.get("vibration_enabled", false))
	_apply_audio_settings(settings)
	_is_loading_settings = false

func _save_settings() -> void:
	var settings := {
		"sound_enabled": sound_toggle.button_pressed,
		"music_enabled": music_toggle.button_pressed,
		"vibration_enabled": vibration_toggle.button_pressed,
	}
	_apply_audio_settings(settings)
	if _save_manager == null:
		return
	var save_data := _save_manager.load_game()
	save_data["settings"] = settings
	_save_manager.save_game(save_data)

func _apply_audio_settings(settings: Dictionary) -> void:
	if _audio_manager != null and _audio_manager.has_method("apply_settings"):
		_audio_manager.apply_settings(settings)

func _apply_responsive_layout() -> void:
	var viewport_size := get_viewport_rect().size
	var is_narrow := viewport_size.x <= MOBILE_WIDTH_THRESHOLD
	var margin := MOBILE_MARGIN if is_narrow else 24
	panel_container.custom_minimum_size = Vector2(min(460.0, viewport_size.x - float(margin * 2)), 0.0)
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)
	for button in [sound_toggle, music_toggle, vibration_toggle, back_button]:
		button.custom_minimum_size = Vector2(0.0 if is_narrow else button.custom_minimum_size.x, max(button.custom_minimum_size.y, 52.0))
