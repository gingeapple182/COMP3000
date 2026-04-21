extends Node3D

@export var bad_path: NodePath
@export var good_path: NodePath

@onready var bad: Node3D = get_node_or_null(bad_path)
@onready var good: Node3D = get_node_or_null(good_path)

@export var linked_interactable_path: NodePath

var linked_interactable: Node3D = null

func _ready() -> void:
	if not linked_interactable_path.is_empty():
		linked_interactable = get_node_or_null(linked_interactable_path)
	
	refresh_state()

func refresh_state() -> void:
	if linked_interactable == null:
		show_bad()
		return
	
	if linked_interactable.visible:
		show_bad()
	else:
		show_good()

func show_bad() -> void:
	if bad:
		bad.visible = true
	if good:
		good.visible = false

func show_good() -> void:
	if bad:
		bad.visible = false
	if good:
		good.visible = true
