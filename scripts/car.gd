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
	rectangle.size = Vector2(118.0, 48.0)
	hitbox.shape = rectangle
	hitbox.position = Vector2(0.0, 4.0)
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
	var shadow_points := PackedVector2Array()
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		shadow_points.append(Vector2(cos(angle) * 70.0, sin(angle) * 11.0 + 17.0))
	draw_colored_polygon(shadow_points, Color(0.025, 0.06, 0.07, 0.30))

	# Chassis and suspension.
	draw_line(Vector2(-43, -9), Vector2(-37, 4), Color(0.13, 0.14, 0.15, 1), 7)
	draw_line(Vector2(40, -9), Vector2(36, 4), Color(0.13, 0.14, 0.15, 1), 7)
	draw_line(Vector2(-42, 0), Vector2(42, 0), Color(0.82, 0.72, 0.48, 1), 5)

	for wheel_x in [-41.0, 41.0]:
		draw_circle(Vector2(wheel_x, 7.0), 24.0, Color(0.045, 0.055, 0.065, 1.0))
		draw_circle(Vector2(wheel_x, 7.0), 17.0, Color(0.13, 0.15, 0.16, 1.0))
		draw_circle(Vector2(wheel_x, 7.0), 11.0, Color(0.72, 0.76, 0.75, 1.0))
		draw_circle(Vector2(wheel_x, 7.0), 5.0, Color(0.28, 0.34, 0.36, 1.0))
		for spoke in range(6):
			var angle := wheel_spin + float(spoke) * TAU / 6.0
			var start := Vector2(wheel_x, 7.0) + Vector2(cos(angle), sin(angle)) * 5.0
			var finish := Vector2(wheel_x, 7.0) + Vector2(cos(angle), sin(angle)) * 15.0
			draw_line(start, finish, Color(0.82, 0.86, 0.84, 1.0), 2.0)

	# Main body with layered highlights for a more dimensional finish.
	var body_points := PackedVector2Array([
		Vector2(-65, -27), Vector2(-52, -48), Vector2(-24, -54),
		Vector2(28, -51), Vector2(53, -34), Vector2(65, -9),
		Vector2(55, -4), Vector2(-58, -4)
	])
	draw_colored_polygon(body_points, Color(0.62, 0.15, 0.08, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-61, -29), Vector2(-48, -48), Vector2(-22, -51),
		Vector2(27, -48), Vector2(49, -32), Vector2(57, -22),
		Vector2(-55, -20)
	]), Color(0.96, 0.28, 0.11, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-29, -48), Vector2(-15, -73), Vector2(19, -73),
		Vector2(41, -48)
	]), Color(0.99, 0.58, 0.16, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(-10, -68), Vector2(14, -68), Vector2(31, -49), Vector2(-22, -49)
	]), Color(0.36, 0.70, 0.82, 0.98))
	draw_line(Vector2(-7, -66), Vector2(-15, -50), Color(0.83, 0.94, 0.96, 0.8), 3)
	draw_line(Vector2(-55, -17), Vector2(52, -17), Color(1.0, 0.69, 0.31, 0.9), 3)
	draw_rect(Rect2(-55, -10, 110, 6), Color(0.16, 0.15, 0.14, 1.0))
	draw_circle(Vector2(54, -26), 6.0, Color(1.0, 0.91, 0.58, 1.0))
	draw_circle(Vector2(-57, -25), 5.0, Color(0.95, 0.18, 0.12, 1.0))
