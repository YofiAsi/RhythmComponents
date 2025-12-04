extends CanvasLayer

@onready var rhythm_animation_player: RhythmAnimationPlayer = $RhythmAnimationPlayer

func _ready() -> void:
	rhythm_animation_player.play_synced("new_animation", -1.0, 1.0, true)
