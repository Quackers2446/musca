extends Node
class_name NetworkHandler

signal player_connected(player_id: int)
signal player_disconnected(player_id: int)
signal server_started
signal server_stopped
signal client_connected
signal client_disconnected

@export var server_port: int = 7000
@export var max_players: int = 8

var is_server: bool = false
var is_client: bool = false
var server_ip: String = "127.0.0.1"

func _ready():
	# Connect multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func start_server() -> bool:
	"""Start a dedicated server"""
	if is_server or is_client:
		print("Already connected as server or client")
		return false
	
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(server_port, max_players)
	
	if result == OK:
		multiplayer.multiplayer_peer = peer
		is_server = true
		print("Server started on port: ", server_port)
		server_started.emit()
		return true
	else:
		print("Failed to start server on port: ", server_port, " Error: ", result)
		return false

func stop_server():
	"""Stop the server"""
	if is_server:
		multiplayer.multiplayer_peer = null
		is_server = false
		print("Server stopped")
		server_stopped.emit()

func connect_to_server(ip: String = "127.0.0.1", port: int = 7000) -> bool:
	"""Connect to a server"""
	if is_server or is_client:
		print("Already connected as server or client")
		return false
	
	var peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(ip, port)
	
	if result == OK:
		multiplayer.multiplayer_peer = peer
		is_client = true
		server_ip = ip
		print("Connecting to server at: ", ip, ":", port)
		return true
	else:
		print("Failed to connect to server at: ", ip, ":", port, " Error: ", result)
		return false

func disconnect():
	"""Disconnect from server or stop hosting"""
	if is_server:
		stop_server()
	elif is_client:
		multiplayer.multiplayer_peer = null
		is_client = false
		print("Disconnected from server")
		client_disconnected.emit()

func get_connected_players() -> Array[int]:
	"""Get list of connected player IDs"""
	var players = []
	if is_server:
		players.append(1)  # Server is always player 1
		for peer_id in multiplayer.get_peers():
			players.append(peer_id)
	elif is_client:
		players.append(multiplayer.get_unique_id())
		for peer_id in multiplayer.get_peers():
			players.append(peer_id)
	return players

func is_host() -> bool:
	"""Check if this instance is the host/server"""
	return is_server

func is_connected() -> bool:
	"""Check if connected to multiplayer"""
	return is_server or is_client

# Signal handlers
func _on_peer_connected(id: int):
	print("Player connected: ", id)
	player_connected.emit(id)

func _on_peer_disconnected(id: int):
	print("Player disconnected: ", id)
	player_disconnected.emit(id)

func _on_connected_to_server():
	print("Connected to server")
	client_connected.emit()

func _on_server_disconnected():
	print("Disconnected from server")
	is_client = false
	client_disconnected.emit()
