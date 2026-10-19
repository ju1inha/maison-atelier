@tool
class_name Prop
extends StaticBody2D
## A solid block in the world: a building, a wall, a piece of furniture.
## The origin is the bottom-center (where it touches the ground) so y-sorting works.
## Until real art is placed under the Visual child, it draws a labeled placeholder box.

const GOLD := Color("c9a96e")

@export var display_name := "":
	set(value):
		display_name = value
		queue_redraw()
@export var size := Vector2(200, 120):
	set(value):
		size = value
		_update_collision()
		queue_redraw()
@export var color := Color("1e1a18"):
	set(value):
		color = value
		queue_redraw()
@export var label_color := Color("f5efe3"):
	set(value):
		label_color = value
		queue_redraw()
## Draws a gold door on the front of the placeholder (for buildings).
@export var has_door := false:
	set(value):
		has_door = value
		queue_redraw()
## How deep the solid part is, measured up from the bottom edge. 0 = the whole box is solid.
## Use a small value for tall thin things (lamp posts) so the player can walk behind them.
@export var footprint := 0.0:
	set(value):
		footprint = value
		_update_collision()


func _ready() -> void:
	_update_collision()
	var visual := get_node_or_null("Visual")
	if visual:
		# Redraw when art is added/removed so the placeholder hides itself automatically.
		visual.child_entered_tree.connect(func(_node): queue_redraw())
		visual.child_exiting_tree.connect(func(_node): queue_redraw())


func _update_collision() -> void:
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null:
		return  # not loaded yet; _ready() calls this again
	var depth := size.y if footprint <= 0.0 else minf(footprint, size.y)
	# A fresh shape per prop, so resizing one prop never resizes the others.
	var box := RectangleShape2D.new()
	box.size = Vector2(size.x, depth)
	collision.shape = box
	collision.position = Vector2(0, -depth / 2.0)


func _draw() -> void:
	var visual := get_node_or_null("Visual")
	if visual and visual.get_child_count() > 0:
		return  # real art is in place
	var rect := Rect2(Vector2(-size.x / 2.0, -size.y), size)
	draw_rect(rect, color)
	draw_rect(Rect2(rect.position, Vector2(size.x, 3)), GOLD)  # thin gold rule on top
	if has_door:
		var door := Rect2(Vector2(-28, -80), Vector2(56, 80))
		draw_rect(door, GOLD.darkened(0.4))
		draw_rect(door, GOLD, false, 2.0)
	if display_name != "":
		# Buildings get a shopfront sign just above the door; furniture is labeled at the top.
		var label_y := -100.0 if has_door else -size.y + 34
		draw_string(ThemeDB.fallback_font, Vector2(-size.x / 2.0, label_y), display_name,
				HORIZONTAL_ALIGNMENT_CENTER, size.x, 22 if has_door else 20, label_color)
