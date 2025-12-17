extends Node3D

## -- Grid generation -- ##
@export var active_slot_scene: PackedScene
@export var inactive_slot_scene: PackedScene
@export_multiline var tile_map_string: String = ""
@export var rows: int = 1
@export var columns: int = 1

## -- Grid state runtime -- ##
var offset_x
var offset_z
var slots: Array = []
var slots_parent: Node3D
var held_piece: RigidBody3D = null
var hovered_slot: Node3D = null

## -- Slot roles -- ##
const SLOT_NORMAL := 0
const SLOT_INPUT := 1
const SLOT_OUTPUT := 2
# - Direction helpers - #
enum Direction {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

func dir_to_offset(dir: int) -> Vector2i:
	match dir:
		Direction.UP:
			return Vector2i(-1, 0)
		Direction.DOWN:
			return Vector2i(1, 0)
		Direction.LEFT:
			return Vector2i(0, -1)
		Direction.RIGHT:
			return Vector2i(0, 1)
		_:
			return Vector2i.ZERO


## -- Core -- ##

func _ready() -> void:
	offset_x = (columns - 1) * 0.5
	offset_z = (rows - 1) * 0.5
	slots_parent = get_node("../Slots")
	generate_grid()

func _process(delta: float) -> void:
	update_hover()

## ---------- ##


## -- Grid generation -- ##

func generate_grid():
	for child in slots_parent.get_children():
		child.queue_free()
	slots.clear()
	
	var spacing: float = 1.5
	var tile_map: Array = parse_tile_map()
	
	var rows_local: int = rows
	var cols_local: int = columns
	
	if tile_map.size() > 0:
		rows_local = tile_map.size()
		cols_local = tile_map[0].size()
	
	offset_x = (cols_local - 1) * 0.5
	offset_z = (rows_local - 1) * 0.5
	
	for r in range(rows_local):
		for c in range(cols_local):
			var use_active := true
			if tile_map.size() > 0:
				if r < tile_map.size() and c < tile_map[r].size():
					use_active = (tile_map[r][c] == 1)
			
			var slot_scene: PackedScene = active_slot_scene
			if not use_active:
				slot_scene = inactive_slot_scene
			
			var slot_instance = active_slot_scene.instantiate() if use_active else inactive_slot_scene.instantiate()
			if slot_instance is PackedScene:
				push_error("Slot instance is still a PackedScene, instantiate() failed")
			
			slot_instance.position = Vector3((float(c) - offset_x) * spacing, 0.0, (float(r) - offset_z) * spacing)
			slot_instance.grid_position = Vector2i(r, c)
			slots_parent.add_child(slot_instance)
			slots.append(slot_instance)

func parse_tile_map() -> Array:
	var map: Array = []
	if tile_map_string.is_empty():
		return map
	
	var lines = tile_map_string.strip_edges().split("\n")
	for line in lines:
		var row: Array = []
		line = line.strip_edges()
		for char in line:
			var value := 1
			if char != "1":
				value = 0
			row.append(value)
		map.append(row)
	return map

## --------------------- ##


## -- Placment detection -- ##

func update_hover():
	if hovered_slot:
		hovered_slot.set_highlighted(false)
		hovered_slot = null
	
	if held_piece == null:
		return
	
	hovered_slot = detect_hover_collision()
	
	if hovered_slot:
		hovered_slot.set_highlighted(true)


func detect_hover_collision() -> Node3D:
	for slot in slots_parent.get_children():
		if not slot.active:
			continue
		if slot.current_piece != null:
			continue
		
		var tile_pos = slot.global_transform.origin
		var piece_pos = held_piece.global_transform.origin
		var horizontal_distance = Vector2( 
			piece_pos.x - tile_pos.x,
			piece_pos.z - tile_pos.z
		).length()
		
		if horizontal_distance < 0.75:
			return slot
	
	return null

## ------------------------ ##


## -- Block snapping -- ##

func snap_piece_to_slot(piece: RigidBody3D, slot: Node3D) -> void:
	# Only snap to active, empty slots
	if not slot.active:
		return
	if not slot.is_free():
		return
	
	# Get the snap point inside the slot
	var snap_point: Node3D = slot.get_node("SnapPoint")
	
	# Move piece into position
	piece.global_transform.origin = snap_point.global_transform.origin
	piece.linear_velocity = Vector3.ZERO
	piece.angular_velocity = Vector3.ZERO
	
	# Register occupancy on the slot
	slot.set_piece(piece)

func try_snap(piece: RigidBody3D) -> bool:
	if hovered_slot == null:
		return false
	
