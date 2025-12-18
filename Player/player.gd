extends CharacterBody3D
class_name Player

@export_category("Controller Values")
@export var speed := 5.0
var inertia: Vector3 = Vector3.ZERO
var floor_velocity: Vector3

#state machine variables
@onready var state_machine: PlayerStateMachine = $StateMachine

var is_interacting: bool = false

@onready var camera: Camera3D = $Camera3D
@onready var mesh: MeshInstance3D = $P_Generic_Static

@export var target: Node3D

#ship stuff
@export var ship: Ship
var ship_last_rotation_y: float

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
	
	if state_machine.current_state == state_machine.state.INTERACTING:
		return
	
	camera.rotate_camera_x()
	rotation_degrees.y += camera.mouse_input.y
	camera.rotation_degrees.y = rotation_degrees.y
	camera.mouse_input = Vector2.ZERO

func _physics_process(delta: float) -> void:
	_handle_buoyancy(delta)
	#print(ship.angular_velocity)
	move_and_slide()
	
	if Input.is_action_just_pressed("interact"):
		emit_signal("Interact")
		#if works, sets is_interacting to true


# Handles buoyancy forces when the player is in the water:
func _handle_buoyancy(delta: float) -> void:
	var data := Vector3(global_position.x, global_position.z, 
				(Time.get_ticks_msec() / 1000.0))
	var water_height = NoiseFunc.sample_at_pos_time(data)
	
	if global_position.y - 0.1 < water_height:
		var error = water_height - (global_position.y - 0.1)
		integral += error * delta
		var derivative = (error - last_error) / delta
		last_error = error
		
		var output = KP * error + KI * integral + KD * derivative
		velocity.y += output * delta

func get_water_height() -> float:
	var data := Vector3(global_position.x, global_position.z, 
			(Time.get_ticks_msec() / 1000.0))
	return NoiseFunc.sample_at_pos_time(data)


func get_ship_velocity() -> Vector3:
	var ship_velocity = ship.linear_velocity
	
	return Vector3(ship_velocity.x, 0 ,ship_velocity.z)

func rotate_with_ship(lerp_ratio: float) -> void:
	#player.rotation.x = ship_rotation.x
	#player.rotation.z = ship_rotation.z
	var ship_rotated_amount: float = ship.rotation.y - ship_last_rotation_y
	if absf(ship_rotated_amount) * 1000 > 1 and absf(ship_rotated_amount) * 1000 < 50: 
		rotation.y += move_toward(0, ship_rotated_amount, lerp_ratio)       # 50 since sometimes the -
		#print(ship_rotated_amount * 1000)                                  #-amount is >6000, idk why.
																			# and rotations over 50 are -
																			#-too much probably
	
	ship_last_rotation_y = ship.rotation.y

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
				if event.keycode == KEY_ESCAPE:
					get_tree().quit()
				if event.keycode == KEY_TAB:
					if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
						Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
					else:
						Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				if event.keycode == KEY_R:
					get_tree().reload_current_scene()
