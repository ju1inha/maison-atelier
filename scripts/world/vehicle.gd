class_name Vehicle
extends AnimatableBody3D
## A car that drives along the street (moved by a LaneTraffic node). The front faces +X.
## Put real art under the Visual child and the generated placeholder disappears.

const TAXI_YELLOW := Color("f2c230")
const CAR_COLORS := [Color("1a1a1a"), Color("f3ede2"), Color("f2b8c6"), Color("bcd3ea"), Color("b9d8c6")]

@export var body_color := TAXI_YELLOW
@export var is_taxi := true


func _ready() -> void:
	var p := MeshKit.fresh_placeholder(self)
	if p:
		build_car(p, body_color, is_taxi)


## Half the cars are taxis, the rest are town cars in black or pastel colors.
func randomize_look(rng: RandomNumberGenerator) -> void:
	is_taxi = rng.randf() < 0.5
	body_color = TAXI_YELLOW if is_taxi else CAR_COLORS[rng.randi() % CAR_COLORS.size()]


func face_direction(dir: int) -> void:
	rotation.y = 0.0 if dir > 0 else PI


func set_moving(_moving: bool) -> void:
	pass  # cars just stop; nothing to animate yet


## Builds a simple car out of boxes (also used for the parked taxis in Decor).
static func build_car(p: Node3D, color: Color, taxi: bool) -> void:
	var glass := Color("2b3440")
	var chrome := Color("cfcfcf")
	MeshKit.box(p, Vector3(4.2, 0.65, 1.8), Vector3(0, 0.6, 0), color)
	MeshKit.box(p, Vector3(2.2, 0.55, 1.6), Vector3(-0.2, 1.2, 0), color)
	MeshKit.box(p, Vector3(2.0, 0.42, 1.64), Vector3(-0.2, 1.2, 0), glass)  # side windows
	MeshKit.box(p, Vector3(0.1, 0.18, 1.6), Vector3(2.12, 0.55, 0), chrome)  # bumpers
	MeshKit.box(p, Vector3(0.1, 0.18, 1.6), Vector3(-2.12, 0.55, 0), chrome)
	for z in [-0.6, 0.6]:
		MeshKit.box(p, Vector3(0.05, 0.12, 0.3), Vector3(2.15, 0.75, z), Color("fff2c8"), Vector3.ZERO, 1.5)  # headlights
		MeshKit.box(p, Vector3(0.05, 0.12, 0.3), Vector3(-2.15, 0.75, z), Color("d94a4a"), Vector3.ZERO, 0.8)  # taillights
	if taxi:
		MeshKit.box(p, Vector3(0.6, 0.18, 0.18), Vector3(-0.2, 1.56, 0), Color("f3ede2"))  # roof light
		MeshKit.box(p, Vector3(4.0, 0.05, 0.02), Vector3(0, 0.75, 0.91), Color("1a1a1a"))  # checker stripe
		MeshKit.box(p, Vector3(4.0, 0.05, 0.02), Vector3(0, 0.75, -0.91), Color("1a1a1a"))
	for x in [-1.3, 1.3]:
		for z in [-0.85, 0.85]:
			MeshKit.cylinder(p, 0.33, 0.33, 0.25, Vector3(x, 0.33, z), Color("151515"), Vector3(90, 0, 0))
