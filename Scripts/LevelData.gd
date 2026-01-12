extends Resource
class_name LevelData

@export var level_name: String = ""
@export_multiline var tile_map: String = ""
@export var description: String = ""

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
