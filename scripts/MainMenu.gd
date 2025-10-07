extends Control

@onready var fly_model: Node3D = $FlyModel
@onready var start_button: Button = $UI/ButtonContainer/StartButton
@onready var create_room_button: Button = $UI/ButtonContainer/CreateRoomButton
@onready var join_room_button: Button = $UI/ButtonContainer/JoinRoomButton

var rotation_speed: float = 1.0

func _ready():
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	create_room_button.pressed.connect(_on_create_room_pressed)
	join_room_button.pressed.connect(_on_join_room_pressed)
	
	# Style the buttons
	_style_buttons()

func _process(delta):
	# Rotate the fly model
	if fly_model:
		fly_model.rotate_y(rotation_speed * delta)

func _style_buttons():
	# Create a theme for the buttons
	var theme = Theme.new()
	
	# Button style
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.3, 0.8, 0.8)
	button_style.border_color = Color(0.1, 0.2, 0.6, 1.0)
	button_style.border_width_left = 2
	button_style.border_width_right = 2
	button_style.border_width_top = 2
	button_style.border_width_bottom = 2
	button_style.corner_radius_top_left = 8
	button_style.corner_radius_top_right = 8
	button_style.corner_radius_bottom_left = 8
	button_style.corner_radius_bottom_right = 8
	
	# Apply style to all buttons
	start_button.add_theme_stylebox_override("normal", button_style)
	create_room_button.add_theme_stylebox_override("normal", button_style)
	join_room_button.add_theme_stylebox_override("normal", button_style)
	
	# Hover style
	var hover_style = button_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.4, 0.9, 0.9)
	start_button.add_theme_stylebox_override("hover", hover_style)
	create_room_button.add_theme_stylebox_override("hover", hover_style)
	join_room_button.add_theme_stylebox_override("hover", hover_style)
	
	# Pressed style
	var pressed_style = button_style.duplicate()
	pressed_style.bg_color = Color(0.1, 0.2, 0.7, 1.0)
	start_button.add_theme_stylebox_override("pressed", pressed_style)
	create_room_button.add_theme_stylebox_override("pressed", pressed_style)
	join_room_button.add_theme_stylebox_override("pressed", pressed_style)
	
	# Font styling
	var font = ThemeDB.fallback_font
	var font_size = 18
	start_button.add_theme_font_size_override("font_size", font_size)
	create_room_button.add_theme_font_size_override("font_size", font_size)
	join_room_button.add_theme_font_size_override("font_size", font_size)
	
	# Title styling
	var title_label = $UI/Title
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.add_theme_color_override("font_color", Color.WHITE)

func _on_start_pressed():
	print("Starting single player game...")
	# Load the SimpleTest scene
	get_tree().change_scene_to_file("res://scenes/SimpleTest.tscn")

func _on_create_room_pressed():
	print("Starting as server...")
	# Load multiplayer game and start server
	get_tree().change_scene_to_file("res://scenes/MultiplayerGame.tscn")
	# Start server after scene loads
	await get_tree().process_frame
	var network_handler = get_node("/root/NetworkHandler")
	if network_handler:
		network_handler.start_server()

func _on_join_room_pressed():
	print("Opening client connection...")
	# Open client connection screen
	get_tree().change_scene_to_file("res://scenes/ClientConnection.tscn")
