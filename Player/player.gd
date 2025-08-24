extends CharacterBody3D

signal sprint_triggered(sprint_trigger: bool)

@export var walk_speed: float = 11.0
@export var sprint_speed: float = 16.0
@export var jump_strength: float = 20.0
@export var gravity: float = 50.0
@export var mouse_sensitivity: float = 0.1

var sprinting := false
var dir := Vector3.ZERO
var invert_y := false

# Mouse rotation
var yaw: float = 0.0
var pitch: float = 0.0
@onready var head = $Head  # Head is the node that pitches (vertical aim)

func _ready():
	print("ready")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity * (1 if not invert_y else -1)
		pitch = clamp(pitch, -90, 90)

		rotation_degrees.y = yaw
		head.rotation_degrees.x = pitch

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
		if not Input.is_action_pressed("jump"):
			velocity.y -= gravity * delta * 0.5

	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength

	# Directional input
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Sprint toggle
	sprinting = Input.is_action_pressed("sprint")
	emit_signal("sprint_triggered", sprinting)

	var speed := sprint_speed if sprinting else walk_speed
	var accel := 15.0 if dir.is_zero_approx() else 5.0
	velocity.x = lerpf(velocity.x, dir.x * speed, 1.0 - exp(-accel * delta))
	velocity.z = lerpf(velocity.z, dir.z * speed, 1.0 - exp(-accel * delta))

	move_and_slide()
