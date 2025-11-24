extends Control

@onready var button_resume: Button = $PanelContainer/VBoxContainer/Button_Resume
@onready var button_settings: Button = $PanelContainer/VBoxContainer/Button_Settings
@onready var button_reset: Button = $PanelContainer/VBoxContainer/Button_Reset
@onready var button_quit: Button = $PanelContainer/VBoxContainer/Button_Quit

var current_scene: String

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	current_scene = get_tree().current_scene.name
	print("Current scene: ", current_scene)

	if current_scene == "Main":
		button_quit.text = "Quit game"
	elif current_scene.begins_with("Puzzle_") or current_scene.begins_with("Level_"):
		button_quit.text = "Return to Hub"
	update_pause_buttons()

func _on_button_resume_pressed() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	visible = false


func _on_button_settings_pressed() -> void:
	pass # Replace with function body.


func _on_button_reset_pressed() -> void:
	pass # Replace with function body.


func _on_button_quit_pressed() -> void:
	var scene = get_tree().current_scene.name
	if scene == "Main":
		get_tree().quit()
	elif scene.begins_with("Puzzle_") or scene.begins_with("Level_"):
		get_tree().change_scene_to_file("res://Scenes/main.tscn")


func update_pause_buttons():
	if current_scene == "Main":
		button_reset.visible = false
	elif current_scene.begins_with("Puzzle_") or current_scene.begins_with("Level_"):
		button_reset.visible = true
	else:
		button_reset.visible = false
