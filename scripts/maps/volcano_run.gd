extends "res://scripts/stage_map_base.gd"
class_name VolcanoRunMap

func height_at(x: float) -> float:
	var volcanic_ridge := sin(x * 0.00108 + 0.9) * 9.0 + sin(x * 0.00029) * 6.5
	var basalt_steps := absf(sin(x * 0.0052 + 0.2)) * 3.6
	var crater_bowls := -pow(maxf(0.0, sin(x * 0.00074)), 3.0) * 3.0
	return 3.0 + volcanic_ridge + basalt_steps + crater_bowls

func _build_scenery() -> void:
	for i in range(640):
		var x := rng.randf_range(25.0, WORLD_END - 25.0)
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		var z := side * rng.randf_range(9.0, 34.0)
		var pos := Vector3(x, height_at(x), z)
		if i % 3 == 0:
			_add_lava_vent(pos)
		else:
			_add_rock(pos, rng.randf_range(1.0, 2.3))

func _add_lava_vent(pos: Vector3) -> void:
	var basalt := Color("#342b2a")
	var rim := CylinderMesh.new()
	rim.top_radius = 1.15
	rim.bottom_radius = 1.35
	rim.height = 1.2
	_add_landmark_mesh("BasaltLavaVent", pos + Vector3(0.0, 0.6, 0.0), rim, basalt)
	var lava := CylinderMesh.new()
	lava.top_radius = 0.78
	lava.bottom_radius = 0.78
	lava.height = 0.12
	_add_landmark_mesh("MoltenLavaCore", pos + Vector3(0.0, 1.24, 0.0), lava, Color("#ff5b22"), Vector3.ONE, true)

func _build_unique_landmarks() -> void:
	var obsidian := Color("#393237")
	for x in [620.0, 1840.0, 3060.0, 4320.0, 5580.0]:
		var y := height_at(x)
		for j in range(10):
			_add_landmark_spire("ObsidianSpire", Vector3(x - 12.0 + float(j) * 2.7, y, -14.0), rng.randf_range(4.0, 11.0), 1.25, obsidian)
		_add_lava_vent(Vector3(x + 8.0, y, 8.0))
		_add_landmark_box("VolcanicBasaltShelf", Vector3(x, y + 0.45, 0.0), Vector3(16.0, 0.8, 11.0), Color("#49302c"))
