extends Node3D

@onready var pause_menu = $PauseMenu
@onready var office_hub_01: Node3D = $OfficeHub01

var ceiling: Node3D

var is_paused := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ceiling =  office_hub_01.find_child("Ceiling", true)
	if ceiling:
		ceiling.visible = true

func _input(event):
	if event.is_action_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		toggle_pause()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func toggle_pause():
	is_paused = not is_paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused
