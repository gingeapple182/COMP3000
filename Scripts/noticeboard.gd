extends Node3D

@export_multiline var notes: Array[String] = []
@export var note_font: Font
@export var font_size: int

@onready var note_nodes := $Notes.get_children()

func _ready() -> void:
	apply_notes()

func apply_notes() -> void:
	for i in range(note_nodes.size()):
		if i < notes.size():
			note_nodes[i].show_note(notes[i], note_font, font_size)
		else:
			note_nodes[i].hide_note()

	if notes.size() > note_nodes.size():
		push_warning("NoticeBoard has more notes than available slots.")