	if hovered_slot.current_piece != null:
		return false
	
	var snap_pos: Vector3 = hovered_slot.get_snap_position()
	var t := piece.global_transform
	t.origin = snap_pos
	t.basis = Basis() # resets to upright rotation
	
	piece.set_deferred("global_transform", t)
	
	piece.linear_velocity = Vector3.ZERO
	piece.angular_velocity = Vector3.ZERO
	piece.gravity_scale = 0.0
	
	piece.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	piece.freeze = true
	
	hovered_slot.set_piece(piece)
	
	return true

func clear_piece_from_slots(piece: RigidBody3D) -> void:
	for slot in slots_parent.get_children():
		if slot.current_piece == piece:
			slot.clear_piece(piece)
			return

## -------------------- ##


## -- Slot queries -- ##

func get_slot_at(pos: Vector2i) -> Node:
	for slot in slots:
		if slot.grid_position == pos:
			return slot
	return null

func get_neighbour(slot: Node, dir: int) -> Node:
	var offset: Vector2i = dir_to_offset(dir)
	if offset == Vector2i.ZERO:
		return null
	
	return get_slot_at(slot.grid_position + offset)

## ------------------ ##


## -- Signal cleanup -- ##

func clear_all_signals() -> void:
	for slot in slots:
		slot.clear_signal()

func get_input_slots() -> Array:
	var inputs := []
	for slot in slots:
		if slot.slot_role == slot.SlotRole.INPUT:
			inputs.append(slot)
	return inputs

func get_output_slots() -> Array:
	var outputs := []
	for slot in slots:
		if slot.slot_role == slot.SlotRole.OUTPUT:
			outputs.append(slot)
	return outputs

func inject_input_signals() -> void:
	for slot in get_input_slots():
		slot.set_signal(slot.input_value)

func inject_value_blocks() -> void:
	for slot in slots:
		if slot.current_piece == null:
			continue
		
		if not slot.current_piece is LogicBlock:
			continue
		
		var block: LogicBlock = slot.current_piece
		if block.block_type != block.BlockType.VALUE:
			continue

		slot.set_signal(block.value)
		print(
			"[Value Block]",
			slot.grid_position,
			"value =",
			block.value
		)

## -------------------- ##


## -- Validation and propogation -- ##

func run_validation() -> void:
	clear_all_signals()
	inject_input_signals()
	inject_value_blocks()
	
	var queue: Array = []
	
	# Start propagation from ANY slot that currently has a signal
	for slot in slots:
		if slot.signal_present:
			propagate_from_slot(slot)
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var new_signal := propagate_from_slot(current)
		for s in new_signal:
			queue.append(s)

func propagate_from_slot(slot) -> Array:
	var new_signal: Array = []
	
	if not slot.signal_present:
		return new_signal
	if slot.current_piece == null:
		return new_signal
	
	if not (slot.current_piece is LogicBlock):
		return new_signal
	
	var block: LogicBlock = slot.current_piece
	
	# VALUE blocks: always output RIGHT
	if block.block_type == LogicBlock.BlockType.VALUE:
		var target := get_neighbour(slot, Direction.RIGHT)
		if target == null:
			print("  → blocked (edge)")
			return new_signal
		if not target.active:
			print("  → blocked (inactive)")
			return new_signal
		if target.signal_present:
			return new_signal
		
		target.set_signal(slot.signal_value)
		print("  → propagated to", target.grid_position, "value =", target.signal_value)
		new_signal.append(target)
		return new_signal

	
	#  CONNECTOR blocks
	if block.block_type == LogicBlock.BlockType.CONNECTOR:
		for dir in block.output_dirs:
			var target := get_neighbour(slot, dir)
			if target == null:
				print("  → blocked (edge)")
				continue
			if not target.active:
				print("  → blocked (inactive)")
				continue
			if target.signal_present:
				continue
			
			target.set_signal(slot.signal_value)
			print("  → propagated to", target.grid_position, "value =", target.signal_value)
			new_signal.append(target)
	
	return new_signal

## -------------------------------- ##


## -- Slot role assignment (temporary) -- ##

func set_slot_role(grid_pos: Vector2i, role: int, input_value: bool = false) -> void:
	for slot in slots:
		if slot.grid_position == grid_pos:
			slot.slot_role = role
			if role == slot.SlotRole.INPUT:
				slot.input_value = input_value
			print("[GridManager] set_slot_role OK:", grid_pos, " role=", role, " input=", input_value)
			return
	
	push_warning("[GridManager] set_slot_role FAILED: no slot at " + str(grid_pos))

## -------------------------------------- ##
