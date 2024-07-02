extends CharacterBody3D  # Inherits CharacterBody3D class to create a 3D character controller

@export var max_speed = 20  # Maximum speed of the character
@export var gravity = 70  # Gravity affecting the character
@export var jump_impulse = 18  # Initial impulse when the character jumps
@export var rotation_speed = 750.0  # Rotation speed, must be a float value
@export var smooth_speed = 5.0  # Variable for smooth rotation

@onready var pivot = $Pivot  # Get reference to the Pivot node

var is_jumping = false  # Whether the character is currently jumping
var rotation_on_jump = 0.0  # Current rotation during the jump
var facing_right = true  # Whether the character is facing right

# Added variables for smooth rotation
var current_y_rotation = 0.0  # Current Y-axis rotation of the pivot
var target_y_rotation = 0.0  # Target Y-axis rotation for the pivot

# Variables for smooth rotation around the X-axis during the jump
var current_x_rotation = 0.0  # Current X-axis rotation of the pivot
var target_x_rotation = 0.0  # Target X-axis rotation for the pivot

func _ready():
	# Set the pivot to initially face the X-axis
	pivot.look_at(position + Vector3(1, 0, 0), Vector3.UP)
	current_y_rotation = pivot.rotation.y  # Initialize current Y rotation
	target_y_rotation = pivot.rotation.y  # Initialize target Y rotation
	current_x_rotation = pivot.rotation.x  # Initialize current X rotation
	target_x_rotation = pivot.rotation.x  # Initialize target X rotation

func _physics_process(delta):
	var input_vector = get_input_vector()  # Get input vector
	apply_movement(input_vector)  # Apply movement based on input vector
	apply_gravity(delta)  # Apply gravity to the character
	jump(delta)  # Process jump logic
	set_velocity(velocity)  # Set the character's velocity
	set_up_direction(Vector3.UP)  # Set up direction to be the world's up direction
	move_and_slide()  # Move and slide the character based on its velocity

func get_input_vector():
	var input_vector = Vector3.ZERO  # Initialize input vector to zero
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")  # Get horizontal input
	input_vector.z = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")  # Get vertical input
	return input_vector.normalized()  # Normalize input vector

func apply_movement(input_vector):
	velocity.x = input_vector.x * max_speed  # Set horizontal speed
	velocity.z = input_vector.z * max_speed  # Set vertical speed

	if input_vector != Vector3.ZERO:
		pivot.look_at(position + input_vector, Vector3.UP)  # Rotate pivot to face the direction of movement
		flip(input_vector)  # Flip the character based on the direction of movement

func apply_gravity(delta):
	velocity.y -= gravity * delta  # Apply gravity to vertical speed

func jump(delta):
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		is_jumping = true  # Set jumping flag
		velocity.y = jump_impulse  # Apply jump impulse

	if is_jumping:
		if get_input_vector() == Vector3.ZERO:
			jump_in_place(delta)
		else:
			jump_in_motion(delta)

	if is_on_floor() and not is_jumping:
		rotation_on_jump = 0.0  # Reset rotation during jump when on the floor
		pivot.rotation.x = 0.0  # Reset pivot rotation when on the floor
		current_x_rotation = 0.0  # Reset current X rotation
		target_x_rotation = 0.0  # Reset target X rotation

func jump_in_place(delta):
	if rotation_on_jump < 360.0:
		rotation_on_jump += rotation_speed * delta  # Increase rotation during jump
		pivot.rotation.x += -deg_to_rad(rotation_speed * delta)  # Rotate pivot during jump
	else:
		is_jumping = false  # Reset jumping flag
		rotation_on_jump = 0.0  # Reset rotation during jump
		pivot.rotation.x = 0.0  # Reset pivot rotation after jump

func jump_in_motion(delta):
	if rotation_on_jump < 360.0:
		rotation_on_jump += rotation_speed * delta  # Increase rotation during jump

		if Input.is_action_pressed("move_left") and Input.is_action_pressed("jump"):
			target_x_rotation = current_x_rotation + deg_to_rad(180)
		elif Input.is_action_pressed("move_right") and Input.is_action_pressed("jump"):
			target_x_rotation = current_x_rotation + deg_to_rad(180)
		elif Input.is_action_pressed("move_up") and Input.is_action_pressed("jump"):
			target_x_rotation = current_x_rotation + deg_to_rad(180)
		elif Input.is_action_pressed("move_down") and Input.is_action_pressed("jump"):
			target_x_rotation = current_x_rotation + deg_to_rad(180)

		current_x_rotation = lerp_angle(current_x_rotation, target_x_rotation, delta * smooth_speed)
		pivot.rotation.x = current_x_rotation
	else:
		is_jumping = false  # Reset jumping flag
		rotation_on_jump = 0.0  # Reset rotation during jump
		pivot.rotation.x = 0.0  # Reset pivot rotation after jump

func flip(direction):
	target_y_rotation = atan2(-direction.x, -direction.z)  # Calculate target Y-axis rotation based on direction
