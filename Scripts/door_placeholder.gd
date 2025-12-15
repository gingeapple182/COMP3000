extends Node3D

@export var is_open := false:
	set(value):
		if is_open == value:
			return
		is_open = value
		if is_inside_tree():
			_apply_state()

@onready var panel: CSGBox3D = $CSGBox3D

func _ready() -> void:
	_apply_state()

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
