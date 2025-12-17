extends Node3D

## -- Slot config -- ##
@export var active: bool = true
@export var slot_role: SlotRole = SlotRole.NORMAL
@export var input_value: bool = false

@onready var snap_point: Node3D = $SnapPoint

## -- Block height + pos -- ##
var grid_position: Vector2i
var current_piece: Node3D = null

const LIFT_HEIGHT := 0.25
const LIFT_SPEED := 8.0

var base_y := 0.0
var target_y := 0.0

## -- Signal state -- ##
var signal_present: bool = false
var signal_value: bool = false

## -- Slot Roles -- ##
enum SlotRole {
	NORMAL,
	INPUT,
	OUTPUT
}

## -- Core -- ##

func _ready() -> void:
	base_y = global_transform.origin.y
	target_y = base_y

func _process(delta: float) -> void:
	var pos := global_transform.origin
	pos.y = lerp(pos.y, target_y, delta * LIFT_SPEED)
	var t := global_transform
	t.origin = pos
	global_transform = t

## ---------- ##


## -- Visual highlight -- ##

func set_highlighted(state: bool):
	if not active:
		return
	if state:
		target_y = base_y + LIFT_HEIGHT
	else:
		target_y = base_y

## ---------------------- ##


## -- Block handling -- ##

func is_free() -> bool:
	return active and current_piece == null

func set_piece(piece: RigidBody3D) -> void:
	current_piece = piece

func clear_piece(piece: RigidBody3D) -> void:
	if current_piece == piece:
		current_piece = null

func get_snap_position() -> Vector3:
	if snap_point:
		return snap_point.global_transform.origin
	return global_transform.origin

## -------------------- ##


## -- Signal management -- ##

func clear_signal() -> void:
	signal_present = false
	signal_value = false

func set_signal(value: bool) -> void:
	signal_present = true
	signal_value = value

## ----------------------- ##
