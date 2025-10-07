extends CharacterBody3D
class_name FlyController

# Flight parameters
@export var max_speed: float = 5.0
@export var acceleration: float = 3.0
@export var drag: float = 0.98
@export var angular_drag: float = 0.95
@export var roll_speed: float = 3.0
@export var pitch_speed: float = 2.0
@export var yaw_speed: float = 2.0

# Gravity system
@export var gravity: float = 2.0
@export var gravity_strength: float = 0.3

# Landing parameters
@export var landing_distance: float = 0.3
@export var surface_align_speed: float = 2.0
@export var ground_speed: float = 3.0

# Stamina system
@export var max_stamina: float = 100.0
@export var stamina_regen: float = 20.0
@export var boost_cost: float = 30.0
@export var boost_multiplier: float = 2.0
@export var flying_stamina_cost: float = 5.0  # Stamina cost per second while flying

# Head bob parameters
@export var head_bob_frequency: float = 8.0
@export var head_bob_amplitude: float = 0.05

# Node references
@onready var camera: Camera3D = $Camera3D
@onready var surface_ray: RayCast3D = $SurfaceRay
@onready var up_ref: Marker3D = $UpRef
@onready var buzz_player: AudioStreamPlayer3D = $Buzz

# Fly vision effect
var fly_vision: Node

# Fly legs
var fly_legs: Node3D

# Stamina UI
var stamina_ui: Control

# State variables
var is_landed: bool = false
var surface_normal: Vector3 = Vector3.UP
var current_stamina: float
var head_bob_time: float = 0.0
var original_camera_position: Vector3
var rotation_velocity: Vector3 = Vector3.ZERO

# Input vectors
var input_vector: Vector3
var mouse_input: Vector2
var roll_input: float

func _ready():
	current_stamina = max_stamina
	original_camera_position = camera.position
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Initialize fly vision effect
	var fly_vision_script = load("res://scripts/FlyVision.gd")
	fly_vision = Node.new()
	fly_vision.set_script(fly_vision_script)
	add_child(fly_vision)
	print("Fly vision node created and added")
	
	# Initialize fly legs
	var fly_legs_script = load("res://scripts/FlyLegs.gd")
	fly_legs = Node3D.new()
	fly_legs.set_script(fly_legs_script)
	camera.add_child(fly_legs)
	print("Fly legs created and added")
	
	# Initialize stamina UI
	var stamina_ui_script = load("res://scripts/StaminaUI.gd")
	stamina_ui = Control.new()
	stamina_ui.set_script(stamina_ui_script)
	get_tree().current_scene.add_child(stamina_ui)
	print("Stamina UI created and added")

func _input(event):
	if event is InputEventMouseMotion:
		mouse_input = event.relative * 0.002
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Fly vision toggle
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		if fly_vision:
			print("Toggle fly vision")
			fly_vision.toggle_fly_vision()

func _physics_process(delta):
	handle_input()
	update_stamina(delta)
	
	if is_landed:
		handle_landed_movement(delta)
	else:
		handle_flight_movement(delta)
	
	update_head_bob(delta)
	move_and_slide()

func handle_input():
	# Movement input using default Godot actions
	input_vector = Vector3.ZERO
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_S):
		input_vector.z -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_W):
		input_vector.z += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	# Space key disabled to prevent camera issues
	# if Input.is_key_pressed(KEY_SPACE):
	#	input_vector.y += 1
	if Input.is_key_pressed(KEY_SHIFT):
		input_vector.y -= 1
	
	# Roll input - disabled to prevent camera issues
	roll_input = 0.0
	# if Input.is_key_pressed(KEY_Q):
	#	roll_input -= 1
	# if Input.is_key_pressed(KEY_E):
	#	roll_input += 1
	
	# Landing toggle - only L key to prevent Space conflicts
	if Input.is_key_pressed(KEY_L):
		toggle_landing()

func handle_flight_movement(delta):
	# Apply gentle gravity if not landed and not actively flying
	if not is_landed and not input_vector.y > 0:
		velocity.y -= gravity * gravity_strength * delta
	
	# Apply drag
	velocity *= drag
	
	# Calculate movement direction relative to camera
	var forward = -global_transform.basis.z
	var right = global_transform.basis.x
	var up = global_transform.basis.y
	
	# Apply input forces
	var move_direction = forward * input_vector.z + right * input_vector.x + up * input_vector.y
	move_direction = move_direction.normalized()
	
	# Flying stamina cost
	if not is_landed:
		current_stamina -= flying_stamina_cost * delta
		current_stamina = max(0, current_stamina)
	
	# Boost with stamina
	var boost = 1.0
	if Input.is_key_pressed(KEY_CTRL) and current_stamina > 0:
		boost = boost_multiplier
		current_stamina -= boost_cost * delta
	
	# Apply acceleration
	velocity += move_direction * acceleration * boost * delta
	
	# Limit speed
	if velocity.length() > max_speed * boost:
		velocity = velocity.normalized() * max_speed * boost
	
	# Handle rotation
	handle_flight_rotation(delta)

