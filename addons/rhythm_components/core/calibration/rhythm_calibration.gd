class_name RhythmCalibration
extends RhythmComponent

signal update_latency_offset(val: float)
signal calibration_finished()

enum CALIBRATION_MODE {
	HITS_AMOUNT,
	TIME,
	STREAM
}

var _hit_count: int = 0
var _desired_time: float = 0.0
var _desired_count: int = -1
var error_sum: float = 0.0
var _mode: CALIBRATION_MODE = CALIBRATION_MODE.STREAM

const SECONDS_PER_MINUTE := 60.0
const INVALID_VALUE := -1

var timer: RhythmTimer

func _ready() -> void:
	super._ready()
	
	timer = RhythmTimer.new()
	timer.one_shot = true
	timer.autostart = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func start_calibration(
	mode: CALIBRATION_MODE,
	hit_count: int = INVALID_VALUE,
	desired_time: float = INVALID_VALUE,
) -> void:
	orchestrator.player_input_entered.connect(_on_player_input)
	_mode = mode
	_hit_count = 0
	_desired_time = desired_time
	_desired_count = hit_count
	error_sum = 0.0
	
	if _mode == CALIBRATION_MODE.TIME:
		timer.start(_desired_time)

func stop_calibration() -> void:
	orchestrator.player_input_entered.disconnect(_on_player_input)
	timer.stop()
	calibration_finished.emit()
	if _hit_count > 0:
		var avg_error: float = error_sum / _hit_count
		update_latency_offset.emit(avg_error)

func _on_player_input(action_name: StringName, event: InputEvent) -> void:
	var error_beats := _calculate_error_beats()
	var error_ms := _beats_to_ms(error_beats)

	_hit_count += 1
	error_sum += error_ms
	
	if _mode == CALIBRATION_MODE.HITS_AMOUNT:
		if _hit_count >= _desired_count and _desired_count > INVALID_VALUE:
			stop_calibration()

func _calculate_error_beats() -> float:
	var curr_beat: float = orchestrator.beat

	var prev_beat: float = floor(curr_beat)
	var dist_to_prev := curr_beat - prev_beat
	return -dist_to_prev

func _beats_to_ms(error_beats: float) -> float:
	var bpm := orchestrator.bpm
	var beat_duration_sec := SECONDS_PER_MINUTE / bpm
	return error_beats * beat_duration_sec

func _on_timer_timeout() -> void:
	stop_calibration()

func get_mode() -> CALIBRATION_MODE:
	return _mode
