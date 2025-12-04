class_name RhythmJudge
extends RhythmComponent

signal judged(note_id: int, result: StringName, timing_error: float)
signal note_missed(note_id: int)
