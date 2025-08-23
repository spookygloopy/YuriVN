extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var standing_collision: CollisionShape3D = $standing_collision
@onready var crouch_collision: CollisionShape3D = $crouch_collision
@onready var ray_cast_3d: RayCast3D = $RayCast3D



var current_speed = 5.0
const jump_velocity = 4.5

const walk_speed = 5.0
const sprint_speed = 11.0
const crouch_speed = 2.0

const mouse_sens = .3

var lerp_speed = 10

var direction = Vector3.ZERO 
var crouch_depth = -0.3
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("crouch"):
		current_speed = crouch_speed
		head.position.y = lerp(head.position.y,1.8 + crouch_depth, delta *lerp_speed)
		standing_collision.disabled = true 
		crouch_collision.disabled = false
	elif !ray_cast_3d.is_colliding():
		standing_collision.disabled = false
		crouch_collision.disabled = true
		
		head.position.y = lerp(head.position.y,1.8, delta *lerp_speed)
		if Input.is_action_pressed("sprint"):
			current_speed = sprint_speed
			
		else: 
			current_speed = walk_speed
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
