extends Node3D

const TerrainScript = preload("res://scripts/terrain_3d.gd")
const CarScript = preload("res://scripts/car_3d.gd")
const AudioScript = preload("res://scripts/audio_manager.gd")
const STAGE_NAMES := ["PINE FOOTHILLS", "ROCK PASS", "DESERT DUNES", "FROZEN RIDGE", "VOLCANO RUN"]
const STAGE_LENGTHS := [2400.0, 2800.0, 3200.0, 3700.0, 4200.0]
const STAGE_DIFFICULTIES := ["ROOKIE", "EASY", "MEDIUM", "HARD", "EXTREME"]

var stage_length_m := 2400.0
var current_stage := 0
var selected_stage := 0
var unlocked_stage := 0
var fuel_drain_per_second := 1.45
const FUEL_MAX := 100.0
const FUEL_DRAIN_PER_SECOND := 1.45
const COIN_REWARD := 10

var terrain: Variant
var car: Variant
var camera: Camera3D
var speed_label: Label
var distance_label: Label
var status_label: Label
var coins_label: Label
var fuel_bar: ProgressBar
var fuel_label: Label
var stage_bar: ProgressBar
var best_distance := 0.0
var start_x := 12.0
var fuel := FUEL_MAX
var coins := 0
var wallet_coins := 0
var engine_level := 0
var upgrade_button: Button
var stage_finished := false
var run_ended := false
var pickups: Array[Area3D] = []
var menu_layer: CanvasLayer
var menu_title: Label
var menu_subtitle: Label
var menu_start_button: Button
var menu_upgrade_button: Button
var menu_restart_button: Button
var stage_select: OptionButton
var audio_manager: Variant
var world_environment: WorldEnvironment
var sun_light: DirectionalLight3D
var game_started := false

func _ready() -> void:
	_load_progress()
	audio_manager = AudioScript.new()
	audio_manager.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(audio_manager)
	_setup_environment()
	_build_world()
	_build_pickups_and_hazards()
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
	world_environment = world
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-42, -28, 0)
	sun.light_color = Color("#fff0d7")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	sun_light = sun
	add_child(sun)
	_apply_stage_look()

func _build_world() -> void:
	terrain = TerrainScript.new()
	terrain.configure_stage(current_stage)
	terrain.name = "3D_Mountain_Track"
	add_child(terrain)
	car = CarScript.new()
	car.name = "Rally_SUV"
	car.engine_force = 34.0 + float(engine_level) * 5.0
	add_child(car)
	car.global_position = Vector3(start_x, terrain.height_at(start_x) + 1.65, 0)
	camera = Camera3D.new()
	camera.name = "SideFollowCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 13.5
	camera.current = true
	add_child(camera)
	camera.global_position = car.global_position + Vector3(2.0, 9.0, 22.0)
	camera.look_at(car.global_position + Vector3(2.0, 1.0, 0), Vector3.UP)

func _build_pickups_and_hazards() -> void:
	var fuel_interval := 760 - current_stage * 62
	for x in range(300, int(stage_length_m) - 120, fuel_interval):
		_spawn_pickup(Vector3(float(x), terrain.height_at(float(x)) + 1.45, 0.0), "fuel")
	for x in range(150, int(stage_length_m) - 100, 310):
		for offset in [0, 24, 48]:
			var coin_x := float(x + offset)
			_spawn_pickup(Vector3(coin_x, terrain.height_at(coin_x) + 1.9, 0.0), "coin")
	var hazard_interval := 650 - current_stage * 82
	for x in range(610, int(stage_length_m) - 100, hazard_interval):
		_spawn_log_obstacle(float(x))

