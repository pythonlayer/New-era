extends CharacterBody2D

var max_speed = 125
var sprint_speed = 200
var acceleration = 400
var deceleration = 500
var gravity = 800
var reduced_gravity = 400
var normal_jump_height_tiles = 2  # Regular jump height
var high_jump_height_tiles = 3.5   # Jump height when holding up
var base_jump_force = -sqrt(2 * gravity * normal_jump_height_tiles * 16)

@onready var animator: AnimationPlayer = $animator
@onready var sprite: Sprite2D = $sprite

var is_looking_up = false
var is_looking_down = false

func _physics_process(delta):
	var current_gravity = gravity
	if Input.is_action_pressed("A"):
		current_gravity = reduced_gravity
	velocity.y += current_gravity * delta

	var speed = max_speed
	if Input.is_action_pressed("B"):
		speed = sprint_speed

	# Movement control
	var is_moving = not (Input.is_action_pressed("up") or Input.is_action_pressed("down"))

	if is_moving:
		if Input.is_action_pressed("right"):
			velocity.x = min(velocity.x + acceleration * delta, speed)
			sprite.flip_h = false
		elif Input.is_action_pressed("left"):
			velocity.x = max(velocity.x - acceleration * delta, -speed)
			sprite.flip_h = true
		else:
			if abs(velocity.x) > 0:
				velocity.x -= deceleration * delta * sign(velocity.x)
				if abs(velocity.x) < deceleration * delta:
					velocity.x = 0

	if is_on_floor() and Input.is_action_just_pressed("A"):
		var jump = jump_speed() 
		print("jump:",jump)
		velocity.y = jump # Call the jump_speed function to set jump velocity

	if Input.is_action_pressed("up"):
		if not is_looking_up:
			animator.play("look_up")
			is_looking_up = true
		is_looking_down = false
		velocity.x = 0  # Stop horizontal movement while looking up
	elif Input.is_action_pressed("down"):
		if not is_looking_down:
			animator.play("look_down")
			is_looking_down = true
		is_looking_up = false
		velocity.x = 0  # Stop horizontal movement while looking down
	else:
		is_looking_up = false
		is_looking_down = false

		if abs(velocity.x) > 0 and is_on_floor():
			animator.play("run")
		elif not is_on_floor():
			animator.play("jump")
		else:
			animator.play("idle")

	move_and_slide()

func jump_speed() -> float:
	var jump_height = normal_jump_height_tiles  # Default to normal jump height (1 tile)

	# Check if the jump button is pressed
	if Input.is_action_just_pressed("A"):
		jump_height = high_jump_height_tiles  # Set to high jump height (2 tiles)
	elif abs(velocity.x) >= max_speed:
		jump_height = 3.5  # Jump height when running (3.5 tiles)
		
	# Calculate the jump force based on the desired jump height
	return -sqrt(2 * gravity * jump_height * 16)/1.25


func bounce():
	velocity.y = base_jump_force * 0.8
