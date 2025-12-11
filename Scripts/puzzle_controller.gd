extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var grid_manager: Node3D = $GridManager

var grabbed: RigidBody3D = null
var grab_offset: Vector3 = Vector3.ZERO
@export var hover_height := 1.5
@export var lerp_speed := 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var hit = get_mouse_hit()
		if hit:
			print("Hit collider:", hit.collider)
		else:
			print("No hit")

	# Pick up
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var hit = get_mouse_hit()
		if hit and hit.collider is RigidBody3D:
			grabbed = hit.collider
			grab_offset = Vector3.ZERO
			grabbed.gravity_scale = 0.0
			grabbed.linear_velocity = Vector3.ZERO
			
			grid_manager.held_piece = grabbed

	# Drop
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if grabbed:
			grabbed.gravity_scale = 1.0
			grabbed.linear_velocity = Vector3.ZERO
			grabbed.angular_velocity = Vector3.ZERO
		grabbed = null
		grid_manager.held_piece = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta):
	if grabbed:
		var hit = get_mouse_hit()
		if hit:
			# Get the ground point under the mouse
			var ground_pos = hit.position
			var target_pos = ground_pos + Vector3.UP * hover_height
			var current = grabbed.global_transform.origin
			var new_pos = current.lerp(target_pos, lerp_speed * delta)

			grabbed.global_transform.origin = new_pos
			# Prevent weird physics behaviour while holding
			grabbed.linear_velocity = Vector3.ZERO
			grabbed.angular_velocity = Vector3.ZERO

func get_mouse_hit():
	var mouse_pos = get_viewport().get_mouse_position()
	var origin = camera.project_ray_origin(mouse_pos)
	var direction = camera.project_ray_normal(mouse_pos)
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = origin + direction * 500
	query.collide_with_bodies = true
	query.collide_with_areas = false
	query.collision_mask = 0xFFFFFFFF   # all layers
	if grabbed:
		query.exclude = [grabbed]
	else:
		query.exclude = []
	var result = space.intersect_ray(query)
	return result


func _on_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
