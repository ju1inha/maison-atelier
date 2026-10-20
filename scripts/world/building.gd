@tool
class_name Building
extends StaticBody3D
## A placeholder New York building made of simple shapes, generated from the settings below.
## Change the settings in the Inspector and the building rebuilds itself, even in the editor.
## Origin = ground level at the middle of the front wall. The front faces +Z (toward the street).
## Put real art under the Visual child and the generated placeholder disappears.

enum Style { CAST_IRON, BROWNSTONE, LIMESTONE }

const GROUND_FLOOR_HEIGHT := 4.0
const FLOOR_HEIGHT := 3.2
const STOOP_HEIGHT := 1.25
const GLASS := Color("2b3440")
const LIT_GLASS := Color("f2c98a")
const SHOP_GLASS := Color("d9b98c")
const DOOR_WOOD := Color("2a1f1a")
const BRASS := Color("c9a96e")
const IRON := Color("1f1f1f")

## Text on the shop sign. Leave empty for no sign.
@export var display_name := "":
	set(value):
		display_name = value
		_queue_rebuild()
## CAST_IRON = SoHo loft with columns, BROWNSTONE = townhouse, LIMESTONE = classic pale stone.
@export var style := Style.CAST_IRON:
	set(value):
		style = value
		_queue_rebuild()
@export var width := 10.0:
	set(value):
		width = value
		_queue_rebuild()
@export var depth := 12.0:
	set(value):
		depth = value
		_queue_rebuild()
@export_range(1, 12) var floors := 4:
	set(value):
		floors = value
		_queue_rebuild()
@export var facade_color := Color("e0d6c6"):
	set(value):
		facade_color = value
		_queue_rebuild()
## Window frames, cornice and columns.
@export var trim_color := Color("cfc3ad"):
	set(value):
		trim_color = value
		_queue_rebuild()
## Big shop windows on the ground floor. Off = a townhouse with front steps (a stoop).
@export var storefront := true:
	set(value):
		storefront = value
		_queue_rebuild()
@export var has_awning := true:
	set(value):
		has_awning = value
		_queue_rebuild()
@export var awning_color := Color("1a1818"):
	set(value):
		awning_color = value
		_queue_rebuild()
@export var striped_awning := false:
	set(value):
		striped_awning = value
		_queue_rebuild()
@export var awning_stripe_color := Color("f3ede2"):
	set(value):
		awning_stripe_color = value
		_queue_rebuild()
@export var sign_color := Color("c9a96e"):
	set(value):
		sign_color = value
		_queue_rebuild()
@export var fire_escape := false:
	set(value):
		fire_escape = value
		_queue_rebuild()
@export var water_tower := false:
	set(value):
		water_tower = value
		_queue_rebuild()

var _rebuild_queued := false


func _ready() -> void:
	_rebuild()


## Rebuilding once at the end of the frame means changing five settings = one rebuild.
func _queue_rebuild() -> void:
	if _rebuild_queued or not is_inside_tree():
		return
	_rebuild_queued = true
	_rebuild.call_deferred()


func total_height() -> float:
	return GROUND_FLOOR_HEIGHT + (floors - 1) * FLOOR_HEIGHT


func _rebuild() -> void:
	_rebuild_queued = false
	var height := total_height()

	MeshKit.clear_collision(self)
	MeshKit.add_box_collision(self, Vector3(width, height, depth), Vector3(0, height / 2.0, -depth / 2.0))
	if not storefront:
		MeshKit.add_box_collision(self, Vector3(2.2, STOOP_HEIGHT, 2.0), Vector3(0, STOOP_HEIGHT / 2.0, 1.0))

	var p := MeshKit.fresh_placeholder(self)
	if p == null:
		return  # real art is in place

	var cols := maxi(2, int(width / 2.4))
	var spacing := width / cols
	var win_w := minf(1.3, spacing * 0.55)

	# Main body, cornice at the top and a band above the ground floor
	MeshKit.box(p, Vector3(width, height, depth), Vector3(0, height / 2.0, -depth / 2.0), facade_color)
	MeshKit.box(p, Vector3(width + 0.5, 0.45, 0.9), Vector3(0, height - 0.1, 0.05), trim_color)
	MeshKit.box(p, Vector3(width + 0.2, 0.18, 0.55), Vector3(0, height - 0.55, 0.05), trim_color)
	MeshKit.box(p, Vector3(width + 0.1, 0.3, 0.35), Vector3(0, GROUND_FLOOR_HEIGHT, 0.1), trim_color)

	if style == Style.CAST_IRON:
		_build_columns(p, height, cols, spacing)
	_build_upper_windows(p, cols, spacing, win_w)
	if storefront:
		_build_storefront(p)
	else:
		_build_stoop_entry(p, cols, spacing, win_w)
	if fire_escape and floors >= 3:
		_build_fire_escape(p, spacing)
	if water_tower:
		_build_water_tower(p, height)


