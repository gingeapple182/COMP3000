extends Control

signal briefing_acknowledged

@onready var name_label: Label = $HBoxContainer/VBoxContainer/NameLabel
@onready var body_text: RichTextLabel = $HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/BodyText
@onready var okay_button: Button = $HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/VBoxContainer/Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	okay_button.pressed.connect(_on_okay_button_pressed)

func show_briefing(title: String, sender: String, subject: String, body: String) -> void:
	name_label.text = sender
	body_text.text = body
	
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_briefing() -> void:
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_okay_button_pressed() -> void:
	hide_briefing()
	briefing_acknowledged.emit()
