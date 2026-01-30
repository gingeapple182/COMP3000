extends Node3D
## -- temp
@export var debug_level: LevelData
@export var current_level: LevelData
@export var levels: Array[LevelData] = []
var current_level_index: int = 0

@export var block_scene: PackedScene
@onready var block_spawn: Node3D = $Elements/BlockSpawn
@onready var level_display_title: Label = $CanvasLayer/Control/VBoxContainer/DisplayTitle
@onready var level_description: RichTextLabel = $CanvasLayer/Control/VBoxContainer/LevelDescription


## -- Scene refs -- ##

@onready var camera: Camera3D = $Camera3D
@onready var grid_manager: Node3D = $GridManager
@onready var pause_menu: Control = $PauseMenu
@onready var level_complete: Control = $LevelComplete

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
	print("[PUZZLE] Initial State →", PuzzleState.keys()[puzzle_state])
	if levels.size() > 0:
		load_level(0)
	#if current_level:
		#spawn_blocks_for_level(current_level)

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
	
	set_puzzle_state(PuzzleState.VALIDATING)
	print("[PUZZLE BOARD] Validation started")
	
	grid_manager.run_validation()
	
	if grid_manager.validate_outputs():
		set_puzzle_state(PuzzleState.SOLVED)
		var is_final_level := current_level_index >= levels.size() - 1
		if is_final_level:
			print("[PUZZLE] Final level completed")
			level_complete.show_popup(level_complete.PopupMode.OFFICE_COMPLETE)
		else:
			level_complete.show_popup(level_complete.PopupMode.LEVEL_COMPLTE)
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		level_complete.visible = true
	else:
		set_puzzle_state(PuzzleState.EDITING)


func set_puzzle_state(new_state: PuzzleState) -> void:
	if puzzle_state == new_state:
		return
	
	puzzle_state = new_state
	print("[PUZZLE] State →", PuzzleState.keys()[puzzle_state])

## -------------------- ##

func load_level(index: int) -> void:
	if index < 0 or index >= levels.size():
		print("[PUZZLE] Invalid level index:", index)
		return
	
	current_level_index = index
	current_level = levels[index]
	
	print("[PUZZLE] Loading level:", current_level.level_id)
	
	clear_level_blocks()
	
	level_display_title.text = current_level.display_title
	level_description.text = current_level.level_description
	grid_manager.apply_level(current_level)
	spawn_blocks_for_level(current_level)
	
	set_puzzle_state(PuzzleState.EDITING)

func advance_level() -> void:
	var next_index := current_level_index + 1
	if next_index >= levels.size():
		print("[PUZZLE] All levels complete")
		level_complete.show_popup(level_complete.PopupMode.OFFICE_COMPLETE)
		return
	print("[PUZZLE] Advancing to level", next_index)
	load_level(next_index)


func spawn_block(scene: PackedScene, position: Vector3) -> LogicBlock:
	if scene == null:
		return null
	var block := scene.instantiate()
	block_spawn.add_child(block)
	block.global_transform.origin = position
	return block

func configure_block(block: LogicBlock, block_type: int, subtype) -> void:
	block.block_type = block_type
	
	match block_type:
		LogicBlock.BlockType.VALUE:
			block.value = subtype  # bool
		
		LogicBlock.BlockType.GATE:
			block.gate_type = subtype  # GateType enum
		
		LogicBlock.BlockType.CONNECTOR:
			block.connector_type = subtype  # ConnectorType enum
	
	block.refresh_visuals()


func spawn_configured_block(scene: PackedScene, position: Vector3, configure: Callable) -> void:
	if scene == null:
		return
	
	var block := scene.instantiate()
	block_spawn.add_child(block)
	block.global_transform.origin = position
	
	if configure:
		configure.call(block)


