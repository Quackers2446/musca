extends Node
class_name FlyVision

@export var hex_size: float = 0.15
@export var distortion_strength: float = 0.3
@export var color_shift: float = 0.2
@export var enable_hex_filter: bool = true
@export var transition_speed: float = 2.0

var shader_material: ShaderMaterial
var overlay: ColorRect
var is_setup: bool = false

func _ready():
	# Wait a frame for the scene to be ready
	await get_tree().process_frame
	setup_fly_vision()

func setup_fly_vision():
	if is_setup:
		return
	
	print("Setting up fly vision...")
	
	# Create a ColorRect to cover the entire screen
	overlay = ColorRect.new()
	overlay.name = "FlyVisionOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0)  # Completely transparent
	
	# Create shader material
	var shader = load("res://shaders/hex_grid.gdshader")
	if shader:
		print("Shader loaded successfully")
		shader_material = ShaderMaterial.new()
		shader_material.shader = shader
		
		# Set initial shader parameters
		update_shader_parameters()
		
		# Apply material to ColorRect
		overlay.material = shader_material
		print("Shader applied to overlay")
	else:
		print("Failed to load shader!")
		return
	
	# Add to scene
	get_tree().current_scene.add_child(overlay)
	
	# Make sure it's on top
	overlay.z_index = 1000
	
	# Start with overlay visible (fly vision always on)
	overlay.visible = true
	
	is_setup = true
	print("Fly vision setup complete")

func update_shader_parameters():
	if shader_material:
		shader_material.set_shader_parameter("hex_size", hex_size)
		shader_material.set_shader_parameter("hex_opacity", 2)  # Bright honeycomb effect
		print("Shader parameters updated - hex_size: ", hex_size, " enabled: ", enable_hex_filter)
	else:
		print("No shader material to update!")

func toggle_fly_vision():
	if not is_setup:
		print("Fly vision not setup yet!")
		return
	
	enable_hex_filter = !enable_hex_filter
	overlay.visible = enable_hex_filter
	update_shader_parameters()
	print("Fly vision toggled: ", enable_hex_filter)

func set_fly_vision(enabled: bool):
	if not is_setup:
		return
	enable_hex_filter = enabled
	overlay.visible = enable_hex_filter
	update_shader_parameters()

func set_hex_size(value: float):
	hex_size = clamp(value, 0.01, 0.1)
	update_shader_parameters()

func set_distortion_strength(value: float):
	distortion_strength = clamp(value, 0.0, 1.0)
	update_shader_parameters()

func set_color_shift(value: float):
	color_shift = clamp(value, 0.0, 1.0)
	update_shader_parameters()

func _input(event):
	# Toggle fly vision with F key
	if event.is_action_pressed("ui_cancel") or Input.is_key_pressed(KEY_F):
		toggle_fly_vision()