func _spawn_pickup(pos: Vector3, kind: String) -> void:
	var area := Area3D.new()
	area.name = "FuelCan" if kind == "fuel" else "GoldCoin"
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 1
	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 1.15 if kind == "fuel" else 0.8
	collision.shape = sphere
	area.add_child(collision)
	var visual := MeshInstance3D.new()
	if kind == "fuel":
		var can := BoxMesh.new()
		can.size = Vector3(0.72, 0.95, 0.58)
		visual.mesh = can
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("#d94b2e")
		mat.metallic = 0.25
		mat.roughness = 0.35
		visual.material_override = mat
	else:
		var coin := CylinderMesh.new()
		coin.top_radius = 0.42
		coin.bottom_radius = 0.42
		coin.height = 0.12
		coin.radial_segments = 24
		visual.mesh = coin
		visual.rotation.x = PI * 0.5
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("#ffd34e")
		mat.metallic = 0.72
		mat.roughness = 0.22
		visual.material_override = mat
	area.add_child(visual)
	area.body_entered.connect(_on_pickup_body_entered.bind(area, kind))
	add_child(area)
	pickups.append(area)

func _on_pickup_body_entered(body: Node3D, pickup: Area3D, kind: String) -> void:
	if body != car or not is_instance_valid(pickup):
		return
	if kind == "fuel":
		fuel = minf(FUEL_MAX, fuel + 34.0)
		audio_manager.play_sfx("fuel")
	else:
		coins += COIN_REWARD
		audio_manager.play_sfx("coin")
		wallet_coins += COIN_REWARD
		_save_progress()
	pickup.queue_free()
	pickups.erase(pickup)

