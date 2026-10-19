@tool
class_name Player
extends CharacterBody2D
## The player character. Walks in 8 directions with WASD, arrow keys or a gamepad stick.
## The origin is at the character's feet so y-sorting puts them in front of / behind things.
## Until real art is placed under the Visual child, it draws a simple placeholder figure.

const GOLD := Color("c9a96e")

@export var speed := 240.0

@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	var visual := get_node_or_null("Visual")
	if visual:
		# Redraw when art is added/removed so the placeholder hides itself automatically.
		visual.child_entered_tree.connect(func(_node): queue_redraw())
		visual.child_exiting_tree.connect(func(_node): queue_redraw())


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()


## Stops the player from moving (used during screen fades).
func freeze(frozen: bool) -> void:
	velocity = Vector2.ZERO
	set_physics_process(not frozen)


## Keeps the camera inside the current location's area and snaps it to the player.
func set_camera_limits(bounds: Rect2) -> void:
	_camera.limit_left = int(bounds.position.x)
	_camera.limit_top = int(bounds.position.y)
	_camera.limit_right = int(bounds.end.x)
	_camera.limit_bottom = int(bounds.end.y)
	_camera.reset_smoothing()


func _draw() -> void:
	var visual := get_node_or_null("Visual")
	if visual and visual.get_child_count() > 0:
		return  # real art is in place
	# Soft shadow at the feet
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, 16, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO)
	# Body and head
	draw_rect(Rect2(-12, -44, 24, 40), Color("141414"))
	draw_rect(Rect2(-12, -44, 24, 3), GOLD)
	draw_circle(Vector2(0, -54), 10, Color("e8d9c4"))
