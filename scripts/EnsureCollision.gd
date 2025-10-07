extends Node3D

func _ready():
	# Ensure all StaticBody3D nodes have collision shapes
	ensure_collision_for_node(self)

func ensure_collision_for_node(node: Node3D):
	# If this is a StaticBody3D, make sure it has collision
	if node is StaticBody3D:
		var has_collision = false
		for child in node.get_children():
			if child is CollisionShape3D:
				has_collision = true
				break
		
		# If no collision shape found, add a basic one
		if not has_collision:
			var mesh_instance = null
			for child in node.get_children():
				if child is MeshInstance3D:
					mesh_instance = child
					break
			
			if mesh_instance and mesh_instance.mesh:
				var collision_shape = CollisionShape3D.new()
				var shape = mesh_instance.mesh.create_trimesh_shape()
				collision_shape.shape = shape
				node.add_child(collision_shape)
				print("Added collision shape to: ", node.name)
	
	# Recursively check all children
	for child in node.get_children():
		if child is Node3D:
			ensure_collision_for_node(child)