func _spawn_log_obstacle(x: float) -> void:
	var obstacle := StaticBody3D.new()
	obstacle.name = "TrailLogObstacle"
	obstacle.position = Vector3(x, terrain.height_at(x) + 0.48, 0.0)
	var mesh := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.34
	cylinder.bottom_radius = 0.34
	cylinder.height = 2.5
	cylinder.radial_segments = 12
	mesh.mesh = cylinder
	mesh.rotation.z = PI * 0.5
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color("#68452c")
	wood.roughness = 0.95
	mesh.material_override = wood
	obstacle.add_child(mesh)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.5, 0.72, 0.85)
	collision.shape = shape
	obstacle.add_child(collision)
	terrain.add_child(obstacle)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	var top_panel := PanelContainer.new()
	top_panel.position = Vector2(18, 14)
	top_panel.custom_minimum_size = Vector2(300, 150)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.035, 0.055, 0.065, 0.86)
	panel_style.corner_radius_top_left = 16
	panel_style.corner_radius_top_right = 16
	panel_style.corner_radius_bottom_left = 16
	panel_style.corner_radius_bottom_right = 16
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.75, 0.66, 0.43, 0.8)
	top_panel.add_theme_stylebox_override("panel", panel_style)
	root.add_child(top_panel)
	var stats := VBoxContainer.new()
	stats.add_theme_constant_override("separation", 5)
	top_panel.add_child(stats)
	var title := Label.new()
	title.text = "STAGE %02d  /  %s  /  %s" % [current_stage + 1, STAGE_NAMES[current_stage], STAGE_DIFFICULTIES[current_stage]]
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", Color("#f4d99a"))
	stats.add_child(title)
	speed_label = _make_stat_label(stats, "SPEED   000 km/h", 20)
	distance_label = _make_stat_label(stats, "DISTANCE   0000 m", 17)
	coins_label = _make_stat_label(stats, "COINS   000", 17)
	fuel_label = _make_stat_label(stats, "FUEL   100%", 15)
	fuel_bar = ProgressBar.new()
	fuel_bar.max_value = FUEL_MAX
	fuel_bar.value = FUEL_MAX
	fuel_bar.show_percentage = false
	fuel_bar.custom_minimum_size = Vector2(270, 13)
	stats.add_child(fuel_bar)

	stage_bar = ProgressBar.new()
	stage_bar.anchor_left = 0.5
	stage_bar.anchor_right = 0.5
	stage_bar.offset_left = -190
	stage_bar.offset_right = 190
	stage_bar.offset_top = 20
	stage_bar.offset_bottom = 34
	stage_bar.max_value = stage_length_m
	stage_bar.value = 0
	stage_bar.show_percentage = false
	root.add_child(stage_bar)
	status_label = Label.new()
	status_label.anchor_left = 0.5
	status_label.anchor_right = 0.5
	status_label.offset_left = -280
	status_label.offset_right = 280
	status_label.offset_top = 43
	status_label.offset_bottom = 78
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 17)
	status_label.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(status_label)

	var gas := _make_button(root, "GAS  ▶", 0.0, Vector2(28, -132), Vector2(220, -24), Color("#c94b2d"))
	var brake := _make_button(root, "◀  BRAKE", 1.0, Vector2(-220, -132), Vector2(-28, -24), Color("#245b86"))
	gas.button_down.connect(_on_gas_down)
	gas.button_up.connect(func(): car.set_controls(false, car.touch_brake))
	brake.button_down.connect(_on_brake_down)
	brake.button_up.connect(func(): car.set_controls(car.touch_accelerate, false))
	var restart := Button.new()
	restart.text = "↻"
	restart.anchor_left = 1.0
	restart.anchor_right = 1.0
	restart.offset_left = -92
	restart.offset_top = 18
	restart.offset_right = -20
	restart.offset_bottom = 82
	restart.add_theme_font_size_override("font_size", 30)
	restart.tooltip_text = "Restart stage"
	restart.pressed.connect(_restart)
	root.add_child(restart)
	upgrade_button = Button.new()
	upgrade_button.text = "ENGINE UPGRADE  •  100 COINS"
	upgrade_button.anchor_left = 1.0
	upgrade_button.anchor_right = 1.0
	upgrade_button.offset_left = -300
	upgrade_button.offset_top = 96
	upgrade_button.offset_right = -20
	upgrade_button.offset_bottom = 148
	upgrade_button.add_theme_font_size_override("font_size", 15)
	upgrade_button.pressed.connect(_buy_engine_upgrade)
	root.add_child(upgrade_button)
	_update_upgrade_button()
	var pause_button := Button.new()
	pause_button.text = "Ⅱ"
	pause_button.anchor_left = 1.0
	pause_button.anchor_right = 1.0
	pause_button.offset_left = -174
	pause_button.offset_top = 18
	pause_button.offset_right = -102
	pause_button.offset_bottom = 82
	pause_button.add_theme_font_size_override("font_size", 28)
	pause_button.pressed.connect(_toggle_pause)
	root.add_child(pause_button)
	_build_menu_overlay()


func _build_menu_overlay() -> void:
	menu_layer = CanvasLayer.new()
	menu_layer.name = "TitleAndPauseOverlay"
	menu_layer.layer = 20
	menu_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(menu_layer)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.015, 0.025, 0.035, 0.88)
	menu_layer.add_child(shade)
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -250
	panel.offset_top = -190
	panel.offset_right = 250
	panel.offset_bottom = 190
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#14232b")
	panel_style.border_color = Color("#d5ad68")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(22)
	panel_style.content_margin_left = 28
	panel_style.content_margin_right = 28
	panel_style.content_margin_top = 26
	panel_style.content_margin_bottom = 26
	panel.add_theme_stylebox_override("panel", panel_style)
	menu_layer.add_child(panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 16)
	panel.add_child(layout)
	menu_title = Label.new()
	menu_title.text = "EXTREME HILL RACING"
	menu_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_title.add_theme_font_size_override("font_size", 30)
	menu_title.add_theme_color_override("font_color", Color("#f2d49a"))
	layout.add_child(menu_title)
	menu_subtitle = Label.new()
	menu_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_subtitle.add_theme_font_size_override("font_size", 16)
	menu_subtitle.add_theme_color_override("font_color", Color("#d5e0e3"))
	layout.add_child(menu_subtitle)
	stage_select = OptionButton.new()
	stage_select.custom_minimum_size = Vector2(0, 44)
	stage_select.add_theme_font_size_override("font_size", 17)
	stage_select.item_selected.connect(_on_stage_selected)
	layout.add_child(stage_select)
	_refresh_stage_select()
	menu_start_button = _make_menu_button("START DRIVE", Color("#b94b2d"))
	menu_start_button.pressed.connect(_on_menu_start)
	layout.add_child(menu_start_button)
	menu_upgrade_button = _make_menu_button("GARAGE  •  ENGINE UPGRADE", Color("#80653b"))
	menu_upgrade_button.pressed.connect(_buy_engine_upgrade)
	layout.add_child(menu_upgrade_button)
	menu_restart_button = _make_menu_button("RESTART STAGE", Color("#315d78"))
	menu_restart_button.pressed.connect(_restart)
	menu_restart_button.visible = false
	layout.add_child(menu_restart_button)
	_show_title_menu()
	get_tree().paused = true

