#extends CSGSphere3D
extends CSGCombiner3D

enum ButtonType { SCENE, DOOR, OTHER }
@export var button_type: ButtonType

@export var target_scene: PackedScene
@export var level_set: Array[LevelData] = []
@export var target_door: NodePath
@export var office_hub: NodePath

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func interact():
	match button_type:
		ButtonType.SCENE:
			handle_scene_action()
		ButtonType.DOOR:
			handle_door_action()
	#ceiling =  office_hub_01.find_child("Ceiling", true)
	#if ceiling:
	#	ceiling.visible = false
	#get_tree().change_scene_to_file("res://Scenes/puzzle_board.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func handle_scene_action() -> void:
	if target_scene == null:
		push_warning("[Interactable] No target scene set on " + name)
		return
	
	if office_hub.is_empty():
		push_warning("[Interactable] No office_hub NodePath set on " + name)
		return
	
	var hub := get_node_or_null(office_hub)
	if hub == null:
		push_warning("[Interactable] office_hub path invalid: " + str(office_hub))
		return
	
	var ceiling := hub.find_child("Ceiling", true)
	if ceiling:
		ceiling.visible = false
	
	GameManager.set_return_scene_with_id("hub_01")
	GameManager.change_scene("puzzle_board")

func handle_door_action() -> void:
	if target_door.is_empty():
		push_warning("[Interactable] No target door set on "+ name)
		return
	
	var door = get_node_or_null(target_door)
	if door == null:
		push_warning("[Interactable] Door not found: " + str(target_door))
		return
	
	if not door.has_method("toggle_open"):
		push_warning("[Interactable] Target has no 'is_open' variable.")
		return
	
	door.toggle_open()
