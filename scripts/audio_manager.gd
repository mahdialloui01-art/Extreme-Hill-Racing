extends Node
class_name RacingAudioManager

var music_player: AudioStreamPlayer
var engine_player: AudioStreamPlayer
var effects_player: AudioStreamPlayer
var effects: Dictionary = {}

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "ProceduralMountainMusic"
	music_player.stream = _make_music_loop()
	music_player.volume_db = -19.0
	add_child(music_player)
	music_player.play()
	engine_player = AudioStreamPlayer.new()
	engine_player.name = "ProceduralEngineLoop"
	engine_player.stream = _make_engine_loop()
	engine_player.volume_db = -15.0
	add_child(engine_player)
	effects_player = AudioStreamPlayer.new()
	effects_player.name = "RacingSoundEffects"
	add_child(effects_player)
	effects["coin"] = _make_tone(880.0, 0.16, 0.75)
	effects["fuel"] = _make_tone(520.0, 0.34, 0.65)
	effects["crash"] = _make_tone(95.0, 0.48, 0.95)
	effects["finish"] = _make_tone(660.0, 0.72, 0.72)
	effects["upgrade"] = _make_tone(740.0, 0.25, 0.55)

func _make_stream(samples: PackedFloat32Array, looped: bool) -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.stereo = false
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in range(samples.size()):
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	stream.data = bytes
	if looped:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = samples.size()
	return stream

func _make_tone(frequency: float, duration: float, volume: float) -> AudioStreamWAV:
	var count := int(22050.0 * duration)
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in range(count):
		var t := float(i) / 22050.0
		var envelope := pow(maxf(0.0, 1.0 - float(i) / float(count)), 1.7)
		var sweep := frequency * (1.0 + 0.12 * (1.0 - float(i) / float(count)))
		samples[i] = sin(TAU * sweep * t) * envelope * volume
	return _make_stream(samples, false)

func _make_engine_loop() -> AudioStreamWAV:
	var count := 22050
	var samples := PackedFloat32Array()
	samples.resize(count)
	for i in range(count):
		var t := float(i) / 22050.0
		var phase := TAU * 62.0 * t
		var pulse := pow(maxf(0.0, sin(phase) * 0.5 + 0.5), 3.0)
		samples[i] = (sin(phase) * 0.28 + sin(phase * 2.0) * 0.12 + pulse * 0.22) * 0.42
	return _make_stream(samples, true)

func _make_music_loop() -> AudioStreamWAV:
	var count := 22050 * 8
	var samples := PackedFloat32Array()
	samples.resize(count)
	var roots := [110.0, 130.81, 146.83, 98.0]
	for i in range(count):
		var t := float(i) / 22050.0
		var chord_index := int(floor(t / 2.0)) % roots.size()
		var root: float = roots[chord_index]
		var pulse := 0.82 + 0.18 * sin(TAU * 1.5 * t)
		var pad := sin(TAU * root * t) * 0.34
		pad += sin(TAU * root * 1.5 * t) * 0.16
		pad += sin(TAU * root * 2.0 * t) * 0.10
		var melody_note := root * [2.0, 2.5, 3.0, 2.5][int(floor(t * 2.0)) % 4]
		var melody := sin(TAU * melody_note * t) * 0.08
		samples[i] = (pad + melody) * pulse * 0.22
	return _make_stream(samples, true)

func play_sfx(kind: String) -> void:
	if effects.has(kind):
		effects_player.stream = effects[kind]
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
