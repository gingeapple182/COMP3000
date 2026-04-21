extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $characterMedium/AnimationPlayer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var sprite_3d: Sprite3D = $Sprite3D

enum NPCType {
	STATIC,
	ROAMING,
	FOLLOW,
	RETURN
}
@export var npc_type: NPCType
@export var follow_target: Node3D
@export var follow_stop_dist:= 2.0
@export var return_target: Node3D
@export var x_lower: float
@export var x_higher: float
@export var z_lower: float
@export var z_higher: float
@export var idle_wait_min := 1.5
@export var idle_wait_max := 4.0

@export_group("Marker")
@export var use_marker: bool = true
@export var marker_show_distance: float = 5.0
@export var marker_type: MarkerType = MarkerType.NONE
@export_subgroup("Target Marker")
@export var target_marker_icon: Texture2D
@export_subgroup("State Marker")
@export var initial_marker_icon: Texture2D
@export var secondary_marker_icon: Texture2D
@export var linked_interactable_path: NodePath

enum State {
	IDLE,
	MOVE
}
enum MarkerType {
	NONE,
	TARGET,
	STATE
}
var can_roam: bool
var current_state: State = State.IDLE
var idle_timer := 0.0
var current_idle_wait := 0.0
var walk_timer := 0.0
var broken_path_timer := 0.0
var broken_path_limit := 15.0
var linked_interactable: Node = null
var target_marker_active := true
var player: Node3D = null

signal follow_target_reached
var follow_reached_emitted := false

func _ready() -> void:
	follow_reached_emitted = false
	match npc_type:
		NPCType.STATIC:
			can_roam = false
		NPCType.ROAMING:
			can_roam = true
		NPCType.FOLLOW:
			can_roam = false
		_:
			return
	
	if !can_roam:
		current_state = State.IDLE
	navigation_agent_3d.target_desired_distance = 0.1
	current_idle_wait = randf_range(idle_wait_min, idle_wait_max)
	
	player = get_tree().get_first_node_in_group("player")
	if not linked_interactable_path.is_empty():
		linked_interactable = get_node_or_null(linked_interactable_path)
	
	setup_marker()

