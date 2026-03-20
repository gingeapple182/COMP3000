extends Node3D

@onready var pause_menu = $PauseMenu
@onready var office_hub_01: Node3D = $OfficeHub01

#Room data
@onready var tutorial: DoorPlaceholder = $OfficeHub01/Tutorial
@onready var area_01: DoorPlaceholder = $OfficeHub01/Area01
@onready var area_02: DoorPlaceholder = $OfficeHub01/Area02
@onready var area_03: DoorPlaceholder = $OfficeHub01/Area03
@onready var area_04: DoorPlaceholder = $OfficeHub01/Area04

@onready var notifications: Control = $CanvasLayer/Notifications
@onready var objectives: Control = $CanvasLayer/Objectives

var ceiling: Node3D

var is_paused := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ceiling =  office_hub_01.find_child("Ceiling", true)
	if ceiling:
		ceiling.visible = true
	
	tutorial.is_open = GameManager.tutorial_open
	area_01.is_open = GameManager.area1_open
	area_02.is_open = GameManager.area2_open
	area_03.is_open = GameManager.area3_open
	area_04.is_open = GameManager.area4_open
	
	if objectives.has_method("update_objective"):
		objectives.update_objective()
	
	if GameManager.pending_notification:
		notifications.show_message(
			GameManager.notification_title,
			GameManager.notification_sender,
			GameManager.notification_subject,
			GameManager.notification_body
		)
		GameManager.clear_notification()

func _input(event):
	if event.is_action_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		toggle_pause()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func toggle_pause():
	is_paused = not is_paused
	get_tree().paused = is_paused
	pause_menu.visible = is_paused


func _on_tree_exited() -> void:
	GameManager.tutorial_open = tutorial.is_open
	GameManager.area1_open = area_01.is_open
	GameManager.area2_open = area_02.is_open
	GameManager.area3_open = area_03.is_open
	GameManager.area4_open = area_04.is_open
