extends Node
## Boots the game, keeps the one Player, and moves them between locations with a fade.
## Moving between locations never changes the time of day (see GameState).

const PLAYER_SCENE := preload("res://scenes/world/player.tscn")
const START_SCENE := "res://scenes/world/side_street.tscn"
const START_SPAWN := "Start"
const FADE_SECONDS := 0.35

var _player: Player
var _location: Location
var _traveling := false

@onready var _world: Node2D = $World
@onready var _fade: ColorRect = $FadeLayer/Fade
@onready var _day_label: Label = $HUD/Panel/DayLabel
@onready var _place_label: Label = $HUD/Panel/PlaceLabel


func _ready() -> void:
	_player = PLAYER_SCENE.instantiate()
	_enter_location(START_SCENE, START_SPAWN)
	GameState.time_changed.connect(_update_hud)


## Called by doors. Fades out, swaps the location, places the player, fades back in.
func travel_to(scene_path: String, spawn_name: String) -> void:
	if _traveling:
		return
	_traveling = true
	_player.freeze(true)
	await _fade_to(1.0)
	_enter_location(scene_path, spawn_name)
	await _fade_to(0.0)
	_player.freeze(false)
	_traveling = false


func _enter_location(scene_path: String, spawn_name: String) -> void:
	# Take the player out of the old place before freeing it, so the player survives.
	if _location:
		_player.get_parent().remove_child(_player)
		_location.queue_free()
	_location = load(scene_path).instantiate()
	_world.add_child(_location)
	_location.get_node("Entities").add_child(_player)
	_player.global_position = _location.get_spawn_position(spawn_name)
	_player.set_camera_limits(_location.bounds)
	_update_hud()


func _fade_to(alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", alpha, FADE_SECONDS)
	await tween.finished


func _update_hud() -> void:
	_day_label.text = "DAY %d  ·  %s" % [GameState.day, GameState.get_time_slot().to_upper()]
	_place_label.text = _location.location_name if _location else ""
