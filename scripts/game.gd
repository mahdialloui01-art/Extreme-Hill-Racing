extends Node2D

const TerrainScript = preload("res://scripts/terrain.gd")
const CarScript = preload("res://scripts/car.gd")

var terrain: Node2D
var car: CharacterBody2D
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
	terrain.name = "ProceduralHills"
	add_child(terrain)

	car = CarScript.new()
	car.name = "PlayerCar"
	car.z_index = 5
	add_child(car)
	start_x = 130.0
	car.global_position = Vector2(start_x, terrain.get_height_at(start_x) - 100.0)

	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	camera.zoom = Vector2(0.82, 0.82)
	car.add_child(camera)
	camera.position = Vector2(170.0, -150.0)
	camera.make_current()

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var title := Label.new()
	title.text = "EXTREME  /  HILL RACING"
	title.position = Vector2(28, 22)
	title.add_theme_font_size_override("font_size", 27)
	title.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	root.add_child(title)

	speed_label = Label.new()
	speed_label.position = Vector2(30, 62)
	speed_label.add_theme_font_size_override("font_size", 21)
	speed_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.68))
	root.add_child(speed_label)

	distance_label = Label.new()
	distance_label.position = Vector2(30, 91)
	distance_label.add_theme_font_size_override("font_size", 19)
	distance_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	root.add_child(distance_label)

	message_label = Label.new()
	message_label.text = "HOLD RIGHT TO ACCELERATE  •  LEFT TO BRAKE / ROTATE"
	message_label.anchor_left = 0.5
	message_label.anchor_right = 0.5
	message_label.offset_left = -310
	message_label.offset_right = 310
	message_label.offset_top = 24
	message_label.offset_bottom = 60
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 16)
	message_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	root.add_child(message_label)

	accelerate_button = _make_control_button(root, "GAS  ▶", Vector2(1, 1), Vector2(-205, -125), Vector2(-35, -35), Color(0.92, 0.31, 0.12, 0.92))
	brake_button = _make_control_button(root, "◀  BRAKE", Vector2(0, 1), Vector2(35, -125), Vector2(205, -35), Color(0.12, 0.30, 0.48, 0.92))
	accelerate_button.button_down.connect(_on_accelerate_down)
	accelerate_button.button_up.connect(_on_accelerate_up)
	brake_button.button_down.connect(_on_brake_down)
	brake_button.button_up.connect(_on_brake_up)

	var restart := Button.new()
	restart.text = "↻"
	restart.position = Vector2(1180, 24)
	restart.size = Vector2(68, 58)
	restart.add_theme_font_size_override("font_size", 30)
	restart.pressed.connect(_restart)
	root.add_child(restart)

func _make_control_button(parent: Control, caption: String, anchor: Vector2, from_offset: Vector2, to_offset: Vector2, color: Color) -> Button:
	var button := Button.new()
	button.text = caption
	button.anchor_left = anchor.x
	button.anchor_right = anchor.x
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
	normal.corner_radius_top_left = 22
	normal.corner_radius_top_right = 22
	normal.corner_radius_bottom_left = 22
	normal.corner_radius_bottom_right = 22
	normal.border_width_left = 2
	normal.border_width_top = 2
	normal.border_width_right = 2
	normal.border_width_bottom = 2
	normal.border_color = Color(1, 1, 1, 0.32)
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
	var screen := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, screen), Color(0.42, 0.72, 0.92, 1.0))
	# Soft distant mountain silhouettes.
	var far := PackedVector2Array([
		Vector2(-100, 440), Vector2(120, 250), Vector2(310, 390),
		Vector2(520, 205), Vector2(760, 400), Vector2(980, 230),
		Vector2(1250, 420), Vector2(1450, 260), Vector2(1450, 800), Vector2(-100, 800)
	])
	draw_colored_polygon(far, Color(0.64, 0.79, 0.78, 0.62))
	draw_circle(Vector2(1080, 135), 58.0, Color(1.0, 0.88, 0.53, 0.95))

func _on_accelerate_down() -> void:
	car.set_controls(true, car.touch_brake)

func _on_accelerate_up() -> void:
	car.set_controls(false, car.touch_brake)

func _on_brake_down() -> void:
	car.set_controls(car.touch_accelerate, true)

func _on_brake_up() -> void:
	car.set_controls(car.touch_accelerate, false)

func _restart() -> void:
	var spawn := Vector2(start_x, terrain.get_height_at(start_x) - 100.0)
	car.reset_car(spawn)
	camera.position = Vector2(170.0, -150.0)
