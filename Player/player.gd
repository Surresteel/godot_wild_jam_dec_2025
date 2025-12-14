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
	
	move_and_slide()




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
