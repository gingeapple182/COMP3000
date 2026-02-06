#extends CSGSphere3D
extends CSGCombiner3D

enum ButtonType { SCENE, DOOR, OTHER }
var is_enabled := true
@onready var status_label: Label3D = get_node_or_null("Label3D")

@export_group("")
@export var button_type: ButtonType

@export_group("Button type: Door")
@export var target_door: NodePath

@export_group("Button type: Scene")

@export var target_scene: PackedScene
@export var office_hub: NodePath
@export var room_path: NodePath
@export var return_spawn_point: NodePath
@export var start_index: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func interact():
	if not is_enabled:
		return
	
	match button_type:
		ButtonType.SCENE:
			handle_scene_action()
		ButtonType.DOOR:
			handle_door_action()


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
	
	#GameManager.current_level_set = level_set
	var room := get_node_or_null(room_path)
	if room == null:
		push_warning("[Interactable] Invalid room_path on " + name)
		return
	
	if not room.has_puzzles:
		push_warning("[Interactable] Room has no puzzles: " + room.name)
		return
	
	GameManager.current_level_set = room.get_level_slice(start_index)
	print("[Interactable] Sending level slice from index ", start_index, " for room ", room.name)
	#GameManager.return_spawn_point = return_spawn_point
	var marker = get_node_or_null(return_spawn_point)
	if marker:
		GameManager.return_spawn_point = marker.get_path()
	else:
		push_warning("[Interactable] return_spawn_point invalid: " + str(return_spawn_point))
	
	print("[Interactable] return_spawn_point:", return_spawn_point)
	print("[Interactable] Sent to GameManager.return_spawn_point:", GameManager.return_spawn_point)
	GameManager.current_room_name = room.name
	
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

func _update_label(text: String, colour: Color) -> void:
	if status_label == null:
		return

	status_label.text = text
	status_label.modulate = colour
	status_label.visible = true
