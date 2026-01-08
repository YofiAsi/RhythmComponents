extends GutTest

# Unit tests for core timing logic in Rhythm Components
# These tests verify the mathematical accuracy of timing calculations
# which are critical for rhythm game synchronization.

var conductor: RhythmConductor
var composer: RhythmComposer
var calibration: RhythmCalibration
var mock_orchestrator: RhythmOrchestrator

func before_each():
	mock_orchestrator = RhythmOrchestrator.new()
	mock_orchestrator.bpm = 120.0
	mock_orchestrator.beats_per_measure = 4.0
	mock_orchestrator.measure = 0
	mock_orchestrator.beat = 0.0
	add_child(mock_orchestrator)
	
	conductor = RhythmConductor.new()
	add_child(conductor)
	
	composer = RhythmComposer.new()
	add_child(composer)
	composer.orchestrator = mock_orchestrator
	
	calibration = RhythmCalibration.new()
	add_child(calibration)
	calibration.orchestrator = mock_orchestrator

func after_each():
	if is_instance_valid(conductor):
		conductor.queue_free()
	if is_instance_valid(composer):
		composer.queue_free()
	if is_instance_valid(calibration):
		calibration.queue_free()
	if is_instance_valid(mock_orchestrator):
		mock_orchestrator.queue_free()

# ============================================
# RhythmConductor Tests
# ============================================

func test_conductor_beat_calculation_120_bpm():
	conductor.set_song(120.0, 4.0, 4.0)
	
	var beat_1 = conductor._get_beat(0.5)
	assert_eq(beat_1, 1.0, "At 120 BPM, 0.5 seconds should equal 1.0 beat")
	
	var beat_2 = conductor._get_beat(1.0)
	assert_eq(beat_2, 2.0, "At 120 BPM, 1.0 second should equal 2.0 beats")
	
	var beat_3 = conductor._get_beat(0.25)
	assert_eq(beat_3, 0.5, "At 120 BPM, 0.25 seconds should equal 0.5 beats")

func test_conductor_beat_calculation_60_bpm():
	conductor.set_song(60.0, 4.0, 4.0)
	
	var beat_1 = conductor._get_beat(1.0)
	assert_eq(beat_1, 1.0, "At 60 BPM, 1.0 second should equal 1.0 beat")
	
	var beat_2 = conductor._get_beat(2.0)
	assert_eq(beat_2, 2.0, "At 60 BPM, 2.0 seconds should equal 2.0 beats")

func test_conductor_beat_calculation_180_bpm():
	conductor.set_song(180.0, 4.0, 4.0)
	
	var beat_1 = conductor._get_beat(1.0 / 3.0)
	assert_almost_eq(beat_1, 1.0, 0.001, "At 180 BPM, 1/3 second should equal 1.0 beat")
	
	var beat_2 = conductor._get_beat(2.0 / 3.0)
	assert_almost_eq(beat_2, 2.0, 0.001, "At 180 BPM, 2/3 second should equal 2.0 beats")

func test_conductor_measure_calculation_4_beats_per_measure():
	conductor.set_song(120.0, 4.0, 4.0)
	
	var measure_0 = conductor._get_measure(0.0)
	assert_eq(measure_0, 0, "Beat 0.0 should be measure 0")
	
	var measure_0_upper = conductor._get_measure(3.9)
	assert_eq(measure_0_upper, 0, "Beat 3.9 should still be measure 0")
	
	var measure_1 = conductor._get_measure(4.0)
	assert_eq(measure_1, 1, "Beat 4.0 should be measure 1")
	
	var measure_1_upper = conductor._get_measure(7.9)
	assert_eq(measure_1_upper, 1, "Beat 7.9 should still be measure 1")
	
	var measure_2 = conductor._get_measure(8.0)
	assert_eq(measure_2, 2, "Beat 8.0 should be measure 2")

func test_conductor_measure_calculation_3_beats_per_measure():
	conductor.set_song(120.0, 3.0, 4.0)
	
	var measure_0 = conductor._get_measure(0.0)
	assert_eq(measure_0, 0, "Beat 0.0 should be measure 0")
	
	var measure_0_upper = conductor._get_measure(2.9)
	assert_eq(measure_0_upper, 0, "Beat 2.9 should still be measure 0")
	
	var measure_1 = conductor._get_measure(3.0)
	assert_eq(measure_1, 1, "Beat 3.0 should be measure 1")
	
	var measure_2 = conductor._get_measure(6.0)
	assert_eq(measure_2, 2, "Beat 6.0 should be measure 2")

func test_conductor_beat_duration_calculation():
	conductor.set_song(120.0, 4.0, 4.0)
	var expected_duration = 60.0 / 120.0
	assert_eq(conductor.beat_duration, expected_duration, "Beat duration should be 0.5 seconds at 120 BPM")
	
	conductor.set_song(60.0, 4.0, 4.0)
	expected_duration = 60.0 / 60.0
	assert_eq(conductor.beat_duration, expected_duration, "Beat duration should be 1.0 second at 60 BPM")

# ============================================
# RhythmComposer Quantization Tests
# ============================================

