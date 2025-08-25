class_name Player extends CharacterBody3D

static var ref: CharacterBody3D


var waiting: bool = false

@onready var camera: Camera3D = %Camera3D

const SPEED: float = 15.
const JUMP_VELOCITY: float = 4.5

const ROTATE_FACTOR: float = 50.
const ROTATE_SPEED: float = 1.
const ROTATE_CLAMP: float = 1.5
const ROTATE_VERTICAL_CLAMP: float = .65

var is_fishing: bool = false
var game_over: bool = false
var in_house: bool = false

var can_fish: bool = false
var current_node: Area3D = null

@onready var mesh: MeshInstance3D = $MeshInstance3D

func _init() -> void:
	ref = self
	
func _ready() -> void:
	mesh.visible =false

func _input(_event: InputEvent) -> void:
	if not waiting and can_fish and Input.is_action_just_pressed("Action"):
		if not current_node == null:
			is_fishing = true
			current_node.fishing_state(true)

func _physics_process(delta: float) -> void:
	if not is_fishing:
		_handle_movement(delta)
	
func _handle_movement(delta:float) -> void:
	if not game_over:
		if not in_house:
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

func rotate_player(mouse_pos:Vector2) -> void:
	var vertical_rotation_deg: float = deg_to_rad(-mouse_pos.y * ROTATE_SPEED/4.)
	var horizontal_rotation_deg: float = deg_to_rad(-mouse_pos.x * ROTATE_SPEED/4.)
	
	var horiz_rotation: float = global_rotation.y + horizontal_rotation_deg
	global_rotation.y = lerp(global_rotation.y,horiz_rotation,1.)
	
	var vert_rotation: float = camera.global_rotation.x + vertical_rotation_deg
	camera.global_rotation.x = lerp(camera.global_rotation.x,vert_rotation,1.)
