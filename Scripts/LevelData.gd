extends Resource
class_name LevelData

@export var level_id: String = ""
@export_multiline var tile_map: String = ""
@export var display_title: String = ""
@export_multiline var level_description: String = ""
@export_multiline var level_complete_description: String = ""

enum OutputGoals {
	TRUE,
	FALSE
	# Extendable further
}
@export var expected_output: OutputGoals = OutputGoals.TRUE

# --- Block availability ---
@export var true_value_count: int = 0
@export var false_value_count: int = 0
@export var and_gate_count: int = 0
@export var not_gate_count: int = 0
@export var or_gate_count: int = 0
@export var L_U_connector_count: int = 0
@export var L_R_connector_count: int = 0
@export var L_D_connector_count: int = 0
@export var D_U_connector_count: int = 0
@export var D_R_connector_count: int = 0
@export var U_R_connector_count: int = 0
@export var U_D_connector_count: int = 0
