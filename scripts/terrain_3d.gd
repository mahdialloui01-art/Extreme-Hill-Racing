extends Node3D
class_name HillTerrain3D

const WORLD_START := -80.0
const WORLD_END := 18000.0
const STEP := 5.0
const HALF_WIDTH := 32.0
const ROAD_HALF_WIDTH := 4.6
const BOTTOM_Y := -34.0
const TREE_MODEL_PATH := "res://assets/vegetation/fir_tree.glb"
const ROCK_MODEL_PATH := "res://assets/rocks/boulder.glb"
const ROAD_ALBEDO_PATH := "res://assets/materials/dirt_albedo.jpg"
const ROAD_NORMAL_PATH := "res://assets/materials/dirt_normal.jpg"
const ROAD_ROUGHNESS_PATH := "res://assets/materials/dirt_roughness.jpg"

var tree_scene: PackedScene
var rock_scene: PackedScene

func height_at(x: float) -> float:
	return 5.0 + sin(x * 0.0010) * 5.0 + sin(x * 0.0028 + 1.2) * 2.1 + sin(x * 0.00032 + 0.6) * 7.0 + maxf(0.0, sin(x * 0.00072)) * 3.0 + sin(x * 0.006) * 0.28

func _ready() -> void:
	if ResourceLoader.exists(TREE_MODEL_PATH):
		tree_scene = load(TREE_MODEL_PATH) as PackedScene
	if ResourceLoader.exists(ROCK_MODEL_PATH):
		rock_scene = load(ROCK_MODEL_PATH) as PackedScene
	_build_ground()
	_build_road()
	_build_scenery()

func _build_ground() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var faces := PackedVector3Array()
	var x := WORLD_START
	while x < WORLD_END:
		var x2 := minf(x + STEP, WORLD_END)
		var h1 := height_at(x)
		var h2 := height_at(x2)
		var a := Vector3(x, h1, -HALF_WIDTH)
		var b := Vector3(x2, h2, -HALF_WIDTH)
		var c := Vector3(x2, h2, HALF_WIDTH)
		var d := Vector3(x, h1, HALF_WIDTH)
		_add_triangle(st, faces, a, b, c)
		_add_triangle(st, faces, a, c, d)
		_add_triangle(st, faces, d, c, Vector3(x2, BOTTOM_Y, HALF_WIDTH))
		_add_triangle(st, faces, d, Vector3(x2, BOTTOM_Y, HALF_WIDTH), Vector3(x, BOTTOM_Y, HALF_WIDTH))
		_add_triangle(st, faces, b, a, Vector3(x, BOTTOM_Y, -HALF_WIDTH))
		_add_triangle(st, faces, b, Vector3(x, BOTTOM_Y, -HALF_WIDTH), Vector3(x2, BOTTOM_Y, -HALF_WIDTH))
		x = x2
	st.generate_normals()
	var mesh := st.commit()
	var ground := MeshInstance3D.new()
	ground.name = "MountainGround"
	ground.mesh = mesh
	var earth := StandardMaterial3D.new()
	earth.albedo_color = Color("#66503d")
	earth.roughness = 1.0
	ground.material_override = earth
	add_child(ground)
	var body := StaticBody3D.new()
	body.name = "TerrainCollision"
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func _add_triangle(st: SurfaceTool, faces: PackedVector3Array, a: Vector3, b: Vector3, c: Vector3) -> void:
	st.set_color(Color.WHITE)
	st.add_vertex(a)
	st.add_vertex(c)
	st.add_vertex(b)
	faces.append(a)
	faces.append(c)
	faces.append(b)

func _build_road() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var x := WORLD_START
	while x < WORLD_END:
		var x2 := minf(x + STEP, WORLD_END)
		var y1 := height_at(x) + 0.13
		var y2 := height_at(x2) + 0.13
		var a := Vector3(x, y1, -ROAD_HALF_WIDTH)
		var b := Vector3(x2, y2, -ROAD_HALF_WIDTH)
		var c := Vector3(x2, y2, ROAD_HALF_WIDTH)
		var d := Vector3(x, y1, ROAD_HALF_WIDTH)
		st.set_color(Color.WHITE)
		st.set_uv(Vector2(x * 0.18, 0.0))
		st.add_vertex(a)
		st.set_uv(Vector2(x2 * 0.18, ROAD_HALF_WIDTH * 0.18))
		st.add_vertex(c)
		st.set_uv(Vector2(x2 * 0.18, 0.0))
		st.add_vertex(b)
		st.set_uv(Vector2(x * 0.18, 0.0))
		st.add_vertex(a)
		st.set_uv(Vector2(x * 0.18, ROAD_HALF_WIDTH * 0.18))
		st.add_vertex(d)
		st.set_uv(Vector2(x2 * 0.18, ROAD_HALF_WIDTH * 0.18))
		st.add_vertex(c)
		x = x2
	st.generate_normals()
	var road := MeshInstance3D.new()
	road.name = "DirtRaceTrack"
	road.mesh = st.commit()
	var road_mat := StandardMaterial3D.new()
	road_mat.albedo_color = Color("#a17b55")
	road_mat.roughness = 0.94
	if ResourceLoader.exists(ROAD_ALBEDO_PATH):
		road_mat.albedo_texture = load(ROAD_ALBEDO_PATH) as Texture2D
	if ResourceLoader.exists(ROAD_NORMAL_PATH):
		road_mat.normal_enabled = true
		road_mat.normal_texture = load(ROAD_NORMAL_PATH) as Texture2D
	if ResourceLoader.exists(ROAD_ROUGHNESS_PATH):
		road_mat.roughness_texture = load(ROAD_ROUGHNESS_PATH) as Texture2D
	road_mat.uv1_scale = Vector3(0.22, 0.22, 0.22)
	road.material_override = road_mat
	add_child(road)
	_add_road_edges()

