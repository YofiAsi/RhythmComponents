extends Resource
class_name RhythmAccuracyProfile

@export var levels: Array[RhythmAccuracyLevel] = []
@export var max_hit_window_beats: float = 0.25   # anything beyond this is a miss
@export var allow_blank_hit: bool = true         # if false, you can treat blank hits differently

func get_accuracy(delta_beats: float) -> StringName:
	var ad := abs(delta_beats)

	for level in levels:
		if ad <= level.max_delta_beats:
			return level.name

	if ad <= max_hit_window_beats:
		# Inside the overall hit window, but not in a named level.
		# You can return a generic result or reuse the last level name.
		return &"hit"

	return &"miss"
