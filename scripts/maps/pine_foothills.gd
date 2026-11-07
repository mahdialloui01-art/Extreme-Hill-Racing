extends "res://scripts/stage_map_base.gd"
class_name PineFoothillsMap

func height_at(x: float) -> float:
	var rolling := sin(x * 0.00135) * 7.0 + sin(x * 0.00048 + 0.8) * 5.0
	var forest_ridges := sin(x * 0.0034 + 0.3) * 2.1
	var creek_dips := -absf(sin(x * 0.00082)) * 2.2
	return 3.0 + rolling + forest_ridges + creek_dips

func _build_scenery() -> void:
	for i in range(560):
		var x := rng.randf_range(25.0, WORLD_END - 25.0)
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		var z := side * rng.randf_range(9.0, 31.0)
		var pos := Vector3(x, height_at(x), z)
		if i % 5 == 0:
			_add_rock(pos, rng.randf_range(0.7, 1.5))
		else:
			_add_tree(pos, rng.randf_range(0.9, 1.8))

func _build_unique_landmarks() -> void:
	var timber := Color("#765037")
	var moss := Color("#355d3c")
	for x in [420.0, 1480.0, 2630.0, 3890.0, 5100.0]:
		var y := height_at(x)
		_add_landmark_box("PineTrailTimberBridge", Vector3(x, y + 0.55, 0.0), Vector3(12.0, 0.55, 10.5), timber)
		for side in [-1.0, 1.0]:
			for post in range(5):
				_add_landmark_column("BridgeRailPost", Vector3(x - 5.0 + float(post) * 2.5, y + 1.25, side * 4.7), 1.5, 0.13, timber)
		for j in range(4):
			_add_landmark_spire("PineCanopy", Vector3(x + float(j) * 2.0 - 3.0, y + 3.0, -12.0), 8.0 + float(j % 2) * 2.0, 2.3, moss)
