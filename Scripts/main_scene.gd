extends Node3D

@onready var pause_menu = $PauseMenu
@onready var office_hub_01: Node3D = $OfficeHub01
@onready var rory: CharacterBody3D = $NPC/Rory
#@onready var manager_briefing: Control = $CanvasLayer/ManagerBriefing
@onready var manager_briefing: Control = $CanvasLayer/Dialogue

#Room data
@onready var tutorial: DoorPlaceholder = $OfficeHub01/Tutorial
@onready var area_01: DoorPlaceholder = $OfficeHub01/Area01
@onready var area_02: DoorPlaceholder = $OfficeHub01/Area02
@onready var area_03: DoorPlaceholder = $OfficeHub01/Area03
@onready var area_04: DoorPlaceholder = $OfficeHub01/Area04

@onready var notifications: Control = $CanvasLayer/Notifications
@onready var objectives: Control = $CanvasLayer/Objectives
@onready var introduction: Control = $CanvasLayer/Introduction
@onready var intro_button: Button = $CanvasLayer/Introduction/HBoxContainer/VBoxContainer/Panel/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Button

@onready var proto_controller: CharacterBody3D = $ProtoController

var ceiling: Node3D

var is_paused := false
var tutotial_seen := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ceiling = office_hub_01.find_child("Ceiling", true)
	if ceiling:
		ceiling.visible = true
	
	tutorial.is_open = GameManager.tutorial_open
	area_01.is_open = GameManager.area1_open
	area_02.is_open = GameManager.area2_open
	area_03.is_open = GameManager.area3_open
	area_04.is_open = GameManager.area4_open
	
	if objectives.has_method("update_objective"):
		objectives.update_objective()
	
	if rory.has_signal("follow_target_reached"):
		rory.follow_target_reached.connect(_on_rory_reached_player)
	
	if manager_briefing.has_signal("briefing_acknowledged"):
		manager_briefing.briefing_acknowledged.connect(_on_manager_briefing_acknowledged)
	
	if GameManager.tutorial_seen == false:
		proto_controller.can_move = false
		introduction.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		proto_controller.can_move = true
		introduction.visible = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if GameManager.pending_notification:
		notifications.show_message(
			GameManager.notification_title,
			GameManager.notification_sender,
			GameManager.notification_subject,
			GameManager.notification_body
		)
		GameManager.clear_notification()
	
	if GameManager.manager_should_follow:
		if rory.has_method("start_follow"):
			rory.start_follow()
		GameManager.manager_should_follow = false
	
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if manager_briefing.visible:
		return
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


func _on_rory_reached_player() -> void:
	if not GameManager.pending_manager_briefing:
		return
	
	if manager_briefing.has_method("show_briefing"):
		manager_briefing.show_briefing(
			GameManager.manager_briefing_title,
			GameManager.manager_briefing_sender,
			GameManager.manager_briefing_subject,
			GameManager.manager_briefing_body
		)

func _on_manager_briefing_acknowledged() -> void:
	GameManager.clear_manager_briefing()
	
	if rory.has_method("start_return"):
		rory.start_return()


func _on_intro_button_pressed() -> void:
	proto_controller.can_move = true
	introduction.visible = false
	GameManager.tutorial_seen = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
