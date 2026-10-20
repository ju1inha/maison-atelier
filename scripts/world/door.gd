class_name Door
extends Area3D
## An invisible zone in front of a doorway. When the player stands in it a prompt appears,
## and pressing "interact" (E / Enter) takes them into target_scene.
## Leave target_scene empty for a building that's closed for now.

@export var prompt_text := "Enter"
@export_file("*.tscn") var target_scene := ""
## Name of the Marker3D (under "Spawns") where the player appears in the target scene.
@export var target_spawn := "Entrance"
@export var closed_text := "Closed for now"

var _player_inside := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside or not event.is_action_pressed("interact"):
		return
	get_viewport().set_input_as_handled()
	if target_scene == "":
		_main().show_prompt(closed_text, self)
	else:
		_main().travel_to(target_scene, target_spawn)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		_main().show_prompt("[E]  " + prompt_text, self)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		_main().hide_prompt(self)


## Main (scenes/main.tscn) shows prompts and handles travelling between places.
func _main() -> Node:
	return get_tree().get_first_node_in_group("main")
