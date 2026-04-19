extends Node
class_name AudioManager

# Placeholder audio manager for future music and SFX playback.

var current_music_path: String = ""
var last_sfx_path: String = ""

func _ready() -> void:
    # Reserve bus setup and mixer defaults for later.
    pass

func play_music(track_path: String) -> void:
    # Record the requested music track until playback is implemented.
    current_music_path = track_path

func play_sfx(sfx_path: String) -> void:
    # Record the requested one-shot SFX until playback is implemented.
    last_sfx_path = sfx_path
