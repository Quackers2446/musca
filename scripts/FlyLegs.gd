extends Node3D
class_name FlyLegs

@export var leg_length: float = 0.5
@export var leg_thickness: float = 0.02
@export var hair_density: float = 1000.0
@export var hair_length: float = 0.01
@export var leg_sway_speed: float = 2.0
@export var leg_sway_amount: float = 0.3

var left_leg: MeshInstance3D
var right_leg: MeshInstance3D
var left_hair: MeshInstance3D
var right_hair: MeshInstance3D
var time: float = 0.0

func _ready():
	create_fly_legs()

func create_fly_legs():
	# Create left leg - positioned at bottom of screen, pointing left
	left_leg = create_leg_mesh()
	left_leg.position = Vector3(-0.15, -0.4, -0.2)
	left_leg.rotation = Vector3(0.4, -0.6 - 11*PI/4, 0)  # Rotated forward more
	add_child(left_leg)
	
	# Create right leg - positioned at bottom of screen, pointing outward
	right_leg = create_leg_mesh()
	right_leg.position = Vector3(0.15, -0.4, -0.2)
	right_leg.rotation = Vector3(0.4, -0.6 - 11*PI/4, 0)  # Rotated forward more
	add_child(right_leg)
	
	# Create hair for left leg
	left_hair = create_hair_mesh()
	left_hair.position = Vector3(-0.15, -0.4, -0.2)
	left_hair.rotation = Vector3(0.4, -0.6 - 11*PI/4, 0)  # Rotated forward more
	add_child(left_hair)
	
	# Create hair for right leg
	right_hair = create_hair_mesh()
	right_hair.position = Vector3(0.15, -0.4, -0.2)
	right_hair.rotation = Vector3(0.4, -0.6 - 11*PI/4, 0)  # Rotated forward more
	add_child(right_hair)

func create_leg_mesh() -> MeshInstance3D:
	var leg = MeshInstance3D.new()
	
	# Create a more realistic leg with segments
	var leg_mesh = ArrayMesh.new()
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	# Create segmented leg (like real fly leg)
	var segments = 8
	var segment_height = leg_length / segments
	
	for i in range(segments + 1):
		var t = float(i) / segments
		var radius = leg_thickness * (1.0 - t * 0.3)  # Tapered leg
		var height = t * leg_length - leg_length * 0.5
		
		# Create ring of vertices
		for j in range(8):
			var angle = j * PI * 2.0 / 8.0
			var x = cos(angle) * radius
			var z = sin(angle) * radius
			
			vertices.append(Vector3(x, height, z))
			normals.append(Vector3(x, 0, z).normalized())
			uvs.append(Vector2(float(j) / 8.0, t))
	
	# Create faces between segments
	for i in range(segments):
		for j in range(8):
			var current = i * 9 + j
			var next = i * 9 + (j + 1) % 8
			var below = (i + 1) * 9 + j
			var below_next = (i + 1) * 9 + (j + 1) % 8
			
			# First triangle
			indices.append(current)
			indices.append(next)
			indices.append(below)
			
			# Second triangle
			indices.append(next)
			indices.append(below_next)
			indices.append(below)
	
	# Create the mesh
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	leg_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	leg.mesh = leg_mesh
	
	# Create textured material for the leg
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.15, 0.1, 0.05)  # Dark brown
	material.roughness = 0.9
	material.metallic = 0.0
	material.normal_enabled = true
	
	# Add some texture variation
	material.albedo_texture = create_leg_texture()
	
	leg.material_override = material
	
	return leg

func create_leg_texture() -> ImageTexture:
	# Create a simple procedural texture for the leg
	var image = Image.create(64, 64, false, Image.FORMAT_RGB8)
	
	for x in range(64):
		for y in range(64):
			# Create a segmented pattern
			var segment = int(y / 8.0) % 2
			var noise = sin(x * 0.3) * cos(y * 0.2) * 0.1
			var base_color = 0.15 + segment * 0.05 + noise
			
			image.set_pixel(x, y, Color(base_color, base_color * 0.8, base_color * 0.5))
	
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture

func create_hair_mesh() -> MeshInstance3D:
	var hair = MeshInstance3D.new()
	
	# Create hair using a simple mesh
	var hair_mesh = ArrayMesh.new()
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var indices = PackedInt32Array()
	
	# Generate hair along the leg
	for i in range(int(hair_density)):
		var t = float(i) / hair_density
		var angle = randf() * 2.0 * PI
		var height = t * leg_length
		
		# Hair base position
		var base_pos = Vector3(
			cos(angle) * leg_thickness,
			height - leg_length * 0.5,
			sin(angle) * leg_thickness
		)
		
		# Hair tip position
		var tip_pos = base_pos + Vector3(
			cos(angle) * hair_length,
			sin(angle) * hair_length * 0.5,
			sin(angle) * hair_length
		)
		
		# Add hair vertices
		var start_idx = vertices.size()
		vertices.append(base_pos)
		vertices.append(tip_pos)
		
		# Add normals
		normals.append(Vector3(0, 1, 0))
		normals.append(Vector3(0, 1, 0))
		
		# Add UVs
		uvs.append(Vector2(0, 0))
		uvs.append(Vector2(1, 1))
		
		# Add indices for hair line
		indices.append(start_idx)
		indices.append(start_idx + 1)
	
	# Create the mesh
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	
	hair_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	hair.mesh = hair_mesh
	
	# Create material for hair
	var hair_material = StandardMaterial3D.new()
	hair_material.albedo_color = Color(0.1, 0.1, 0.1)  # Very dark
	hair_material.roughness = 0.9
	hair_material.metallic = 0.0
	hair.material_override = hair_material
	
	return hair

func _process(delta):
	time += delta
	
	# Animate leg movement
	if left_leg and right_leg:
		# Sway the legs slightly
		var sway = sin(time * leg_sway_speed) * leg_sway_amount
		left_leg.rotation.z = sway
		right_leg.rotation.z = -sway
		
		# Move hair with the legs
		if left_hair and right_hair:
			left_hair.rotation.z = sway
			right_hair.rotation.z = -sway