func _make_menu_button(caption: String, tint: Color) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(0, 58)
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_color_override("font_color", Color.WHITE)
	var style := StyleBoxFlat.new()
	style.bg_color = tint
	style.set_corner_radius_all(13)
	style.set_border_width_all(1)
	style.border_color = Color(1, 1, 1, 0.35)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	return button

func _show_title_menu() -> void:
	menu_layer.visible = true
	menu_title.text = "EXTREME HILL RACING"
	menu_subtitle.text = "CHOOSE YOUR ROUTE  •  UNLOCKED %d / 5  •  WALLET %d" % [unlocked_stage + 1, wallet_coins]
	stage_select.visible = true
	_refresh_stage_select()
	menu_start_button.text = "START STAGE %02d" % (selected_stage + 1)
	menu_restart_button.visible = false
	_update_menu_upgrade_button()

func _show_pause_menu() -> void:
	menu_layer.visible = true
	menu_title.text = "PAUSED"
	menu_subtitle.text = "STAGE %02d  •  %s" % [current_stage + 1, STAGE_NAMES[current_stage]]
	stage_select.visible = false
	menu_start_button.text = "RESUME DRIVE"
	menu_restart_button.visible = true
	_update_menu_upgrade_button()

func _show_end_menu(title_text: String, detail_text: String) -> void:
	menu_layer.visible = true
	menu_title.text = title_text
	menu_subtitle.text = detail_text
	stage_select.visible = stage_finished
	_refresh_stage_select()
	menu_start_button.text = "NEXT STAGE" if stage_finished and current_stage < 4 else "RETRY STAGE"
	menu_restart_button.visible = false
	_update_menu_upgrade_button()
	get_tree().paused = true

func _update_menu_upgrade_button() -> void:
	if not is_instance_valid(menu_upgrade_button):
		return
	if engine_level >= 5:
		menu_upgrade_button.text = "GARAGE  •  ENGINE MAX"
	else:
		menu_upgrade_button.text = "GARAGE  •  UPGRADE LV %d  •  100 COINS" % engine_level
	menu_upgrade_button.disabled = engine_level >= 5 or wallet_coins < 100

func _on_menu_start() -> void:
	if run_ended:
		if stage_finished and current_stage < unlocked_stage:
			selected_stage = min(current_stage + 1, unlocked_stage)
			_load_stage(selected_stage)
		else:
			_restart()
		return
	if not game_started or selected_stage != current_stage:
		_load_stage(selected_stage)
		return
	game_started = true
	menu_layer.visible = false
	get_tree().paused = false

func _toggle_pause() -> void:
	if not game_started or get_tree().paused:
		return
	audio_manager.set_engine_active(false)
	get_tree().paused = true
	_show_pause_menu()

func _on_gas_down() -> void:
	if not run_ended and fuel > 0.0:
		car.set_controls(true, car.touch_brake)

func _on_brake_down() -> void:
	if not run_ended:
		car.set_controls(car.touch_accelerate, true)

