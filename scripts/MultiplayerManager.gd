extends Node
class_name MultiplayerManager

signal room_created(room_code: String)
signal room_joined()
signal player_connected(player_id: int)
signal player_disconnected(player_id: int)
signal connection_failed()

var room_code: String = ""
var is_host: bool = false
var players: Dictionary = {}

func _ready():
	# Set up multiplayer
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_room() -> String:
	"""Create a new room and return the room code"""
	room_code = _generate_room_code()
	is_host = true
	
	# Create ENet multiplayer peer
	var peer = ENetMultiplayerPeer.new()
	
	# Try different ports if 7000 is busy
	var ports_to_try = [7000, 7001, 7002, 7003, 7004]
	var result = ERR_UNAVAILABLE
	
	for port in ports_to_try:
		result = peer.create_server(port, 2)
		if result == OK:
			print("Server created on port: ", port)
			break
		else:
			print("Failed to create server on port ", port, " error: ", result)
			peer = ENetMultiplayerPeer.new()  # Create new peer for next attempt
	
	if result == OK:
		multiplayer.multiplayer_peer = peer
		print("Room created with code: ", room_code)
		room_created.emit(room_code)
		return room_code
	else:
		print("Failed to create room on any port. Error: ", result)
		return ""

func join_room(code: String) -> bool:
	"""Join a room with the given code (localhost only)"""
	return await join_room_with_ip(code, "127.0.0.1")

func join_room_with_ip(code: String, ip: String) -> bool:
	"""Join a room with the given code and IP address"""
	room_code = code
	is_host = false
	
	var peer = ENetMultiplayerPeer.new()
	
	# Try different ports
	var ports_to_try = [7000, 7001, 7002, 7003, 7004]
	var result = ERR_UNAVAILABLE
	
	for port in ports_to_try:
		result = peer.create_client(ip, port)
		if result == OK:
			print("Attempting to connect to IP: ", ip, " port: ", port)
			break
		else:
			print("Failed to connect to port ", port, " error: ", result)
			peer = ENetMultiplayerPeer.new()  # Create new peer for next attempt
	
	if result == OK:
		multiplayer.multiplayer_peer = peer
		print("Attempting to join room: ", room_code, " at IP: ", ip)
		
		# Set up a timer to check connection status
		await get_tree().create_timer(3.0).timeout
		if not multiplayer.is_server() and not multiplayer.multiplayer_peer:
			connection_failed.emit()
			return false
		
		return true
	else:
		print("Failed to connect to room at IP: ", ip, " on any port")
		connection_failed.emit()
		return false

func _generate_room_code() -> String:
	"""Generate a 6-digit room code"""
	var code = ""
	for i in range(6):
		code += str(randi() % 10)
	return code

func _on_player_connected(id: int):
	print("Player connected: ", id)
	players[id] = {"id": id, "position": Vector3.ZERO, "rotation": Vector3.ZERO}
	player_connected.emit(id)
	
	# If we're the host, send our current state to the new player
	if is_host:
		_sync_player_state(id)

func _on_player_disconnected(id: int):
	print("Player disconnected: ", id)
	players.erase(id)
	player_disconnected.emit(id)

func _on_connected_to_server():
	print("Connected to server")
	room_joined.emit()

func _on_server_disconnected():
	print("Server disconnected")

func _on_connection_failed():
	print("Connection failed")
	connection_failed.emit()

@rpc("any_peer", "reliable")
func sync_fly_state(position: Vector3, rotation: Vector3):
	"""Sync fly position and rotation between players"""
	var sender_id = multiplayer.get_remote_sender_id()
	
	if sender_id in players:
		players[sender_id]["position"] = position
		players[sender_id]["rotation"] = rotation
		
		# Update other players' fly representations
		_update_other_player_fly(sender_id, position, rotation)

func _sync_player_state(player_id: int):
	"""Send current state to a specific player"""
	# This would be called by the host to send current game state
	pass

func _update_other_player_fly(player_id: int, position: Vector3, rotation: Vector3):
	"""Update the visual representation of another player's fly"""
	# Find the multiplayer game scene and update the other player's fly
	var game_scene = get_tree().current_scene
	if game_scene and game_scene.has_method("update_other_player_fly"):
		game_scene.update_other_player_fly(player_id, position, rotation)

func get_players() -> Dictionary:
	return players

func is_room_host() -> bool:
	return is_host

func get_room_code() -> String:
	return room_code
