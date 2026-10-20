@tool
class_name Block
extends StaticBody3D
## A plain box: floors, walls, sidewalks, simple furniture. Origin = bottom-center.
## Put real art under the Visual child and the generated box disappears (collision stays).

@export var size := Vector3(1, 1, 1):
	set(value):
		size = value
		_queue_rebuild()
@export var color := Color("eae2d6"):
	set(value):
		color = value
		_queue_rebuild()
## Optional thin slab on top in another color (e.g. a gold counter top). Transparent = none.
@export var top_color := Color(0, 0, 0, 0):
	set(value):
		top_color = value
		_queue_rebuild()
## Off = you can walk over/through it (rugs, floor markings).
@export var solid := true:
	set(value):
		solid = value
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
	if solid:
		MeshKit.add_box_collision(self, size, Vector3(0, size.y / 2.0, 0))
	var p := MeshKit.fresh_placeholder(self)
	if p == null:
		return
	MeshKit.box(p, size, Vector3(0, size.y / 2.0, 0), color)
	if top_color.a > 0.0:
		MeshKit.box(p, Vector3(size.x + 0.04, 0.04, size.z + 0.04), Vector3(0, size.y + 0.02, 0), top_color)
