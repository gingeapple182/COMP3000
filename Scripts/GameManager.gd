extends Node

@onready var load_screen_scene: PackedScene = preload("res://Scenes/Menus/load_screen.tscn")
var load_screen: CanvasLayer = null

var fade_rect: ColorRect
var loading_label: Label
var loading_bar: ProgressBar

var current_level_set: Array[LevelData] = []
var completed_levels_by_room := {}
var current_room_name: String

var return_spawn_point: NodePath = NodePath("")

func _ready() -> void:
	load_screen = load_screen_scene.instantiate()
	load_screen.visible = false
	add_child(load_screen)
	
	fade_rect = load_screen.get_node("ColorRect")
	loading_label = load_screen.get_node("Label")
	loading_bar = load_screen.get_node("ProgressBar")


## -- scene chanigng functions -- ##

var scenes:= {
	"landing_menu": preload("res://Scenes/landing_menu.tscn"),
	"hub_01": preload("res://Scenes/main.tscn"),
	"puzzle_board": preload("res://Scenes/puzzle_board.tscn"),
}
var return_scene: PackedScene


func change_scene(scene_id: String) -> void:
	if not scenes.has(scene_id):
		push_error("[GameManager] Unknown scene_id: " + scene_id)
		return
	
	print("[GameManager] Changing to scene: " + scene_id)
	print("[GameManager] current_level_set:", current_level_set)
	print("[GameManager] return_spawn_point:", return_spawn_point)
	#if load_screen:
	#	load_screen.visible = true
	
	#await get_tree().create_timer(1.0).timeout
	
	await fade_in(0.3)
	loading_text_animated(1.2)
	await fake_loading(1.2)
	
	get_tree().change_scene_to_packed(scenes[scene_id])
	
	await get_tree().process_frame
	
	await fade_out(0.3)
	
	#if load_screen:
	#	load_screen.visible = false

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
