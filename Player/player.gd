extends CharacterBody3D
class_name Player

@export var speed := 10.0
var is_interacting: bool = false

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
		if Input.is_action_just_pressed("jump"):
			velocity.y += 5
	else:
		velocity.y += get_gravity().y * delta
	
	var input_dir: Vector2 = Input.get_vector("left","right","forward","backward")
	var dir: Vector3 = (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()
	
	if dir and not is_interacting:
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
	elif is_on_floor():
		velocity.x = move_toward(velocity.x,0.0, 0.8)
		velocity.z = move_toward(velocity.z,0.0, 0.8)
	
	
	move_and_slide()





func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		emit_signal("Interact")

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
