#extends CSGSphere3D
extends CSGCombiner3D

enum ButtonType { PUZZLE, SCENE, DOOR, NPC, BRIEFING, OTHER }

var is_enabled := true
@onready var status_label: Label3D = get_node_or_null("Label3D")

@export_group("")
@export var button_type: ButtonType
@export var disable_if_tutorial_complete: bool = true


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

@export_group("Button type: Briefing")
@export var dialogue_screen_path: NodePath
@export var briefing_title: String = "Reception Briefing"
@export var briefing_sender: String = "Receptionist"
@export var briefing_subject: String = "First Task"
@export_multiline var briefing_body: String = "Head to the Tutorial Room and resolve the issues there while the manager is on the way."

@export var update_objective_on_interact: bool = true
@export var new_objective_text: String = "Head to the Tutorial Room and resolve the issues there."
@export var new_objective_room: String = "Tutorial"

@export var disable_after_interaction: bool = true

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
		ButtonType.BRIEFING:
			handle_briefing_action()
		_:
			push_warning("[Interactables] Unhandled button_type on: " + name)


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

func handle_briefing_action() -> void:
	if disable_if_tutorial_complete and GameManager.area1_open:
		is_enabled = false
		return
	
	if dialogue_screen_path.is_empty():
		push_warning("[Interactable] No dialogue_screen_path set on " + name)
		return
	
	var dialogue_screen = get_node_or_null(dialogue_screen_path)
	if dialogue_screen == null:
		push_warning("[Interactable] Dialogue screen not found: " + str(dialogue_screen_path))
		return
	
	if not dialogue_screen.has_method("show_briefing"):
		push_warning("[Interactable] Target has no show_briefing() method: " + dialogue_screen.name)
		return
	
	dialogue_screen.show_briefing(
		briefing_title,
		briefing_sender,
		briefing_subject,
		briefing_body
	)
	
	if update_objective_on_interact:
		GameManager.set_objective(new_objective_text, new_objective_room)
	
	if disable_after_interaction:
		is_enabled = false


func get_scene_name() -> String:
	match target_scene:
		SceneID.LANDING_MENU: return "landing_menu"
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
