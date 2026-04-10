extends Control

@onready var title_label: Label = $HBox/VBox/HBox/VBox/Title
@onready var sender_label: Label = $HBox/VBox/HBox/VBox/Panel/VBoxContainer/Sender
@onready var subject_label: Label = $HBox/VBox/HBox/VBox/Panel/VBoxContainer/Subject
@onready var body_text: RichTextLabel = $HBox/VBox/HBox/VBox/Panel/VBoxContainer/Body
@onready var close_button: Button = $HBox/VBox/HBox/VBox/Panel/VBoxContainer/Button
@onready var hide_timer: Timer = $HideTimer
#var duration

func _ready() -> void:
	visible = false
	hide_timer.timeout.connect(_on_hide_timer_timeout)
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)

func show_message(title: String, sender: String, subject: String, body: String, duration: float = 4.0) -> void:
	title_label.text = title
	sender_label.text = "From: " + sender
	subject_label.text = "Subject: " + subject
	body_text.text = body
	
	visible = true
	hide_timer.start(duration)

func hide_message() -> void:
	visible = false
	hide_timer.stop()

func _on_close_button_pressed() -> void:
	hide_message()

func _on_hide_timer_timeout() -> void:
	hide_message()
