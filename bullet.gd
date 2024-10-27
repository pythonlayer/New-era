extends CharacterBody2D

# Constants for bullet speed and lifespan
const SPEED = 250.0
const LIFESPAN = 2.0  # Bullet will disappear after 2 seconds



func _physics_process(delta: float) -> void:
	# Move the bullet forward based on its initial direction
	velocity.x = -SPEED
	move_and_slide()

func _on_LifespanTimer_timeout() -> void:
	# Remove the bullet when the lifespan timer expires
	queue_free()

func _on_Bullet_body_entered(body: Node) -> void:
	# Check for collision with player or walls
	if body.is_in_group("Player") or body.is_in_group("Wall"):
		queue_free()  # Remove the bullet upon collision
