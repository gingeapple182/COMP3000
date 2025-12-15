extends Node

var return_scene: PackedScene

func set_return_scene(scene: PackedScene) -> void:
	return_scene = scene
	print("[GameManager] return_scene set to: ", return_scene)

func return_to_scene() -> void:
	if return_scene == null:
		push_error("[GameManager] return_scene is NULL")
		return
	
	print("[GameManager] Returning to scene: ", return_scene)
	get_tree().change_scene_to_packed(return_scene)
