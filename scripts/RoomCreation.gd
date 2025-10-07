extends Control

@onready var room_code_display: Label = $UI/RoomCodeDisplay
@onready var ip_display: Label = $UI/IPDisplay
@onready var start_game_button: Button = $UI/ButtonContainer/StartGameButton
@onready var back_button: Button = $UI/ButtonContainer/BackButton

var multiplayer_manager: MultiplayerManager

func _ready():
	# Get or create multiplayer manager
	multiplayer_manager = get_node("/root/MultiplayerManager")
	if not multiplayer_manager:
		multiplayer_manager = MultiplayerManager.new()
		multiplayer_manager.name = "MultiplayerManager"
		get_tree().root.add_child(multiplayer_manager)
	
	# Connect signals
	multiplayer_manager.room_created.connect(_on_room_created)
	multiplayer_manager.player_connected.connect(_on_player_connected)
	
	# Connect button signals
	start_game_button.pressed.connect(_on_start_game_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Style buttons
	_style_buttons()
	
	# Create room
	_create_room()

func _create_room():
	room_code_display.text = "Creating room..."
	ip_display.text = "Getting IP..."
	
	var code = multiplayer_manager.create_room()
	if code != "":
		room_code_display.text = code
		print("Room created with code: ", code)
		
		# Get local IP address
		_get_local_ip()
	else:
		room_code_display.text = "Failed to create room"
		ip_display.text = "Failed to get IP"

func _get_local_ip():
	# Get the local IP address
	var ip = _get_local_ip_address()
	if ip != "" and ip != "127.0.0.1":
		ip_display.text = ip
		print("Host IP address: ", ip)
	else:
		# Show manual input option for itch.io
		ip_display.text = "Enter your IP manually"
		print("Could not determine local IP address, showing manual input")
		_show_manual_ip_input()

func _get_local_ip_address() -> String:
	# Try to get the local IP address
	var interfaces = IP.get_local_interfaces()
	print("Available interfaces: ", interfaces)
	
	for interface in interfaces:
		var addresses = interface.get("addresses", [])
		print("Interface addresses: ", addresses)
		for address in addresses:
			# Skip loopback and link-local addresses
			if not address.begins_with("127.") and not address.begins_with("169.254.") and not address.begins_with("::1"):
				print("Found valid IP: ", address)
				return address
	
	# Fallback: try to get any non-loopback address
	for interface in interfaces:
		var addresses = interface.get("addresses", [])
		for address in addresses:
			if not address.begins_with("::1"):
				print("Using fallback IP: ", address)
				return address
	
	print("No valid IP found, using localhost")
	return "127.0.0.1"

func _show_manual_ip_input():
	# For itch.io, we'll show instructions instead of auto-detecting IP
	ip_display.text = "Share your public IP with friends"
	print("Manual IP input mode for itch.io")

func _on_room_created(code: String):
	room_code_display.text = code
	print("Room created successfully: ", code)

func _on_player_connected(player_id: int):
	print("Player joined! ID: ", player_id)
	# Enable start game button when another player joins
	start_game_button.disabled = false
	start_game_button.text = "Start Game (2/2)"

func _on_start_game_pressed():
	print("Starting multiplayer game...")
	# Load the multiplayer game scene
	get_tree().change_scene_to_file("res://scenes/MultiplayerGame.tscn")

func _on_back_pressed():
	# Clean up multiplayer
	if multiplayer_manager:
		multiplayer_manager.multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _style_buttons():
	# Style the buttons similar to main menu
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
	
	start_game_button.add_theme_stylebox_override("normal", button_style)
	back_button.add_theme_stylebox_override("normal", button_style)
	
	# Hover style
	var hover_style = button_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.4, 0.9, 0.9)
	start_game_button.add_theme_stylebox_override("hover", hover_style)
	back_button.add_theme_stylebox_override("hover", hover_style)
	
	# Disabled style for start button
	var disabled_style = button_style.duplicate()
	disabled_style.bg_color = Color(0.1, 0.1, 0.3, 0.5)
	start_game_button.add_theme_stylebox_override("disabled", disabled_style)
	
	# Font styling
	start_game_button.add_theme_font_size_override("font_size", 18)
	back_button.add_theme_font_size_override("font_size", 18)
	
	# Title styling
	var title_label = $UI/Title
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Room code styling
	room_code_display.add_theme_font_size_override("font_size", 24)
	room_code_display.add_theme_color_override("font_color", Color.YELLOW)
	
	var room_code_label = $UI/RoomCodeLabel
	room_code_label.add_theme_font_size_override("font_size", 18)
	room_code_label.add_theme_color_override("font_color", Color.WHITE)
