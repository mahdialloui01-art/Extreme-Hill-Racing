extends Node3D
class_name HillTerrain3D

# One deliberately authored mountain stage: long, readable and easy to extend.
const WORLD_START := -80.0
const WORLD_END := 4200.0
const STEP := 4.0
const HALF_WIDTH := 38.0
const ROAD_HALF_WIDTH := 4.8
const BOTTOM_Y := -34.0
const TREE_MODEL_PATH := "res://spruce-tree.glb"
const ROCK_MODEL_PATH := "res://low-poly-nature-rock-cluster (1).glb"

var tree_scene: PackedScene
var rock_scene: PackedScene
var rng := RandomNumberGenerator.new()

func height_at(x: float) -> float:
	# Long readable climbs, rolling bowls and small surface bumps.
	return 4.0 + sin(x * 0.00145) * 4.8 + sin(x * 0.0031 + 1.1) * 1.7 + sin(x * 0.00042 + 0.5) * 5.8 + maxf(0.0, sin(x * 0.00078 - 0.3)) * 2.5 + sin(x * 0.009) * 0.16

func _ready() -> void:
	rng.seed = 732041
	if ResourceLoader.exists(TREE_MODEL_PATH):
		tree_scene = load(TREE_MODEL_PATH) as PackedScene
	if ResourceLoader.exists(ROCK_MODEL_PATH):
		rock_scene = load(ROCK_MODEL_PATH) as PackedScene
	_build_ground()
	_build_road()
	_build_distant_ridges()
	_build_scenery()
	_build_stage_markers()

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
		_add_ground_triangle(st, faces, a, b, c)
		_add_ground_triangle(st, faces, a, c, d)
		_add_ground_triangle(st, faces, d, c, Vector3(x2, BOTTOM_Y, HALF_WIDTH))
		_add_ground_triangle(st, faces, d, Vector3(x2, BOTTOM_Y, HALF_WIDTH), Vector3(x, BOTTOM_Y, HALF_WIDTH))
		_add_ground_triangle(st, faces, b, a, Vector3(x, BOTTOM_Y, -HALF_WIDTH))
		_add_ground_triangle(st, faces, b, Vector3(x, BOTTOM_Y, -HALF_WIDTH), Vector3(x2, BOTTOM_Y, -HALF_WIDTH))
		x = x2
	st.generate_normals()
	var ground := MeshInstance3D.new()
	ground.name = "LayeredMountainTerrain"
	ground.mesh = st.commit()
	var earth := StandardMaterial3D.new()
	earth.vertex_color_use_as_albedo = true
	earth.roughness = 1.0
	earth.cull_mode = BaseMaterial3D.CULL_DISABLED
	ground.material_override = earth
	add_child(ground)

	var body := StaticBody3D.new()
	body.name = "MountainCollision"
	var shape := ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func _add_ground_triangle(st: SurfaceTool, faces: PackedVector3Array, a: Vector3, b: Vector3, c: Vector3) -> void:
	var altitude := clampf(((a.y + b.y + c.y) / 3.0 + 2.0) / 20.0, 0.0, 1.0)
	var x_factor := 0.5 + 0.5 * sin((a.x + b.x + c.x) * 0.0017)
	var grass := Color("#435b3c").lerp(Color("#78805a"), x_factor * 0.34)
	var stone := Color("#77766c").lerp(Color("#a49a83"), x_factor * 0.22)
	st.set_color(grass.lerp(stone, altitude))
	st.add_vertex(a)
	st.add_vertex(c)
	st.add_vertex(b)
	faces.append(a)
	faces.append(c)
	faces.append(b)

func _make_road_texture() -> Texture2D:
	# Small seamless procedural gravel tile; no external texture download required.
	var image := Image.create(256, 256, false, Image.FORMAT_RGBA8)
	for y in range(256):
		for x in range(256):
			var n := rng.randf_range(-0.12, 0.12)
			var grain := 0.035 if ((x * 17 + y * 31) % 19) < 3 else 0.0
			var base := Color(0.53 + n + grain, 0.38 + n * 0.78 + grain, 0.25 + n * 0.55 + grain, 1.0)
			image.set_pixel(x, y, base)
	return ImageTexture.create_from_image(image)

