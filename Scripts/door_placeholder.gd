extends Node3D

@export var is_open: bool = false

@onready var panel: CSGBox3D = $CSGBox3D

func _ready() -> void:
	_apply_state()

# ROOM STRUCTURE RULE:
# All direct children must be Node3D container nodes.
# Do not place meshes, collisions, or logic directly under this node.

func _apply_state() -> void:
	if is_open:
		# Door OPEN
		panel.visible = false
		panel.use_collision = false
		## so in here i want the code to check child nodes and enable them all
		set_children_enabled(true)
	else:
		# Door CLOSED
		panel.visible = true
		panel.use_collision = true
		## so in here i want the code to check child nodes and disable them all
		set_children_enabled(false)


func set_children_enabled(enabled: bool) -> void:
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