func test_quantize_to_measure_parts_empty_parts():
	mock_orchestrator.beat = 2.5
	mock_orchestrator.measure = 0
	
	var result = composer._quantize_to_measure_parts(2.5, [])
	assert_eq(result, 3.0, "Empty parts should ceil to next whole beat")

func test_quantize_to_measure_parts_single_part():
	mock_orchestrator.beat = 1.0
	mock_orchestrator.measure = 0
	
	var result = composer._quantize_to_measure_parts(1.0, [0.0])
	var expected = (0 + 1) * 4.0 + 0.0 * 4.0
	assert_eq(result, expected, "Should fallback to next measure when time is past part 0.0")

func test_quantize_to_measure_parts_multiple_parts():
	mock_orchestrator.beat = 1.0
	mock_orchestrator.measure = 0
	
	var result = composer._quantize_to_measure_parts(1.0, [0.0, 0.5])
	var expected = 0.0 * 4.0 + 0.5 * 4.0
	assert_eq(result, expected, "Should quantize to 0.5 (middle) of current measure")

func test_quantize_to_measure_parts_past_current_measure():
	mock_orchestrator.beat = 3.5
	mock_orchestrator.measure = 0
	
	var result = composer._quantize_to_measure_parts(3.5, [0.0, 0.5])
	var expected = (0 + 1) * 4.0 + 0.0 * 4.0
	assert_eq(result, expected, "Should fallback to next measure when all parts are in the past")

func test_quantize_to_measure_parts_next_measure_fallback():
	mock_orchestrator.beat = 3.9
	mock_orchestrator.measure = 0
	
	var result = composer._quantize_to_measure_parts(3.9, [0.25])
	var expected = (0 + 1) * 4.0 + 0.25 * 4.0
	assert_eq(result, expected, "Should fallback to next measure if past all parts")

# ============================================
# RhythmCalibration Conversion Tests
# ============================================

func test_beats_to_ms_120_bpm():
	mock_orchestrator.bpm = 120.0
	
	var beat_duration_sec = 60.0 / 120.0
	var beats = 1.0
	var expected_ms = beats * beat_duration_sec * 1000.0
	var result_ms = calibration._beats_to_ms(beats) * 1000.0
	
	assert_almost_eq(result_ms, expected_ms, 0.1, "1 beat at 120 BPM should equal 500ms")

func test_beats_to_ms_60_bpm():
	mock_orchestrator.bpm = 60.0
	
	var beat_duration_sec = 60.0 / 60.0
	var beats = 1.0
	var expected_ms = beats * beat_duration_sec * 1000.0
	var result_ms = calibration._beats_to_ms(beats) * 1000.0
	
	assert_almost_eq(result_ms, expected_ms, 0.1, "1 beat at 60 BPM should equal 1000ms")

func test_beats_to_ms_fractional_beats():
	mock_orchestrator.bpm = 120.0
	
	var beat_duration_sec = 60.0 / 120.0
	var beats = 0.5
	var expected_ms = beats * beat_duration_sec * 1000.0
	var result_ms = calibration._beats_to_ms(beats) * 1000.0
	
	assert_almost_eq(result_ms, expected_ms, 0.1, "0.5 beats at 120 BPM should equal 250ms")

# ============================================
# Edge Cases and Boundary Tests
# ============================================

func test_conductor_zero_bpm_edge_case():
	conductor.set_song(0.0, 4.0, 4.0)
	
	var beat = conductor._get_beat(1.0)
	assert_true(is_inf(beat) or is_nan(beat) or beat == 0.0, "Zero BPM should result in invalid beat calculation (inf/nan/0)")

func test_conductor_very_high_bpm():
	conductor.set_song(300.0, 4.0, 4.0)
	
	var beat = conductor._get_beat(0.2)
	var expected = 0.2 / (60.0 / 300.0)
	assert_almost_eq(beat, expected, 0.001, "Very high BPM should still calculate correctly")

func test_conductor_negative_time():
	conductor.set_song(120.0, 4.0, 4.0)
	
	var beat = conductor._get_beat(-1.0)
	assert_lt(beat, 0.0, "Negative time should result in negative beat")

func test_quantize_negative_time():
	mock_orchestrator.beat = -1.0
	mock_orchestrator.measure = 0
	
	var result = composer._quantize_to_measure_parts(-1.0, [0.0])
	assert_true(result >= 0.0, "Quantization should handle negative time gracefully")

# ============================================
# Integration-style Tests
# ============================================

func test_full_timing_chain_120_bpm():
	# Test the full chain: seconds -> beats -> measures
	conductor.set_song(120.0, 4.0, 4.0)
	
	var time_seconds = 2.0
	var beat = conductor._get_beat(time_seconds)
	var measure = conductor._get_measure(beat)
	
	assert_eq(beat, 4.0, "2 seconds at 120 BPM = 4 beats")
	assert_eq(measure, 1, "4 beats at 4 beats/measure = measure 1")

func test_full_timing_chain_60_bpm():
	conductor.set_song(60.0, 4.0, 4.0)
	
	var time_seconds = 4.0
	var beat = conductor._get_beat(time_seconds)
	var measure = conductor._get_measure(beat)
	
	assert_eq(beat, 4.0, "4 seconds at 60 BPM = 4 beats")
	assert_eq(measure, 1, "4 beats at 4 beats/measure = measure 1")
