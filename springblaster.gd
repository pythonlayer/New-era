extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -200.0
const SHOOT_INTERVAL = 2.0

@onready var animator: AnimationPlayer = $animator
@onready var ground_check: RayCast2D = $GroundCheck
@onready var gun_point: Marker2D = $GunPoint
@onready var shooting_timer: Timer = $ShootingTimer
const BULLET = preload("res://bullet.tscn")

var is_dying = false
var player_in_range = false
var is_jumping = false

func _ready() -> void:
	shooting_timer.wait_time = SHOOT_INTERVAL
	shooting_timer.start()

func _physics_process(delta: float) -> void:
	if is_dying:
		return  # Skip further processing if dying

	# Apply gravity
	velocity.y += 800 * delta

	# Jump if on the ground, and player input for jump is detected
	if ground_check.is_colliding() and !is_jumping:
		if Input.is_action_just_pressed("A"):
			velocity.y = JUMP_VELOCITY
			is_jumping = true

	# Apply movement and slide
	move_and_slide()

	# Determine if on the ground to reset jump status and play the correct animation
	if ground_check.is_colliding():
		animator.play("idle")
		if is_jumping:  # Play landing or idle animation only if jump just ended
			is_jumping = false
	else:
		animator.play("jump")  # Maintain jump animation while in the air

# Timer callback for shooting
func _on_ShootingTimer_timeout() -> void:
	if !is_dying:  # Only shoot if not dying
		animator.stop()
		animator.play("shoot")
		shoot_bullet()

# Spawn and shoot a bullet
func shoot_bullet() -> void:
	var bullet = BULLET.instantiate()  # Instantiate the bullet scene
	bullet.position = gun_point.global_position
	bullet.velocity = Vector2(SPEED, 0)  # Set bullet direction
	get_parent().add_child(bullet)

# Detect collision with Slimmy
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and !is_dying:
		# Play dying animation
		animator.play("die")
		body.bounce()  # Make Slimmy bounce
		is_dying = true  # Set dying state to true
		shooting_timer.stop()  # Stop shooting when dying

# Handle animation finishing to queue free the turret
func _on_animator_animation_finished(anim_name: StringName) -> void:
	if anim_name == "die":
		queue_free()  # Remove turret from the scene