func _make_stat_label(parent: Node, value: String, size: int) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color.WHITE)
	parent.add_child(label)
	return label

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
	if not run_ended and (car.touch_accelerate or Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D)):
		fuel = maxf(0.0, fuel - fuel_drain_per_second * delta)
		if fuel <= 0.0:
			car.fuel_empty = true
			car.set_controls(false, car.touch_brake)
			run_ended = true
			audio_manager.set_engine_active(false)
			status_label.text = "OUT OF FUEL  •  TAP RESTART"
			_show_end_menu("OUT OF FUEL", "REFUEL AND TRY THE MOUNTAIN AGAIN")
	var speed := absf(car.velocity.x) * 3.6
	var distance := maxf(0.0, car.global_position.x - start_x)
	speed_label.text = "SPEED   %03d km/h" % int(speed)
	distance_label.text = "STAGE %02d  •  %04d / %04d m" % [current_stage + 1, int(distance), int(stage_length_m)]
	coins_label.text = "COINS   %03d  •  WALLET %d" % [coins, wallet_coins]
	fuel_label.text = "FUEL   %d%%" % int(fuel)
	fuel_bar.value = fuel
	stage_bar.value = distance
	audio_manager.set_engine_active(not run_ended and (car.touch_accelerate or Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D)), speed / 133.2)
	best_distance = maxf(best_distance, distance)
	_update_upgrade_button()
	_update_menu_upgrade_button()
	if not run_ended:
		status_label.text = "BEST %04d m   •   COLLECT FUEL & COINS" % int(best_distance)
	if not stage_finished and distance >= stage_length_m:
		stage_finished = true
		run_ended = true
		car.set_controls(false, false)
		var stage_bonus := 500 + current_stage * 150
		coins += stage_bonus
		wallet_coins += stage_bonus
		unlocked_stage = mini(4, maxi(unlocked_stage, current_stage + 1))
		audio_manager.set_engine_active(false)
		audio_manager.play_sfx("finish")
		status_label.text = "STAGE COMPLETE!   +%d COINS" % stage_bonus
		_show_end_menu("STAGE COMPLETE!", "STAGE %02d CLEARED  •  +%d COINS" % [current_stage + 1, stage_bonus])
		_save_progress()
	if car.crashed and not run_ended:
		run_ended = true
		car.set_controls(false, false)
		audio_manager.set_engine_active(false)
		audio_manager.play_sfx("crash")
		status_label.text = "CRASHED!  TAP RESTART"
		_show_end_menu("CRASHED!", "RESTART AND TAKE A CLEANER LINE")
	if is_instance_valid(camera):
		var target: Vector3 = car.global_position + Vector3(2.0, 9.0, 22.0)
		camera.global_position = camera.global_position.lerp(target, minf(1.0, delta * 3.0))
		camera.look_at(car.global_position + Vector3(2.0, 1.2, 0), Vector3.UP)


func _apply_stage_look() -> void:
	if not is_instance_valid(world_environment) or not is_instance_valid(sun_light):
		return
	var env := world_environment.environment
	match current_stage:
		0:
			env.background_color = Color("#39739a")
			env.ambient_light_color = Color("#b6c8d5")
			sun_light.light_color = Color("#fff0d7")
		1:
			env.background_color = Color("#9b7755")
			env.ambient_light_color = Color("#d5b998")
			sun_light.light_color = Color("#ffe0b0")
		2:
			env.background_color = Color("#d19a55")
			env.ambient_light_color = Color("#f0c98e")
			sun_light.light_color = Color("#fff0c5")
		3:
			env.background_color = Color("#7895ad")
			env.ambient_light_color = Color("#d1e2ed")
			sun_light.light_color = Color("#e6f4ff")
		4:
			env.background_color = Color("#4d3535")
			env.ambient_light_color = Color("#c58b70")
			sun_light.light_color = Color("#ff9a62")

