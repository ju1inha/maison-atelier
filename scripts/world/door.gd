@tool
class_name Door
extends Area2D
## An invisible zone in front of a doorway. When the player stands in it a prompt appears,
## and pressing "interact" (E / Enter) walks them into target_scene.
## Leave target_scene empty for a building that's closed for now.

@export var prompt_text := "Enter"
@export_file("*.tscn") var target_scene := ""
## Name of the Marker2D (under "Spawns") where the player appears in the target scene.
@export var target_spawn := "Entrance"
@export var closed_text := "Closed for now"
## Draws a gold doormat outline (for exits inside rooms, which have no building door).
@export var show_mat := false:
	set(value):
		show_mat = value
		queue_redraw()

var _player_inside := false

@onready var _prompt: Label = $Prompt


func _ready() -> void:
	_prompt.hide()
	if Engine.is_editor_hint():
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or not _player_inside:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if target_scene == "":
			_prompt.text = closed_text
		else:
			# Main (scenes/main.tscn) handles the fade and loading the new place.
			get_tree().get_first_node_in_group("main").travel_to(target_scene, target_spawn)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		_prompt.text = "[E]  " + prompt_text
		_prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		_prompt.hide()


func _draw() -> void:
	if show_mat:
		var mat := Rect2(-48, -14, 96, 28)
		draw_rect(mat, Color("c9a96e", 0.25))
		draw_rect(mat, Color("c9a96e"), false, 2.0)
