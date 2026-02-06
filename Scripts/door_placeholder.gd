extends Node3D

@export var is_open := false:
	set(value):
		if is_open == value:
			return
		is_open = value
		if is_inside_tree():
			_apply_state()

@onready var panel: CSGBox3D = $CSGBox3D

@export var has_puzzles := false
@export var levels: Array[LevelData] = []


func _ready() -> void:
	_apply_state()
	apply_progression_state()

# ROOM STRUCTURE RULE:
# All direct children must be Node3D container nodes.
# Do not place meshes, collisions, or logic directly under this node.

func toggle_open() -> void:
	is_open = not is_open

func _apply_state() -> void:
	if is_open:
		print("[ROOM] Opening room:", name)
		panel.visible = false
		panel.use_collision = false
		## so in here i want the code to check child nodes and enable them all
		set_children_enabled(true)
	else:
		print("[ROOM] Closing room:", name)
		panel.visible = true
		panel.use_collision = true
		## so in here i want the code to check child nodes and disable them all
		set_children_enabled(false)


func set_children_enabled(enabled: bool) -> void:
	var togglied := 0
	
	for child in get_children():
		if child == panel:
			continue
		
		if child is Node3D:
			child.visible = enabled
			child.process_mode = (
				Node.PROCESS_MODE_INHERIT
				if enabled
				else Node.PROCESS_MODE_DISABLED
			)
			togglied += 1
		
		if child is not Node3D:
			push_warning("[ROOM] Non-Node3D child found in room: " + child.name) 
	
	print(
		"[ROOM] ",
		"Enabled" if enabled else "Disabled",
		" ", togglied,
		" room node(s) in ",
		name
	)


func get_level_slice(start_index: int) -> Array[LevelData]:
	if not has_puzzles:
		push_warning("[ROOM] get_level_slice called on room with has_puzzles = false: " + name)
		return []
	
	if start_index < 0 or start_index >= levels.size():
		push_warning("[ROOM] Invalid start_index " + str(start_index) + " in room: " + name)
		return []
	
	return levels.slice(start_index, levels.size())


func apply_progression_state() -> void:
	if not has_puzzles:
		return
	
	var completed_up_to := -1
	for i in range(levels.size()):
		if GameManager.is_level_complete(name, i):
			completed_up_to = i
		else:
			break
	
	var interactables_root := get_node("Interactables")
	for child in interactables_root.get_children():
		if not child.has_method("interact"):
			continue
		
		if child.start_index <= completed_up_to:
			# completed → remove / disable
			child.visible = false
			child._update_label("FICXED", Color.GRAY)
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.is_enabled = false
		elif child.start_index == completed_up_to + 1:
			# next available → keep active
			child.visible = true
			child._update_label("AVAILABLE", Color.GREEN)
			child.process_mode = Node.PROCESS_MODE_INHERIT
			child.is_enabled = true
		else:
			# future → hide or keep blocked
			child.visible = true
			child._update_label("LOCKED", Color.RED)
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.is_enabled = false
