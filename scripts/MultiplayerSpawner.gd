extends Node
class_name MultiplayerSpawner

@export var fly_scene: PackedScene = preload("res://scenes/Fly.tscn")
@export var spawn_offset: Vector3 = Vector3(0, 2, 0)

var network_handler: NetworkHandler
var player_instances: Dictionary = {}  # player_id -> fly_instance

func _ready():
	# Get the network handler
	network_handler = get_node("/root/NetworkHandler")
	if not network_handler:
		print("NetworkHandler not found!")
		return
	
	# Connect to network handler signals
	network_handler.player_connected.connect(_on_player_connected)
	network_handler.player_disconnected.connect(_on_player_disconnected)
	
	# If we're the server, spawn the host player
	if network_handler.is_host():
		spawn_local_player()

func spawn_local_player():
	"""Spawn the local player (host)"""
	var player_id = 1  # Host is always player 1
	spawn_player(player_id, true)

func spawn_player(player_id: int, is_local: bool = false):
	"""Spawn a player instance"""
	if player_instances.has(player_id):
		print("Player ", player_id, " already exists")
		return
	
	var fly_instance = fly_scene.instantiate()
	fly_instance.name = "Player" + str(player_id)
	
	# Position the player
	var spawn_position = Vector3.ZERO
	if player_instances.size() > 0:
		# Offset subsequent players
		spawn_position = Vector3(player_instances.size() * 3, 0, 0)
	
	fly_instance.global_position = spawn_position + spawn_offset
	
	# Set multiplayer authority
	if is_local:
		fly_instance.set_multiplayer_authority(1)  # Host controls their own fly
	else:
		fly_instance.set_multiplayer_authority(player_id)
	
	# Add to scene
	add_child(fly_instance, true)
	player_instances[player_id] = fly_instance
	
	print("Spawned player ", player_id, " at position: ", fly_instance.global_position)

func remove_player(player_id: int):
	"""Remove a player instance"""
	if player_instances.has(player_id):
		var fly_instance = player_instances[player_id]
		fly_instance.queue_free()
		player_instances.erase(player_id)
		print("Removed player ", player_id)

func get_player_instance(player_id: int) -> Node:
	"""Get a player instance by ID"""
	return player_instances.get(player_id, null)

func get_local_player() -> Node:
	"""Get the local player instance"""
	if network_handler.is_host():
		return player_instances.get(1, null)
	else:
		return player_instances.get(multiplayer.get_unique_id(), null)

# Signal handlers
func _on_player_connected(player_id: int):
	print("Spawning player: ", player_id)
	spawn_player(player_id)

func _on_player_disconnected(player_id: int):
	print("Removing player: ", player_id)
	remove_player(player_id)
