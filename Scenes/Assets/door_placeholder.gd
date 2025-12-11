extends Node3D

@export var is_open: bool = false

@onready var panel: CSGBox3D = $CSGBox3D

func _ready() -> void:
	_apply_state()

func _apply_state() -> void:
	if is_open:
		# Door OPEN: no mesh, no collision → walk through
		panel.visible = false
		panel.use_collision = false
	else:
		# Door CLOSED: visible + collides
		panel.visible = true
		panel.use_collision = true
