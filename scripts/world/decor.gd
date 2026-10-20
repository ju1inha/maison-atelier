@tool
class_name Decor
extends StaticBody3D
## Placeholder street furniture and room decorations. Pick a `kind` in the Inspector.
## Origin = on the ground, at the object's center. Front faces +Z.
## Put real art under the Visual child and the generated placeholder disappears.

enum Kind {
	LAMP_POST, STREET_TREE, HYDRANT, BENCH, TAXI, PLANTER, CROSSWALK,
	CLOTHING_RACK, MANNEQUIN, POTTED_PLANT, PENDANT_LIGHT, MIRROR,
}

const IRON := Color("1f1f1f")
const BRASS := Color("c9a96e")
const LEAF := Color("5e7a4a")
const LEAF_LIGHT := Color("7a9658")
## Garment colors used on clothing racks.
const GARMENTS := [Color("f3ede2"), Color("1a1a1a"), Color("5e1a1d"), Color("c4a27a"), Color("2f4a3a"), Color("e8c4bd")]

@export var kind := Kind.LAMP_POST:
	set(value):
		kind = value
		_queue_rebuild()
## Used by MANNEQUIN (dress color) and PLANTER (flowers).
@export var color := Color("5e1a1d"):
	set(value):
		color = value
		_queue_rebuild()

var _rebuild_queued := false


func _ready() -> void:
	_rebuild()


func _queue_rebuild() -> void:
	if _rebuild_queued or not is_inside_tree():
		return
	_rebuild_queued = true
	_rebuild.call_deferred()


func _rebuild() -> void:
	_rebuild_queued = false
	MeshKit.clear_collision(self)
	var p := MeshKit.fresh_placeholder(self)
	match kind:
		Kind.LAMP_POST:
			MeshKit.add_cylinder_collision(self, 0.18, 4.5, Vector3(0, 2.25, 0))
			if p: _lamp_post(p)
		Kind.STREET_TREE:
			MeshKit.add_cylinder_collision(self, 0.25, 3.0, Vector3(0, 1.5, 0))
			if p: _street_tree(p)
		Kind.HYDRANT:
			MeshKit.add_cylinder_collision(self, 0.2, 0.7, Vector3(0, 0.35, 0))
			if p: _hydrant(p)
		Kind.BENCH:
			MeshKit.add_box_collision(self, Vector3(1.9, 0.9, 0.6), Vector3(0, 0.45, 0))
			if p: _bench(p)
		Kind.TAXI:
			MeshKit.add_box_collision(self, Vector3(4.3, 1.5, 1.85), Vector3(0, 0.75, 0))
			if p: _taxi(p)
		Kind.PLANTER:
			MeshKit.add_box_collision(self, Vector3(1.2, 0.8, 0.55), Vector3(0, 0.4, 0))
			if p: _planter(p)
		Kind.CROSSWALK:
			if p: _crosswalk(p)  # painted on the road, nothing to bump into
		Kind.CLOTHING_RACK:
			MeshKit.add_box_collision(self, Vector3(2.0, 1.7, 0.6), Vector3(0, 0.85, 0))
			if p: _clothing_rack(p)
		Kind.MANNEQUIN:
			MeshKit.add_cylinder_collision(self, 0.3, 1.8, Vector3(0, 0.9, 0))
			if p: _mannequin(p)
		Kind.POTTED_PLANT:
			MeshKit.add_cylinder_collision(self, 0.35, 1.0, Vector3(0, 0.5, 0))
			if p: _potted_plant(p)
		Kind.PENDANT_LIGHT:
			if p: _pendant_light(p)  # hangs from the ceiling, nothing to bump into
		Kind.MIRROR:
			MeshKit.add_box_collision(self, Vector3(1.4, 2.6, 0.2), Vector3(0, 1.3, 0))
			if p: _mirror(p)


func _lamp_post(p: Node3D) -> void:
	MeshKit.cylinder(p, 0.14, 0.2, 0.5, Vector3(0, 0.25, 0), IRON)
	MeshKit.cylinder(p, 0.06, 0.07, 4.0, Vector3(0, 2.4, 0), IRON)
	MeshKit.box(p, Vector3(0.35, 0.5, 0.35), Vector3(0, 4.55, 0), Color("ffd9a0"), Vector3.ZERO, 2.0)
	MeshKit.cylinder(p, 0.0, 0.32, 0.3, Vector3(0, 4.95, 0), IRON)
	MeshKit.box(p, Vector3(0.42, 0.06, 0.42), Vector3(0, 4.3, 0), IRON)


