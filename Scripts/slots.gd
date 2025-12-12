extends Node3D

@export var active: bool = true
@onready var snap_point: Node3D = $SnapPoint

var grid_position: Vector2i
var current_piece: Node3D = null

const LIFT_HEIGHT := 0.25
const LIFT_SPEED := 8.0

var base_y := 0.0
var target_y := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_y = global_transform.origin.y
	target_y = base_y

func set_highlighted(state: bool):
	if not active:
		return
	if state:
		target_y = base_y + LIFT_HEIGHT
	else:
		target_y = base_y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var pos := global_transform.origin
	pos.y = lerp(pos.y, target_y, delta * LIFT_SPEED)
	var t := global_transform
	t.origin = pos
	global_transform = t


func is_free() -> bool:
	return active and current_piece == null


func set_piece(piece: RigidBody3D) -> void:
	current_piece = piece


func clear_piece(piece: RigidBody3D) -> void:
	if current_piece == piece:
		current_piece = null


func get_snap_position() -> Vector3:
	# If we have a SnapPoint (active tile), use that.
	print("get_snap_position() called on ", self, " snap_point=", snap_point)
	print("Returning pos: ", snap_point.global_transform.origin)
	
	if snap_point:
		return snap_point.global_transform.origin
	# Fallback: just use the tile centre
	return global_transform.origin
