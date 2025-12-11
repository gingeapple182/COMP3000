extends CSGSphere3D
#extends Node3D
@onready var office_hub_01: Node3D = $"../OfficeHub01"
@onready var ceiling: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func interact():
	ceiling =  office_hub_01.find_child("Ceiling", true)
	if ceiling:
		ceiling.visible = false
	get_tree().change_scene_to_file("res://Scenes/puzzle_board.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
