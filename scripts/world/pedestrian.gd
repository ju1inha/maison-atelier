class_name Pedestrian
extends AnimatableBody3D
## Someone strolling down the sidewalk (moved by a LaneTraffic node). Ambiance for now;
## later they could become clients you can talk to.

var _moving := true
var _bob_time := 0.0


## Random hair, skin and outfit, so the street looks like a crowd of different people.
func randomize_look(rng: RandomNumberGenerator) -> void:
	get_node("Visual/AnimePlaceholder").randomize_look(rng)
	_bob_time = rng.randf() * 10.0  # so they don't all bounce in sync


func face_direction(dir: int) -> void:
	# Models face -Z; turning -90° makes them face +X.
	get_node("Visual").rotation.y = -PI / 2.0 if dir > 0 else PI / 2.0


func set_moving(moving: bool) -> void:
	_moving = moving


func _process(delta: float) -> void:
	var visual: Node3D = $Visual
	if _moving:
		_bob_time += delta
		visual.position.y = absf(sin(_bob_time * 9.0)) * 0.035
	else:
		visual.position.y = lerpf(visual.position.y, 0.0, 10.0 * delta)
