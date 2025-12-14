extends Node3D

@onready var label: RichTextLabel = $Paper/Surface/SubViewport/Control/RichTextLabel

func show_note(text: String, font: Font, size: int) -> void:
	visible = true

	label.bbcode_enabled = true
	label.text = text

	if font:
		label.add_theme_font_override("normal_font", font)
		label.add_theme_font_size_override("normal_font_size", size)

func hide_note() -> void:
	visible = false
