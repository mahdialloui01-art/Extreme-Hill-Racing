extends CharacterBody2D
class_name HillCar

const GRAVITY := 1750.0
const ENGINE_FORCE := 1550.0
const BRAKE_FORCE := 2350.0
const MAX_FORWARD_SPEED := 1050.0
const MAX_REVERSE_SPEED := 360.0
const AIR_ROTATION_SPEED := 2.7

var touch_accelerate := false
var touch_brake := false
var wheel_spin := 0.0
var crashed := false

func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	floor_stop_on_slope = false
	floor_max_angle = deg_to_rad(65.0)
	var hitbox := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(128.0, 52.0)
	hitbox.shape = rectangle
	hitbox.position = Vector2(0.0, 1.0)
	add_child(hitbox)

func set_controls(accelerate: bool, brake: bool) -> void:
	touch_accelerate = accelerate
	touch_brake = brake

func _physics_process(delta: float) -> void:
	if crashed:
		return
	var accelerate := touch_accelerate or Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D)
	var brake := touch_brake or Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A)
	if accelerate:
		velocity.x += ENGINE_FORCE * delta
	elif brake:
		velocity.x -= BRAKE_FORCE * delta
	else:
		velocity.x = move_toward(velocity.x, 0.0, 180.0 * delta)
	velocity.x = clampf(velocity.x, -MAX_REVERSE_SPEED, MAX_FORWARD_SPEED)
	velocity.y += GRAVITY * delta
	if is_on_floor():
		var normal := get_floor_normal()
		var target_angle := atan2(-normal.x, -normal.y)
		rotation = lerp_angle(rotation, target_angle, minf(1.0, delta * 9.0))
		if absf(velocity.y) < 90.0:
			velocity.y = 0.0
	else:
		var tilt := (1.0 if accelerate else 0.0) - (1.0 if brake else 0.0)
		rotation += tilt * AIR_ROTATION_SPEED * delta
	wheel_spin += velocity.x * delta / 22.0
	move_and_slide()
	queue_redraw()
	if global_position.y > 1800.0:
		crashed = true

func reset_car(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	rotation = 0.0
	crashed = false
	touch_accelerate = false
	touch_brake = false
	queue_redraw()

func _draw() -> void:
	# Ground contact shadow
	draw_set_transform(Vector2(0, 17), 0.0, Vector2(1.0, 1.0))
	draw_circle(Vector2.ZERO, 49.0, Color(0.04, 0.05, 0.05, 0.22))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Chunky off-road tyres with tread blocks and alloy hubs
	for wx in [-43.0, 43.0]:
		var center := Vector2(wx, 8)
		draw_circle(center, 25, Color("#171a1b"))
		draw_circle(center, 21, Color("#303638"))
		for tread in range(12):
			var a := wheel_spin + float(tread) * TAU / 12.0
			var p1 := center + Vector2(cos(a), sin(a)) * 21
			var p2 := center + Vector2(cos(a), sin(a)) * 25
			draw_line(p1, p2, Color("#111516"), 3.0)
		draw_circle(center, 14, Color("#aeb7b7"))
		draw_circle(center, 10, Color("#596568"))
		draw_circle(center, 4, Color("#d5dddd"))
		for spoke in range(6):
			var a := wheel_spin + float(spoke) * TAU / 6.0
			draw_line(center + Vector2(cos(a), sin(a)) * 5, center + Vector2(cos(a), sin(a)) * 12, Color("#e1e5e3"), 2.0)

	# Suspension arms and chassis
	draw_line(Vector2(-43, -5), Vector2(-31, -21), Color("#242a2c"), 5)
	draw_line(Vector2(43, -5), Vector2(31, -21), Color("#242a2c"), 5)
	draw_line(Vector2(-48, -12), Vector2(48, -12), Color("#b8a17b"), 5)

	# Sculpted rally SUV lower body
	draw_colored_polygon(PackedVector2Array([
		Vector2(-68,-22), Vector2(-61,-39), Vector2(-42,-45), Vector2(39,-44),
		Vector2(58,-34), Vector2(70,-12), Vector2(62,-4), Vector2(-62,-4)
	]), Color("#7f241b"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-65,-25), Vector2(-57,-40), Vector2(-39,-43), Vector2(38,-41),
		Vector2(55,-31), Vector2(64,-15), Vector2(-59,-15)
	]), Color("#e34b28"))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-30,-43), Vector2(-19,-70), Vector2(23,-70), Vector2(43,-43)
	]), Color("#bd351f"))
	# Windshield and side glass
	draw_colored_polygon(PackedVector2Array([
		Vector2(-23,-65), Vector2(19,-65), Vector2(34,-46), Vector2(-31,-46)
	]), Color("#9bcbd4"))
	draw_line(Vector2(-4,-65), Vector2(-4,-46), Color("#34484c"), 3)
	draw_line(Vector2(20,-64), Vector2(34,-46), Color("#34484c"), 3)
	draw_line(Vector2(-30,-45), Vector2(43,-45), Color("#f4b26b"), 3)
	# Roof rack and roll cage
	draw_line(Vector2(-27,-73), Vector2(25,-73), Color("#20282a"), 4)
	draw_line(Vector2(-27,-73), Vector2(-35,-43), Color("#20282a"), 3)
	draw_line(Vector2(25,-73), Vector2(40,-43), Color("#20282a"), 3)
	draw_line(Vector2(-48,-37), Vector2(49,-37), Color("#ffb15f"), 3)
	# Fender flares, bumpers, grille and lamps
	draw_arc(Vector2(-43,-7), 24.0, PI, TAU, 20, Color("#242a2b"), 7.0)
	draw_arc(Vector2(43,-7), 24.0, PI, TAU, 20, Color("#242a2b"), 7.0)
	draw_rect(Rect2(52,-22,13,8), Color("#f7e6b0"))
	draw_rect(Rect2(-66,-22,9,7), Color("#ff4437"))
	draw_rect(Rect2(60,-11,13,8), Color("#292f30"))
	draw_line(Vector2(-57,-8), Vector2(59,-8), Color("#252a2a"), 5)
	draw_line(Vector2(-52,-19), Vector2(48,-19), Color("#ffbd70"), 2)
	draw_colored_polygon(PackedVector2Array([Vector2(-14,-6),Vector2(14,-6),Vector2(9,1),Vector2(-9,1)]), Color("#202728"))
	# Door seam, handle and racing number
	draw_line(Vector2(5,-42), Vector2(5,-17), Color("#8e2d20"), 1.5)
	draw_rect(Rect2(-8,-35,17,12), Color("#f4eee0"))
	draw_string(ThemeDB.fallback_font, Vector2(-5,-26), "07", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#282a29"))
