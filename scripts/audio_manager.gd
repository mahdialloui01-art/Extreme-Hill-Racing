extends Node
class_name RacingAudioManager

const SAMPLE_RATE: int = 22050
const MUSIC_SECONDS: int = 16
const ENGINE_SECONDS: float = 1.0

var music_player: AudioStreamPlayer
var engine_player: AudioStreamPlayer
var effects_player: AudioStreamPlayer
var effects: Dictionary = {}

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "ProceduralMountainMusic"
	music_player.stream = _make_music_loop()
	music_player.volume_db = -20.0
	add_child(music_player)
	music_player.play()

	engine_player = AudioStreamPlayer.new()
	engine_player.name = "ProceduralEngineLoop"
	engine_player.stream = _make_engine_loop()
	engine_player.volume_db = -17.0
	add_child(engine_player)

	effects_player = AudioStreamPlayer.new()
	effects_player.name = "RacingSoundEffects"
	add_child(effects_player)

	effects["coin"] = _make_tone(880.0, 0.16, 0.72, 1.35)
	effects["fuel"] = _make_tone(520.0, 0.34, 0.62, 1.18)
	effects["crash"] = _make_tone(95.0, 0.48, 0.90, 0.42)
	effects["finish"] = _make_tone(660.0, 0.72, 0.70, 1.55)
	effects["upgrade"] = _make_tone(740.0, 0.25, 0.56, 1.42)

func _make_stream(samples: PackedFloat32Array, looped: bool) -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false

	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i: int in range(samples.size()):
		var sample_value: float = clampf(samples[i], -1.0, 1.0)
		bytes.encode_s16(i * 2, int(sample_value * 32767.0))

	stream.data = bytes
	if looped and not samples.is_empty():
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = samples.size()
	return stream

func _make_tone(frequency: float, duration: float, volume: float, pitch_end: float = 1.0) -> AudioStreamWAV:
	var count: int = maxi(1, int(float(SAMPLE_RATE) * duration))
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(count)

	for i: int in range(count):
		var progress: float = float(i) / float(count)
		var t: float = float(i) / float(SAMPLE_RATE)
		var envelope: float = pow(maxf(0.0, 1.0 - progress), 1.7)
		var current_frequency: float = lerpf(frequency * pitch_end, frequency, progress)
		var fundamental: float = sin(TAU * current_frequency * t)
		var harmonic: float = sin(TAU * current_frequency * 2.01 * t) * 0.16
		samples[i] = (fundamental + harmonic) * envelope * volume

	return _make_stream(samples, false)

func _make_engine_loop() -> AudioStreamWAV:
	var count: int = int(float(SAMPLE_RATE) * ENGINE_SECONDS)
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(count)

	for i: int in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var phase: float = TAU * 62.0 * t
		var pulse: float = pow(maxf(0.0, sin(phase) * 0.5 + 0.5), 3.0)
		var low_frequency: float = sin(phase) * 0.30
		var second_harmonic: float = sin(phase * 2.0) * 0.13
		var roughness: float = sin(phase * 3.0) * 0.035
		samples[i] = (low_frequency + second_harmonic + roughness + pulse * 0.20) * 0.42

	return _make_stream(samples, true)

func _make_music_loop() -> AudioStreamWAV:
	var count: int = SAMPLE_RATE * MUSIC_SECONDS
	var samples: PackedFloat32Array = PackedFloat32Array()
	samples.resize(count)

	var roots: Array[float] = [110.0, 130.81, 146.83, 98.0, 110.0, 164.81, 146.83, 98.0]
	var melody_intervals: Array[float] = [2.0, 2.5, 3.0, 2.5, 2.0, 1.5, 2.5, 3.0]
	var beat_seconds: float = 0.5

	for i: int in range(count):
		var t: float = float(i) / float(SAMPLE_RATE)
		var chord_index: int = int(floor(t / 2.0)) % roots.size()
		var root: float = roots[chord_index]
		var beat_index: int = int(floor(t / beat_seconds))
		var melody_index: int = beat_index % melody_intervals.size()
		var melody_note: float = root * melody_intervals[melody_index]

		var slow_breath: float = 0.90 + 0.10 * sin(TAU * 0.12 * t)
		var pad: float = sin(TAU * root * t) * 0.30
		pad += sin(TAU * root * 1.5 * t) * 0.13
		pad += sin(TAU * root * 2.0 * t) * 0.08

		var note_phase: float = fposmod(t, beat_seconds) / beat_seconds
		var note_envelope: float = exp(-note_phase * 4.0)
		var melody: float = sin(TAU * melody_note * t) * note_envelope * 0.10
		var bass: float = sin(TAU * (root * 0.5) * t) * 0.12
		samples[i] = (pad + melody + bass) * slow_breath * 0.24

	return _make_stream(samples, true)

func play_sfx(kind: String) -> void:
	if effects.has(kind):
		effects_player.stream = effects[kind] as AudioStream
		effects_player.play()

func set_engine_active(active: bool, speed_ratio: float = 0.0) -> void:
	if active:
		if not engine_player.playing:
			engine_player.play()
		engine_player.pitch_scale = clampf(0.78 + speed_ratio * 0.72, 0.75, 1.65)
	elif engine_player.playing:
		engine_player.stop()

func set_music_enabled(enabled: bool) -> void:
	if enabled and not music_player.playing:
		music_player.play()
	elif not enabled and music_player.playing:
		music_player.stop()
