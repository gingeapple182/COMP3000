extends Node

@onready var load_screen_scene: PackedScene = preload("res://Scenes/Menus/load_screen.tscn")
var load_screen: CanvasLayer = null


func _ready() -> void:
	load_screen = load_screen_scene.instantiate()
	load_screen.visible = false
	add_child(load_screen)


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
	
	if load_screen:
		load_screen.visible = true
	
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_packed(scenes[scene_id])
	await get_tree().process_frame
	
	if load_screen:
		load_screen.visible = false

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
