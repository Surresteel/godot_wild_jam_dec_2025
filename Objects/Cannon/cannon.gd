extends Node3D
class_name Cannon

@onready var cannon_rack: MeshInstance3D = $"Mesh/Cannon Rack"
@onready var wheels_front: MeshInstance3D = $"Mesh/Cannon Rack/Wheels/Wheel Jointer Front"
@onready var wheels_back: MeshInstance3D = $"Mesh/Cannon Rack/Wheels/Wheel Joiner Back"
@onready var cannon_barrel: MeshInstance3D = $"Mesh/Cannon Rack/Barrel/Cannon Barrel"

@onready var camera_positon: Node3D = $"Mesh/Cannon Rack/Barrel/Cannon Barrel/Camera_positon"

const CANNONBALL = preload("uid://jifqhmqqi4ym")

var player: Player
@onready var cannon_interact: CannonInteract = $CannonInteract
@onready var animation_player: AnimationPlayer = $"Mesh/Cannon Rack/Barrel/Cannon Barrel/AnimationPlayer"
@onready var animaiton_mesh_parent: Node3D = $"Mesh/Cannon Rack/Barrel/Cannon Barrel/FPArms"

@export_category("Stats")
@export var rotation_speed: float = 2.0
@export var max_power: float = 30.0
var current_power: float = 0.0
@onready var power_timer: Timer = $PowerTimer
@export_range(0.5, 10, 0.5, "suffix:Seconds") var charge_time: float = 1.5

var projectile_Offset := Vector3(0,0,-1).length()
var last_pos: Vector3
var Velocity: Vector3
var is_active: bool = false
var reloaded: bool = true

@export_category("TurnAngle")
@onready var initial_angle:Vector3 = rotation
@export var max_angle_y: float = 28.0
@export var min_angle_x: float = -6.0
@export var max_angle_x: float = 10.0


signal cannon_exit(pos: Vector3, rot: Vector3)

func activate() -> void:
	is_active = true
	animaiton_mesh_parent.visible = true

func deactivate() -> void:
	is_active = false
	animaiton_mesh_parent.visible = false                      #Player Height
	cannon_exit.emit(0.65 * global_basis.z + global_position,
			 global_rotation)

func _ready() -> void:
	power_timer.wait_time = charge_time
	last_pos = global_position
	
	cannon_interact.cannon = self
	
	animation_player.play(&"Cannon/P_FPArms_Cannon_Idle")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_active:
		var new_rotation_x: float = -event.screen_relative.y * rotation_speed * get_process_delta_time()
		var new_rotation_y: float = -event.screen_relative.x * rotation_speed * get_process_delta_time()
		cannon_barrel.rotation_degrees.x = clampf(cannon_barrel.rotation_degrees.x + new_rotation_x,min_angle_x,max_angle_x)
		cannon_rack.rotation_degrees.y = clampf(cannon_rack.rotation_degrees.y + new_rotation_y,-max_angle_y,max_angle_y)

func _physics_process(delta: float) -> void:
	if is_active:
		
		##camera_positon shenanigans
		#camera_positon.position = camera_positon.position.move_toward(Vector3.ZERO, delta * 2)
		#camera_positon.rotation = camera_positon.rotation.slerp(Vector3.ZERO, delta * 5)
		
		Velocity = (global_position - last_pos) / delta
		last_pos = global_position
		
		#check if reloaded on each if, maybe looks nicer doubt it matters
		if Input.is_action_just_pressed("Main Action") and reloaded:
			power_timer.start()
			
		if Input.is_action_just_released("Main Action") and reloaded:
			var new_cannonball = instance_new_cannonball()
			shoot(new_cannonball)
			reloaded = false
		
		#if is_active then player shouldnt be null
		if Input.is_action_just_pressed("Reload"):
			reload_start()

func instance_new_cannonball() -> CannonBall:
	var local_offset: Vector3 = -cannon_barrel.global_basis.z * projectile_Offset
	var new_cannonball: RigidBody3D = CANNONBALL.instantiate()
	
	get_tree().get_root().add_child(new_cannonball)
	new_cannonball.freeze = true
	new_cannonball.global_position = cannon_barrel.global_position + local_offset
	new_cannonball.rotate_x(randf() * TAU)
	new_cannonball.rotate_y(randf() * TAU)
	new_cannonball.freeze = false
	return new_cannonball

func shoot(new_cannonball: RigidBody3D) -> void:
	if power_timer.is_stopped():
		current_power = max_power
	else:
		current_power = lerpf(5, max_power, #Min-Max Power based on powertimer
				 1 - (power_timer.time_left / power_timer.wait_time))
	new_cannonball.fire(current_power, -cannon_barrel.global_basis.z, Velocity)
	
	power_timer.stop()

func reload_start() -> void:
	if not reloaded:
		animation_player.play(&"Cannon/P_FPArms_Cannon_Reload")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"Cannon/P_FPArms_Cannon_Reload":
		reloaded = true
		animation_player.play(&"Cannon/P_FPArms_Cannon_Idle")
