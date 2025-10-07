extends Control

@onready var ip_input: LineEdit = $UI/InputContainer/IPInput
@onready var port_input: LineEdit = $UI/InputContainer/PortInput
@onready var connect_button: Button = $UI/InputContainer/ButtonContainer/ConnectButton
@onready var back_button: Button = $UI/InputContainer/ButtonContainer/BackButton
@onready var status_label: Label = $UI/StatusLabel

func _ready():
	# Connect button signals
	connect_button.pressed.connect(_on_connect_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Style the UI
	_style_ui()

func _style_ui():
	# Style the title
	var title_label = $UI/Title
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Style the status label
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", Color.YELLOW)
	
	# Style the input fields
	ip_input.add_theme_font_size_override("font_size", 16)
	port_input.add_theme_font_size_override("font_size", 16)
	
	# Style the buttons
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
	
	connect_button.add_theme_stylebox_override("normal", button_style)
	back_button.add_theme_stylebox_override("normal", button_style)
	
	# Hover style
	var hover_style = button_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.4, 0.9, 0.9)
	connect_button.add_theme_stylebox_override("hover", hover_style)
	back_button.add_theme_stylebox_override("hover", hover_style)
	
	# Font styling
	var font_size = 18
	connect_button.add_theme_font_size_override("font_size", font_size)
	back_button.add_theme_font_size_override("font_size", font_size)

func _on_connect_pressed():
	"""Connect to the server"""
	var ip = ip_input.text.strip_edges()
	var port_text = port_input.text.strip_edges()
	
	# Validate inputs
	if ip.is_empty():
		ip = "127.0.0.1"
	
	var port = 7000
	if not port_text.is_empty():
		port = port_text.to_int()
		if port <= 0 or port > 65535:
			port = 7000
	
	status_label.text = "Connecting to " + ip + ":" + str(port) + "..."
	status_label.modulate = Color.YELLOW
	
	# Load multiplayer game and connect
	get_tree().change_scene_to_file("res://scenes/MultiplayerGame.tscn")
	
	# Connect to server after scene loads
	await get_tree().process_frame
	var network_handler = get_node("/root/NetworkHandler")
	if network_handler:
		var success = network_handler.connect_to_server(ip, port)
		if not success:
			status_label.text = "Failed to connect to server"
			status_label.modulate = Color.RED
			# Go back to main menu
			await get_tree().create_timer(2.0).timeout
			get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_back_pressed():
	"""Go back to main menu"""
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
