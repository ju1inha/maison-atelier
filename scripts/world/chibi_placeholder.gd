@tool
extends Node3D
## A cute big-head placeholder character made of simple shapes. Faces -Z (Godot's "forward").
## To use a real character model later: delete this node and put the model under Visual.

@export var skin_color := Color("f2d7c4"):
	set(value):
		skin_color = value
		_rebuild()
@export var hair_color := Color("3b2a25"):
	set(value):
		hair_color = value
		_rebuild()
@export var outfit_color := Color("1a1a1a"):
	set(value):
		outfit_color = value
		_rebuild()
@export var accent_color := Color("c9a96e"):
	set(value):
		accent_color = value
		_rebuild()

var _holder: Node3D


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	if not is_inside_tree():
		return  # still loading; _ready() builds it
	if _holder:
		_holder.free()
	_holder = Node3D.new()
	add_child(_holder, false, Node.INTERNAL_MODE_BACK)
	var h := _holder

	# Legs and shoes
	for side in [-1, 1]:
		MeshKit.cylinder(h, 0.06, 0.06, 0.3, Vector3(side * 0.09, 0.15, 0), Color("2a2626"))
		MeshKit.box(h, Vector3(0.12, 0.07, 0.18), Vector3(side * 0.09, 0.035, -0.03), Color("111111"))
	# Dress with a gold belt
	MeshKit.cylinder(h, 0.15, 0.3, 0.5, Vector3(0, 0.5, 0), outfit_color)
	MeshKit.cylinder(h, 0.2, 0.2, 0.04, Vector3(0, 0.64, 0), accent_color)
	# Arms and neck
	MeshKit.capsule(h, 0.05, 0.34, Vector3(-0.21, 0.56, 0), skin_color, Vector3(0, 0, -15))
	MeshKit.capsule(h, 0.05, 0.34, Vector3(0.21, 0.56, 0), skin_color, Vector3(0, 0, 15))
	MeshKit.cylinder(h, 0.06, 0.06, 0.08, Vector3(0, 0.78, 0), skin_color)
	# Big head, hair and bangs
	MeshKit.sphere(h, 0.33, Vector3(0, 1.08, 0), skin_color)
	MeshKit.sphere(h, 0.35, Vector3(0, 1.15, 0.08), hair_color)
	MeshKit.sphere(h, 0.3, Vector3(0, 1.29, -0.12), hair_color, Vector3(1, 0.5, 0.8))
	# Face: big eyes with a highlight, and blush
	for side in [-1, 1]:
		MeshKit.sphere(h, 0.055, Vector3(side * 0.11, 1.04, -0.3), Color("1b1414"), Vector3(0.85, 1.25, 0.5))
		MeshKit.sphere(h, 0.018, Vector3(side * 0.095, 1.07, -0.33), Color.WHITE)
		MeshKit.sphere(h, 0.045, Vector3(side * 0.19, 0.96, -0.26), Color("f4a7a7"), Vector3(1, 0.55, 0.4))
