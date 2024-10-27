extends Camera2D

# Variables to control camera movement and pause state
var is_paused = false
# Movement limits
const MIN_OFFSET_X = -125
const MAX_OFFSET_X = 75
const MIN_OFFSET_Y = -50
const MAX_OFFSET_Y = 50
const FORWARD_OFFSET_X = 50  # Distance to shift camera forward when player moves

@onready var player: CharacterBody2D = $"../Player"

# Timer to check how long up or down is held
var up_hold_time = 0.0
var down_hold_time = 0.0
const HOLD_THRESHOLD = 0.5  # Time (in seconds) to trigger the look up or down

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = player.position
	handle_camera_movement(delta)

# Handles all camera movement and looking adjustments
func handle_camera_movement(delta: float) -> void:
	# Horizontal movement: Adjust to focus more forward based on player direction
	if Input.is_action_pressed("L"):  # Move left
		offset.x = clamp(-FORWARD_OFFSET_X, float(MIN_OFFSET_X), float(MAX_OFFSET_X))
		# Check if player is moving in the opposite direction (right) and snap back
		if player.velocity.x > 0:
			offset.x = lerp(offset.x, 0.0, 0.1)
	elif Input.is_action_pressed("R"):  # Move right
		offset.x = clamp(FORWARD_OFFSET_X, float(MIN_OFFSET_X), float(MAX_OFFSET_X))
		# Check if player is moving in the opposite direction (left) and snap back
		if player.velocity.x < 0:
			offset.x = lerp(offset.x, 0.0, 0.1)
	else:
		# Gradually return to center if no left/right input
		offset.x = lerp(offset.x, 0.0, 0.1) 

	# Vertical movement: Up and Down keys with hold threshold
	if Input.is_action_pressed("up"):
		up_hold_time += delta
		if up_hold_time >= HOLD_THRESHOLD:
			offset.y = clamp(offset.y - 5, float(MIN_OFFSET_Y), 0.0)  # Look up, limit to MIN_OFFSET_Y
	else:
		up_hold_time = 0.0  # Reset timer if key is released

	if Input.is_action_pressed("down"):
		down_hold_time += delta
		if down_hold_time >= HOLD_THRESHOLD:
			offset.y = clamp(offset.y + 5, 0.0, float(MAX_OFFSET_Y))  # Look down, limit to MAX_OFFSET_Y
	else:
		down_hold_time = 0.0  # Reset timer if key is released

	# If no vertical key is pressed, return to the original y position smoothly
	if !Input.is_action_pressed("up") and !Input.is_action_pressed("down"):
		offset.y = lerp(offset.y, 0.0, 0.1)  # Gradually return to center vertically
