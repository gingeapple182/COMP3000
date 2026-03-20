extends Control

@onready var objective_label: Label = $VBox/HBox/Label

func _ready() -> void:
	update_objective()

func update_objective() -> void:
	if GameManager.current_obj.is_empty():
		objective_label.text = "No current objective."
	else:
		objective_label.text = "Objective: " + GameManager.current_obj
