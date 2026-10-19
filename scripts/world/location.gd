class_name Location
extends Node2D
## Shared script for every place you can walk around: a street, the atelier, home.
## Each location scene needs:
##   - an "Entities" child with Y Sort on (the player gets placed in here)
##   - a "Spawns" child holding Marker2D points where the player can appear

## Shown in the HUD.
@export var location_name := "Somewhere"
## The area of this place. Invisible walls are built along its edges,
## and the camera never shows anything outside it.
@export var bounds := Rect2(0, 0, 1280, 720)


func _ready() -> void:
	_build_edge_walls()


func get_spawn_position(spawn_name: String) -> Vector2:
	var marker := get_node_or_null("Spawns/" + spawn_name) as Marker2D
	if marker == null:
		push_warning("No spawn point named '%s' in %s" % [spawn_name, name])
		return bounds.get_center()
	return marker.global_position


## Adds four invisible walls just outside the bounds so the player can't walk off the map.
func _build_edge_walls() -> void:
	var walls := StaticBody2D.new()
	walls.name = "EdgeWalls"
	add_child(walls)
	var t := 40.0  # wall thickness
	var r := bounds
	var wall_rects := [
		Rect2(r.position.x - t, r.position.y - t, r.size.x + 2 * t, t),  # top
		Rect2(r.position.x - t, r.end.y, r.size.x + 2 * t, t),  # bottom
		Rect2(r.position.x - t, r.position.y, t, r.size.y),  # left
		Rect2(r.end.x, r.position.y, t, r.size.y),  # right
	]
	for rect: Rect2 in wall_rects:
		var box := RectangleShape2D.new()
		box.size = rect.size
		var shape := CollisionShape2D.new()
		shape.shape = box
		shape.position = rect.get_center()
		walls.add_child(shape)