func _build_road() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var x := WORLD_START
	while x < WORLD_END:
		var x2 := minf(x + STEP, WORLD_END)
		var y1 := height_at(x) + 0.16
		var y2 := height_at(x2) + 0.16
		var a := Vector3(x, y1, -ROAD_HALF_WIDTH)
		var b := Vector3(x2, y2, -ROAD_HALF_WIDTH)
		var c := Vector3(x2, y2, ROAD_HALF_WIDTH)
		var d := Vector3(x, y1, ROAD_HALF_WIDTH)
		st.set_color(Color.WHITE)
		st.set_uv(Vector2(x * 0.075, 0.0)); st.add_vertex(a)
		st.set_uv(Vector2(x2 * 0.075, 0.9)); st.add_vertex(c)
		st.set_uv(Vector2(x2 * 0.075, 0.0)); st.add_vertex(b)
		st.set_uv(Vector2(x * 0.075, 0.0)); st.add_vertex(a)
		st.set_uv(Vector2(x * 0.075, 0.9)); st.add_vertex(d)
		st.set_uv(Vector2(x2 * 0.075, 0.9)); st.add_vertex(c)
		x = x2
	st.generate_normals()
	var road := MeshInstance3D.new()
	road.name = "TexturedDirtRaceRoad"
	road.mesh = st.commit()
	var road_mat := StandardMaterial3D.new()
	road_mat.albedo_texture = _make_road_texture()
	road_mat.roughness = 1.0
	road_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	road.material_override = road_mat
	add_child(road)
	_add_road_shoulders()
	_add_road_markings()

func _add_road_shoulders() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var outer := ROAD_HALF_WIDTH + 0.95
	var x := WORLD_START
	while x < WORLD_END:
		var x2 := minf(x + STEP, WORLD_END)
		var y1 := height_at(x) + 0.09
		var y2 := height_at(x2) + 0.09
		for side in [-1.0, 1.0]:
			var inner1 := Vector3(x, y1, side * ROAD_HALF_WIDTH)
			var inner2 := Vector3(x2, y2, side * ROAD_HALF_WIDTH)
			var outer1 := Vector3(x, y1 - 0.035, side * outer)
			var outer2 := Vector3(x2, y2 - 0.035, side * outer)
			st.set_color(Color.WHITE)
			st.add_vertex(inner1); st.add_vertex(outer2); st.add_vertex(inner2)
			st.add_vertex(inner1); st.add_vertex(outer1); st.add_vertex(outer2)
		x = x2
	st.generate_normals()
	var shoulder := MeshInstance3D.new()
	shoulder.name = "LooseGravelShoulders"
	shoulder.mesh = st.commit()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#65513b")
	mat.roughness = 1.0
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	shoulder.material_override = mat
	add_child(shoulder)

func _add_road_markings() -> void:
	# Bright edge paint and broken centre guide make the drivable surface readable.
	for side in [-1.0, 1.0]:
		_add_strip(side * (ROAD_HALF_WIDTH - 0.18), 0.105, Color("#e7d2a5"), WORLD_START, WORLD_END, 0.0)
	for x in range(0, int(WORLD_END), 28):
		_add_strip(0.0, 0.105, Color("#e7c66c"), float(x), minf(float(x + 10), WORLD_END), 0.0)

func _add_strip(z: float, width: float, tint: Color, from_x: float, to_x: float, lift: float) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var x := from_x
	while x < to_x:
		var x2 := minf(x + 4.0, to_x)
		var y1 := height_at(x) + 0.205 + lift
		var y2 := height_at(x2) + 0.205 + lift
		var a := Vector3(x, y1, z - width)
		var b := Vector3(x2, y2, z - width)
		var c := Vector3(x2, y2, z + width)
		var d := Vector3(x, y1, z + width)
		st.set_color(tint)
		st.add_vertex(a); st.add_vertex(c); st.add_vertex(b)
		st.add_vertex(a); st.add_vertex(d); st.add_vertex(c)
		x = x2
	st.generate_normals()
	var marking := MeshInstance3D.new()
	marking.mesh = st.commit()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.roughness = 0.8
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	marking.material_override = mat
	add_child(marking)

func _build_distant_ridges() -> void:
	# Two muted mountain silhouettes add depth behind the playable ridge.
	for layer in range(2):
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		var z := -54.0 - float(layer) * 13.0
		var spacing := 85.0 if layer == 0 else 125.0
		var x := WORLD_START - 100.0
		while x < WORLD_END + 100.0:
			var x2 := x + spacing
			var y1 := -4.0 + sin(x * 0.002 + float(layer)) * 5.0 + rng.randf_range(4.0, 13.0)
			var y2 := -4.0 + sin(x2 * 0.002 + float(layer)) * 5.0 + rng.randf_range(4.0, 13.0)
			var p1 := Vector3(x, y1, z)
			var p2 := Vector3(x2, y2, z)
			var b1 := Vector3(x, BOTTOM_Y, z)
			var b2 := Vector3(x2, BOTTOM_Y, z)
			st.set_color(Color("#596b69") if layer == 0 else Color("#7b8981"))
			st.add_vertex(p1); st.add_vertex(p2); st.add_vertex(b2)
			st.add_vertex(p1); st.add_vertex(b2); st.add_vertex(b1)
			x = x2
		st.generate_normals()
		var ridge := MeshInstance3D.new()
		ridge.name = "FarMountainLayer%d" % layer
		ridge.mesh = st.commit()
		var mat := StandardMaterial3D.new()
		mat.vertex_color_use_as_albedo = true
		mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		mat.roughness = 1.0
		ridge.material_override = mat
		add_child(ridge)

