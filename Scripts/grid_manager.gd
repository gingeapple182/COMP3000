extends Node3D

@export var active_slot_scene: PackedScene
@export var inactive_slot_scene: PackedScene
@export_multiline var tile_map_string: String = ""
@export var rows: int = 1
@export var columns: int = 1

var offset_x
var offset_z

var slots_parent: Node3D
var held_piece: RigidBody3D = null
var hovered_slot: Node3D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	offset_x = (columns - 1) * 0.5
	offset_z = (rows - 1) * 0.5
	slots_parent = get_node("../Slots")
	generate_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_hover()


func generate_grid():
	for child in slots_parent.get_children():
		child.queue_free()
	
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
		
		var tile_pos = slot.global_transform.origin
		var piece_pos = held_piece.global_transform.origin
		var horizontal_distance = Vector2( 
			piece_pos.x - tile_pos.x,
			piece_pos.z - tile_pos.z
		).length()
		
		if horizontal_distance < 0.75:
			return slot
	
	return null


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
	#piece.gravity_scale = 0.0
	#piece.freeze = true  # lock in place until picked up again
	
	# Register occupancy on the slot
	slot.set_piece(piece)


func try_snap(piece: RigidBody3D) -> bool:
	print("\n>>> try_snap() CALLED")
	print("hovered_slot: ", hovered_slot)
	if hovered_slot == null:
		print("FAIL: hovered_slot is NULL")
		return false
	
	if hovered_slot.current_piece != null:
		print("FAIL: Slot already occupied")
		return false
	
	var snap_pos = hovered_slot.get_snap_position()
	print("Snapping to: ", snap_pos)
	print("Piece BEFORE snap: ", piece.global_transform.origin)
	
	piece.global_transform.origin = snap_pos
	print("Piece AFTER snap: ", piece.global_transform.origin)
	#piece.freeze = true
	#piece.gravity_scale = 0.0
	piece.linear_velocity = Vector3.ZERO
	piece.angular_velocity = Vector3.ZERO
	
	hovered_slot.set_piece(piece)  # ← use the helper
	
	return true


func clear_piece_from_slots(piece: RigidBody3D) -> void:
	for slot in slots_parent.get_children():
		if slot.current_piece == piece:
			slot.clear_piece(piece)
			return