func _physics_process(delta: float) -> void:
	update_marker_visibility()
	
	if navigation_agent_3d.is_navigation_finished():
		current_state = State.IDLE
	else:
		current_state = State.MOVE
	
	if npc_type == NPCType.FOLLOW:
		if follow_target == null:
			npc_type = NPCType.STATIC
			return
		
		var target_pos = follow_target.global_position
		var stop_dist = global_position.distance_to(target_pos)
		if stop_dist <= follow_stop_dist:
			velocity = Vector3.ZERO
			animation_player.play("idle/Root|Idle")
			
			if not follow_reached_emitted:
				follow_reached_emitted = true
				follow_target_reached.emit()
			return
		
		navigation_agent_3d.set_target_position(target_pos)
		
		var destination = navigation_agent_3d.get_next_path_position()
		var local_destination = destination - global_position
		var direction = local_destination.normalized()
		
		velocity = direction * 5.0
		
		if velocity.length() > 0.01:
			var target_angle = atan2(velocity.x, velocity.z)
			rotation.y = lerp_angle(rotation.y, target_angle, 8.0 * delta)
		
		if velocity.length() > 0.15:
			if animation_player.current_animation != "run/Root|Run":
				animation_player.play("run/Root|Run")
	
	if npc_type == NPCType.RETURN:
		if return_target == null:
			npc_type = NPCType.STATIC
			return
		
		var target_pos = return_target.global_position
		var stop_dist = global_position.distance_to(target_pos)
		if stop_dist <= follow_stop_dist:
			velocity = Vector3.ZERO
			animation_player.play("idle/Root|Idle")
			npc_type = NPCType.STATIC
			return
		
		navigation_agent_3d.set_target_position(target_pos)
		
		var destination = navigation_agent_3d.get_next_path_position()
		var local_destination = destination - global_position
		var direction = local_destination.normalized()
		
		velocity = direction * 5.0
		
		if velocity.length() > 0.01:
			var target_angle = atan2(velocity.x, velocity.z)
			rotation.y = lerp_angle(rotation.y, target_angle, 8.0 * delta)
		
		if velocity.length() > 0.15:
			if animation_player.current_animation != "run/Root|Run":
				animation_player.play("run/Root|Run")
	
	
	match current_state:
		State.IDLE:
			velocity = Vector3.ZERO
			
			if animation_player.current_animation != "idle/Root|Idle":
				animation_player.play("idle/Root|Idle")
			
			if !can_roam:
				return
			
			idle_timer += delta
			
			if idle_timer >= current_idle_wait:
				idle_timer = 0.0
				current_idle_wait = randf_range(idle_wait_min, idle_wait_max)
				
				var random_position := Vector3.ZERO
				random_position.x = randf_range(x_lower, x_higher)
				random_position.z = randf_range(z_lower, z_higher)
				
				navigation_agent_3d.set_target_position(random_position)
		State.MOVE:
			var destination = navigation_agent_3d.get_next_path_position()
			var local_destination = destination - global_position
			var direction = local_destination.normalized()
			
			velocity = direction * 5.0
			
			if velocity.length() > 0.01:
				var target_angle = atan2(velocity.x, velocity.z)
				rotation.y = lerp_angle(rotation.y, target_angle, 8.0 * delta)
			
			if velocity.length() > 0.15:
				if animation_player.current_animation != "run/Root|Run":
					animation_player.play("run/Root|Run")
			
			 # --- BROKEN PATH FAILSAFE ---
			broken_path_timer += delta
			if broken_path_timer >= broken_path_limit:
				broken_path_timer = 0.0
				# Pick a new random roam point
				var new_pos := Vector3.ZERO
				new_pos.x = randf_range(x_lower, x_higher)
				new_pos.z = randf_range(z_lower, z_higher)
				navigation_agent_3d.set_target_position(new_pos)
				print("NPC stuck too long — resetting path")
			#State.
	
	move_and_slide()

func start_follow() -> void:
	follow_reached_emitted = false
	npc_type = NPCType.FOLLOW

func start_return() -> void:
	npc_type = NPCType.RETURN

func start_static() -> void:
	npc_type = NPCType.STATIC

func setup_marker() -> void:
	if sprite_3d == null:
		return
	
	sprite_3d.visible = false
	
	if not use_marker:
		sprite_3d.texture = null
		return
	
	match marker_type:
		MarkerType.NONE:
			sprite_3d.texture = null
		
		MarkerType.TARGET:
			sprite_3d.texture = target_marker_icon
		
		MarkerType.STATE:
			sprite_3d.texture = get_state_marker_texture()


func update_marker_visibility() -> void:
	if sprite_3d == null:
		return
	
	if not use_marker:
		sprite_3d.visible = false
		return
	
	match marker_type:
		MarkerType.NONE:
			sprite_3d.visible = false
			return
		
		MarkerType.TARGET:
			sprite_3d.texture = target_marker_icon
			
			if not target_marker_active:
				sprite_3d.visible = false
				return
			
			sprite_3d.visible = sprite_3d.texture != null
			return
		
		MarkerType.STATE:
			sprite_3d.texture = get_state_marker_texture()
			
			if sprite_3d.texture == null:
				sprite_3d.visible = false
				return
			
			if player == null:
				player = get_tree().get_first_node_in_group("player")
				if player == null:
					sprite_3d.visible = false
					return
			
			var distance_to_player = global_position.distance_to(player.global_position)
			sprite_3d.visible = distance_to_player <= marker_show_distance

func get_state_marker_texture() -> Texture2D:
	if linked_interactable == null:
		return initial_marker_icon
	
	if linked_interactable.visible:
		return initial_marker_icon
	
	return secondary_marker_icon

func disable_target_marker() -> void:
	target_marker_active = false
	update_marker_visibility()
