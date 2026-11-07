extends Node2D
class_name HillTerrain

const STEP := 90.0
const WORLD_END := 14000.0
const GROUND_BOTTOM := 2600.0

var _height_points: PackedVector2Array = PackedVector2Array()

func _ready() -> void:
	_build_terrain()

func _build_terrain() -> void:
	var x := -1200.0
	while x <= WORLD_END:
		var y := 500.0
		y += sin(x * 0.00115) * 105.0
		y += sin(x * 0.0028 + 1.4) * 48.0
		y += sin(x * 0.00042 + 0.8) * 135.0
		# Gentle ramps with occasional sharper hills.
		y += maxf(0.0, sin(x * 0.00072 + 0.5)) * 75.0
		_height_points.append(Vector2(x, y))
		x += STEP

	var polygon_points := _height_points.duplicate()
	polygon_points.append(Vector2(WORLD_END, GROUND_BOTTOM))
	polygon_points.append(Vector2(-1200.0, GROUND_BOTTOM))

	var fill := Polygon2D.new()
	fill.polygon = polygon_points
	fill.color = Color(0.24, 0.48, 0.27, 1.0)
	fill.z_index = -1
	add_child(fill)

	var top_line := Line2D.new()
	top_line.points = _height_points
	top_line.width = 12.0
	top_line.default_color = Color(0.76, 0.88, 0.48, 1.0)
	top_line.joint_mode = Line2D.LINE_JOINT_ROUND
	add_child(top_line)

	var body := StaticBody2D.new()
	body.name = "GroundBody"
	body.collision_layer = 1
	body.collision_mask = 1
	add_child(body)

	var collision := CollisionPolygon2D.new()
	collision.polygon = polygon_points
	collision.build_mode = CollisionPolygon2D.BUILD_SOLIDS
	body.add_child(collision)

func get_height_at(world_x: float) -> float:
	if _height_points.is_empty():
		return 500.0
	var index := clampi(int(floor((world_x + 1200.0) / STEP)), 0, _height_points.size() - 2)
	var a := _height_points[index]
	var b := _height_points[index + 1]
	var weight := clampf((world_x - a.x) / maxf(1.0, b.x - a.x), 0.0, 1.0)
	return lerpf(a.y, b.y, weight)
