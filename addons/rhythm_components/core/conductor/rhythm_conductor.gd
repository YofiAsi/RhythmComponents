class_name RhythmConductor extends RhythmComponent

signal beat_update(beat: float)
signal measure_update(measure: int)

var bpm : float = 120.0
var beats_per_measure : float = 4
var beat_unit : float = 4

var beat_duration : float = 0.0
var current_beat : float = 0.0
var current_measure: int = 0

const SECONDS_PER_MINUTE := 60.0
const INVALID_SONG_POSITION := -1.0

func _ready() -> void:
	super._ready()

func set_song(
	song_bpm: float,
	song_beat_per_measure: float,
	song_beat_unit: float,
) -> void:
	self.bpm = song_bpm
	self.beats_per_measure = song_beat_per_measure
	self.beat_unit = song_beat_unit
	self.beat_duration = SECONDS_PER_MINUTE / bpm
	self.current_beat = 0.0
	self.current_measure = 0

func update(song_pos: float = INVALID_SONG_POSITION) -> void:
	var t := song_pos
	if t <= INVALID_SONG_POSITION:
		push_error("song time not provided")
		return
	
	var beat: float = _get_beat(t)
	if current_beat == beat:
		return
	current_beat = beat
	beat_update.emit(current_beat)
	
	var measure: int = _get_measure(current_beat)
	if current_measure == measure:
		return
	current_measure = measure
	measure_update.emit(current_measure)

func _get_beat(time: float) -> float:
	return time / beat_duration

func _get_measure(beat: float) -> int:
	return int(floor(beat / beats_per_measure))
