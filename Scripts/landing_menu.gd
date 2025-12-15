extends Node3D
@onready var main_button_start: Button = $CanvasLayer/MainMenu/VBoxContainer/Button_Start
@onready var main_button_select: Button = $CanvasLayer/MainMenu/VBoxContainer/Button_Select
@onready var main_button_settings: Button = $CanvasLayer/MainMenu/VBoxContainer/Button_Settings
@onready var main_button_credits: Button = $CanvasLayer/MainMenu/VBoxContainer/Button_Credits
@onready var main_button_quit: Button = $CanvasLayer/MainMenu/VBoxContainer/Button_Quit
@onready var settings_button_return: Button = $CanvasLayer/Settings/VBoxContainer/Button_Return


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_menus()
	show_landing()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


## -- Main menu -- ##
func _on_button_start_pressed() -> void:
	GameManager.change_scene("hub_01")

func _on_button_select_pressed() -> void:
	show_level_select()

func _on_button_settings_pressed() -> void:
	show_settings()

func _on_button_credits_pressed() -> void:
	show_credits()

func _on_button_quit_pressed() -> void:
	get_tree().quit()


## -- Settings menu -- ##
func _on_button_return_pressed() -> void:
	show_landing()


## -- Show/hide helpers -- ##
func show_landing():
	hide_menus()
	$CanvasLayer/MainMenu.visible = true

func show_level_select():
	hide_menus()
	$CanvasLayer/LevelSelect.visible = true

func show_settings():
	hide_menus()
	$CanvasLayer/Settings.visible = true

func show_credits():
	hide_menus()
	$CanvasLayer/Credits.visible = true

func hide_menus():
	for child in $CanvasLayer.get_children():
		child.visible = false
