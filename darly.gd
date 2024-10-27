extends CharacterBody2D

var speed = 50
var direction = -1
var gravity = 800
@onready var animator: AnimationPlayer = $animator
@onready var sprite: Sprite2D = $sprite
@onready var hitbox: Area2D = $hitbox
@onready var raycast: RayCast2D = $Ray

var is_turning = false
var is_dying = false

func _physics_process(delta: float) -> void:
	raycast.force_raycast_update()
	velocity.y += gravity * delta

	if raycast.is_colliding():
		direction *= -1
		sprite.flip_h = direction < 0
		if not is_turning and not is_dying:
			is_turning = true
			animator.play("turn")
		if direction < 0:
			raycast.target_position.x = 15 * -1 
		else:
			raycast.target_position.x = 15

	if is_turning or is_dying:
		velocity.x = 0
		move_and_slide()
		return

	velocity.x = speed * direction
	move_and_slide()

	if velocity.x != 0:
		animator.play("walk")
	else:
		animator.play("idle")

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		animator.play("die")
		body.bounce()
		is_dying = true  # Set dying state to true

func _on_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		queue_free()
	if anim_name == "turn":
		is_turning = false
	if anim_name == "die":  # Reset dying state on animation finish
		is_dying = false