func _build_columns(p: Node3D, height: float, cols: int, spacing: float) -> void:
	var column_height := height - GROUND_FLOOR_HEIGHT - 0.6
	for c in cols + 1:
		var x := clampf(-width / 2.0 + c * spacing, -width / 2.0 + 0.14, width / 2.0 - 0.14)
		MeshKit.box(p, Vector3(0.28, column_height, 0.22),
				Vector3(x, GROUND_FLOOR_HEIGHT + column_height / 2.0, 0.11), trim_color)


func _build_upper_windows(p: Node3D, cols: int, spacing: float, win_w: float) -> void:
	var win_h := 1.7 if style == Style.BROWNSTONE else (2.0 if style == Style.LIMESTONE else 2.2)
	for f in range(1, floors):
		var y := GROUND_FLOOR_HEIGHT + (f - 1) * FLOOR_HEIGHT + FLOOR_HEIGHT * 0.5
		for c in cols:
			var x := -width / 2.0 + spacing * (c + 0.5)
			# A simple pattern decides which windows have the lights on.
			var lit := (f * 7 + c * 3 + int(width)) % 5 == 0
			_build_window(p, x, y, win_w, win_h, lit)


func _build_window(p: Node3D, x: float, y: float, w: float, h: float, lit: bool) -> void:
	MeshKit.box(p, Vector3(w + 0.24, h + 0.24, 0.1), Vector3(x, y, 0.05), trim_color)
	MeshKit.box(p, Vector3(w, h, 0.1), Vector3(x, y, 0.09),
			LIT_GLASS if lit else GLASS, Vector3.ZERO, 0.8 if lit else 0.0)
	MeshKit.box(p, Vector3(0.05, h, 0.04), Vector3(x, y, 0.15), trim_color)  # center bar
	MeshKit.box(p, Vector3(w, 0.05, 0.04), Vector3(x, y + h * 0.15, 0.15), trim_color)  # cross bar
	MeshKit.box(p, Vector3(w + 0.4, 0.1, 0.3), Vector3(x, y - h / 2.0 - 0.14, 0.15), trim_color)  # sill
	if style != Style.CAST_IRON:
		MeshKit.box(p, Vector3(w + 0.35, 0.22, 0.2), Vector3(x, y + h / 2.0 + 0.2, 0.12), trim_color)  # lintel


func _build_storefront(p: Node3D) -> void:
	var glass_w := width - 1.8
	# Side piers, the low wall under the glass, and the big shop window
	MeshKit.box(p, Vector3(0.8, GROUND_FLOOR_HEIGHT, 0.3), Vector3(-width / 2.0 + 0.4, GROUND_FLOOR_HEIGHT / 2.0, 0.15), trim_color)
	MeshKit.box(p, Vector3(0.8, GROUND_FLOOR_HEIGHT, 0.3), Vector3(width / 2.0 - 0.4, GROUND_FLOOR_HEIGHT / 2.0, 0.15), trim_color)
	MeshKit.box(p, Vector3(glass_w, 0.5, 0.25), Vector3(0, 0.25, 0.12), trim_color)
	MeshKit.box(p, Vector3(glass_w, 2.5, 0.08), Vector3(0, 1.75, 0.06), SHOP_GLASS, Vector3.ZERO, 0.35)
	MeshKit.box(p, Vector3(glass_w, 0.12, 0.2), Vector3(0, 3.06, 0.1), trim_color)
	var panes := maxi(2, int(glass_w / 1.8))
	for i in range(1, panes):
		var x := -glass_w / 2.0 + i * glass_w / panes
		MeshKit.box(p, Vector3(0.08, 2.5, 0.1), Vector3(x, 1.75, 0.1), trim_color)
	# Front door with a brass handle
	MeshKit.box(p, Vector3(1.4, 2.7, 0.16), Vector3(0, 1.35, 0.12), DOOR_WOOD)
	MeshKit.box(p, Vector3(0.06, 0.35, 0.06), Vector3(0.5, 1.3, 0.24), BRASS)
	if has_awning:
		_build_awning(p, glass_w)
	_build_sign(p, Vector3(0, 3.55, 0.32), 96)


func _build_awning(p: Node3D, w: float) -> void:
	var tilt := 18.0
	var length := 1.6
	var rad := deg_to_rad(tilt)
	var top := Vector3(0, 3.0, 0.15)  # where it meets the wall
	var center := top + Vector3(0, -sin(rad) * length / 2.0, cos(rad) * length / 2.0)
	var stripes := maxi(1, int(w / 0.55))
	var stripe_w := w / stripes
	for i in stripes:
		var color := awning_stripe_color if striped_awning and i % 2 == 1 else awning_color
		MeshKit.box(p, Vector3(stripe_w, 0.06, length),
				center + Vector3(-w / 2.0 + stripe_w * (i + 0.5), 0, 0), color, Vector3(tilt, 0, 0))
	# The hanging flap along the front edge
	var edge := top + Vector3(0, -sin(rad) * length, cos(rad) * length)
	MeshKit.box(p, Vector3(w, 0.3, 0.04), edge + Vector3(0, -0.15, 0), awning_color)


