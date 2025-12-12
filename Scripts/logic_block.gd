extends RigidBody3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var label_3d: Label3D = $Label3D

enum BlockType { VALUE, GATE, CONNECTOR }
@export var block_type: BlockType

@export var value: bool

enum GateType { AND, NOT, OR }
@export var gate_type: GateType

enum ConnectorType { L_R, L_U, L_D, L_U_D, L_U_R, L_D_R, D_R, U_R }
@export var connector_type: ConnectorType


# Called when the node enters the scene tree for the first time.
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
			label_3d.text = connector_type_name(connector_type)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
	match text:
		ConnectorType.L_R: return "→"
		ConnectorType.L_U: return "↗"
		ConnectorType.L_D: return "↘"
		ConnectorType.L_U_D: return "↕"
		ConnectorType.L_U_R: return "┐"
		ConnectorType.L_D_R: return "┘"
		ConnectorType.U_R: return "└"
		ConnectorType.D_R: return "┌"
		_:
			return "name not found go home youre drunk"
