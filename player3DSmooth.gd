extends CharacterBody3D  # Extends the CharacterBody3D class to create a 3D character controller

@export var max_speed = 20  # The maximum speed of the character
@export var gravity = 70  # The gravity applied to the character
@export var jump_impulse = 18  # The initial impulse given when the character jumps
@export var rotation_speed = 750.0  # Ensure the rotation speed is a float
@export var smooth_speed = 5.0  # Variable for smooth rotation speed

@onready var pivot = $Pivot  # Get a reference to the Pivot node

var is_jumping = false  # Whether the character is currently jumping
var rotation_on_jump = 0.0  # The current rotation during the jump
var facing_right = true  # Whether the character is facing right

# Added variables for smooth rotation
var current_y_rotation = 0.0  # Current Y-axis rotation of the pivot
var target_y_rotation = 0.0  # Target Y-axis rotation for the pivot

func _ready():
	# Set the pivot to initially face along the X-axis
	pivot.look_at(position + Vector3(1, 0, 0), Vector3.UP)
	current_y_rotation = pivot.rotation.y  # Initialize the current rotation
	target_y_rotation = pivot.rotation.y  # Initialize the target rotation

func _physics_process(delta):
	var input_vector = get_input_vector()  # Get the input vector
	apply_movement(input_vector, delta)  # Apply movement based on the input vector
	apply_gravity(delta)  # Apply gravity to the character
	jump(delta)  # Handle jumping logic
	set_velocity(velocity)  # Set the character's velocity
	set_up_direction(Vector3.UP)  # Set the up direction to be the world's up direction
	move_and_slide()  # Move and slide the character based on its velocity

func get_input_vector():
	var input_vector = Vector3.ZERO  # Initialize the input vector to zero
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")  # Get horizontal input
	input_vector.z = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")  # Get vertical input
	return input_vector.normalized()  # Normalize the input vector

func apply_movement(input_vector, delta):
	velocity.x = input_vector.x * max_speed  # Set the horizontal velocity
	velocity.z = input_vector.z * max_speed  # Set the vertical velocity

	if input_vector != Vector3.ZERO:
		pivot.look_at(position + input_vector, Vector3.UP)  # Rotate the pivot to face the input direction
		flip(input_vector)  # Flip the character based on the input direction

	# Call the smooth rotation function
	smooth_rotate_y(delta)

func apply_gravity(delta):
	velocity.y -= gravity * delta  # Apply gravity to the vertical velocity

func jump(delta):
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		is_jumping = true  # Set the jumping flag
		velocity.y = jump_impulse  # Apply the jump impulse

	if is_jumping and rotation_on_jump < 360.0:
		rotation_on_jump += rotation_speed * delta  # Increase the rotation during the jump
		pivot.rotation.x -= deg_to_rad(rotation_speed * delta)  # Rotate the pivot during the jump
	else:
		is_jumping = false  # Reset the jumping flag
		rotation_on_jump = 0.0  # Reset the rotation on jump
		pivot.rotation.x = 0.0  # Reset the pivot's rotation after the jump

	if is_on_floor() and not is_jumping:
		rotation_on_jump = 0.0  # Reset the rotation on jump when on the floor
		pivot.rotation.x = 0.0  # Reset the pivot's rotation when on the floor

func flip(direction):
	target_y_rotation = atan2(-direction.x, -direction.z)  # Calculate the target Y rotation based on the direction

func smooth_rotate_y(delta):
	current_y_rotation = lerp_angle(current_y_rotation, target_y_rotation, delta * smooth_speed)  # Smoothly rotate to the target Y rotation
	pivot.rotation.y = current_y_rotation  # Apply the current Y rotation to the pivot
