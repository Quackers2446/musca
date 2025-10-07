extends Node3D

@onready var fly: CharacterBody3D = $Fly
@onready var other_player_fly: Node3D = $OtherPlayerFly
@onready var other_player_model: Node3D = $OtherPlayerFly/OtherPlayerModel

var multiplayer_manager: MultiplayerManager
var sync_timer: float = 0.0
var sync_interval: float = 1.0 / 20.0  # 20 times per second

func _ready():
	# Get multiplayer manager
	multiplayer_manager = get_node("/root/MultiplayerManager")
	if not multiplayer_manager:
		print("No multiplayer manager found!")
		return
	
	# Connect to multiplayer signals
	multiplayer_manager.player_connected.connect(_on_player_connected)
	multiplayer_manager.player_disconnected.connect(_on_player_disconnected)
	
	# Set up the fly controller for multiplayer
	_setup_multiplayer_fly()
	
	# Position other player fly
	other_player_fly.position = Vector3(2, 2, 0)
	
	print("Multiplayer game started")

func _setup_multiplayer_fly():
	# Get the fly controller script
	var fly_controller = fly.get_script()
	if fly_controller:
		# We'll need to modify the fly controller to sync position
		# For now, just ensure it's working
		pass

func _process(delta):
	sync_timer += delta
	
	# Sync position with other players
	if sync_timer >= sync_interval:
		_sync_position()
		sync_timer = 0.0

func _sync_position():
	if not multiplayer_manager or not multiplayer_manager.multiplayer.multiplayer_peer:
		return
	
	# Get current position and rotation
	var position = fly.global_position
	var rotation = fly.global_rotation
	
	# Send to other players
	multiplayer_manager.sync_fly_state.rpc(position, rotation)

func _on_player_connected(player_id: int):
	print("Player connected: ", player_id)
	# Show the other player's fly
	other_player_fly.visible = true

func _on_player_disconnected(player_id: int):
	print("Player disconnected: ", player_id)
	# Hide the other player's fly
	other_player_fly.visible = false

# This function will be called by the multiplayer manager
func update_other_player_fly(player_id: int, position: Vector3, rotation: Vector3):
	"""Update the visual representation of another player's fly"""
	other_player_fly.global_position = position
	other_player_fly.global_rotation = rotation
