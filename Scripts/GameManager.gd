extends Node

@onready var load_screen_scene: PackedScene = preload("res://Scenes/Menus/load_screen.tscn")
var load_screen: CanvasLayer = null

#@onready var rory: CharacterBody3D = $NPC/Rory
var manager_should_follow := false
var pending_manager_briefing := false
var manager_briefing_title := ""
var manager_briefing_sender := ""
var manager_briefing_subject := ""
var manager_briefing_body := ""

var fade_rect: ColorRect
var loading_label: Label
var loading_bar: ProgressBar

var current_level_set: Array[LevelData] = []
var completed_levels_by_room := {}
var current_room_name: String
var tutorial_name: String = "tutorial"
var area01_name: String = "AND room"
var area02_name: String = "NOT room"
var area03_name: String = "OR room"
var area04_name: String = "AND room"

# return values
var return_spawn_point: NodePath = NodePath("")
var tutorial_open: bool = true
var area1_open: bool
var area2_open: bool
var area3_open: bool
var area4_open: bool
var tutorial_seen: bool = false

#notification vars
var pending_notification := false
var notification_title := ""
var notification_sender := ""
var notification_subject := ""
var notification_body := ""
var next_room_to_highlight := ""

#objective stuff
var current_obj: String = ""
var current_obj_room: String = ""

func _ready() -> void:
	load_screen = load_screen_scene.instantiate()
	load_screen.visible = false
	add_child(load_screen)
	
	fade_rect = load_screen.get_node("ColorRect")
	loading_label = load_screen.get_node("Label")
	loading_bar = load_screen.get_node("ProgressBar")
	
	current_obj = "Head to the Tutorial Room and resolve the issues there."
	current_obj_room = "Tutorial"


## -- scene chanigng functions -- ##

var scenes:= {
	"landing_menu": preload("res://Scenes/landing_menu.tscn"),
	"hub_01": preload("res://Scenes/main.tscn"),
	"puzzle_board": preload("res://Scenes/puzzle_board.tscn"),
	"maze": preload("res://Scenes/maze.tscn"),
	"zoo": preload("res://Dev/asset_zoo.tscn"),
}
var return_scene: PackedScene


func change_scene(scene_id: String) -> void:
	if not scenes.has(scene_id):
		push_error("[GameManager] Unknown scene_id: " + scene_id)
		return
	
	print("[GameManager] Changing to scene: " + scene_id)
	print("[GameManager] current_level_set:", current_level_set)
	print("[GameManager] return_spawn_point:", return_spawn_point)
	
	await fade_in(0.3)
	loading_text_animated(1.2)
	await fake_loading(1.2)
	
	get_tree().change_scene_to_packed(scenes[scene_id])
	
	await get_tree().process_frame
	
	await fade_out(0.3)

func set_return_scene_with_id(scene_id: String) -> void:
	if not scenes.has(scene_id):
		push_error("[GameManager] Unknown return scene_id: " + scene_id)
		return
	
	return_scene = scenes[scene_id]
	print("[GameManager] return_scene set by id: " + scene_id)
	return

func return_to_scene() -> void:
	if return_scene == null:
		push_error("[GameManager] return_scene is NULL")
		return
	
	print("[GameManager] Returning to scene: ", return_scene)
	get_tree().change_scene_to_packed(return_scene)

# transition polish helpers #

func fade_in(duration := 0.3) -> void:
	load_screen.visible = true
	fade_rect.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)
	await tween.finished

func fade_out(duration := 0.3) -> void:
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)
	await tween.finished
	
	load_screen.visible = false

func fake_loading(duration := 1.0) -> void:
	loading_bar.value = 0
	
	var tween = create_tween()
	tween.tween_property(loading_bar, "value", 100, duration)
	await tween.finished

func loading_text_animated(duration := 1.0) -> void:
	var time := 0.0
	while time < duration:
		loading_label.text = "Loading"
		await get_tree().create_timer(0.3).timeout
		loading_label.text = "Loading."
		await get_tree().create_timer(0.3).timeout
		loading_label.text = "Loading.."
		await get_tree().create_timer(0.3).timeout
		loading_label.text = "Loading..."
		await get_tree().create_timer(0.3).timeout
		
		time += 1.2


