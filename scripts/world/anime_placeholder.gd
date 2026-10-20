@tool
class_name AnimePlaceholder
extends Node3D
## A slim anime-style placeholder person made of simple shapes (about 1.7 m tall).
## Faces -Z (Godot's "forward"). Used for the player and for people walking on the street.
## To use a real character model later: delete this node and put the model under Visual.

enum Hair { LONG, BOB, BUN, PONYTAIL, SHORT }
enum Bottom { SKIRT, PANTS, DRESS }

const SKIN_TONES := [Color("f6dccb"), Color("eac3a6"), Color("d4a383"), Color("a8775a"), Color("7a5240")]
const HAIR_COLORS := [Color("2b1f1c"), Color("5a3a2a"), Color("a0683f"), Color("e2c48c"), Color("c25a4a"), Color("efd2dc")]
const EYE_COLORS := [Color("3b2a25"), Color("2f4a6e"), Color("3e6b4a"), Color("6b4a8a")]
const OUTFIT_COLORS := [
	Color("f3ede2"), Color("1a1a1a"), Color("f2b8c6"), Color("c9a96e"), Color("9fc6b3"),
	Color("b9b0e0"), Color("f6e3a1"), Color("8fb3dd"), Color("5e1a1d"), Color("ffffff"),
]

@export var skin_color := Color("f6dccb"):
	set(value):
		skin_color = value
		_queue_rebuild()
@export var hair_style := Hair.LONG:
	set(value):
		hair_style = value
		_queue_rebuild()
@export var hair_color := Color("2b1f1c"):
	set(value):
		hair_color = value
		_queue_rebuild()
@export var eye_color := Color("3b2a25"):
	set(value):
		eye_color = value
		_queue_rebuild()
@export var top_color := Color("f2b8c6"):
	set(value):
		top_color = value
		_queue_rebuild()
@export var bottom_style := Bottom.SKIRT:
	set(value):
		bottom_style = value
		_queue_rebuild()
@export var bottom_color := Color("f3ede2"):
	set(value):
		bottom_color = value
		_queue_rebuild()
@export var shoe_color := Color("c9a96e"):
	set(value):
		shoe_color = value
		_queue_rebuild()

var _holder: Node3D
var _rebuild_queued := false


func _ready() -> void:
	_rebuild()


## Gives this person a random look (used for people on the street).
func randomize_look(rng: RandomNumberGenerator) -> void:
	skin_color = SKIN_TONES[rng.randi() % SKIN_TONES.size()]
	hair_style = (rng.randi() % Hair.size()) as Hair
	hair_color = HAIR_COLORS[rng.randi() % HAIR_COLORS.size()]
	eye_color = EYE_COLORS[rng.randi() % EYE_COLORS.size()]
	top_color = OUTFIT_COLORS[rng.randi() % OUTFIT_COLORS.size()]
	bottom_style = (rng.randi() % Bottom.size()) as Bottom
	bottom_color = OUTFIT_COLORS[rng.randi() % OUTFIT_COLORS.size()]
	shoe_color = [Color("1a1a1a"), Color("c9a96e"), Color("f3ede2"), Color("8a5a3a")][rng.randi() % 4]


func _queue_rebuild() -> void:
	if _rebuild_queued or not is_inside_tree():
		return
	_rebuild_queued = true
	_rebuild.call_deferred()


func _rebuild() -> void:
	_rebuild_queued = false
	if _holder:
		_holder.free()
	_holder = Node3D.new()
	add_child(_holder, false, Node.INTERNAL_MODE_BACK)
	var h := _holder
	var dress := bottom_style == Bottom.DRESS
	var lower := top_color if dress else bottom_color

	# Shoes and legs
	for side in [-1, 1]:
		MeshKit.box(h, Vector3(0.09, 0.07, 0.22), Vector3(side * 0.085, 0.035, -0.03), shoe_color)
		if bottom_style == Bottom.PANTS:
			MeshKit.capsule(h, 0.065, 0.86, Vector3(side * 0.085, 0.48, 0), lower)
		else:
			MeshKit.capsule(h, 0.05, 0.84, Vector3(side * 0.085, 0.47, 0), skin_color)
	# Skirt (or the lower half of a dress)
	if bottom_style != Bottom.PANTS:
		MeshKit.cylinder(h, 0.14, 0.27, 0.42, Vector3(0, 0.87, 0), lower)
	else:
		MeshKit.cylinder(h, 0.14, 0.17, 0.16, Vector3(0, 0.94, 0), lower)  # hips
	# Torso, waist and arms
	MeshKit.cylinder(h, 0.15, 0.125, 0.4, Vector3(0, 1.18, 0), top_color)
	MeshKit.cylinder(h, 0.13, 0.13, 0.04, Vector3(0, 1.0, 0), Color("c9a96e") if dress else lower)
	for side in [-1, 1]:
		MeshKit.capsule(h, 0.04, 0.6, Vector3(side * 0.2, 1.06, 0), skin_color, Vector3(0, 0, side * 7))
		MeshKit.capsule(h, 0.052, 0.26, Vector3(side * 0.19, 1.25, 0), top_color, Vector3(0, 0, side * 7))
	MeshKit.cylinder(h, 0.045, 0.045, 0.1, Vector3(0, 1.42, 0), skin_color)

	# Head (slightly tall, anime proportions)
	MeshKit.sphere(h, 0.15, Vector3(0, 1.56, 0), skin_color, Vector3(1, 1.12, 1))
	_build_hair(h)
	# Face: big eyes with highlights, blush and a tiny mouth
	for side in [-1, 1]:
		MeshKit.sphere(h, 0.028, Vector3(side * 0.052, 1.55, -0.138), eye_color, Vector3(0.8, 1.3, 0.4))
		MeshKit.sphere(h, 0.009, Vector3(side * 0.046, 1.565, -0.149), Color.WHITE)
		MeshKit.sphere(h, 0.022, Vector3(side * 0.085, 1.51, -0.118), Color("f4a7a7"), Vector3(1, 0.55, 0.3))
	MeshKit.box(h, Vector3(0.03, 0.007, 0.006), Vector3(0, 1.48, -0.136), Color("d77a86"))


func _build_hair(h: Node3D) -> void:
	MeshKit.sphere(h, 0.158, Vector3(0, 1.6, 0.025), hair_color, Vector3(1, 1.05, 1))  # top and back
	MeshKit.sphere(h, 0.13, Vector3(0, 1.665, -0.09), hair_color, Vector3(1.05, 0.45, 0.6))  # bangs
	match hair_style:
		Hair.LONG:
			MeshKit.capsule(h, 0.14, 0.62, Vector3(0, 1.38, 0.07), hair_color).scale = Vector3(1.1, 1, 0.55)
		Hair.BOB:
			MeshKit.sphere(h, 0.17, Vector3(0, 1.52, 0.03), hair_color, Vector3(1.05, 0.8, 1))
		Hair.BUN:
			MeshKit.sphere(h, 0.07, Vector3(0, 1.77, 0.07), hair_color)
		Hair.PONYTAIL:
			MeshKit.capsule(h, 0.05, 0.38, Vector3(0, 1.5, 0.18), hair_color, Vector3(20, 0, 0))
		Hair.SHORT:
			pass  # the base cap is the haircut
