extends Control

@onready var title_label: Label = $HBox/VBox/Panel/HBox/VBox/Title
@onready var sender_label: Label = $HBox/VBox/Panel/HBox/VBox/Sender
@onready var subject_label: Label = $HBox/VBox/Panel/HBox/VBox/Subject
@onready var body_text: RichTextLabel = $HBox/VBox/Panel/HBox/VBox/Body
@onready var close_button: Button = $HBox/VBox/Panel/HBox/VBox/Button

func _ready() -> void:
	visible = false
	
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)

func show_message(title: String, sender: String, subject: String, body: String) -> void:
	title_label.text = title
	sender_label.text = "From: " + sender
	subject_label.text = "Subject: " + subject
	body_text.text = body
	
	visible = true

func hide_message() -> void:
	visible = false

func _on_close_button_pressed() -> void:
	hide_message()