func _street_tree(p: Node3D) -> void:
	MeshKit.box(p, Vector3(1.4, 0.04, 1.4), Vector3(0, 0.08, 0), Color("4a3a2e"))  # soil
	for side in [-1, 1]:  # little iron fence around the tree pit
		MeshKit.box(p, Vector3(1.4, 0.04, 0.04), Vector3(0, 0.45, side * 0.7), IRON)
		MeshKit.box(p, Vector3(0.04, 0.04, 1.4), Vector3(side * 0.7, 0.45, 0), IRON)
		MeshKit.box(p, Vector3(0.05, 0.45, 0.05), Vector3(side * 0.7, 0.23, 0.7), IRON)
		MeshKit.box(p, Vector3(0.05, 0.45, 0.05), Vector3(side * 0.7, 0.23, -0.7), IRON)
	MeshKit.cylinder(p, 0.1, 0.14, 2.6, Vector3(0, 1.3, 0), Color("5a4232"))
	MeshKit.sphere(p, 1.2, Vector3(0, 3.3, 0), LEAF)
	MeshKit.sphere(p, 0.9, Vector3(0.6, 3.9, 0.2), LEAF_LIGHT)
	MeshKit.sphere(p, 0.85, Vector3(-0.6, 3.7, -0.3), LEAF_LIGHT)


func _hydrant(p: Node3D) -> void:
	var red := Color("a8322d")
	MeshKit.cylinder(p, 0.16, 0.18, 0.08, Vector3(0, 0.04, 0), red)
	MeshKit.cylinder(p, 0.13, 0.13, 0.5, Vector3(0, 0.33, 0), red)
	MeshKit.sphere(p, 0.13, Vector3(0, 0.58, 0), red)
	MeshKit.cylinder(p, 0.06, 0.06, 0.4, Vector3(0, 0.4, 0), red, Vector3(0, 0, 90))


func _bench(p: Node3D) -> void:
	var wood := Color("8a6440")
	MeshKit.box(p, Vector3(1.8, 0.08, 0.5), Vector3(0, 0.45, 0), wood)
	MeshKit.box(p, Vector3(1.8, 0.45, 0.06), Vector3(0, 0.75, -0.22), wood)
	for side in [-1, 1]:
		MeshKit.box(p, Vector3(0.06, 0.45, 0.5), Vector3(side * 0.8, 0.22, 0), IRON)
		MeshKit.box(p, Vector3(0.06, 0.06, 0.45), Vector3(side * 0.8, 0.62, -0.02), IRON)  # armrest


func _taxi(p: Node3D) -> void:
	var yellow := Color("f2c230")
	var glass := Color("2b3440")
	MeshKit.box(p, Vector3(4.2, 0.65, 1.8), Vector3(0, 0.6, 0), yellow)
	MeshKit.box(p, Vector3(2.2, 0.55, 1.6), Vector3(-0.2, 1.2, 0), yellow)
	MeshKit.box(p, Vector3(2.0, 0.42, 1.64), Vector3(-0.2, 1.2, 0), glass)  # side windows
	MeshKit.box(p, Vector3(0.6, 0.18, 0.18), Vector3(-0.2, 1.56, 0), Color("f3ede2"))  # roof light
	MeshKit.box(p, Vector3(0.1, 0.18, 1.6), Vector3(2.12, 0.55, 0), Color("cfcfcf"))  # bumpers
	MeshKit.box(p, Vector3(0.1, 0.18, 1.6), Vector3(-2.12, 0.55, 0), Color("cfcfcf"))
	MeshKit.box(p, Vector3(0.05, 0.12, 0.3), Vector3(2.15, 0.75, 0.6), Color("fff2c8"), Vector3.ZERO, 1.5)  # headlights
	MeshKit.box(p, Vector3(0.05, 0.12, 0.3), Vector3(2.15, 0.75, -0.6), Color("fff2c8"), Vector3.ZERO, 1.5)
	MeshKit.box(p, Vector3(4.0, 0.05, 0.02), Vector3(0, 0.75, 0.91), Color("1a1a1a"))  # checker stripe
	MeshKit.box(p, Vector3(4.0, 0.05, 0.02), Vector3(0, 0.75, -0.91), Color("1a1a1a"))
	for x in [-1.3, 1.3]:
		for z in [-0.85, 0.85]:
			MeshKit.cylinder(p, 0.33, 0.33, 0.25, Vector3(x, 0.33, z), Color("151515"), Vector3(90, 0, 0))


