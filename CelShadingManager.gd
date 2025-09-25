extends Node

# Reusable Cel-Shading Manager for Compatibility Renderer
# Automatically applies cel-shading materials to characters and objects

# Predefine different cel-shading material types
var cel_materials = {}

func _ready():
	print("CelShadingManager: Initializing cel-shading materials for Compatibility renderer")
	create_cel_materials()

# Create different types of cel-shading materials
func create_cel_materials():
	# All materials use white base to avoid tinting textures
	cel_materials["player"] = create_cel_material(Color(1.0, 1.0, 1.0, 1.0))
	cel_materials["enemy"] = create_cel_material(Color(1.0, 1.0, 1.0, 1.0))
	cel_materials["neutral"] = create_cel_material(Color(1.0, 1.0, 1.0, 1.0))
	
	print("CelShadingManager: Created ", cel_materials.size(), " cel-shading materials")

# Create a cel-shading compatible material
func create_cel_material(base_color: Color) -> StandardMaterial3D:
	var material = StandardMaterial3D.new()
	
	# Core cel-shading properties for Compatibility renderer
	material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	material.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT_WRAP  # Softer shading
	material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED    # No specular for flat look
	
	# Color settings
	material.albedo_color = base_color
	material.metallic = 0.0       # Non-metallic for flat appearance
	material.roughness = 1.0      # Maximum roughness for diffuse look
	
	# Simple cel-shading without rim lighting (to avoid property errors)
	# Rim lighting can be added later when we confirm correct property names
	
	# Disable features that interfere with cel-shading
	material.clearcoat_enabled = false
	material.anisotropy_enabled = false
	material.ao_enabled = false
	
	# Vertex color support (in case models use it)
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	
	return material

# Apply cel-shading to a specific node and all its children
func apply_cel_shading(root_node: Node3D, material_type: String = "neutral"):
	if not cel_materials.has(material_type):
		print("CelShadingManager: Unknown material type: ", material_type, ". Using 'neutral'.")
		material_type = "neutral"
	
	var cel_material = cel_materials[material_type]
	var mesh_instances = find_all_mesh_instances(root_node)
	
	print("CelShadingManager: Applying ", material_type, " cel-shading to ", mesh_instances.size(), " meshes")
	
	for mesh_instance in mesh_instances:
		apply_material_to_mesh(mesh_instance, cel_material)

# Apply cel-shading material to a single MeshInstance3D
func apply_material_to_mesh(mesh_instance: MeshInstance3D, cel_material: StandardMaterial3D):
	if not mesh_instance.mesh:
		return
	
	# Get surface count
	var surface_count = mesh_instance.mesh.get_surface_count()
	
	for i in range(surface_count):
		# Get the original material first
		var original_material = mesh_instance.get_surface_override_material(i)
		if not original_material:
			original_material = mesh_instance.mesh.surface_get_material(i)
		
		# If there's an original material, enhance it with cel-shading instead of replacing
		if original_material and original_material is StandardMaterial3D:
			var orig_std = original_material as StandardMaterial3D
			# Clone the original material and add cel-shading properties
			var enhanced_material = orig_std.duplicate()
			
			# Apply cel-shading enhancements to the original material
			enhanced_material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
			enhanced_material.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT_WRAP
			enhanced_material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
			
			# Keep original colors and textures - DON'T change albedo_color if texture exists
			if not orig_std.albedo_texture:
				# Only modify color if no texture (for pure color materials)
				enhanced_material.albedo_color = cel_material.albedo_color
			
			# Simple cel-shading enhancement (rim lighting disabled to avoid errors)
			# The Lambert wrap diffuse and disabled specular provide the cel-shading effect
			
			# Ensure proper material properties for cel-shading
			enhanced_material.metallic = 0.0
			enhanced_material.roughness = max(enhanced_material.roughness, 0.8)
			
			# Apply the enhanced original material
			mesh_instance.set_surface_override_material(i, enhanced_material)
		else:
			# No original material, use our cel-shading material
			var material_copy = cel_material.duplicate()
			mesh_instance.set_surface_override_material(i, material_copy)

# Find all MeshInstance3D nodes in a tree
func find_all_mesh_instances(root_node: Node) -> Array:
	var mesh_instances = []
	_recursive_find_meshes(root_node, mesh_instances)
	return mesh_instances

func _recursive_find_meshes(node: Node, mesh_list: Array):
	if node is MeshInstance3D:
		mesh_list.append(node)
	
	for child in node.get_children():
		_recursive_find_meshes(child, mesh_list)

# Convenience functions for common use cases
func apply_player_shading(player_node: Node3D):
	apply_cel_shading(player_node, "player")

func apply_enemy_shading(enemy_node: Node3D):
	apply_cel_shading(enemy_node, "enemy")

func apply_neutral_shading(node: Node3D):
	apply_cel_shading(node, "neutral")

# Apply cel-shading to multiple nodes at once
func apply_shading_to_group(nodes: Array, material_type: String = "neutral"):
	for node in nodes:
		if node is Node3D:
			apply_cel_shading(node, material_type)

# Remove cel-shading and restore original materials
func remove_cel_shading(root_node: Node3D):
	var mesh_instances = find_all_mesh_instances(root_node)
	print("CelShadingManager: Removing cel-shading from ", mesh_instances.size(), " meshes")
	
	for mesh_instance in mesh_instances:
		if mesh_instance.mesh:
			var surface_count = mesh_instance.mesh.get_surface_count()
			for i in range(surface_count):
				# Remove override material to restore original
				mesh_instance.set_surface_override_material(i, null)
