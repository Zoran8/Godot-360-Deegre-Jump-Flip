extends CharacterBody3D  # Inherits the CharacterBody3D class to create a 3D character controller

@export var max_speed = 20  # Maximum speed of the character
@export var gravity = 70  # Gravity affecting the character
@export var jump_impulse = 18  # Initial impulse when the character jumps
@export var rotation_speed = 750.0  # Rotation speed, must be a float value
@export var smooth_speed = 5.0  # Variable for smooth rotation

@onready var pivot = $Pivot  # Gets reference to the Pivot node

var is_jumping = false  # Is the character currently jumping
var rotation_on_jump = 0.0  # Current rotation during jump
var facing_right = true  # Is the character facing right

# Added variables for smooth rotation
var current_y_rotation = 0.0  # Current Y-axis rotation of the pivot
var target_y_rotation = 0.0  # Target Y-axis rotation for the pivot

# Variables for smooth X-axis rotation during jump
var current_x_rotation = 0.0  # Current X-axis rotation of the pivot
var target_x_rotation = 0.0  # Target X-axis rotation for the pivot

func _ready():
	# Sets the pivot to initially face the X-axis
	pivot.look_at(position + Vector3(1, 0, 0), Vector3.UP)
	current_y_rotation = pivot.rotation.y  # Initialize current rotation
	target_y_rotation = pivot.rotation.y  # Initialize target rotation
	current_x_rotation = pivot.rotation.x  # Initialize current rotation on X-axis
	target_x_rotation = pivot.rotation.x  # Initialize target rotation on X-axis

func _physics_process(delta):
	var input_vector = get_input_vector()  # Gets input vector
	apply_movement(input_vector, delta)  # Applies movement based on input vector
	apply_gravity(delta)  # Applies gravity to the character
	jump(delta)  # Processes jump logic
	set_velocity(velocity)  # Sets the character's velocity
	set_up_direction(Vector3.UP)  # Sets the up direction to be the world's up direction
	move_and_slide()  # Moves and slides the character based on its velocity

func get_input_vector():
	var input_vector = Vector3.ZERO  # Initializes input vector to zero
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")  # Gets horizontal input
	input_vector.z = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")  # Gets vertical input
	return input_vector.normalized()  # Normalizes the input vector

func apply_movement(input_vector, delta):
	velocity.x = input_vector.x * max_speed  # Sets horizontal velocity
	velocity.z = input_vector.z * max_speed  # Sets vertical velocity

	if input_vector != Vector3.ZERO:
		pivot.look_at(position + input_vector, Vector3.UP)  # Rotates pivot to face the direction of movement
		flip(input_vector)  # Flips the character based on movement direction

	# Calls function for smooth rotation
	smooth_rotate_y(delta)

func apply_gravity(delta):
	velocity.y -= gravity * delta  # Applies gravity to vertical velocity

func jump(delta):
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		is_jumping = true  # Sets jumping flag
		velocity.y = jump_impulse  # Applies jump impulse

	if is_jumping:
		if get_input_vector() == Vector3.ZERO:
			jump_in_place(delta)
		else:
			jump_in_motion(delta)

	if is_on_floor() and not is_jumping:
		rotation_on_jump = 0.0  # Resets jump rotation when on the ground
		pivot.rotation.x = 0.0  # Resets pivot rotation when on the ground
		current_x_rotation = 0.0  # Resets current rotation
		target_x_rotation = 0.0  # Resets target rotation

func jump_in_place(delta):
	if rotation_on_jump < 360.0:
		rotation_on_jump += rotation_speed * delta  # Increases rotation during jump
		pivot.rotation.x += -deg_to_rad(rotation_speed * delta)  # Rotates pivot during jump
	else:
		is_jumping = false  # Resets jumping flag
		rotation_on_jump = 0.0  # Resets jump rotation
		pivot.rotation.x = 0.0  # Resets pivot rotation after jump

func jump_in_motion(delta):
	if rotation_on_jump < 360.0:
		rotation_on_jump += rotation_speed * delta  # Increases rotation during jump

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
		is_jumping = false  # Resets jumping flag
		rotation_on_jump = 0.0  # Resets jump rotation
		pivot.rotation.x = 0.0  # Resets pivot rotation after jump

func flip(direction):
	target_y_rotation = atan2(-direction.x, -direction.z)  # Calculates target Y-axis rotation based on direction

func smooth_rotate_y(delta):
	current_y_rotation = lerp_angle(current_y_rotation, target_y_rotation, delta * smooth_speed)  # Smoothly rotates to target Y-axis rotation
	pivot.rotation.y = current_y_rotation  # Applies current Y-axis rotation to pivot
