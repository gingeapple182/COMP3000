extends Node

## Scene dictionary
var scenes:= {
	"landing_menu": preload("res://Scenes/landing_menu.tscn"),
	"hub_01": preload("res://Scenes/main.tscn"),
	"puzzle_board": preload("res://Scenes/puzzle_board.tscn"),
}

var return_scene: PackedScene


## functions

func change_scene(scene_id: String) -> void:
	if not scenes.has(scene_id):
		push_error("[GameManager] Unknown scene_id: " + scene_id)
		return
	
	print("[GameManager] Changing to scene: " + scene_id)
	get_tree().change_scene_to_packed(scenes[scene_id])

func set_return_scene_with_id(scene_id: String) -> void:
	if not scenes.has(scene_id):
		push_error("[GameManager] Unknown return scene_id: " + scene_id)
		return
	
	return_scene = scenes[scene_id]
	print("[GameManager] return_scene set by id: " + scene_id)
	return

func set_return_scene(scene: PackedScene) -> void:
	return_scene = scene
	print("[GameManager] return_scene set to: ", return_scene)

func return_to_scene() -> void:
	if return_scene == null:
		push_error("[GameManager] return_scene is NULL")
		return
	
	print("[GameManager] Returning to scene: ", return_scene)
	get_tree().change_scene_to_packed(return_scene)