func _add_road_edges() -> void:
	for side in [-1.0, 1.0]:
		var rail := MeshInstance3D.new()
		var im := ImmediateMesh.new()
		im.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
		for i in range(0, 1801, 3):
			var x := float(i) * 10.0
			var y := height_at(x) + 0.2
			im.surface_add_vertex(Vector3(x, y, side * (ROAD_HALF_WIDTH - 0.12)))
			im.surface_add_vertex(Vector3(x, y + 0.045, side * (ROAD_HALF_WIDTH - 0.32)))
		im.surface_end()
		rail.mesh = im
		var edge_mat := StandardMaterial3D.new()
		edge_mat.albedo_color = Color("#d2ad7b")
		rail.material_override = edge_mat
		add_child(rail)

func _build_scenery() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 271828
	for i in range(420):
		var x := rng.randf_range(40.0, WORLD_END - 40.0)
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		var z := side * rng.randf_range(7.0, 25.0)
		var base := Vector3(x, height_at(x), z)
		if i % 3 == 0:
			_add_tree(base, rng.randf_range(0.75, 1.55), rng)
		else:
			_add_rock(base, rng.randf_range(0.45, 1.65), rng)

func _add_tree(pos: Vector3, scale_value: float, rng: RandomNumberGenerator) -> void:
	if tree_scene != null:
		var imported_tree := tree_scene.instantiate() as Node3D
		if imported_tree != null:
			imported_tree.position = pos
			imported_tree.scale = Vector3.ONE * scale_value
			imported_tree.rotation.y = rng.randf_range(0.0, TAU)
			add_child(imported_tree)
			return
	var tree := Node3D.new()
	tree.position = pos
	tree.scale = Vector3.ONE * scale_value
	add_child(tree)
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.12
	trunk_mesh.bottom_radius = 0.2
	trunk_mesh.height = 2.0
	trunk.mesh = trunk_mesh
	trunk.position.y = 1.0
	var bark := StandardMaterial3D.new()
	bark.albedo_color = Color("#55402c")
	trunk.material_override = bark
	tree.add_child(trunk)
	for j in range(3):
		var crown := MeshInstance3D.new()
		var cone := PrismMesh.new()
		cone.size = Vector3(2.0 - j * 0.28, 2.2, 1.8 - j * 0.24)
		crown.mesh = cone
		crown.position.y = 2.0 + float(j) * 0.8
		crown.rotation.y = rng.randf_range(-0.3, 0.3)
		var leaves := StandardMaterial3D.new()
		leaves.albedo_color = Color("#31513d").lerp(Color("#71804b"), rng.randf() * 0.35)
		leaves.roughness = 1.0
		crown.material_override = leaves
		tree.add_child(crown)

func _add_rock(pos: Vector3, size_value: float, rng: RandomNumberGenerator) -> void:
	if rock_scene != null:
		var imported_rock := rock_scene.instantiate() as Node3D
		if imported_rock != null:
			imported_rock.position = pos
			imported_rock.scale = Vector3.ONE * size_value
			imported_rock.rotation = Vector3(rng.randf_range(-0.2, 0.2), rng.randf_range(0.0, TAU), rng.randf_range(-0.2, 0.2))
			add_child(imported_rock)
			return
	var rock := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = size_value
	mesh.height = size_value * 1.15
	rock.mesh = mesh
	rock.position = pos + Vector3(0, size_value * 0.35, 0)
	rock.scale = Vector3(rng.randf_range(0.8, 1.5), rng.randf_range(0.55, 1.0), rng.randf_range(0.8, 1.4))
	rock.rotation = Vector3(rng.randf_range(-0.2, 0.2), rng.randf_range(0.0, TAU), rng.randf_range(-0.2, 0.2))
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#62645e").lerp(Color("#8a8172"), rng.randf() * 0.5)
	mat.roughness = 1.0
	rock.material_override = mat
	add_child(rock)
