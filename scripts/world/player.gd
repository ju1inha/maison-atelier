class_name Player
extends CharacterBody3D
## The player. Walks relative to the camera (WASD / arrows / left stick), hold Shift to run.
## The mouse (or right stick) orbits the camera around the player.
## The origin is at the feet. The art lives under Visual and turns to face where you walk.

@export var walk_speed := 4.5
@export var run_speed := 7.5
@export var mouse_sensitivity := 0.0025
## How fast the right stick turns the camera (radians per second at full tilt).
@export var stick_sensitivity := 2.5

const PITCH_MIN := -1.1  # looking down from above
const PITCH_MAX := 0.25  # looking slightly up

var _yaw := 0.0  # camera's left/right angle
var _pitch := -0.35  # camera's up/down angle
var _bob_time := 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _visual: Node3D = $Visual
@onready var _pivot: Node3D = $CameraPivot
@onready var _spring_arm: SpringArm3D = $CameraPivot/SpringArm3D


func _ready() -> void:
	# The spring arm pulls the camera in when a wall is behind you; it shouldn't hit you.
	_spring_arm.add_excluded_object(get_rid())
	_apply_camera_rotation()


func _unhandled_input(event: InputEvent) -> void:
	# Click to lock the mouse for looking around; Esc gives the mouse back.
	if event is InputEventMouseButton and event.pressed \
			and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_yaw -= event.relative.x * mouse_sensitivity
		_pitch -= event.relative.y * mouse_sensitivity
		_apply_camera_rotation()


func _physics_process(delta: float) -> void:
	var look := Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	if look != Vector2.ZERO:
		_yaw -= look.x * stick_sensitivity * delta
		_pitch -= look.y * stick_sensitivity * delta
		_apply_camera_rotation()

	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Turn the stick/keys into a direction on the ground, relative to where the camera looks.
	var direction := Vector3(input.x, 0.0, input.y).rotated(Vector3.UP, _yaw)
	var speed := run_speed if Input.is_action_pressed("run") else walk_speed
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	velocity.y = 0.0 if is_on_floor() else velocity.y - _gravity * delta
	move_and_slide()
	_animate(direction, delta)


## Stops the player from moving (used during screen fades).
func freeze(frozen: bool) -> void:
	velocity = Vector3.ZERO
	set_physics_process(not frozen)


## Puts the player on a spawn point, facing the way the spawn faces, camera behind them.
func place_at(spawn: Node3D) -> void:
	global_position = spawn.global_position
	velocity = Vector3.ZERO
	_yaw = spawn.global_rotation.y
	_pitch = -0.35
	_visual.rotation.y = _yaw
	_apply_camera_rotation()


func _apply_camera_rotation() -> void:
	_pitch = clampf(_pitch, PITCH_MIN, PITCH_MAX)
	_pivot.rotation = Vector3(_pitch, _yaw, 0.0)


## Turns the character toward where it's walking and adds a little bouncy step.
func _animate(direction: Vector3, delta: float) -> void:
	if direction.length() > 0.1:
		# Models face -Z, so this is the angle that points -Z along `direction`.
		var target_yaw := atan2(-direction.x, -direction.z)
		_visual.rotation.y = lerp_angle(_visual.rotation.y, target_yaw, 12.0 * delta)
		_bob_time += delta
		_visual.position.y = absf(sin(_bob_time * 14.0)) * 0.06
	else:
		_bob_time = 0.0
		_visual.position.y = lerpf(_visual.position.y, 0.0, 15.0 * delta)