func spawn_blocks_for_level(level: LevelData) -> void:
	var start_pos := block_spawn.global_transform.origin
	var blocks_per_row := 3
	var x_spacing := 1.5
	var z_spacing := 1.5
	var index := 0
	
	var block: LogicBlock
	
	# TRUE value blocks
	for i in range(level.true_value_count):
		var spawn_pos := get_tray_spawn_position(start_pos, index, blocks_per_row, x_spacing, z_spacing)
		block = spawn_block(block_scene, spawn_pos)
		if block:
			configure_block(block, LogicBlock.BlockType.VALUE, true)
		index += 1
	
	# FALSE value blocks
	for i in range(level.false_value_count):
		var spawn_pos := get_tray_spawn_position(start_pos, index, blocks_per_row, x_spacing, z_spacing)
		block = spawn_block(block_scene, spawn_pos)
		if block:
			configure_block(block, LogicBlock.BlockType.VALUE, false)
		index += 1
	
	# AND gates
	for i in range(level.and_gate_count):
		var spawn_pos := get_tray_spawn_position(start_pos, index, blocks_per_row, x_spacing, z_spacing)
		block = spawn_block(block_scene, spawn_pos)
		if block:
			configure_block(block, LogicBlock.BlockType.GATE, LogicBlock.GateType.AND)
		index += 1
	
	# NOT gates
	for i in range(level.not_gate_count):
		var spawn_pos := get_tray_spawn_position(start_pos, index, blocks_per_row, x_spacing, z_spacing)
		block = spawn_block(block_scene, spawn_pos)
		if block:
			configure_block(block, LogicBlock.BlockType.GATE, LogicBlock.GateType.NOT)
		index += 1
	
	# OR gates
	for i in range(level.or_gate_count):
		var spawn_pos := get_tray_spawn_position(start_pos, index, blocks_per_row, x_spacing, z_spacing)
		block = spawn_block(block_scene, spawn_pos)
		if block:
			configure_block(block, LogicBlock.BlockType.GATE, LogicBlock.GateType.OR)
		index += 1
	
	# L_R connectors
	for i in range(level.L_R_connector_count):
		var spawn_pos := get_tray_spawn_position(start_pos, index, blocks_per_row, x_spacing, z_spacing)
		block = spawn_block(block_scene, spawn_pos)
		if block:
			configure_block(block, LogicBlock.BlockType.CONNECTOR, LogicBlock.ConnectorType.L_R)
		index += 1
	
	# L_U connectors
	for i in range(level.L_U_connector_count):
		var spawn_pos := get_tray_spawn_position(start_pos, index, blocks_per_row, x_spacing, z_spacing)
		block = spawn_block(block_scene, spawn_pos)
		if block:
			configure_block(block, LogicBlock.BlockType.CONNECTOR, LogicBlock.ConnectorType.L_U)
		index += 1
	
	# L_D connectors
	for i in range(level.L_D_connector_count):
		var spawn_pos := get_tray_spawn_position(start_pos, index, blocks_per_row, x_spacing, z_spacing)
		block = spawn_block(block_scene, spawn_pos)
		if block:
			configure_block(block, LogicBlock.BlockType.CONNECTOR, LogicBlock.ConnectorType.L_D)
		index += 1
	
	# U_R connectors
	for i in range(level.U_R_connector_count):
		var spawn_pos := get_tray_spawn_position(start_pos, index, blocks_per_row, x_spacing, z_spacing)
		block = spawn_block(block_scene, spawn_pos)
		if block:
			configure_block(block, LogicBlock.BlockType.CONNECTOR, LogicBlock.ConnectorType.U_R)
		index += 1
	
	# U_D connectors
	for i in range(level.U_D_connector_count):
		var spawn_pos := get_tray_spawn_position(start_pos, index, blocks_per_row, x_spacing, z_spacing)
		block = spawn_block(block_scene, spawn_pos)
		if block:
			configure_block(block, LogicBlock.BlockType.CONNECTOR, LogicBlock.ConnectorType.U_D)
		index += 1
	
	# D_R connectors
	for i in range(level.D_R_connector_count):
		var spawn_pos := get_tray_spawn_position(start_pos, index, blocks_per_row, x_spacing, z_spacing)
		block = spawn_block(block_scene, spawn_pos)
		if block:
			configure_block(block, LogicBlock.BlockType.CONNECTOR, LogicBlock.ConnectorType.D_R)
		index += 1
	
	# D_U connectors
	for i in range(level.D_U_connector_count):
		var spawn_pos := get_tray_spawn_position(start_pos, index, blocks_per_row, x_spacing, z_spacing)
		block = spawn_block(block_scene, spawn_pos)
		if block:
			configure_block(block, LogicBlock.BlockType.CONNECTOR, LogicBlock.ConnectorType.D_U)
		index += 1


func get_tray_spawn_position(start_pos: Vector3, index: int, blocks_per_row: int, x_spacing: float, z_spacing: float) -> Vector3:
	var row := index / blocks_per_row
	var col := index % blocks_per_row
	var pos := start_pos
	pos.x += col * x_spacing
	pos.z += row * z_spacing 
	return pos


func clear_level_blocks() -> void:
	for child in block_spawn.get_children():
		child.queue_free()


func reload_current_level() -> void:
	load_level(current_level_index)
