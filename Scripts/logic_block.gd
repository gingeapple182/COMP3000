class_name LogicBlock
extends RigidBody3D

## -- Visuals -- ##
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var label_3d: Label3D = $Label3D

## -- Block config -- ##
enum BlockType { VALUE, GATE, CONNECTOR }
@export var block_type: BlockType

## -- Block Data -- ##
# VALUE
@export var value: bool
# GATE
enum GateType { AND, NOT, OR }
@export var gate_type: GateType
# CONNECTOR
enum ConnectorType { L_R, L_U, L_D, D_R, D_U, U_R, U_D }
@export var connector_type: ConnectorType
var input_dirs: Array[int] = []
var output_dirs: Array[int] = []
# Direction values for arrays
const DIR_UP := 0
const DIR_DOWN := 1
const DIR_LEFT := 2
const DIR_RIGHT := 3


## -- Core -- ##

func _ready() -> void:
	match block_type:
		BlockType.VALUE:
			if value:
				label_3d.text = "1"
			else:
				label_3d.text = "0"

		BlockType.GATE:
			label_3d.text = gate_type_name(gate_type)

		BlockType.CONNECTOR:
			setup_connector_dirs()
			label_3d.text = connector_type_name(connector_type)

func _process(delta: float) -> void:
	pass

## ---------- ##

## -- Block visuals -- ##

func gate_type_name(text: GateType) -> String:
	match text:
		GateType.AND:
			return "AND"
		GateType.NOT:
			return "NOT"
		GateType.OR:
			return "OR"
		_:
			return "name not found go home youre drunk"

func connector_type_name(text: ConnectorType) -> String:
	#ConnectorType { L_R, L_U, L_D, D_R, D_U, U_R, U_D }
	match text:
		ConnectorType.L_R: return "L_R"
		ConnectorType.L_U: return "L_U"
		ConnectorType.L_D: return "L_D"
		ConnectorType.U_R: return "U_R"
		ConnectorType.U_D: return "U_D"
		ConnectorType.D_R: return "D_R"
		ConnectorType.D_U: return "D_U"
		_:
			return "name not found go home youre drunk"

## ------------------- ##


## -- Apply connections -- ##

func setup_connector_dirs() -> void:
	#ConnectorType { L_R, L_U, L_D, D_R, D_U, U_R, U_D }
	input_dirs.clear()
	output_dirs.clear()
	
	match connector_type:
		ConnectorType.L_R:
			input_dirs.append(DIR_LEFT)
			output_dirs.append(DIR_RIGHT)
		ConnectorType.L_U:
			input_dirs.append(DIR_LEFT)
			output_dirs.append(DIR_UP)
		ConnectorType.L_D:
			input_dirs.append(DIR_LEFT)
			output_dirs.append(DIR_DOWN)
		ConnectorType.U_R:
			input_dirs.append(DIR_UP)
			output_dirs.append(DIR_RIGHT)
		ConnectorType.U_D:
			input_dirs.append(DIR_UP)
			output_dirs.append(DIR_DOWN)
		ConnectorType.D_U:
			input_dirs.append(DIR_DOWN)
			output_dirs.append(DIR_UP)
		ConnectorType.D_R:
			input_dirs.append(DIR_DOWN)
			output_dirs.append(DIR_RIGHT)

## ----------------------- ##
