extends Node2D
@onready var rhythm_conductor: RhythmConductor = $RhythmConductor

@onready var rhythm_sound_player: RhythmSoundPlayer = $RhythmSoundPlayer
var beat: float
var song_time: float

func _ready() -> void:
	rhythm_sound_player.song_position_updated.connect(func(value): song_time = value)
	rhythm_conductor.beat_update.connect(func(value): beat = value)
	rhythm_sound_player.set_song(load("uid://cxj5wf70iok5f"))
	rhythm_conductor.set_song(110, 4 ,4)
	rhythm_sound_player.play_main_song()
	
func _process(_delta: float) -> void:
	rhythm_sound_player.update()
	rhythm_conductor.update({"song_time": song_time})
