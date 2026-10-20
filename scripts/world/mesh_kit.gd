class_name MeshKit
## Helpers for building placeholder art out of simple shapes (boxes, cylinders, spheres).
## Every shape is a MeshInstance3D added under `parent`. Materials are shared per color,
## so a street full of identical windows doesn't create hundreds of materials.

static var _materials := {}


static func material(color: Color, glow := 0.0) -> StandardMaterial3D:
	var key := "%s/%s" % [color.to_html(), glow]
	if not _materials.has(key):
		var mat := StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.85
		if glow > 0.0:
			mat.emission_enabled = true
			mat.emission = color
			mat.emission_energy_multiplier = glow
		_materials[key] = mat
	return _materials[key]


static func box(parent: Node3D, size: Vector3, pos: Vector3, color: Color,
		rot_deg := Vector3.ZERO, glow := 0.0) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _add(parent, mesh, pos, color, rot_deg, glow)


static func cylinder(parent: Node3D, radius_top: float, radius_bottom: float, height: float,
		pos: Vector3, color: Color, rot_deg := Vector3.ZERO, glow := 0.0) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius_top
	mesh.bottom_radius = radius_bottom
	mesh.height = height
	mesh.radial_segments = 20
	return _add(parent, mesh, pos, color, rot_deg, glow)


static func sphere(parent: Node3D, radius: float, pos: Vector3, color: Color,
		scale := Vector3.ONE, glow := 0.0) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 24
	mesh.rings = 12
	var instance := _add(parent, mesh, pos, color, Vector3.ZERO, glow)
	instance.scale = scale
	return instance


static func capsule(parent: Node3D, radius: float, height: float, pos: Vector3, color: Color,
		rot_deg := Vector3.ZERO) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	return _add(parent, mesh, pos, color, rot_deg, 0.0)


static func _add(parent: Node3D, mesh: Mesh, pos: Vector3, color: Color, rot_deg: Vector3,
		glow: float) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = material(color, glow)
	instance.position = pos
	instance.rotation_degrees = rot_deg
	parent.add_child(instance)
	return instance


# --- Generated placeholders and collision -------------------------------------------------
# Generated nodes are added as "internal" children: they don't show up in the Scene dock and
# aren't saved into the .tscn file, because the script rebuilds them every time.

## Removes the old generated placeholder and returns a fresh, empty node to build into.
## Returns null when real art has been placed under the node's "Visual" child.
static func fresh_placeholder(node: Node3D) -> Node3D:
	var old := node.get_node_or_null("Placeholder")
	if old:
		old.free()
	var visual := node.get_node_or_null("Visual")
	if visual and visual.get_child_count() > 0:
		return null
	var holder := Node3D.new()
	holder.name = "Placeholder"
	node.add_child(holder, false, Node.INTERNAL_MODE_BACK)
	return holder


static func clear_collision(body: Node3D) -> void:
	var old: Array[Node] = []
	for child in body.get_children(true):
		if child.name.begins_with("AutoCollision"):
			old.append(child)
	for child in old:
		child.free()


static func add_box_collision(body: Node3D, size: Vector3, pos: Vector3) -> void:
	var box_shape := BoxShape3D.new()
	box_shape.size = size
	_add_collision(body, box_shape, pos)


static func add_cylinder_collision(body: Node3D, radius: float, height: float, pos: Vector3) -> void:
	var cylinder_shape := CylinderShape3D.new()
	cylinder_shape.radius = radius
	cylinder_shape.height = height
	_add_collision(body, cylinder_shape, pos)


static func _add_collision(body: Node3D, shape: Shape3D, pos: Vector3) -> void:
	var collision := CollisionShape3D.new()
	collision.name = "AutoCollision"
	collision.shape = shape
	collision.position = pos
	body.add_child(collision, true, Node.INTERNAL_MODE_BACK)
