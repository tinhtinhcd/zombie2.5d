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

var current_music_path: String = ""
var last_sfx_path: String = ""
var _sfx_players: Array[AudioStreamPlayer] = []
var _warned_missing_paths: Dictionary = {}

func _ready() -> void:
    # Reserve bus setup and mixer defaults for later.
    pass

func play_music(track_path: String) -> void:
    # Record the requested music track until playback is implemented.
    current_music_path = track_path

func play_sfx(sfx_path: String) -> void:
	last_sfx_path = sfx_path
	if sfx_path.is_empty():
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

func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	if _sfx_players.has(player):
		_sfx_players.erase(player)
	player.queue_free()
