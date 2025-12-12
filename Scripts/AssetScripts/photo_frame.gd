extends Node3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

@export var portrait: Texture2D

func _ready() -> void:
	apply_portrait()

func apply_portrait() -> void:
	if not portrait:
		return

	var mat: StandardMaterial3D

	# Use material_override (recommended for prototypes)
	if mesh_instance_3d.material_override:
		mat = mesh_instance_3d.material_override
	else:
		mat = StandardMaterial3D.new()
		mesh_instance_3d.material_override = mat

	mat.albedo_texture = portrait
	mat.albedo_color = Color.WHITE