func mark_level_complete(level_index: int) -> void:
	var room_name := current_room_name
	if not completed_levels_by_room.has(room_name):
		completed_levels_by_room[room_name] = {}

	completed_levels_by_room[room_name][level_index] = true
	print("[GameManager] Marked level", level_index, "complete for room", room_name)


func is_level_complete(room_name: String, level_index: int) -> bool:
	return (
		completed_levels_by_room.has(room_name)
		and completed_levels_by_room[room_name].has(level_index)
	)

func complete_current_room() -> void:
	match current_room_name:
		"Tutorial":
			area1_open = true
			set_objective("Head to the AND Room and resolve the issues there.", "Area01")
			queue_notification(
				"New Message",
				"Manager",
				"Next Assignment",
				"Good work on fixing this room up. The NOT room is in need to fixing too. Head there next.",
				"Area01"
			)
			queue_manager_briefing(
				"Manager Briefing",
				"Rory",
				"Next Assignment",
				"Hello there! I am your new manager, Rory. Good work on fixing this room up., so I've opened the NOT Room for you next. Head over there and deal with the issues waiting for you."
			)
			manager_should_follow = true

		"Area01":
			area2_open = true
			set_objective("Head to the next room and resolve the issues there.", "Area02")
			queue_notification(
				"New Message",
				"Manager",
				"Next Assignment",
				"The next has now been unlocked. Proceed when ready.",
				"Area02"
			)
			queue_manager_briefing(
				"Manager Briefing",
				"Rory",
				"Next Assignment",
				"Good work with that lot. I've opened the next room now, so head there next and sort out the new problems."
			)
			manager_should_follow = true

		"Area02":
			area3_open = true
			set_objective("Head to the next room and resolve the issues there.", "Area03")
			queue_notification(
				"New Message",
				"Manager",
				"Next Assignment",
				"Area 03 is now available. Please investigate the new issues there.",
				"Area03"
			)
			queue_manager_briefing(
				"Manager Briefing",
				"Rory",
				"Next Assignment",
				"You've dealt with those issues nicely. The OR Room is open now, so get over there and take a look at what's gone wrong this time."
			)
			manager_should_follow = true

		"Area03":
			area4_open = true
			set_objective("Head to the next room and resolve the issues there.", "Area04")
			queue_notification(
				"New Message",
				"Manager",
				"Next Assignment",
				"Area 04 is now open. Head there for the next set of tasks.",
				"Area04"
			)
			queue_manager_briefing(
				"Manager Briefing",
				"Rory",
				"Next Assignment",
				"Nice work. I've opened the next room for you, so head over there and see if you can get those systems working as well."
			)
			manager_should_follow = true

		"Area04":
			set_objective("All assigned office issues have been resolved.")
			queue_notification(
				"New Message",
				"Manager",
				"All Areas Complete",
				"Excellent work. All currently assigned office areas have now been resolved. Thank you for playing."
			)
			queue_manager_briefing(
				"Manager Briefing",
				"Rory",
				"All Areas Complete",
				"That's everything sorted. You've done a solid job getting this place back under control."
			)
			manager_should_follow = true
	#NPC.set_state(FOLLOW)

func queue_notification(title: String, sender: String, subject: String, body: String, room_name: String = "") -> void:
	pending_notification = true
	notification_title = title
	notification_sender = sender
	notification_subject = subject
	notification_body = body
	next_room_to_highlight = room_name

func clear_notification() -> void:
	pending_notification = false
	notification_title = ""
	notification_sender = ""
	notification_subject = ""
	notification_body = ""
	next_room_to_highlight = ""


func set_objective(new_objective: String, room_name: String = "") -> void:
	current_obj = new_objective
	current_obj_room = room_name

func clear_objective() -> void:
	current_obj = ""
	current_obj_room = ""

func queue_manager_briefing(title: String, sender: String, subject: String, body: String) -> void:
	pending_manager_briefing = true
	manager_briefing_title = title
	manager_briefing_sender = sender
	manager_briefing_subject = subject
	manager_briefing_body = body

func clear_manager_briefing() -> void:
	pending_manager_briefing = false
	manager_briefing_title = ""
	manager_briefing_sender = ""
	manager_briefing_subject = ""
	manager_briefing_body = ""