func _build_scenery() -> void:
	# Designed roadside bands; keep a clear safety gap beside the driving line.
	for i in range(310):
		var x := rng.randf_range(35.0, WORLD_END - 35.0)
		var side := -1.0 if rng.randf() < 0.5 else 1.0
		var z := side * rng.randf_range(8.0, 26.0)
		var pos := Vector3(x, height_at(x), z)
		if i % 4 == 0:
			_add_tree(pos, rng.randf_range(0.85, 1.65))
		elif i % 4 == 1:
			_add_bush(pos, rng.randf_range(0.65, 1.25))
		else:
			_add_rock(pos, rng.randf_range(0.45, 1.45))

func _add_tree(pos: Vector3, scale_value: float) -> void:
	if tree_scene != null:
		var imported := tree_scene.instantiate() as Node3D
		if imported != null:
			imported.position = pos
			imported.scale = Vector3.ONE * scale_value
			imported.rotation.y = rng.randf_range(0.0, TAU)
			add_child(imported)
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
		cone.size = Vector3(2.1 - j * 0.3, 2.2, 1.9 - j * 0.25)
		crown.mesh = cone
		crown.position.y = 2.0 + float(j) * 0.78
		var leaves := StandardMaterial3D.new()
		leaves.albedo_color = Color("#31513d").lerp(Color("#78834c"), rng.randf() * 0.35)
		leaves.roughness = 1.0
		crown.material_override = leaves
		tree.add_child(crown)

func _add_bush(pos: Vector3, scale_value: float) -> void:
	var bush := Node3D.new()
	bush.position = pos + Vector3(0.0, 0.35, 0.0)
	bush.scale = Vector3.ONE * scale_value
	add_child(bush)
	for i in range(3):
		var leaf := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.65
		mesh.height = 0.9
		leaf.mesh = mesh
		leaf.position = Vector3(rng.randf_range(-0.45, 0.45), rng.randf_range(0.0, 0.45), rng.randf_range(-0.45, 0.45))
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color("#405b37").lerp(Color("#78834a"), rng.randf() * 0.5)
		mat.roughness = 1.0
		leaf.material_override = mat
		bush.add_child(leaf)

func _add_rock(pos: Vector3, size_value: float) -> void:
	if rock_scene != null:
		var imported := rock_scene.instantiate() as Node3D
		if imported != null:
			imported.position = pos
			imported.scale = Vector3.ONE * size_value
			imported.rotation = Vector3(rng.randf_range(-0.2, 0.2), rng.randf_range(0.0, TAU), rng.randf_range(-0.2, 0.2))
			add_child(imported)
			return
	var rock := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = size_value
	mesh.height = size_value * 1.15
	rock.mesh = mesh
	rock.position = pos + Vector3(0.0, size_value * 0.35, 0.0)
	rock.scale = Vector3(rng.randf_range(0.8, 1.5), rng.randf_range(0.55, 1.0), rng.randf_range(0.8, 1.4))
	rock.rotation = Vector3(rng.randf_range(-0.2, 0.2), rng.randf_range(0.0, TAU), rng.randf_range(-0.2, 0.2))
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color("#62645e").lerp(Color("#928674"), rng.randf() * 0.5)
	mat.roughness = 1.0
	rock.material_override = mat
	add_child(rock)

func _build_stage_markers() -> void:
	# Visible wooden distance signs every 500 metres make this a legible stage.
	for distance in range(500, int(WORLD_END), 500):
		var x := float(distance) * 10.0 / 10.0
		var z := 6.6
		var y := height_at(x)
		var post := MeshInstance3D.new()
		var post_mesh := CylinderMesh.new()
		post_mesh.top_radius = 0.09
		post_mesh.bottom_radius = 0.12
		post_mesh.height = 2.5
		post.mesh = post_mesh
		post.position = Vector3(x, y + 1.25, z)
		var wood := StandardMaterial3D.new()
		wood.albedo_color = Color("#63452d")
		post.material_override = wood
		add_child(post)
		var board := MeshInstance3D.new()
		var board_mesh := BoxMesh.new()
		board_mesh.size = Vector3(2.1, 0.85, 0.16)
		board.mesh = board_mesh
		board.position = Vector3(x + 0.35, y + 2.35, z)
		var sign_mat := StandardMaterial3D.new()
		sign_mat.albedo_color = Color("#d5b477")
		sign_mat.roughness = 0.9
		board.material_override = sign_mat
		add_child(board)
