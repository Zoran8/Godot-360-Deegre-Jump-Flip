extends CharacterBody3D

@export var max_speed = 20 # Maximum speed of the character
@export var gravity = 70 # Gravity force applied to the character
@export var jump_impulse = 18 # Impulse force for jumping
@export var rotation_speed = 750 # Speed of rotation during the jump

@onready var pivot = $Pivot # Reference to the Pivot node

var is_jumping = false # Flag to track if the character is jumping
var rotation_on_jump = 0.0 # Rotation angle during the jump
var facing_right = true # Flag to track the direction the character is facing

func _ready():
	# Set the pivot to initially face the X axis
	pivot.look_at(position + Vector3(1, 0, 0), Vector3.UP)

func _physics_process(delta):
	var input_vector = get_input_vector() # Get input vector for movement
	apply_movement(input_vector) # Apply movement based on input
	apply_gravity(delta) # Apply gravity to the character
	jump(delta) # Handle jumping
	set_velocity(velocity) # Set the velocity of the character
	set_up_direction(Vector3.UP) # Set the up direction for the character
	move_and_slide() # Move the character and handle collisions

func get_input_vector():
	var input_vector = Vector3.ZERO # Initialize the input vector to zero
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left") # Get X axis input
	
	 
	return input_vector.normalized() # Normalize the input vector

func apply_movement(input_vector):
	velocity.x = input_vector.x * max_speed # Set velocity on the X axis
	

	if input_vector != Vector3.ZERO:
		pivot.look_at(position + input_vector, Vector3.UP) # Rotate the pivot to look in the direction of movement
		flip(input_vector) # Flip the character based on the movement direction

func apply_gravity(delta):
	velocity.y -= gravity * delta # Apply gravity to the character

func jump(delta):
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		is_jumping = true # Set jumping flag
		velocity.y = jump_impulse # Apply jump impulse to the Y velocity

	if is_jumping and rotation_on_jump < 360.0:
		rotation_on_jump += rotation_speed * delta # Increase the rotation angle during the jump
		pivot.rotation.x -= deg_to_rad(rotation_speed * delta) # Rotate around the X axis during the jump
		
	else:
		is_jumping = false # Reset jumping flag
		rotation_on_jump = 0.0 # Reset rotation angle
		pivot.rotation.x = 0.0 # Reset rotation after the jump

	if is_on_floor() and not is_jumping:
		rotation_on_jump = 0.0 # Reset rotation angle if on the floor and not jumping
		pivot.rotation.x = 0.0 # Reset rotation

func flip(direction):
	if direction.x > 0 and not facing_right:
		facing_right = true # Set facing right flag
		pivot.rotation.y = 0 # Set pivot rotation to 0 degrees
	elif direction.x < 0 and facing_right:
		facing_right = false # Set facing left flag
		pivot.rotation.y = deg_to_rad(180) # Set pivot rotation to 180 degrees
	elif direction.z > 0:
		pivot.rotation.y = deg_to_rad(180) # Set pivot rotation to 180 degrees for forward movement
	elif direction.z < 0:
		pivot.rotation.y = deg_to_rad(0) # Set pivot rotation to 0 degrees for backward movement
