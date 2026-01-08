class_name ChartPartSequence
extends ChartPart

# NOTICE - Hit times are relative to start_time
@export var parts: Array[ChartPart] = []

# which parts of the measure could be entered
@export var enter_measure_parts: Array[float]
