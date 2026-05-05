extends Node
class_name AudioManager

const SFX_EVENTS := {
	"shoot": "res://assets/audio/sfx/shoot.ogg",
	"hit": "res://assets/audio/sfx/hit.ogg",
	"enemy_death": "res://assets/audio/sfx/enemy_death.ogg",
	"pickup_reward": "res://assets/audio/sfx/pickup_reward.ogg",
	"game_over": "res://assets/audio/sfx/game_over.ogg",
	"victory": "res://assets/audio/sfx/victory.ogg",
}

const MUSIC_TRACKS := {
	"menu": "res://assets/audio/music/menu_theme.ogg",
	"gameplay": "res://assets/audio/music/gameplay_loop.ogg",
}

var current_music_path: String = ""
var last_sfx_path: String = ""
var sound_enabled: bool = true
var music_enabled: bool = true
var vibration_enabled: bool = false
var _sfx_players: Array[AudioStreamPlayer] = []
var _warned_missing_paths: Dictionary = {}

func _ready() -> void:
	# Reserve bus setup and mixer defaults for later.
	pass

func play_music(track_path: String) -> void:
	# Record the requested music track until playback is implemented.
	current_music_path = track_path
	if not music_enabled:
		return
	if track_path.is_empty():
		return
	if not ResourceLoader.exists(track_path) and not _warned_missing_paths.has(track_path):
		push_warning("AudioManager missing music asset: %s" % track_path)
		_warned_missing_paths[track_path] = true

func play_music_track(track_name: StringName) -> void:
	var music_path := str(MUSIC_TRACKS.get(String(track_name), ""))
	if music_path.is_empty():
		push_warning("AudioManager received unknown music track: %s" % String(track_name))
		return
	play_music(music_path)

func play_sfx(sfx_path: String) -> void:
	if not sound_enabled:
		return
	last_sfx_path = sfx_path
	if sfx_path.is_empty():
		return
	if not ResourceLoader.exists(sfx_path):
		if not _warned_missing_paths.has(sfx_path):
			push_warning("AudioManager missing SFX asset: %s" % sfx_path)
			_warned_missing_paths[sfx_path] = true
		return
	var stream := load(sfx_path) as AudioStream
	if stream == null:
		if not _warned_missing_paths.has(sfx_path):
			push_warning("AudioManager missing SFX asset: %s" % sfx_path)
			_warned_missing_paths[sfx_path] = true
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	_sfx_players.append(player)
	player.finished.connect(_on_sfx_finished.bind(player))
	player.play()

func play_sfx_event(event_name: StringName) -> void:
	var sfx_path := str(SFX_EVENTS.get(String(event_name), ""))
	if sfx_path.is_empty():
		push_warning("AudioManager received unknown SFX event: %s" % String(event_name))
		return
	play_sfx(sfx_path)

func apply_settings(settings: Dictionary) -> void:
	sound_enabled = bool(settings.get("sound_enabled", sound_enabled))
	music_enabled = bool(settings.get("music_enabled", music_enabled))
	vibration_enabled = bool(settings.get("vibration_enabled", vibration_enabled))

func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	if _sfx_players.has(player):
		_sfx_players.erase(player)
	player.queue_free()
