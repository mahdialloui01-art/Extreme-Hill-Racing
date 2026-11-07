extends "res://scripts/stage_map_base.gd"
class_name RockPassMap

func height_at(x: float) -> float:
	var canyon := sin(x * 0.00105 + 0.4) * 8.5 + sin(x * 0.00031) * 5.5
	var broken_shelves := absf(sin(x * 0.0048)) * 3.2
	var cliff_steps := sin(x * 0.009 + 0.7) * 1.4
	return 2.0 + canyon + broken_shelves + cliff_steps

func _build_scenery() -> void:
	for i in range(620):
		var x := rng.randf_range(25.0, WORLD_END - 25.0)
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		var z := side * rng.randf_range(9.0, 33.0)
		var scale_value := rng.randf_range(0.9, 2.2)
		_add_rock(Vector3(x, height_at(x), z), scale_value)
		if i % 9 == 0:
			_add_landmark_column("BrokenCanyonColumn", Vector3(x, height_at(x), z), rng.randf_range(4.0, 10.0), rng.randf_range(0.7, 1.5), Color("#9b8064"))

func _build_unique_landmarks() -> void:
	var stone := Color("#9d8063")
	for x in [700.0, 1900.0, 3150.0, 4650.0, 5550.0]:
		var y := height_at(x)
		for side in [-1.0, 1.0]:
			_add_landmark_column("CanyonArchPillar", Vector3(x, y, side * 5.8), 9.0 + float(int(x) % 3) * 2.0, 1.15, stone)
		_add_landmark_box("CanyonArchLintel", Vector3(x, y + 10.0, 0.0), Vector3(3.2, 2.2, 14.0), stone, 0.08)
		for j in range(7):
			_add_landmark_spire("JaggedCanyonTooth", Vector3(x - 10.0 + float(j) * 3.2, y + 1.0, 12.0), rng.randf_range(3.0, 8.0), 1.2, stone)
