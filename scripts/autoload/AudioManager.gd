extends Node
class_name AudioManager

# Central audio manager.
# Use this singleton to control music, SFX, and audio state.

func _ready() -> void:
    # Prepare audio buses and defaults.
    pass

func play_music(track_path: String) -> void:
    # Play background music with path-based lookup.
    pass

func play_sfx(sfx_path: String) -> void:
    # Trigger one-shot sound effects.
    pass
