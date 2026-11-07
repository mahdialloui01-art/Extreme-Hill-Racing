extends "res://scripts/terrain_3d.gd"
class_name StageMapBase

func _add_landmark_mesh(node_name: String, pos: Vector3, mesh: Mesh, tint: Color, scale_value: Vector3 = Vector3.ONE, glow: bool = false) -> MeshInstance3D:
	var item := MeshInstance3D.new()
	item.name = node_name
	item.mesh = mesh
	item.position = pos
	item.scale = scale_value
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.roughness = 0.82
	material.metallic = 0.08
	if glow:
		material.emission_enabled = true
		material.emission = tint
		material.emission_energy_multiplier = 1.6
	item.material_override = material
	add_child(item)
	return item

func _add_landmark_box(node_name: String, pos: Vector3, size: Vector3, tint: Color, rotation_y: float = 0.0) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var item := _add_landmark_mesh(node_name, pos, mesh, tint)
	item.rotation.y = rotation_y
	return item

func _add_landmark_spire(node_name: String, pos: Vector3, height: float, radius: float, tint: Color, sides: int = 6) -> MeshInstance3D:
	var mesh := PrismMesh.new()
	mesh.size = Vector3(radius * 2.0, height, radius * 1.7)
	return _add_landmark_mesh(node_name, pos + Vector3.UP * height * 0.5, mesh, tint, Vector3.ONE)

func _add_landmark_column(node_name: String, pos: Vector3, height: float, radius: float, tint: Color) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius * 0.72
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	return _add_landmark_mesh(node_name, pos + Vector3.UP * height * 0.5, mesh, tint)
