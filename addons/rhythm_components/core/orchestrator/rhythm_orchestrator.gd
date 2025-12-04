class_name RhythmOrchestrator extends RhythmComponent

var song_position: float
var beat_position: int

func _ready() -> void:
	set_orchestrator(self)
