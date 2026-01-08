@abstract
class_name RhythmComponent extends Node

var orchestrator: RhythmOrchestrator

func _ready() -> void:
	var orchestrator_array: Array[Node] = get_tree().get_nodes_in_group("rhythm_orchestrator")
	match len(orchestrator_array):
		0:
			push_error("no orchestrator found")
			return
		1: 
			orchestrator = orchestrator_array[0]
		_:
			push_error("more than one orchestrator found.. aborting..")
			return
