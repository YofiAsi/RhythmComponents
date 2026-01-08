class_name RhythmTimer
extends RhythmComponent

signal timeout

@export var wait_beats: float = 1.0
@export var one_shot: bool = false
@export var autostart: bool = false

var paused: bool = false
var time_left: float = STOPPED_STATE
var _start_beat: float = 0.0

const STOPPED_STATE := -100.0

func _ready() -> void:
	super._ready()
	if autostart:
		start(wait_beats)
	else:
		time_left = STOPPED_STATE

func is_stopped() -> bool:
	if paused:
		return true
	if time_left == STOPPED_STATE:
		return true
	return false

func start(beats: float = wait_beats) -> void:
	wait_beats = beats
	var cb := orchestrator.beat
	var rb := roundf(cb)
	_start_beat = rb
	time_left = wait_beats - (cb - rb)

func stop() -> void:
	time_left = STOPPED_STATE

func set_paused(v: bool) -> void:
	paused = v

func is_paused() -> bool:
	return paused

func get_time_left() -> float:
	return time_left

func _process(delta: float) -> void:
	if is_stopped():
		return
	var cb := orchestrator.beat
	time_left = (_start_beat + wait_beats) - cb
	if time_left <= 0.0:
		timeout.emit()
		if one_shot:
			time_left = STOPPED_STATE
		else:
			_start_beat += wait_beats
			time_left = (_start_beat + wait_beats) - cb
