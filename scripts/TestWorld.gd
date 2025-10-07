extends Node3D

func _ready():
	# Create a simple ground plane
	create_ground()
	create_simple_house()

func create_ground():
	var ground = StaticBody3D.new()
	var mesh_instance = MeshInstance3D.new()
	var collision_shape = CollisionShape3D.new()
	
	# Create a box mesh for the ground
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(20, 1, 20)
	mesh_instance.mesh = box_mesh
	
	# Create collision shape
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(20, 1, 20)
	collision_shape.shape = box_shape
	
	ground.add_child(mesh_instance)
	ground.add_child(collision_shape)
	add_child(ground)
	
	# Position the ground
	ground.position = Vector3(0, -0.5, 0)

func create_walls():
	# Create 4 walls around the area
	var wall_positions = [
		Vector3(-10, 2.5, 0),  # Left wall
		Vector3(10, 2.5, 0),   # Right wall
		Vector3(0, 2.5, -10),  # Back wall
		Vector3(0, 2.5, 10)    # Front wall
	]
	
	var wall_scales = [
		Vector3(1, 5, 20),     # Left/Right walls
		Vector3(1, 5, 20),     # Left/Right walls
		Vector3(20, 5, 1),     # Back/Front walls
		Vector3(20, 5, 1)      # Back/Front walls
	]
	
	for i in range(4):
		var wall = StaticBody3D.new()
		var mesh_instance = MeshInstance3D.new()
		var collision_shape = CollisionShape3D.new()
		
		# Create box mesh
		var box_mesh = BoxMesh.new()
		box_mesh.size = wall_scales[i]
		mesh_instance.mesh = box_mesh
		
		# Create collision shape
		var box_shape = BoxShape3D.new()
		box_shape.size = wall_scales[i]
		collision_shape.shape = box_shape
		
		wall.add_child(mesh_instance)
		wall.add_child(collision_shape)
		add_child(wall)
		
		# Position the wall
		wall.position = wall_positions[i]

func create_simple_house():
	# Create a simple house for the fly to explore
	var house = StaticBody3D.new()
	house.name = "SimpleHouse"
	
	# House base
	var base = MeshInstance3D.new()
	var base_mesh = BoxMesh.new()
	base_mesh.size = Vector3(4, 2, 4)
	base.mesh = base_mesh
	base.position = Vector3(0, 1, 0)
	
	# House roof
	var roof = MeshInstance3D.new()
	var roof_mesh = BoxMesh.new()
	roof_mesh.size = Vector3(4.5, 1, 4.5)
	roof.mesh = roof_mesh
	roof.position = Vector3(0, 2.5, 0)
	roof.rotation = Vector3(0, PI/4, 0)  # Rotate roof slightly
	
	# House door
	var door = MeshInstance3D.new()
	var door_mesh = BoxMesh.new()
	door_mesh.size = Vector3(0.8, 1.5, 0.1)
	door.mesh = door_mesh
	door.position = Vector3(0, 0.75, 2.05)  # Slightly in front of base
	
	# Create materials
	var base_material = StandardMaterial3D.new()
	base_material.albedo_color = Color(0.6, 0.4, 0.2)  # Brown
	base.material_override = base_material
	
	var roof_material = StandardMaterial3D.new()
	roof_material.albedo_color = Color(0.3, 0.2, 0.1)  # Dark brown
	roof.material_override = roof_material
	
	var door_material = StandardMaterial3D.new()
	door_material.albedo_color = Color(0.4, 0.2, 0.1)  # Darker brown
	door.material_override = door_material
	
	# Add meshes to house
	house.add_child(base)
	house.add_child(roof)
	house.add_child(door)
	
	# Create collision shape for the house
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(4, 2, 4)
	collision_shape.shape = box_shape
	collision_shape.position = Vector3(0, 1, 0)
	house.add_child(collision_shape)
	
	# Position the house
	house.position = Vector3(0, 0, 0)
	add_child(house)
