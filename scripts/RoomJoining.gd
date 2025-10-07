extends Control

@onready var room_code_input: LineEdit = $UI/RoomCodeInput
@onready var ip_input: LineEdit = $UI/IPInput
@onready var status_label: Label = $UI/StatusLabel
@onready var join_button: Button = $UI/ButtonContainer/JoinButton
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
	multiplayer_manager.room_joined.connect(_on_room_joined)
	multiplayer_manager.connection_failed.connect(_on_connection_failed)
	
	# Connect button signals
	join_button.pressed.connect(_on_join_pressed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Connect input signals
	room_code_input.text_submitted.connect(_on_code_submitted)
	
	# Style buttons
	_style_buttons()
	
	# Focus on input field
	room_code_input.grab_focus()

func _on_join_pressed():
	_attempt_join()

func _on_code_submitted(text: String):
	_attempt_join()

func _attempt_join():
	var code = room_code_input.text.strip_edges()
	var ip = ip_input.text.strip_edges()
	
	if code.length() != 6:
		status_label.text = "Room code must be 6 digits"
		status_label.modulate = Color.RED
		return
	
	if ip.is_empty():
		status_label.text = "Please enter host IP address"
		status_label.modulate = Color.RED
		return
	
	status_label.text = "Connecting to " + ip + "..."
	status_label.modulate = Color.YELLOW
	join_button.disabled = true
	
	# Attempt to join room with IP
	var success = await multiplayer_manager.join_room_with_ip(code, ip)
	if not success:
		status_label.text = "Failed to connect to " + ip
		status_label.modulate = Color.RED
		join_button.disabled = false

func _on_room_joined():
	status_label.text = "Connected! Waiting for host to start..."
	status_label.modulate = Color.GREEN
	print("Successfully joined room")

func _on_connection_failed():
	status_label.text = "Connection failed. Check room code."
	status_label.modulate = Color.RED
	join_button.disabled = false

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
	
	join_button.add_theme_stylebox_override("normal", button_style)
	back_button.add_theme_stylebox_override("normal", button_style)
	
	# Hover style
	var hover_style = button_style.duplicate()
	hover_style.bg_color = Color(0.3, 0.4, 0.9, 0.9)
	join_button.add_theme_stylebox_override("hover", hover_style)
	back_button.add_theme_stylebox_override("hover", hover_style)
	
	# Font styling
	join_button.add_theme_font_size_override("font_size", 18)
	back_button.add_theme_font_size_override("font_size", 18)
	
	# Title styling
	var title_label = $UI/Title
	title_label.add_theme_font_size_override("font_size", 36)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	
	# Input field styling
	room_code_input.add_theme_font_size_override("font_size", 24)
	room_code_input.add_theme_color_override("font_color", Color.WHITE)
	room_code_input.add_theme_color_override("font_placeholder_color", Color.GRAY)
	
	# Label styling
	var room_code_label = $UI/RoomCodeLabel
	room_code_label.add_theme_font_size_override("font_size", 18)
	room_code_label.add_theme_color_override("font_color", Color.WHITE)
	
	status_label.add_theme_font_size_override("font_size", 16)
