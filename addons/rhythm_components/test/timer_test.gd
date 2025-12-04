extends VBoxContainer
@onready var button: Button = $HBoxContainer/Button
@onready var h_slider: HSlider = $HBoxContainer/HSlider
@onready var slider_val: Label = $HBoxContainer/SliderVal
@onready var timer_time_left: Label = $TimerTimeLeft
@onready var rhythm_timer: RhythmTimer = $RhythmTimer

func _ready() -> void:
	button.pressed.connect(
		func():
		rhythm_timer.start(h_slider.value)
		)
	h_slider.value_changed.connect(
		func(value):
			slider_val.text = str(value)
	)

func _process(_delta: float) -> void:
	if not rhythm_timer.is_stopped():
		timer_time_left.text = str("%.1f" % rhythm_timer.time_left)
