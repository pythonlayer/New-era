extends CharacterBody2D

var speed = 50
var direction = -1
var gravity = 800
@onready var animator: AnimationPlayer = $animator
@onready var sprite: Sprite2D = $sprite
@onready var hitbox: Area2D = $hitbox
@onready var raycast: RayCast2D = $Ray       # Detects ground, fixed position
@onready var wallray: RayCast2D = $wallray   # Detects walls, direction-based

var is_turning = false
var is_dying = false

func _ready() -> void:
	update_wallray_position()

func _physics_process(delta: float) -> void:
	raycast.force_raycast_update()
	wallray.force_raycast_update()
	velocity.y += gravity * delta

	# Check for lack of ground or wall in the way
	if not raycast.is_colliding() or wallray.is_colliding():
		direction *= -1
		sprite.flip_h = direction < 0
		if not is_turning and not is_dying:
			is_turning = true
			animator.play("turn")
		update_wallray_position()

	# Stop movement while turning or dying
	if is_turning or is_dying:
		velocity.x = 0
		move_and_slide()
		return

	velocity.x = speed * direction
	move_and_slide()

	if velocity.x != 0:
		animator.play("walk")


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		animator.play("die")
		body.bounce()
		is_dying = true

func _on_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		queue_free()
	if anim_name == "turn":
		is_turning = false
	if anim_name == "die":
		is_dying = false

func update_wallray_position() -> void: 
	wallray.target_position = Vector2(11 * direction, 0)
	position.x+=direction*2
