extends Node2D
class_name HillTerrain

const STEP := 28.0
const WORLD_END := 18000.0
const WORLD_START := -1400.0
const GROUND_BOTTOM := 2800.0

var _height_points: PackedVector2Array = PackedVector2Array()

func _ready() -> void:
	_build_terrain()

func _surface_y(x: float) -> float:
	return 520.0 + sin(x * 0.00082) * 165.0 + sin(x * 0.0021 + 1.2) * 74.0 + sin(x * 0.00031 + 0.8) * 205.0 + maxf(0.0, sin(x * 0.00061 + 0.5)) * 105.0 + sin(x * 0.0054 + 2.0) * 8.0

func _build_terrain() -> void:
	var x := WORLD_START
	while x <= WORLD_END:
		_height_points.append(Vector2(x, _surface_y(x)))
		x += STEP

	var fill_points := _height_points.duplicate()
	fill_points.append(Vector2(WORLD_END, GROUND_BOTTOM))
	fill_points.append(Vector2(WORLD_START, GROUND_BOTTOM))

	var deep := Polygon2D.new()
	deep.polygon = fill_points
	deep.color = Color("#27352f")
	deep.z_index = -5
	add_child(deep)

	var strata_points := PackedVector2Array()
	for p in _height_points:
		strata_points.append(p + Vector2(0, 38))
	for i in range(_height_points.size() - 1, -1, -1):
		strata_points.append(Vector2(_height_points[i].x, GROUND_BOTTOM))
	var strata := Polygon2D.new()
	strata.polygon = strata_points
	strata.color = Color("#76503a")
	strata.z_index = -4
	add_child(strata)

	var soil_highlight := Line2D.new()
	soil_highlight.points = _height_points
	soil_highlight.width = 38.0
	soil_highlight.default_color = Color("#554334")
	soil_highlight.joint_mode = Line2D.LINE_JOINT_ROUND
	soil_highlight.z_index = -2
	add_child(soil_highlight)

	var road_base := Line2D.new()
	road_base.points = _height_points
	road_base.width = 30.0
	road_base.default_color = Color("#493d32")
	road_base.joint_mode = Line2D.LINE_JOINT_ROUND
	road_base.begin_cap_mode = Line2D.LINE_CAP_ROUND
	road_base.end_cap_mode = Line2D.LINE_CAP_ROUND
	road_base.z_index = 0
	add_child(road_base)

	var road_surface := Line2D.new()
	road_surface.points = _height_points
	road_surface.width = 20.0
	road_surface.default_color = Color("#a17a52")
	road_surface.joint_mode = Line2D.LINE_JOINT_ROUND
	road_surface.begin_cap_mode = Line2D.LINE_CAP_ROUND
	road_surface.end_cap_mode = Line2D.LINE_CAP_ROUND
	road_surface.z_index = 1
	add_child(road_surface)

	var road_light := Line2D.new()
	road_light.points = _height_points
	road_light.width = 3.0
	road_light.default_color = Color("#d0a878")
	road_light.joint_mode = Line2D.LINE_JOINT_ROUND
	road_light.z_index = 2
	add_child(road_light)

	var collision_points := _height_points.duplicate()
	collision_points.append(Vector2(WORLD_END, GROUND_BOTTOM))
	collision_points.append(Vector2(WORLD_START, GROUND_BOTTOM))
	var body := StaticBody2D.new()
	body.name = "GroundBody"
	add_child(body)
	var collision := CollisionPolygon2D.new()
	collision.polygon = collision_points
	body.add_child(collision)

	_add_track_detail()
	_add_cliffs_and_grass()

func _add_track_detail() -> void:
	for i in range(3, _height_points.size() - 3, 5):
		var p := _height_points[i]
		var seed_value := float((i * 37) % 17)
		var pebble := Polygon2D.new()
		var r := 1.5 + seed_value * 0.22
		pebble.polygon = PackedVector2Array([Vector2(-r, 0), Vector2(-r * 0.4, -r * 0.7), Vector2(r, -r * 0.3), Vector2(r * 0.7, r * 0.5)])
		pebble.position = p + Vector2(0, 9.0 + seed_value * 0.25)
		pebble.color = Color("#d0aa7c") if i % 2 == 0 else Color("#5c493a")
		pebble.z_index = 3
		add_child(pebble)

	for i in range(8, _height_points.size() - 8, 13):
		var p := _height_points[i]
		var rut := Line2D.new()
		rut.points = PackedVector2Array([p + Vector2(-8, 7), p + Vector2(0, 8), p + Vector2(8, 7)])
		rut.width = 1.5
		rut.default_color = Color(0.28, 0.21, 0.16, 0.45)
		rut.z_index = 3
		add_child(rut)

func _add_cliffs_and_grass() -> void:
	for i in range(4, _height_points.size() - 5, 8):
		var p := _height_points[i]
		for blade in range(3):
			var h := 9.0 + float((i * 11 + blade * 7) % 13)
			var grass := Line2D.new()
			grass.points = PackedVector2Array([p + Vector2(float(blade * 4 - 4), 2), p + Vector2(float(blade * 5 - 5), -h)])
			grass.width = 2.2
			grass.default_color = Color("#8c9b58") if blade % 2 == 0 else Color("#667d49")
			grass.z_index = 4
			add_child(grass)

	for i in range(12, _height_points.size() - 12, 24):
		var p := _height_points[i]
		var boulder := Polygon2D.new()
		var s := 13.0 + float((i * 19) % 23)
		boulder.polygon = PackedVector2Array([Vector2(-s, 0), Vector2(-s * 0.8, -s * 0.55), Vector2(-s * 0.2, -s), Vector2(s * 0.55, -s * 0.75), Vector2(s, 0)])
		boulder.position = p + Vector2(0, 48 + s * 0.2)
		boulder.color = Color("#596057")
		boulder.z_index = -1
		add_child(boulder)

func get_height_at(world_x: float) -> float:
	if _height_points.is_empty():
		return _surface_y(world_x)
	var index := clampi(int(floor((world_x - WORLD_START) / STEP)), 0, _height_points.size() - 2)
	var a := _height_points[index]
	var b := _height_points[index + 1]
	var weight := clampf((world_x - a.x) / maxf(1.0, b.x - a.x), 0.0, 1.0)
	return lerpf(a.y, b.y, weight)
