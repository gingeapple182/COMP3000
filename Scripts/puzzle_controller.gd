extends Node3D

## -- Scene refs -- ##

@onready var camera: Camera3D = $Camera3D
@onready var grid_manager: Node3D = $GridManager
@onready var pause_menu: Control = $PauseMenu

## --  Player interaction -- ##
var grabbed: RigidBody3D = null
var grab_offset: Vector3 = Vector3.ZERO
@export var hover_height := 1.5
@export var lerp_speed := 10.0

## -- Puzzle state -- ##
enum PuzzleState {
	EDITING,
	VALIDATING,
	SOLVED
}
var puzzle_state: PuzzleState = PuzzleState.EDITING
var is_paused := false


## -- Core -- ##

func _ready() -> void:
	print("Scene file path:", get_scene_file_path())
	print("Node path:", get_path())
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	grid_manager.set_slot_role(Vector2i(0, 0), grid_manager.SLOT_INPUT, true)
	grid_manager.set_slot_role(Vector2i(0, 4), grid_manager.SLOT_OUTPUT)


func _process(delta: float) -> void:
	pass

## ---------- ##


## -- Input handling -- ##

func _input(event: InputEvent) -> void:
	if puzzle_state != PuzzleState.EDITING:
		return
	
	if event.is_action_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		toggle_pause()
	
	if event is InputEventMouseButton and event.pressed:
		var hit = get_mouse_hit()
		if hit:
			print("Hit collider:", hit.collider)
		else:
			print("No hit")

	# Pick up
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var hit = get_mouse_hit()
		if hit and hit.collider is RigidBody3D:
			grabbed = hit.collider
			grab_offset = Vector3.ZERO
			grid_manager.clear_piece_from_slots(grabbed)
			grabbed.freeze = false
			grabbed.gravity_scale = 0.0
			grabbed.linear_velocity = Vector3.ZERO
			
			grid_manager.held_piece = grabbed
	
	# Drop
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if grabbed:
			var snapped: bool = grid_manager.try_snap(grabbed)
			if not snapped: 
				grabbed.gravity_scale = 1.0
			grabbed.linear_velocity = Vector3.ZERO
			grabbed.angular_velocity = Vector3.ZERO
		grabbed = null
		grid_manager.held_piece = null

## -------------------- ##


## -- Physics -- ##

func _physics_process(delta):
	if grabbed == null:
		return  # ← STOP applying movement completely once dropped
	
	var hit = get_mouse_hit()
	if hit:
		var ground_pos = hit.position
		var target_pos = ground_pos + Vector3.UP * hover_height
		var current = grabbed.global_transform.origin
		var new_pos = current.lerp(target_pos, lerp_speed * delta)
		
		grabbed.global_transform.origin = new_pos
		grabbed.linear_velocity = Vector3.ZERO
		grabbed.angular_velocity = Vector3.ZERO

## ------------- ##


## -- Raycasting for hits -- ##

func get_mouse_hit():
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = origin + direction * 500
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.collision_mask = 0xFFFFFFFF   # all layers
	if grabbed:
		query.exclude = [grabbed]
	else:
		query.exclude = []
	var result = space.intersect_ray(query)
	return result

## ------------------------- ##


## -- Buttons -- ##

func _on_button_pressed() -> void:
	print("[Puzzle BOARD] Exit button pressed")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameManager.return_to_scene()

func _on_test_solution_pressed() -> void:
	if puzzle_state != PuzzleState.EDITING:
		return
	
	start_validation()

func toggle_pause():
	is_paused = not is_paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused

## ------------- ##


## -- Puzzle control -- ##

func start_validation() -> void:
	if puzzle_state != PuzzleState.EDITING:
		return
	
	puzzle_state = PuzzleState.VALIDATING
	print("[PUZZLE] Validation started")
	
	grid_manager.run_validation()

## -------------------- ##
