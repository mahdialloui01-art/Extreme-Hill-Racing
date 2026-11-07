extends Node3D

const TerrainScript = preload("res://scripts/terrain_3d.gd")
const CarScript = preload("res://scripts/car_3d.gd")

var terrain: HillTerrain3D
var car: HillCar3D
var camera: Camera3D
var speed_label: Label
var distance_label: Label
var status_label: Label
var best_distance := 0.0
var start_x := 12.0

func _ready() -> void:
	_setup_environment()
	_build_world()
	_build_hud()

func _setup_environment() -> void:
	var world := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("#39739a")
	sky_mat.sky_horizon_color = Color("#c5d7d0")
	sky_mat.ground_bottom_color = Color("#283b35")
	sky_mat.ground_horizon_color = Color("#899b8d")
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#b6c8d5")
	env.ambient_light_energy = 0.72
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = env
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -28, 0)
	sun.light_color = Color("#fff0d7")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	add_child(sun)

func _build_world() -> void:
	terrain = TerrainScript.new()
	terrain.name = "3D_Mountain_Track"
	add_child(terrain)
	car = CarScript.new()
	car.name = "Rally_SUV"
	add_child(car)
	car.global_position = Vector3(start_x, terrain.height_at(start_x) + 1.65, 0)
	camera = Camera3D.new()
	camera.name = "SideFollowCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 13.5
	camera.position = Vector3(0, 4.8, 25.0)
	camera.current = true
	add_child(camera)
	camera.look_at(car.global_position + Vector3(2.0, 1.3, 0), Vector3.UP)

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
	title.position = Vector2(28, 18)
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(title)
	speed_label = Label.new()
	speed_label.position = Vector2(30, 55)
	speed_label.add_theme_font_size_override("font_size", 21)
	speed_label.add_theme_color_override("font_color", Color("#ffe0a3"))
	root.add_child(speed_label)
	distance_label = Label.new()
	distance_label.position = Vector2(30, 84)
	distance_label.add_theme_font_size_override("font_size", 18)
	distance_label.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(distance_label)
	status_label = Label.new()
	status_label.anchor_left = 0.5
	status_label.anchor_right = 0.5
	status_label.offset_left = -260
	status_label.offset_right = 260
	status_label.offset_top = 24
	status_label.offset_bottom = 58
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(status_label)
	var gas := _make_button(root, "GAS  ▶", 1.0, Vector2(-225, -145), Vector2(-30, -32), Color("#d94b2e"))
	var brake := _make_button(root, "◀  BRAKE", 0.0, Vector2(30, -145), Vector2(225, -32), Color("#245b86"))
	gas.button_down.connect(func(): car.set_controls(true, car.touch_brake))
	gas.button_up.connect(func(): car.set_controls(false, car.touch_brake))
	brake.button_down.connect(func(): car.set_controls(car.touch_accelerate, true))
	brake.button_up.connect(func(): car.set_controls(car.touch_accelerate, false))
	var restart := Button.new()
	restart.text = "↻"
	restart.anchor_left = 1.0
	restart.anchor_right = 1.0
	restart.offset_left = -98
	restart.offset_top = 18
	restart.offset_right = -22
	restart.offset_bottom = 80
	restart.add_theme_font_size_override("font_size", 30)
	restart.tooltip_text = "Restart run"
	restart.pressed.connect(_restart)
	root.add_child(restart)

func _make_button(parent: Control, caption: String, horizontal_anchor: float, from_offset: Vector2, to_offset: Vector2, tint: Color) -> Button:
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
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_color_override("font_color", Color.WHITE)
	var style := StyleBoxFlat.new()
	style.bg_color = tint
	style.corner_radius_top_left = 22
	style.corner_radius_top_right = 22
	style.corner_radius_bottom_left = 22
	style.corner_radius_bottom_right = 22
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(1, 1, 1, 0.45)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("pressed", style)
	parent.add_child(button)
	return button

func _process(delta: float) -> void:
	if not is_instance_valid(car):
		return
	var speed := absf(car.velocity.x) * 3.6
	var distance := maxf(0.0, (car.global_position.x - start_x) / 10.0)
	speed_label.text = "SPEED   %03d km/h" % int(speed)
	distance_label.text = "DISTANCE   %04d m" % int(distance)
	best_distance = maxf(best_distance, distance)
	status_label.text = "CRASHED!  TAP RESTART" if car.crashed else "BEST   %04d m     •     HOLD GAS TO CLIMB" % int(best_distance)
	if is_instance_valid(camera):
		var target := car.global_position + Vector3(2.0, 2.2, 25.0)
		camera.global_position = camera.global_position.lerp(target, minf(1.0, delta * 3.0))
		camera.look_at(car.global_position + Vector3(2.0, 1.2, 0), Vector3.UP)

func _restart() -> void:
	car.reset_car(Vector3(start_x, terrain.height_at(start_x) + 1.65, 0))
	camera.global_position = car.global_position + Vector3(2.0, 4.8, 25.0)
	camera.look_at(car.global_position + Vector3(2.0, 1.3, 0), Vector3.UP)
