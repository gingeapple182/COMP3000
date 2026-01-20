extends Control

var puzzle_board: Node = null

enum PopupMode {
	LEVEL_COMPLTE,
	OFFICE_COMPLETE
}
var mode: PopupMode = PopupMode.LEVEL_COMPLTE
@onready var label: Label = $PanelContainer/VBoxContainer/Label
@onready var rich_text_label: RichTextLabel = $PanelContainer/VBoxContainer/RichTextLabel
@onready var button_return: Button = $PanelContainer/VBoxContainer/HBoxContainer/Button_Return
@onready var button_replay: Button = $PanelContainer/VBoxContainer/HBoxContainer/Button_Replay
@onready var button_continue: Button = $PanelContainer/VBoxContainer/HBoxContainer/Button_Continue

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
			rich_text_label.text = ""
			button_continue.visible = true
			button_replay.visible = true
		
		PopupMode.OFFICE_COMPLETE:
			label.text = "Office Systems Restored"
			rich_text_label.text = "All issues in this office have been resolved."
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
