extends CharacterBody3D
class_name Player

@export_category("Controller Values")
@export var speed := 5.0
var inertia: Vector3 = Vector3.ZERO
var is_interacting: bool = false
var was_on_floor: bool = false
var floor_velocity: Vector3

@onready var camera: Camera3D = $Camera3D

signal Interact

# Buoyancy PID controller:
const KP := 20.0
const KI := 2.0
const KD := 8.0
var integral := 0.0
var last_error := 0.0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta: float) -> void:
	camera.position = position + camera.pos
	
	if is_interacting:
		return
	
	camera.rotate_camera_x()
	rotation_degrees.y += camera.mouse_input.y
	camera.rotation_degrees.y = rotation_degrees.y
	camera.mouse_input = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	if is_on_floor():
		floor_velocity = get_platform_velocity()
		was_on_floor = true
		velocity -= inertia
		inertia = Vector3.ZERO
		if Input.is_action_just_pressed("jump"):
			velocity.y += 5
	elif was_on_floor:
		inertia = floor_velocity
		was_on_floor = false
	else:
		velocity.y += get_gravity().y * delta
	
	
	var input_dir: Vector2 = Input.get_vector("left","right","forward","backward")
	var dir: Vector3 = (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
	
	if dir and not is_interacting:
		velocity.x = dir.x * speed + inertia.x
		velocity.z = dir.z * speed + inertia.z
		
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, delta * 69)
		velocity.z = move_toward(velocity.z, 0.0, delta * 69)
	else:
		velocity.x = move_toward(velocity.x, 0.0, delta * 1)
		velocity.z = move_toward(velocity.z, 0.0, delta * 1)
	
	
	_handle_buoyancy(delta)
	
	move_and_slide()


# Handles buoyancy forces when the player is in the water:
func _handle_buoyancy(delta: float) -> void:
	var data := Vector3(global_position.x, global_position.z, 
				(Time.get_ticks_msec() / 1000.0))
	var water_height = NoiseFunc.sample_at_pos_time(data)
	
	if global_position.y < water_height:
		var error = water_height - global_position.y
		integral += error * delta
		var derivative = (error - last_error) / delta
		last_error = error
		
		var output = KP * error + KI * integral + KD * derivative
		velocity.y += output * delta


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		emit_signal("Interact")

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
				if event.keycode == KEY_ESCAPE:
					get_tree().quit()
				if event.keycode == KEY_TAB:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
