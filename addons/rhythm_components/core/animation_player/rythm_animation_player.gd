class_name RhythmAnimationPlayer
extends AnimationPlayer

@export var round_start_beat: bool = false
@export var conductor: RhythmConductor

var start_beat: float = 0.0
var speed_factor: float = 1.0
var active_animation: StringName = &""
var play_direction: float = 1.0

func _ready() -> void:
	if not is_instance_valid(conductor):
		push_warning("No conductor provided")
		self.active = false

func _process(delta: float) -> void:
	if not is_playing():
		return
	var beat_offset := (conductor.current_beat - start_beat) * play_direction
	var seconds := beat_offset * speed_factor
	seek(seconds, true, false)

func play_synced(
	name: StringName = &"",
	custom_blend: float = -1.0,
	custom_speed: float = 1.0,
	from_end: bool = false
) -> void:
	if not is_instance_valid(conductor):
		push_error("No conductor provided")
		return
	
	speed_factor = custom_speed
	if round_start_beat:
		start_beat = roundf(conductor.current_beat)
	else:
		start_beat = conductor.current_beat
	active_animation = name
	
	self.play_direction = -1.0 if from_end else 1.0
	super.play(name, custom_blend, 1.0, from_end)
