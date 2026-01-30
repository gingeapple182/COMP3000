extends Control

var puzzle_board: Node = null

enum PopupMode {
	LEVEL_COMPLTE,
	OFFICE_COMPLETE
}
var mode: PopupMode = PopupMode.LEVEL_COMPLTE
@onready var label: Label = $ClipboardPanel/PaperPanel/VBoxContainer/Label
@onready var rich_text_label: RichTextLabel = $ClipboardPanel/PaperPanel/VBoxContainer/Description
@onready var button_return: Button = $ClipboardPanel/PaperPanel/VBoxContainer/HBoxContainer/Button_Return
@onready var button_replay: Button = $ClipboardPanel/PaperPanel/VBoxContainer/HBoxContainer/Button_Replay
@onready var button_continue: Button = $ClipboardPanel/PaperPanel/VBoxContainer/HBoxContainer/Button_Continue

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	puzzle_board = get_parent()

func show_popup(new_mode: PopupMode) -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	configure_for_mode(new_mode)
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func configure_for_mode(new_mode: PopupMode) -> void:
	mode = new_mode
	
	match mode:
		PopupMode.LEVEL_COMPLTE:
			label.text = "Issue Resolved"
			rich_text_label.text = "Congratulations on completing the level" # + current_level.display_title
			button_continue.visible = true
			button_replay.visible = true
		
		PopupMode.OFFICE_COMPLETE:
			label.text = "Office Systems Restored"
			rich_text_label.text = "All issues in this office have been resolved.
			You may now return to the office"
			button_continue.visible = false
			button_replay.visible = false


func _on_button_return_pressed() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GameManager.change_scene("hub_01")


func _on_button_replay_pressed() -> void:
	get_tree().paused = false
	visible = false
	if puzzle_board:
		puzzle_board.reload_current_level()


func _on_button_continue_pressed() -> void:
	get_tree().paused = false
	visible = false
	if puzzle_board:
		puzzle_board.advance_level()
