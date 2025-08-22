extends CharacterBody3D

@onready var camera: Camera3D = %Camera3D


const SPEED: float = 15.
const JUMP_VELOCITY: float = 4.5

const ROTATE_FACTOR: float = 500.
const ROTATE_SPEED: float = 300.
const ROTATE_CLAMP: float = 1.5
#const ROTATE_VERTICAL

func _physics_process(delta: float) -> void:
	_handle_rotation()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	
func _handle_rotation() -> void:
	var vertical_rotation_raw: float = deg_to_rad(-MouseCanvas.mouse_relative.y/ROTATE_FACTOR * ROTATE_SPEED)
	var horizontal_rotation_raw: float = deg_to_rad(-MouseCanvas.mouse_relative.x/ROTATE_FACTOR * ROTATE_SPEED)
	
	var horizontal_rotation: float = horizontal_rotation_raw
	var vertical_rotation: float = vertical_rotation_raw
	
	global_rotation.y = horizontal_rotation #Horizontal rotation	
	camera.global_rotation.x = clamp(vertical_rotation, #Vertical rotation (camera)
	
	print(vertical_rotation)