func _refresh_stage_select() -> void:
	if not is_instance_valid(stage_select):
		return
	stage_select.clear()
	for i in range(STAGE_NAMES.size()):
		var state := "UNLOCKED" if i <= unlocked_stage else "LOCKED"
		stage_select.add_item("%02d  %s  •  %s" % [i + 1, STAGE_NAMES[i], state])
		stage_select.set_item_disabled(i, i > unlocked_stage)
	stage_select.select(clampi(selected_stage, 0, unlocked_stage))

func _on_stage_selected(index: int) -> void:
	if index > unlocked_stage:
		return
	selected_stage = index
	menu_start_button.text = "START STAGE %02d" % (selected_stage + 1)

func _load_stage(index: int) -> void:
	current_stage = clampi(index, 0, unlocked_stage)
	selected_stage = current_stage
	stage_length_m = STAGE_LENGTHS[current_stage]
	fuel_drain_per_second = 1.45 + float(current_stage) * 0.28
	for pickup in pickups:
		if is_instance_valid(pickup):
			pickup.queue_free()
	pickups.clear()
	if is_instance_valid(terrain):
		terrain.queue_free()
	if is_instance_valid(car):
		car.queue_free()
	if is_instance_valid(camera):
		camera.queue_free()
	_apply_stage_look()
	_build_world()
	_build_pickups_and_hazards()
	fuel = FUEL_MAX
	coins = 0
	stage_finished = false
	run_ended = false
	stage_bar.max_value = stage_length_m
	stage_bar.value = 0.0
	game_started = true
	_save_progress()
	menu_layer.visible = false
	get_tree().paused = false

func _load_progress() -> void:
	var config := ConfigFile.new()
	if config.load("user://extreme_hill_progress.cfg") == OK:
		wallet_coins = int(config.get_value("career", "coins", 0))
		unlocked_stage = clampi(int(config.get_value("career", "unlocked_stage", 0)), 0, 4)
		engine_level = int(config.get_value("garage", "engine_level", 0))
		best_distance = float(config.get_value("career", "best_distance", 0.0))

func _save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("career", "coins", wallet_coins)
	config.set_value("career", "unlocked_stage", unlocked_stage)
	config.set_value("career", "best_distance", best_distance)
	config.set_value("garage", "engine_level", engine_level)
	config.save("user://extreme_hill_progress.cfg")

func _buy_engine_upgrade() -> void:
	if wallet_coins < 100 or engine_level >= 5:
		return
	wallet_coins -= 100
	engine_level += 1
	car.engine_force = 34.0 + float(engine_level) * 5.0
	audio_manager.play_sfx("upgrade")
	_save_progress()
	_update_upgrade_button()
	_update_menu_upgrade_button()

func _update_upgrade_button() -> void:
	if not is_instance_valid(upgrade_button):
		return
	if engine_level >= 5:
		upgrade_button.text = "ENGINE MAX  •  LV 5"
	else:
		upgrade_button.text = "ENGINE LV %d  •  UPGRADE 100  •  WALLET %d" % [engine_level, wallet_coins]
	upgrade_button.disabled = engine_level >= 5 or wallet_coins < 100

func _restart() -> void:
	_save_progress()
	car.reset_car(Vector3(start_x, terrain.height_at(start_x) + 1.65, 0))
	camera.global_position = car.global_position + Vector3(2.0, 9.0, 22.0)
	camera.look_at(car.global_position + Vector3(2.0, 1.0, 0), Vector3.UP)
	fuel = FUEL_MAX
	coins = 0
	car.fuel_empty = false
	stage_finished = false
	run_ended = false
	for pickup in pickups:
		if is_instance_valid(pickup):
			pickup.queue_free()
	pickups.clear()
	_build_pickups_and_hazards()
	stage_bar.value = 0.0
	stage_bar.max_value = stage_length_m
	game_started = true
	if is_instance_valid(menu_layer):
		menu_layer.visible = false
	get_tree().paused = false