## Brownstone-style entry: front steps up to a raised door, windows beside it.
func _build_stoop_entry(p: Node3D, cols: int, spacing: float, win_w: float) -> void:
	var stone := facade_color.darkened(0.15)
	for i in 5:
		var step_depth := 2.0 - i * 0.4
		MeshKit.box(p, Vector3(2.2, 0.25, step_depth), Vector3(0, 0.125 + i * 0.25, step_depth / 2.0), stone)
	for side in [-1, 1]:
		MeshKit.box(p, Vector3(0.05, 0.05, 2.3), Vector3(side * 1.05, 1.55, 1.0), IRON, Vector3(32, 0, 0))
		MeshKit.box(p, Vector3(0.08, 1.0, 0.08), Vector3(side * 1.05, 0.7, 1.95), IRON)
	# Raised door with a frame
	MeshKit.box(p, Vector3(1.6, 2.7, 0.12), Vector3(0, STOOP_HEIGHT + 1.35, 0.06), trim_color)
	MeshKit.box(p, Vector3(1.2, 2.4, 0.14), Vector3(0, STOOP_HEIGHT + 1.2, 0.1), DOOR_WOOD)
	MeshKit.box(p, Vector3(0.06, 0.3, 0.06), Vector3(0.42, STOOP_HEIGHT + 1.2, 0.2), BRASS)
	for c in cols:
		var x := -width / 2.0 + spacing * (c + 0.5)
		if absf(x) < 1.6:
			continue  # that's where the door is
		_build_window(p, x, 2.4, win_w, 1.7, false)
	_build_sign(p, Vector3(1.45, 2.6, 0.14), 64)


func _build_sign(p: Node3D, pos: Vector3, font_size: int) -> void:
	if display_name == "":
		return
	var sign := Label3D.new()
	sign.text = display_name
	sign.font_size = font_size
	sign.pixel_size = 0.006
	sign.outline_size = 0
	sign.modulate = sign_color
	sign.position = pos
	p.add_child(sign)


func _build_fire_escape(p: Node3D, spacing: float) -> void:
	var fe_w := spacing * 2.0 - 0.3
	var fe_x := -width / 2.0 + spacing
	for f in range(1, floors):
		var y := GROUND_FLOOR_HEIGHT + (f - 1) * FLOOR_HEIGHT + 0.1
		MeshKit.box(p, Vector3(fe_w, 0.06, 1.1), Vector3(fe_x, y, 0.6), IRON)  # platform
		MeshKit.box(p, Vector3(fe_w, 0.05, 0.05), Vector3(fe_x, y + 1.0, 1.13), IRON)  # top rail
		MeshKit.box(p, Vector3(fe_w, 0.05, 0.05), Vector3(fe_x, y + 0.5, 1.13), IRON)  # middle rail
		for side in [-1, 1]:
			MeshKit.box(p, Vector3(0.05, 1.0, 0.05), Vector3(fe_x + side * fe_w / 2.0, y + 0.5, 1.13), IRON)
		if f < floors - 1:
			# Diagonal ladder up to the next platform
			var run := fe_w - 0.8
			var length := sqrt(run * run + FLOOR_HEIGHT * FLOOR_HEIGHT)
			var angle := rad_to_deg(atan2(FLOOR_HEIGHT, run))
			MeshKit.box(p, Vector3(length, 0.05, 0.5), Vector3(fe_x, y + FLOOR_HEIGHT / 2.0, 0.6), IRON, Vector3(0, 0, angle))


## The classic wooden water tank on the roof.
func _build_water_tower(p: Node3D, height: float) -> void:
	var base := Vector3(width * 0.25, height, -depth * 0.4)
	var wood := Color("7a5a40")
	for corner in [Vector2(-0.8, -0.8), Vector2(0.8, -0.8), Vector2(-0.8, 0.8), Vector2(0.8, 0.8)]:
		MeshKit.box(p, Vector3(0.12, 2.0, 0.12), base + Vector3(corner.x, 1.0, corner.y), IRON)
	MeshKit.cylinder(p, 1.2, 1.2, 2.6, base + Vector3(0, 3.3, 0), wood)
	MeshKit.cylinder(p, 1.23, 1.23, 0.08, base + Vector3(0, 2.7, 0), IRON)  # metal hoops
	MeshKit.cylinder(p, 1.23, 1.23, 0.08, base + Vector3(0, 3.9, 0), IRON)
	MeshKit.cylinder(p, 0.0, 1.35, 1.0, base + Vector3(0, 5.1, 0), Color("4a3a2e"))  # pointy roof
