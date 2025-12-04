class_name RhythmComponent extends Node

var _orchestrator: RhythmOrchestrator

func set_orchestrator(value: RhythmOrchestrator) -> void:
	self._orchestrator = value

func update(args: Dictionary = {}) -> void:
	push_error("function not implemented")
