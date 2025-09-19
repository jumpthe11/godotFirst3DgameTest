extends CharacterBody3D

@export var min_speed = 5

@export var max_speed = 7

# Preload the explosion particle effect
@export var explosion_scene : PackedScene = preload("res://explosion_particles.tscn")

signal squashed


func _physics_process(_delta):
	move_and_slide()

# This function will be called from the Main scene.
func initialize(start_position, player_position):
	# We position the mob by placing it at start_position
	# and rotate it towards player_position, so it looks at the player.
	look_at_from_position(start_position, player_position, Vector3.UP)
	# Rotate this mob randomly within range of -45 and +45 degrees,
	# so that it doesn't move directly towards the player.
	rotate_y(randf_range(-PI / 4, PI / 4))
	# We calculate a random speed (integer)
	var random_speed = randi_range(min_speed, max_speed)
	# We calculate a forward velocity that represents the speed.
	velocity = Vector3.FORWARD * random_speed
	# We then rotate the velocity vector based on the mob's Y rotation
	# in order to move in the direction the mob is looking.
	velocity = velocity.rotated(Vector3.UP, rotation.y)


func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()

func squash():
	# Create explosion particle effect at mob position
	if explosion_scene:
		var explosion = explosion_scene.instantiate()
		# Add to parent (Main scene) so it persists after mob is destroyed
		get_parent().add_child(explosion)
		# Position the explosion at the mob's current position
		explosion.global_position = global_position
		# Trigger the explosion animation
		explosion.explode()
	
	squashed.emit()
	queue_free()
