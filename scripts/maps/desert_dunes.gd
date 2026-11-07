extends "res://scripts/stage_map_base.gd"
class_name DesertDunesMap

func height_at(x: float) -> float:
	var dune_a := sin(x * 0.00115) * 8.0
	var dune_b := sin(x * 0.00225 + 1.2) * 3.0
	var wind_ripples := sin(x * 0.0065) * 0.55
	var dry_wadi := -absf(sin(x * 0.00053 + 0.6)) * 2.0
	return 2.5 + dune_a + dune_b + wind_ripples + dry_wadi

func _build_scenery() -> void:
	for i in range(520):
		var x := rng.randf_range(25.0, WORLD_END - 25.0)
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		var z := side * rng.randf_range(10.0, 34.0)
		var pos := Vector3(x, height_at(x), z)
		if i % 4 == 0:
			_add_rock(pos, rng.randf_range(0.8, 1.8))
		elif i % 4 == 1:
			_add_cactus(pos, rng.randf_range(0.8, 1.5))
		else:
			_add_landmark_column("DesertSandstoneStack", pos, rng.randf_range(1.5, 4.5), rng.randf_range(0.45, 1.0), Color("#bd9059"))

func _add_cactus(pos: Vector3, scale_value: float) -> void:
	var green := Color("#477044")
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.24
	trunk.bottom_radius = 0.34
	trunk.height = 2.8
	_add_landmark_mesh("SaguaroCactus", pos + Vector3(0.0, 1.4, 0.0), trunk, green, Vector3.ONE * scale_value)
	for side in [-1.0, 1.0]:
		var arm := CylinderMesh.new()
		arm.top_radius = 0.13
		arm.bottom_radius = 0.16
		arm.height = 1.15
		var arm_node := _add_landmark_mesh("CactusArm", pos + Vector3(side * 0.48, 1.45, 0.0), arm, green, Vector3.ONE * scale_value)
		arm_node.rotation.z = side * -0.9

func _build_unique_landmarks() -> void:
	var sandstone := Color("#c18b51")
	for x in [560.0, 1720.0, 2890.0, 4210.0, 5350.0]:
		var y := height_at(x)
		for j in range(4):
			_add_landmark_column("DesertMonolith", Vector3(x + float(j) * 3.2, y, -13.0), 7.0 + float(j % 2) * 4.0, 1.15, sandstone)
		_add_landmark_box("AncientDesertLintel", Vector3(x + 4.5, y + 10.0, -13.0), Vector3(14.0, 1.4, 1.4), sandstone)
