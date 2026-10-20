class_name LaneTraffic
extends Node3D
## Spawns things (cars or people) that travel back and forth along the x direction.
## - Cars (turn_around off): drive one way on lane_z and jump back to the start, far away.
## - People (turn_around on): walk toward +x on lane_z, turn at the end, come back on return_z.
## Everyone stops if the player (or someone going the same way) is right in front of them.
## Spawned things should have face_direction(dir), set_moving(bool) and optionally randomize_look(rng).

@export var scene: PackedScene
@export var count := 4
@export var speed := 8.0
@export var x_min := -150.0
@export var x_max := 150.0
## Lane used when moving toward +x.
@export var lane_z := 7.5
## Lane used when moving toward -x (only when turn_around is on).
@export var return_z := 12.5
@export var turn_around := false
## 1 = everyone starts moving toward +x, -1 = toward -x (cars use this for their lane).
@export var direction := 1
## Stop when something is closer than this in front.
@export var keep_distance := 6.0
## How wide the lane is when checking whether the player is in the way.
@export var lane_width := 2.0
## Change for a different (but repeatable) mix of looks and positions.
@export var seed := 1

var _movers: Array[Dictionary] = []  # each: {"node": Node3D, "dir": int}
var _player: Node3D


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	for i in count:
		var node: Node3D = scene.instantiate()
		if node.has_method("randomize_look"):
			node.randomize_look(rng)
		add_child(node)
		var dir := direction
		if turn_around and i % 2 == 1:
			dir = -direction  # people: half walk each way
		var t := (i + rng.randf_range(0.0, 0.5)) / count
		node.position = Vector3(lerpf(x_min, x_max, t), 0, _lane_for(dir))
		node.face_direction(dir)
		_movers.append({"node": node, "dir": dir})


func _physics_process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node3D
	for mover in _movers:
		var node: Node3D = mover.node
		var blocked := _is_blocked(mover)
		node.set_moving(not blocked)
		if blocked:
			continue
		var x: float = node.position.x + mover.dir * speed * delta
		if x > x_max or x < x_min:
			if turn_around:
				mover.dir = -mover.dir
				x = clampf(x, x_min, x_max)
				node.position.z = _lane_for(mover.dir)
				node.face_direction(mover.dir)
			else:
				x = x_min if mover.dir > 0 else x_max  # far away, nobody sees the jump
		node.position.x = x


func _lane_for(dir: int) -> float:
	if turn_around and dir < 0:
		return return_z
	return lane_z


func _is_blocked(mover: Dictionary) -> bool:
	var me: Vector3 = mover.node.position
	for other in _movers:
		if other == mover or other.dir != mover.dir:
			continue
		var gap: float = (other.node.position.x - me.x) * mover.dir
		if gap > 0.0 and gap < keep_distance and absf(other.node.position.z - me.z) < 1.0:
			return true
	if _player and _player.is_inside_tree():
		var p := to_local(_player.global_position)
		var gap: float = (p.x - me.x) * mover.dir
		if gap > 0.0 and gap < keep_distance and absf(p.z - me.z) < lane_width / 2.0:
			return true
	return false
