extends Node2D
class_name HillTerrain

const STEP := 55.0
const WORLD_END := 14000.0
const WORLD_START := -1200.0
const GROUND_BOTTOM := 2600.0

var _height_points: PackedVector2Array = PackedVector2Array()

func _ready() -> void:
	_build_terrain()

func _build_terrain() -> void:
	var x := WORLD_START
	while x <= WORLD_END:
		var y := 500.0
		y += sin(x * 0.00105) * 125.0
		y += sin(x * 0.00265 + 1.4) * 52.0
		y += sin(x * 0.00038 + 0.8) * 155.0
		y += maxf(0.0, sin(x * 0.00072 + 0.5)) * 88.0
		y += sin(x * 0.0048 + 2.0) * 9.0
		_height_points.append(Vector2(x, y))
		x += STEP

	var polygon_points := _height_points.duplicate()
	polygon_points.append(Vector2(WORLD_END, GROUND_BOTTOM))
	polygon_points.append(Vector2(WORLD_START, GROUND_BOTTOM))

	var deep_layer := Polygon2D.new()
	deep_layer.polygon = polygon_points
	deep_layer.color = Color(0.20, 0.29, 0.25, 1.0)
	deep_layer.z_index = -3
	add_child(deep_layer)

	var soil := Polygon2D.new()
	var soil_points := PackedVector2Array()
	for point in _height_points:
		soil_points.append(point + Vector2(0, 30))
	for i in range(_height_points.size() - 1, -1, -1):
		soil_points.append(Vector2(_height_points[i].x, GROUND_BOTTOM))
	soil.polygon = soil_points
	soil.color = Color(0.48, 0.29, 0.17, 1.0)
	soil.z_index = -2
	add_child(soil)

	var fill := Polygon2D.new()
	fill.polygon = polygon_points
	fill.color = Color(0.29, 0.43, 0.25, 1.0)
	fill.z_index = -1
	add_child(fill)

	var rock_line := Line2D.new()
	rock_line.points = _height_points
	rock_line.width = 24.0
	rock_line.default_color = Color(0.39, 0.43, 0.32, 1.0)
	rock_line.joint_mode = Line2D.LINE_JOINT_ROUND
	rock_line.z_index = 0
	add_child(rock_line)

	var top_line := Line2D.new()
	top_line.points = _height_points
	top_line.width = 9.0
	top_line.default_color = Color(0.70, 0.83, 0.43, 1.0)
	top_line.joint_mode = Line2D.LINE_JOINT_ROUND
	top_line.z_index = 1
	add_child(top_line)

	_add_surface_details()

	var body := StaticBody2D.new()
	body.name = "GroundBody"
	body.collision_layer = 1
	body.collision_mask = 1
	add_child(body)

	var collision := CollisionPolygon2D.new()
	collision.polygon = polygon_points
	collision.build_mode = CollisionPolygon2D.BUILD_SOLIDS
	body.add_child(collision)

func _add_surface_details() -> void:
	for i in range(2, _height_points.size() - 2, 3):
		var point := _height_points[i]
		var tuft := Line2D.new()
		var height := 7.0 + float((i * 13) % 10)
		tuft.points = PackedVector2Array([point + Vector2(-4, -1), point + Vector2(-7, -height), point + Vector2(-1, -4), point + Vector2(3, -height - 3)])
		tuft.width = 2.5
		tuft.default_color = Color(0.77, 0.86, 0.48, 0.85)
		tuft.z_index = 2
		add_child(tuft)

	for i in range(5, _height_points.size() - 4, 9):
		var point := _height_points[i]
		var rock := Polygon2D.new()
		var size := 5.0 + float((i * 7) % 9)
		rock.polygon = PackedVector2Array([
			Vector2(-size, 0), Vector2(-size * 0.55, -size * 0.65),
			Vector2(size * 0.35, -size), Vector2(size, 0)
		])
		rock.position = point + Vector2(0, 24)
		rock.color = Color(0.34, 0.35, 0.29, 0.8)
		rock.z_index = 1
		add_child(rock)

func get_height_at(world_x: float) -> float:
	if _height_points.is_empty():
		return 500.0
	var index := clampi(int(floor((world_x - WORLD_START) / STEP)), 0, _height_points.size() - 2)
	var a := _height_points[index]
	var b := _height_points[index + 1]
	var weight := clampf((world_x - a.x) / maxf(1.0, b.x - a.x), 0.0, 1.0)
	return lerpf(a.y, b.y, weight)
