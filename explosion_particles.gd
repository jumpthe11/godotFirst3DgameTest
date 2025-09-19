extends Node3D

func _ready():
	# Wait for the next frame to ensure all nodes are ready
	call_deferred("_setup_particles")

func _setup_particles():
	# Verify the GPUParticles3D node exists
	var particles_node = $GPUParticles3D
	if not particles_node:
		print("Error: GPUParticles3D node not found!")
		return
	
	# Get existing material or create new one
	var material = particles_node.process_material
	if not material:
		material = ParticleProcessMaterial.new()
		print("Created new ParticleProcessMaterial")
	else:
		print("Using existing ParticleProcessMaterial")
	
	# Enhance the material with additional properties
	material.angular_velocity_min = -180.0
	material.angular_velocity_max = 180.0
	material.damping_min = 1.0
	material.damping_max = 3.0
	
	# Add color animation (explosion effect)
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color.YELLOW)
	gradient.add_point(0.3, Color.ORANGE)
	gradient.add_point(0.7, Color.RED)
	gradient.add_point(1.0, Color.TRANSPARENT)
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = gradient
	material.color_ramp = gradient_texture
	
	# Apply the enhanced material
	particles_node.process_material = material
	
	# Verify the material was applied
	if particles_node.process_material:
		print("Particle material successfully applied")
	else:
		print("Warning: Failed to apply particle material")

func explode():
	# Verify particles node and material exist
	var particles_node = $GPUParticles3D
	if not particles_node:
		print("Error: Cannot explode - GPUParticles3D node not found!")
		return
		
	if not particles_node.process_material:
		print("Warning: No particle material assigned - calling setup again")
		_setup_particles()
		
	# Start the particle emission
	particles_node.emitting = true
	# Start cleanup timer
	$Timer.start()

func _on_timer_timeout():
	# Clean up the particle system after animation completes
	queue_free()