func _planter(p: Node3D) -> void:
	MeshKit.box(p, Vector3(1.2, 0.5, 0.5), Vector3(0, 0.25, 0), Color("2b2b2b"))
	MeshKit.box(p, Vector3(1.1, 0.25, 0.4), Vector3(0, 0.6, 0), LEAF)
	for i in 4:  # little flowers
		MeshKit.sphere(p, 0.09, Vector3(-0.4 + i * 0.27, 0.78, 0.05 * (i % 2)), color)


func _crosswalk(p: Node3D) -> void:
	# White bars across the road (the road runs along X, people cross along Z).
	for i in 11:
		MeshKit.box(p, Vector3(3.0, 0.01, 0.45), Vector3(0, 0.005, -4.5 + i * 0.9), Color("e8e4dc"))


func _clothing_rack(p: Node3D) -> void:
	for side in [-1, 1]:
		MeshKit.cylinder(p, 0.025, 0.025, 1.6, Vector3(side * 0.9, 0.8, 0), BRASS)
		MeshKit.box(p, Vector3(0.05, 0.04, 0.5), Vector3(side * 0.9, 0.02, 0), BRASS)
	MeshKit.cylinder(p, 0.02, 0.02, 1.8, Vector3(0, 1.58, 0), BRASS, Vector3(0, 0, 90))
	for i in 6:  # garments hanging side by side
		MeshKit.box(p, Vector3(0.08, 1.0, 0.5), Vector3(-0.65 + i * 0.26, 1.02, 0), GARMENTS[i % GARMENTS.size()])


func _mannequin(p: Node3D) -> void:
	var form := Color("f3ede2")
	MeshKit.cylinder(p, 0.25, 0.25, 0.05, Vector3(0, 0.025, 0), BRASS)
	MeshKit.cylinder(p, 0.02, 0.02, 0.6, Vector3(0, 0.3, 0), BRASS)
	MeshKit.cylinder(p, 0.15, 0.34, 0.85, Vector3(0, 0.95, 0), color)  # dress
	MeshKit.cylinder(p, 0.13, 0.15, 0.35, Vector3(0, 1.5, 0), form)  # torso
	MeshKit.cylinder(p, 0.04, 0.04, 0.12, Vector3(0, 1.72, 0), form)
	MeshKit.sphere(p, 0.11, Vector3(0, 1.85, 0), form)


func _potted_plant(p: Node3D) -> void:
	MeshKit.cylinder(p, 0.3, 0.22, 0.55, Vector3(0, 0.275, 0), Color("e8e0d2"))
	MeshKit.sphere(p, 0.4, Vector3(0, 0.9, 0), LEAF)
	MeshKit.sphere(p, 0.28, Vector3(0.2, 1.2, 0.1), LEAF_LIGHT)


func _pendant_light(p: Node3D) -> void:
	MeshKit.cylinder(p, 0.01, 0.01, 1.4, Vector3(0, 3.9, 0), IRON)
	MeshKit.cylinder(p, 0.12, 0.4, 0.35, Vector3(0, 3.05, 0), BRASS)
	MeshKit.sphere(p, 0.12, Vector3(0, 2.88, 0), Color("ffe2b0"), Vector3.ONE, 3.0)
	var light := OmniLight3D.new()
	light.position = Vector3(0, 2.7, 0)
	light.light_color = Color("ffd7a0")
	light.light_energy = 1.2
	light.omni_range = 7.0
	p.add_child(light)


func _mirror(p: Node3D) -> void:
	MeshKit.box(p, Vector3(1.4, 2.6, 0.1), Vector3(0, 1.3, 0), BRASS)
	MeshKit.box(p, Vector3(1.2, 2.4, 0.1), Vector3(0, 1.3, 0.03), Color("c9d3da"), Vector3.ZERO, 0.15)
