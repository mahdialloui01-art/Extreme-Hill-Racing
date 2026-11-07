extends CharacterBody3D
class_name HillCar3D

const ENGINE_FORCE := 34.0
const BRAKE_FORCE := 48.0
const MAX_SPEED := 37.0
const GRAVITY := 24.0

var touch_accelerate := false
var touch_brake := false
var crashed := false
var wheel_spin := 0.0
var body_visual: Node3D
var wheels: Array[MeshInstance3D] = []

func _ready() -> void:
	motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED
	floor_max_angle = deg_to_rad(58.0)
	floor_snap_length = 0.45
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.7, 1.0, 1.45)
	collision.shape = box
	collision.position.y = 0.92
	add_child(collision)
	_build_vehicle()

func _build_vehicle() -> void:
	body_visual = Node3D.new()
	body_visual.name = "RallySUVVisual"
	add_child(body_visual)
	_box(body_visual, Vector3(0, 1.05, 0), Vector3(2.85, 0.66, 1.48), Color("#c74725"), Vector3.ZERO)
	_box(body_visual, Vector3(-0.12, 1.63, 0), Vector3(1.48, 0.72, 1.32), Color("#a83220"), Vector3(0, 0, -0.08))
	_box(body_visual, Vector3(-0.1, 1.67, 0), Vector3(1.2, 0.48, 1.34), Color("#8fc1ce"), Vector3.ZERO)
	_box(body_visual, Vector3(1.35, 0.94, 0), Vector3(0.18, 0.32, 1.4), Color("#252b2d"), Vector3.ZERO)
	_box(body_visual, Vector3(1.47, 1.18, -0.48), Vector3(0.12, 0.18, 0.22), Color("#fff0b9"), Vector3.ZERO)
	_box(body_visual, Vector3(1.47, 1.18, 0.48), Vector3(0.12, 0.18, 0.22), Color("#fff0b9"), Vector3.ZERO)
	_box(body_visual, Vector3(-1.47, 1.18, -0.48), Vector3(0.12, 0.18, 0.22), Color("#ff453d"), Vector3.ZERO)
	_box(body_visual, Vector3(-1.47, 1.18, 0.48), Vector3(0.12, 0.18, 0.22), Color("#ff453d"), Vector3.ZERO)
	_box(body_visual, Vector3(-0.05, 2.08, 0), Vector3(1.85, 0.09, 1.5), Color("#22292b"), Vector3.ZERO)
	for x in [-0.96, 0.98]:
		for z in [-0.78, 0.78]:
			var wheel := MeshInstance3D.new()
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = 0.48
			cylinder.bottom_radius = 0.48
			cylinder.height = 0.28
			cylinder.radial_segments = 24
			wheel.mesh = cylinder
			wheel.position = Vector3(x, 0.53, z)
			wheel.rotation.x = PI * 0.5
			var tire := StandardMaterial3D.new()
			tire.albedo_color = Color("#171a1c")
			tire.roughness = 1.0
			wheel.material_override = tire
			body_visual.add_child(wheel)
			wheels.append(wheel)
			var hub := MeshInstance3D.new()
			var hub_mesh := CylinderMesh.new()
			hub_mesh.top_radius = 0.23
			hub_mesh.bottom_radius = 0.23
			hub_mesh.height = 0.3
			hub.mesh = hub_mesh
			hub.position = wheel.position
			hub.rotation.x = PI * 0.5
			var alloy := StandardMaterial3D.new()
			alloy.albedo_color = Color("#bdc5c7")
			hub.material_override = alloy
			body_visual.add_child(hub)

func _box(parent: Node3D, pos: Vector3, dimensions: Vector3, tint: Color, tilt: Vector3) -> void:
	var part := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	part.mesh = mesh
	part.position = pos
	part.rotation = tilt
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.metallic = 0.18
	mat.roughness = 0.42
	part.material_override = mat
	parent.add_child(part)

func set_controls(accelerate: bool, brake: bool) -> void:
	touch_accelerate = accelerate
	touch_brake = brake

func _physics_process(delta: float) -> void:
	if crashed:
		return
	var accelerate := touch_accelerate or Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D)
	var brake := touch_brake or Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A)
	if accelerate:
		velocity.x = move_toward(velocity.x, MAX_SPEED, ENGINE_FORCE * delta)
	elif brake:
		velocity.x = move_toward(velocity.x, -8.0, BRAKE_FORCE * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, 3.0 * delta)
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = maxf(velocity.y, -1.0)
		var normal := get_floor_normal()
		var target_pitch := atan2(normal.x, normal.y)
		body_visual.rotation.z = lerp_angle(body_visual.rotation.z, target_pitch, delta * 5.5)
	velocity.z = move_toward(velocity.z, 0.0, 10.0 * delta)
	move_and_slide()
	wheel_spin += velocity.x * delta * 2.2
	for wheel in wheels:
		wheel.rotation.z = wheel_spin
	if global_position.y < -22.0 or global_position.x < -100.0:
		crashed = true

func reset_car(spawn: Vector3) -> void:
	global_position = spawn
	velocity = Vector3.ZERO
	rotation = Vector3.ZERO
	body_visual.rotation = Vector3.ZERO
	crashed = false
	touch_accelerate = false
	touch_brake = false
