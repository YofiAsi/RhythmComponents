class_name RhythmSoundPlayer extends RhythmSoundPlayerInterface

var main_song_player: AudioStreamPlayer
var sfx_players: Dictionary[String, AudioStreamPlayer]
var song_position: float

func _ready() -> void:
	main_song_player = AudioStreamPlayer.new()
	add_child(main_song_player)

func set_sfx(streams: Array[AudioStream], clear: bool = true) -> Array[String]:
	if clear:
		sfx_players.clear()
	
	for stream: AudioStream in streams:
		_add_sfx(stream)
	
	return sfx_players.keys()

func _add_sfx(stream: AudioStream) -> void:
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	sfx_players.set(stream.resource_name, player)

func set_song(stream: AudioStream) -> void:
	main_song_player.stream = stream

func play_main_song() -> void:
	main_song_player.play()

func update(args: Dictionary = {}) -> void:
	if not main_song_player.playing:
		return
	
	song_position = main_song_player.get_playback_position() + AudioServer.get_time_since_last_mix()
	song_position -= AudioServer.get_output_latency()
	song_position_updated.emit(song_position)
