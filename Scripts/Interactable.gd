#extends CSGSphere3D
extends CSGCombiner3D

enum ButtonType { PUZZLE, SCENE, DOOR, NPC, OTHER }

var is_enabled := true
@onready var status_label: Label3D = get_node_or_null("Label3D")

@export_group("")
@export var button_type: ButtonType



@export_group("Button type: Scene")

#@export var target_scene: PackedScene
enum SceneID { LANDING_MENU, HUB_01, PUZZLE_BOARD, MAZE, ZOO }
@export var target_scene: SceneID
@export var return_spawn_point: NodePath

@export_subgroup("Button type: Puzzle")
@export var office_hub: NodePath
@export var room_path: NodePath

@export var start_index: int = 0

@export_group("Button type: Door")
@export var target_door: NodePath

@export_group("Button type: NPC")
@export var NPC: NodePath

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func interact():
	if not is_enabled:
		return
	
	match button_type:
		ButtonType.PUZZLE:
			handle_puzzle_action()
		ButtonType.SCENE:
			handle_scene_action()
		ButtonType.DOOR:
			handle_door_action()
		ButtonType.NPC:
			handle_npc_action()
		_:
			push_warning("[Interactables} Unhandled button_type on: " + name)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func handle_puzzle_action() -> void:
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
	
	var room := get_node_or_null(room_path)
	if room == null:
		push_warning("[Interactable] Invalid room_path on " + name)
		return
	
	if not room.has_puzzles:
		push_warning("[Interactable] Room has no puzzles: " + room.name)
		return
	
	GameManager.current_level_set = room.get_level_slice(start_index)
	print("[Interactable] Sending level slice from index ", start_index, " for room ", room.name)
	
	print("[Interactable] return_spawn_point:", return_spawn_point)
	print("[Interactable] Sent to GameManager.return_spawn_point:", GameManager.return_spawn_point)
	GameManager.current_room_name = room.name
	
	GameManager.set_return_scene_with_id("hub_01")
	scene_change(get_scene_name())



func handle_scene_action() -> void:
	scene_change(get_scene_name())


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

func handle_npc_action() -> void:
	if NPC.is_empty():
		push_warning("[Interactable] No NPC path set on " + name)
		return
	
	var npc = get_node_or_null(NPC)
	if npc == null:
		push_warning("[Interactable] NPC not found: " + str(NPC))
		return
	
	if not npc.has_method("start_return"):
		push_warning("[Interactable] Target NPC has no start_return() method: " + npc.name)
		return
	
	npc.start_return()

func get_scene_name() -> String:
	match target_scene:
		SceneID.LANDING_MENU: return "landing_manu"
		SceneID.HUB_01: return "hub_01"
		SceneID.PUZZLE_BOARD: return "puzzle_board"
		SceneID.MAZE: return "maze"
		SceneID.ZOO: return "zoo"
	return ""

func scene_change(scene_id: String) -> void:
	var marker = get_node_or_null(return_spawn_point)
	if marker:
		GameManager.return_spawn_point = marker.get_path()
	else:
		push_warning("[Interactable] return_spawn_point invalid: " + str(return_spawn_point))
	GameManager.set_return_scene_with_id("hub_01")
	GameManager.change_scene(scene_id)

func _update_label(text: String, colour: Color) -> void:
	if status_label == null:
		return
	
	status_label.text = text
	status_label.modulate = colour
	status_label.visible = true
