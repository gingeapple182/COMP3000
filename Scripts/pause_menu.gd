extends Control

@onready var paused: HBoxContainer = $PanelContainer/Paused
@onready var settings: HBoxContainer = $PanelContainer/Settings
@onready var controls: HBoxContainer = $PanelContainer/Controls
@onready var nodes: HBoxContainer = $PanelContainer/Nodes
#@onready var scroll_container: ScrollContainer = $PanelContainer/Controls/ScrollContainer
#@onready var scroll_container: ScrollContainer = $PanelContainer/Controls/HBoxContainer/ScrollContainer
@onready var scroll_container: ScrollContainer = $PanelContainer/Controls/Controls/HBoxContainer/ScrollContainer

#@onready var button_resume: Button = $PanelContainer/Paused/Button_Resume
#@onready var button_settings: Button = $PanelContainer/Paused/Button_Settings
@onready var button_reset: Button = $PanelContainer/Paused/Paused/Paused/Button_Reset
@onready var button_quit: Button = $PanelContainer/Paused/Paused/Paused/Button_Quit

var current_scene: String

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	current_scene = get_tree().current_scene.name
	print("Current scene: ", current_scene)
	paused.visible = true
	settings.visible = false
	controls.visible = false
	nodes.visible = false
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	if current_scene == "Main":
		button_quit.text = "Quit game"
	elif current_scene.begins_with("Puzzle_") or current_scene.begins_with("Level_"):
		button_quit.text = "Return to Hub"
	update_pause_buttons()

func _on_button_resume_pressed() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	visible = false


func _on_button_guide_pressed() -> void:
	paused.visible = false
	nodes.visible = true

func _on_button_settings_pressed() -> void:
	paused.visible = false
	settings.visible = true


func _on_button_controls_pressed() -> void:
	settings.visible = false
	controls.visible = true


func _on_button_back_pressed() -> void:
	if settings.visible == true:
		paused.visible = true
		settings.visible = false
	if controls.visible == true:
		settings.visible = true
		controls.visible = false
	if nodes.visible == true:
		paused.visible = true
		nodes.visible = false


func _on_button_reset_pressed() -> void:
	pass # Replace with function body.


func _on_button_quit_pressed() -> void:
	get_tree().paused = false
	var scene = get_tree().current_scene.name
	if scene == "Main":
		GameManager.change_scene("landing_menu")
	elif scene.begins_with("Puzzle") or scene.begins_with("Level_") or scene.begins_with("tutorial_"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		GameManager.change_scene("hub_01")
	else:
		get_tree().quit() # fallback for testing


func update_pause_buttons():
	if current_scene == "Main":
		button_reset.visible = false
	elif current_scene.begins_with("Puzzle_") or current_scene.begins_with("Level_"):
		button_reset.visible = true
	else:
		button_reset.visible = false
