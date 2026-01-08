class_name RhythmAnimationPlayer
extends AnimationPlayer

@export var round_start_beat: bool = false
@export var offset_ms: float = 0.0

var orchestrator: RhythmOrchestrator
var start_beat: float = 0.0
var speed_factor: float = 1.0
var active_animation: StringName = &""
var play_direction: float = 1.0

var _last_seconds: float = 0.0

const INVALID_BLEND := -1.0
const DEFAULT_SPEED := 1.0
const REVERSE_DIRECTION := -1.0
const SECONDS_PER_MINUTE := 60.0
const MS_PER_SECOND := 1000.0

func _ready() -> void:
	self.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	if not is_instance_valid(orchestrator):
		self.orchestrator = get_tree().get_first_node_in_group("rhythm_orchestrator")
		if not is_instance_valid(orchestrator):
			push_warning("No orchestrator provided")
			self.active = false
	
	if autoplay:
		play_synced()

func _process(delta: float) -> void:
	if not is_playing():
		return
	
	if not orchestrator:
		advance(delta)
		return

	var beat_offset := (orchestrator.beat - start_beat) * play_direction
	var seconds := beat_offset * speed_factor

	var delta_seconds := seconds - _last_seconds
	_last_seconds = seconds

	advance(delta_seconds)

func play_synced(
	name: StringName = &"",
	custom_blend: float = INVALID_BLEND,
	custom_speed: float = DEFAULT_SPEED,
	from_end: bool = false
) -> void:
	if not is_instance_valid(orchestrator):
		push_error("No orchestrator provided")
		return

	speed_factor = custom_speed
	play_direction = REVERSE_DIRECTION if from_end else DEFAULT_SPEED

	var base_beat = roundf(orchestrator.beat) if round_start_beat else orchestrator.beat
	var offset_beats = _ms_to_beats(offset_ms)
	start_beat = base_beat - offset_beats
	_last_seconds = 0.0
	active_animation = name

	super.play(name, custom_blend, custom_speed, from_end)

func _ms_to_beats(ms: float) -> float:
	if not is_instance_valid(orchestrator):
		return 0.0
	var offset_seconds = ms / MS_PER_SECOND
	var beat_duration = SECONDS_PER_MINUTE / orchestrator.bpm
	return offset_seconds / beat_duration
