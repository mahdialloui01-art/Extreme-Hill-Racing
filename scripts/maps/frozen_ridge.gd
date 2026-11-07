extends "res://scripts/stage_map_base.gd"
class_name FrozenRidgeMap

func height_at(x: float) -> float:
	var alpine := sin(x * 0.00122 + 0.5) * 8.8 + sin(x * 0.00037) * 6.0
	var glacier_waves := sin(x * 0.0038) * 2.0
	var crevasses := -pow(absf(sin(x * 0.0019 + 0.4)), 5.0) * 2.5
	return 4.0 + alpine + glacier_waves + crevasses

func _build_scenery() -> void:
	for i in range(570):
		var x := rng.randf_range(25.0, WORLD_END - 25.0)
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		var z := side * rng.randf_range(9.0, 32.0)
		var pos := Vector3(x, height_at(x), z)
		if i % 3 == 0:
			_add_tree(pos, rng.randf_range(0.7, 1.25))
		else:
			_add_ice_spike(pos, rng.randf_range(1.3, 3.5))

func _add_ice_spike(pos: Vector3, height: float) -> void:
	var ice := Color("#b9e5f2")
	var shard := PrismMesh.new()
	shard.size = Vector3(height * 0.55, height, height * 0.5)
	var node := _add_landmark_mesh("GlacierCrystal", pos + Vector3.UP * height * 0.5, shard, ice)
	node.rotation.z = rng.randf_range(-0.16, 0.16)

func _build_unique_landmarks() -> void:
	var ice := Color("#9bd6eb")
	for x in [650.0, 1780.0, 3000.0, 4320.0, 5520.0]:
		var y := height_at(x)
		for j in range(9):
			var z := -15.0 + float(j) * 3.6
			_add_ice_spike(Vector3(x + rng.randf_range(-2.0, 2.0), y, z), rng.randf_range(5.0, 12.0))
		_add_landmark_box("GlacierIceWall", Vector3(x + 9.0, y + 2.0, 0.0), Vector3(2.0, 4.0, 13.0), ice)