func handle_flight_rotation(delta):
	# Calculate rotation inputs
	var pitch_input = -mouse_input.y * pitch_speed
	var yaw_input = -mouse_input.x * yaw_speed
	var roll_input_value = roll_input * roll_speed
	
	# Apply rotation velocity
	rotation_velocity.x += pitch_input
	rotation_velocity.y += yaw_input
	rotation_velocity.z += roll_input_value * delta
	
	# Apply angular drag
	rotation_velocity *= angular_drag
	
	# Apply rotation
	rotate_around_axis(Vector3.RIGHT, rotation_velocity.x * delta)
	rotate_around_axis(Vector3.UP, rotation_velocity.y * delta)
	rotate_around_axis(Vector3.FORWARD, rotation_velocity.z * delta)
	
	# Clear mouse input
	mouse_input = Vector2.ZERO

func handle_landed_movement(delta):
	# Check if we should take off
	if surface_ray.is_colliding():
		var distance_to_surface = surface_ray.get_collision_point().distance_to(global_position)
		if distance_to_surface > landing_distance * 1.5:
			take_off()
			return
	
	# Align to surface normal
	align_to_surface(delta)
	
	# Handle ground movement
	var forward = global_transform.basis.z
	var right = global_transform.basis.x
	
	# Project movement onto surface plane
	var move_direction = forward * input_vector.z + right * input_vector.x
	move_direction = move_direction.normalized()
	
	# Apply ground movement
	velocity = move_direction * ground_speed
	
	# Handle rotation around surface normal
	handle_landed_rotation(delta)

func handle_landed_rotation(delta):
	# Use the same rotation system as flight mode for consistency
	if mouse_input.length() > 0:
		# Calculate rotation inputs (same as flight mode)
		var pitch_input = -mouse_input.y * pitch_speed
		var yaw_input = -mouse_input.x * yaw_speed
		
		# Apply rotation velocity (same as flight mode)
		rotation_velocity.x += pitch_input
		rotation_velocity.y += yaw_input
		
		# Apply angular drag
		rotation_velocity *= angular_drag
		
		# Apply rotation (same as flight mode)
		rotate_around_axis(Vector3.RIGHT, rotation_velocity.x * delta)
		rotate_around_axis(Vector3.UP, rotation_velocity.y * delta)
		
		# Clear mouse input
		mouse_input = Vector2.ZERO

func align_to_surface(delta):
	if surface_ray.is_colliding():
		surface_normal = surface_ray.get_collision_normal()
		
		# Only align if not actively rotating camera and alignment is very gentle
		if mouse_input.length() < 0.1:
			# Calculate target up direction
			var target_up = surface_normal
			var current_up = global_transform.basis.y
			
			# Very gentle alignment to avoid camera conflicts
			var alignment_strength = surface_align_speed * delta * 0.1  # Much more gentle
			var new_up = current_up.lerp(target_up, alignment_strength)
			
			# Reconstruct basis with new up direction
			var forward = global_transform.basis.z
			var right = new_up.cross(forward).normalized()
			forward = right.cross(new_up).normalized()
			
			global_transform.basis = Basis(right, new_up, forward)

func toggle_landing():
	if is_landed:
		take_off()
	else:
		land()

func land():
	if surface_ray.is_colliding():
		is_landed = true
		velocity = Vector3.ZERO
		rotation_velocity = Vector3.ZERO
		# Store surface normal for alignment
		surface_normal = surface_ray.get_collision_normal()

func take_off():
	is_landed = false
	# Apply small upward velocity when taking off
	velocity += global_transform.basis.y * 3.0

func update_stamina(delta):
	# Regenerate stamina when landed
	if is_landed:
		current_stamina = min(max_stamina, current_stamina + stamina_regen * delta)
	
	# Clamp stamina
	current_stamina = clamp(current_stamina, 0, max_stamina)
	
	# Update stamina UI
	if stamina_ui:
		stamina_ui.update_stamina(current_stamina, max_stamina)

func update_head_bob(delta):
	if not is_landed and velocity.length() > 1.0:
		head_bob_time += delta * head_bob_frequency
		var bob_offset = sin(head_bob_time) * head_bob_amplitude
		camera.position.y = original_camera_position.y + bob_offset
	else:
		# Smoothly return to original position
		camera.position.y = lerp(camera.position.y, original_camera_position.y, 5.0 * delta)

func rotate_around_axis(axis: Vector3, angle: float):
	# Rotate around local axis
	var rotation_axis = global_transform.basis * axis
	rotate(rotation_axis, angle)

func _unhandled_input(event):
	# Disabled ui_accept to prevent Space key conflicts
	# if event.is_action_pressed("ui_accept"):
	#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
