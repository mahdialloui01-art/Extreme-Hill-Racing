extends Node2D

const TerrainScript = preload("res://scripts/terrain.gd")
const CarScript = preload("res://scripts/car.gd")

var terrain
var car
var camera: Camera2D
var speed_label: Label
var distance_label: Label
var message_label: Label
var accelerate_button: Button
var brake_button: Button
var start_x := 0.0
var best_distance := 0.0

func _ready() -> void:
	_build_world()
	_build_hud()
	queue_redraw()

func _build_world() -> void:
	terrain = TerrainScript.new()
	terrain.name = "DetailedMountainRoad"
	add_child(terrain)

	car = CarScript.new()
	car.name = "PlayerCar"
	car.z_index = 5
	add_child(car)
	start_x = 130.0
	car.global_position = Vector2(start_x, terrain.get_height_at(start_x) - 42.0)

	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 4.0
	camera.zoom = Vector2(0.78, 0.78)
	car.add_child(camera)
	camera.position = Vector2(155.0, -145.0)
	camera.make_current()

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var title := Label.new()
	title.text = "EXTREME  /  HILL RACING"
	title.position = Vector2(28, 20)
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	root.add_child(title)

	speed_label = Label.new()
	speed_label.position = Vector2(30, 60)
	speed_label.add_theme_font_size_override("font_size", 22)
	speed_label.add_theme_color_override("font_color", Color(1.0, 0.91, 0.62))
	root.add_child(speed_label)

	distance_label = Label.new()
	distance_label.position = Vector2(30, 91)
	distance_label.add_theme_font_size_override("font_size", 19)
	distance_label.add_theme_color_override("font_color", Color(1, 1, 1))
	root.add_child(distance_label)

	message_label = Label.new()
	message_label.text = "HOLD GAS TO ACCELERATE  •  BRAKE TO SLOW DOWN"
	message_label.anchor_left = 0.5
	message_label.anchor_right = 0.5
	message_label.offset_left = -320
	message_label.offset_right = 320
	message_label.offset_top = 24
	message_label.offset_bottom = 60
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	root.add_child(message_label)

	accelerate_button = _make_control_button(root, "GAS  ▶", 1.0, Vector2(-220, -142), Vector2(-35, -35), Color(0.91, 0.27, 0.10, 0.96))
	brake_button = _make_control_button(root, "◀  BRAKE", 0.0, Vector2(35, -142), Vector2(220, -35), Color(0.10, 0.28, 0.46, 0.96))
	accelerate_button.button_down.connect(_on_accelerate_down)
	accelerate_button.button_up.connect(_on_accelerate_up)
	brake_button.button_down.connect(_on_brake_down)
	brake_button.button_up.connect(_on_brake_up)

	var restart := Button.new()
	restart.text = "↻"
	restart.position = Vector2(1170, 22)
	restart.size = Vector2(76, 62)
	restart.add_theme_font_size_override("font_size", 30)
	restart.pressed.connect(_restart)
	root.add_child(restart)

func _make_control_button(parent: Control, caption: String, horizontal_anchor: float, from_offset: Vector2, to_offset: Vector2, color: Color) -> Button:
	var button := Button.new()
	button.text = caption
	button.anchor_left = horizontal_anchor
	button.anchor_right = horizontal_anchor
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = from_offset.x
	button.offset_top = from_offset.y
	button.offset_right = to_offset.x
	button.offset_bottom = to_offset.y
	button.add_theme_font_size_override("font_size", 23)
	button.add_theme_color_override("font_color", Color.WHITE)
	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.corner_radius_top_left = 24
	normal.corner_radius_top_right = 24
	normal.corner_radius_bottom_left = 24
	normal.corner_radius_bottom_right = 24
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.border_color = Color(1, 1, 1, 0.42)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("pressed", normal)
	parent.add_child(button)
	return button

func _process(_delta: float) -> void:
	if not is_instance_valid(car):
		return
	var speed := absf(car.velocity.x) * 0.12
	var distance := maxf(0.0, (car.global_position.x - start_x) / 10.0)
	speed_label.text = "SPEED   %03d km/h" % int(speed)
	distance_label.text = "DISTANCE   %04d m" % int(distance)
	best_distance = maxf(best_distance, distance)
	if car.crashed:
		message_label.text = "CRASHED!  TAP RESTART TO TRY AGAIN"
	else:
		message_label.text = "BEST   %04d m     •     HOLD GAS TO CLIMB" % int(best_distance)
	queue_redraw()

func _draw() -> void:
	var center_x := 0.0
	var center_y := 0.0
	if is_instance_valid(camera):
		center_x = camera.global_position.x
		center_y = camera.global_position.y
	draw_rect(Rect2(Vector2(center_x - 2400, center_y - 1800), Vector2(5000, 3600)), Color(0.36, 0.66, 0.82, 1.0))

	# Distant mountain layers create a 2.5D parallax illusion.
	var far_points := PackedVector2Array()
	far_points.append(Vector2(center_x - 2200, center_y + 120))
	for i in range(17):
		var px := center_x * 0.28 - 1800.0 + float(i) * 230.0
		var py := center_y * 0.30 + 80.0 - absf(sin(float(i) * 1.7)) * 240.0
		far_points.append(Vector2(px, py))
	far_points.append(Vector2(center_x + 2400, center_y + 500))
	far_points.append(Vector2(center_x - 2400, center_y + 500))
	draw_colored_polygon(far_points, Color(0.48, 0.65, 0.65, 1.0))

	var near_points := PackedVector2Array()
	near_points.append(Vector2(center_x - 2200, center_y + 300))
	for i in range(17):
		var px := center_x * 0.52 - 1800.0 + float(i) * 230.0
		var py := center_y * 0.48 + 240.0 - absf(cos(float(i) * 1.35)) * 190.0
		near_points.append(Vector2(px, py))
	near_points.append(Vector2(center_x + 2400, center_y + 650))
	near_points.append(Vector2(center_x - 2400, center_y + 650))
	draw_colored_polygon(near_points, Color(0.29, 0.49, 0.48, 1.0))

	var sun_pos := Vector2(center_x + 760, center_y - 390)
	draw_circle(sun_pos, 82.0, Color(1.0, 0.84, 0.52, 0.10))
	draw_circle(sun_pos, 54.0, Color(1.0, 0.88, 0.61, 0.95))

	# Soft cloud silhouettes at a slower parallax speed.
	for i in range(6):
		var cloud_x := center_x * 0.18 + float(i) * 390.0 - 1100.0
		var cloud_y := center_y * 0.16 - 300.0 + float((i * 37) % 130)
		var cloud_color := Color(0.91, 0.96, 0.96, 0.52)
		draw_circle(Vector2(cloud_x, cloud_y), 30, cloud_color)
		draw_circle(Vector2(cloud_x + 35, cloud_y - 10), 39, cloud_color)
		draw_circle(Vector2(cloud_x + 72, cloud_y + 2), 27, cloud_color)

func _on_accelerate_down() -> void:
	car.set_controls(true, car.touch_brake)

func _on_accelerate_up() -> void:
	car.set_controls(false, car.touch_brake)

func _on_brake_down() -> void:
	car.set_controls(car.touch_accelerate, true)

func _on_brake_up() -> void:
	car.set_controls(car.touch_accelerate, false)

func _restart() -> void:
	var spawn := Vector2(start_x, terrain.get_height_at(start_x) - 42.0)
	car.reset_car(spawn)
	camera.position = Vector2(155.0, -145.0)
