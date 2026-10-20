class_name Location
extends Node3D
## Shared script for every place you can walk around: a street, the Atelier, Home.
## Each location scene needs a "Spawns" child holding Marker3D points where the player
## can appear. A marker's blue arrow (-Z) is the way the player faces when they arrive.

## Shown in the HUD.
@export var location_name := "Somewhere"
## The area (seen from above: x and z) the player can walk in. Invisible walls surround it.
@export var walk_area := Rect2(-10, -10, 20, 20)


func _ready() -> void:
	_build_edge_walls()


func get_spawn(spawn_name: String) -> Node3D:
	var marker := get_node_or_null("Spawns/" + spawn_name) as Node3D
	if marker == null:
		push_warning("No spawn point named '%s' in %s" % [spawn_name, name])
		return get_node("Spawns").get_child(0)
	return marker


## Adds four tall invisible walls around walk_area so the player can't wander off the map.
func _build_edge_walls() -> void:
	var walls := StaticBody3D.new()
	walls.name = "EdgeWalls"
	add_child(walls)
	var t := 1.0  # wall thickness
	var wall_height := 20.0
	var r := walk_area  # r.position.y and r.size.y are really z values here
	var pieces := [  # [center (x, z), size (x, z)]
		[Vector2(r.get_center().x, r.position.y - t / 2.0), Vector2(r.size.x + 2.0 * t, t)],
		[Vector2(r.get_center().x, r.end.y + t / 2.0), Vector2(r.size.x + 2.0 * t, t)],
		[Vector2(r.position.x - t / 2.0, r.get_center().y), Vector2(t, r.size.y)],
		[Vector2(r.end.x + t / 2.0, r.get_center().y), Vector2(t, r.size.y)],
	]
	for piece in pieces:
		var box := BoxShape3D.new()
		box.size = Vector3(piece[1].x, wall_height, piece[1].y)
		var shape := CollisionShape3D.new()
		shape.shape = box
		shape.position = Vector3(piece[0].x, wall_height / 2.0, piece[0].y)
		walls.add_child(shape)
