@tool
class_name CityBackdrop
extends Node3D
## Far-away city scenery you can't walk to, so the street doesn't fade into nothing:
## the street continuing past the avenues at both ends, and a skyline of towers all around.
## It's just simple shapes (no collision); the pastel fog makes the distance look hazy.

const PASTELS := [
	Color("f2d6d3"), Color("f6ecdd"), Color("cfe3d6"), Color("dcd5ec"),
	Color("f8ebc4"), Color("cfdff0"), Color("e9d1c6"), Color("efe4e9"),
]
const WINDOW_BAND := Color("8a93a3")

## Change to get a different (random but repeatable) skyline.
@export var seed := 7:
	set(value):
		seed = value
		_queue_rebuild()
## Where the far street starts (just past the cross avenues) and ends, on both sides.
@export var street_start_x := 52.0
@export var street_end_x := 170.0
@export var tower_count := 80:
	set(value):
		tower_count = value
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
	var p := MeshKit.fresh_placeholder(self)
	if p == null:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	for side in [-1, 1]:
		_build_far_street(p, rng, side)
	_build_towers(p, rng)


## The same street continuing into the distance: road, sidewalks and two rows of buildings.
func _build_far_street(p: Node3D, rng: RandomNumberGenerator, side: int) -> void:
	var length := street_end_x - street_start_x
	var center_x := side * (street_start_x + length / 2.0)
	MeshKit.box(p, Vector3(length, 0.1, 10), Vector3(center_x, -0.05, 10), Color("706b6d"))
	MeshKit.box(p, Vector3(length, 0.12, 5), Vector3(center_x, -0.04, 2.5), Color("ede3d6"))
	MeshKit.box(p, Vector3(length, 0.12, 5), Vector3(center_x, -0.04, 17.5), Color("ede3d6"))
	# Rows start a bit further out, behind the corner buildings on the avenue.
	for row_front_z in [0.0, 20.0]:
		var x := street_start_x + 12.0
		while x < street_end_x:
			var w := rng.randf_range(8.0, 14.0)
			_build_far_building(p, rng, Vector3(side * (x + w / 2.0), 0, row_front_z), w, row_front_z > 10.0)
			x += w


func _build_far_building(p: Node3D, rng: RandomNumberGenerator, front: Vector3, w: float, faces_north: bool) -> void:
	var h := rng.randf_range(13.0, 26.0)
	var d := 12.0
	var facing := -1.0 if faces_north else 1.0  # which way the front faces (z)
	var color: Color = PASTELS[rng.randi() % PASTELS.size()]
	MeshKit.box(p, Vector3(w, h, d), front + Vector3(0, h / 2.0, -facing * d / 2.0), color)
	MeshKit.box(p, Vector3(w + 0.4, 0.4, 0.6), front + Vector3(0, h - 0.2, facing * 0.1), color.lightened(0.3))
	# Rows of windows read as darker stripes from far away.
	var y := 5.0
	while y < h - 2.0:
		MeshKit.box(p, Vector3(w - 1.2, 1.3, 0.06), front + Vector3(0, y, facing * 0.03), WINDOW_BAND)
		y += 3.2


## Towers all around, taller the further away they are. None are placed over the street lines.
func _build_towers(p: Node3D, rng: RandomNumberGenerator) -> void:
	var placed := 0
	var attempts := 0
	while placed < tower_count and attempts < tower_count * 10:
		attempts += 1
		var angle := rng.randf() * TAU
		var radius := rng.randf_range(75.0, 260.0)
		var pos := Vector3(cos(angle) * radius, 0, 10.0 + sin(angle) * radius)
		if absf(pos.z - 10.0) < 32.0 and absf(pos.x) < street_end_x + 25.0:
			continue  # keep the view down the street clear
		var t := inverse_lerp(75.0, 260.0, radius)
		var h := rng.randf_range(lerpf(25.0, 70.0, t), lerpf(55.0, 190.0, t))
		var w := rng.randf_range(14.0, 30.0)
		var d := rng.randf_range(14.0, 30.0)
		var color: Color = PASTELS[rng.randi() % PASTELS.size()]
		MeshKit.box(p, Vector3(w, h, d), pos + Vector3(0, h / 2.0, 0), color)
		if rng.randf() < 0.5:  # a stepped top, like classic Manhattan towers
			var top_h := h * 0.15
			MeshKit.box(p, Vector3(w * 0.65, top_h, d * 0.65), pos + Vector3(0, h + top_h / 2.0, 0), color.lightened(0.15))
			if rng.randf() < 0.4:
				MeshKit.cylinder(p, 0.0, 1.2, h * 0.12, pos + Vector3(0, h + top_h + h * 0.06, 0), color.lightened(0.3))
		placed += 1
