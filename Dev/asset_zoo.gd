extends Node3D

@export var asset_folder := "res://Assets/ZooModels/"
@export var spacing := 5.0
@export var columns := 5

func _ready():
	var dir = DirAccess.open(asset_folder)
	if dir == null:
		push_error("Folder not found: " + asset_folder)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	var index = 0

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".glb"):
			var scene = load(asset_folder + file_name)
			if scene:
				var instance = scene.instantiate()
				add_child(instance)

				var x = (index % columns) * spacing
				var z = (index / columns) * spacing
				instance.position = Vector3(x, 0, z)

				# Label
				var label = Label3D.new()
				label.text = file_name.get_basename()
				label.position = Vector3(0, 2, 0)
				instance.add_child(label)

				index += 1

		file_name = dir.get_next()

	dir.list_dir_end()
