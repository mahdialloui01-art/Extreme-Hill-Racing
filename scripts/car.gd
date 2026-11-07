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
var distance_origin := 0.0
var wheel_spin := 0.0
var crashed := false

func _ready() -> void:
	collision_layer = 1
	collision_mask = 1
	floor_stop_on_slope = false
	floor_max_angle = deg_to_rad(65.0)
	var hitbox := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(112.0, 38.0)
	hitbox.shape = rectangle
	hitbox.position = Vector2(0.0, -18.0)
	add_child(hitbox)
	distance_origin = global_position.x

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
		velocity.x = move_toward(velocity.x, 0.0, 260.0 * delta)

	velocity.x = clampf(velocity.x, -MAX_REVERSE_SPEED, MAX_FORWARD_SPEED)
	velocity.y += GRAVITY * delta

	if is_on_floor():
		var floor_normal := get_floor_normal()
		var target_angle := atan2(-floor_normal.x, -floor_normal.y)
		rotation = lerp_angle(rotation, target_angle, minf(1.0, delta * 8.5))
		if absf(velocity.y) < 80.0:
			velocity.y = 0.0
	else:
		var air_direction := 0.0
		if brake:
			air_direction -= 1.0
		if accelerate:
			air_direction += 1.0
		rotation += air_direction * AIR_ROTATION_SPEED * delta

	wheel_spin += velocity.x * delta / 22.0
	move_and_slide()

	if global_position.y > 1800.0:
		crashed = true

func reset_car(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	rotation = 0.0
	crashed = false
	touch_accelerate = false
	touch_brake = false

func _draw() -> void:
	# Shadow
	draw_ellipse(Vector2(0.0, 14.0), Vector2(65.0, 10.0), Color(0.05, 0.12, 0.10, 0.22))
	# Wheels
	for wheel_x in [-39.0, 39.0]:
		draw_circle(Vector2(wheel_x, 5.0), 22.0, Color(0.075, 0.085, 0.10, 1.0))
		draw_circle(Vector2(wheel_x, 5.0), 12.0, Color(0.62, 0.68, 0.70, 1.0))
		for spoke in range(4):
			var angle := wheel_spin + float(spoke) * PI * 0.5
			var start := Vector2(wheel_x, 5.0) + Vector2(cos(angle), sin(angle)) * 4.0
			var finish := Vector2(wheel_x, 5.0) + Vector2(cos(angle), sin(angle)) * 10.0
			draw_line(start, finish, Color(0.18, 0.22, 0.24, 1.0), 2.5)
	# Chassis and cabin
	var body_points := PackedVector2Array([
		Vector2(-61, -28), Vector2(-47, -48), Vector2(25, -48),
		Vector2(54, -27), Vector2(62, -7), Vector2(-58, -7)
	])
	draw_colored_polygon(body_points, Color(0.93, 0.30, 0.12, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-28, -46), Vector2(-15, -69), Vector2(18, -69),
		Vector2(39, -46)
	]), Color(0.96, 0.57, 0.16, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-10, -64), Vector2(15, -64), Vector2(29, -48), Vector2(-20, -48)
	]), Color(0.48, 0.78, 0.88, 0.95))
	draw_rect(Rect2(-54, -25, 108, 8), Color(0.20, 0.16, 0.13, 1.0))
	draw_circle(Vector2(49, -20), 5.0, Color(1.0, 0.88, 0.50, 1.0))
