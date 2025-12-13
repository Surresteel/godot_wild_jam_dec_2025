extends Node3D

@onready var cannon_rack: MeshInstance3D = $"Mesh/Cannon Rack"
@onready var wheels_front: MeshInstance3D = $"Mesh/Cannon Rack/Wheels/Wheel Jointer Front"
@onready var wheels_back: MeshInstance3D = $"Mesh/Cannon Rack/Wheels/Wheel Joiner Back"
@onready var cannon_barrel: MeshInstance3D = $"Mesh/Cannon Rack/Barrel/Cannon Barrel"
@onready var camera: Camera3D = $Camera3D

const CANNONBALL = preload("uid://jifqhmqqi4ym")

@export_category("Stats")
@export var rotation_speed: float = 1.0
@export var max_power: float = 100.0
var current_power: float = 0.0
@onready var power_timer: Timer = $PowerTimer

var projectile_Offset := Vector3(0,0,-0.9).length()
var is_active: bool = false

@export_category("TurnAngle")
@onready var initial_angle:Vector3 = rotation
@export var max_angle_y: float = 28.0
@export var min_angle_x: float = -6.0
@export var max_angle_x: float = 10.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_active:
		var new_rotation: Vector2
		var new_rotation_x: float = -event.screen_relative.y * rotation_speed * get_process_delta_time()
		var new_rotation_y: float = -event.screen_relative.x * rotation_speed * get_process_delta_time()
		cannon_barrel.rotation_degrees.x = clampf(cannon_barrel.rotation_degrees.x + new_rotation_x,min_angle_x,max_angle_x)
		cannon_rack.rotation_degrees.y = clampf(cannon_rack.rotation_degrees.y + new_rotation_y,-max_angle_y,max_angle_y)
	
	if event is InputEvent and is_active:
		if event.is_action_pressed("Main Action"):
			power_timer.start()
			print("timer start")
		if event.is_action_released("Main Action"):
			var local_offset: Vector3 = -cannon_barrel.global_basis.z * projectile_Offset
			var new_cannonball: RigidBody3D = CANNONBALL.instantiate()
			get_tree().get_root().add_child(new_cannonball)
			new_cannonball.global_position = cannon_barrel.global_position + local_offset
			if power_timer.is_stopped():
				current_power = max_power
			else:
				current_power = lerpf(5,max_power,1 - (power_timer.time_left / power_timer.wait_time))
			new_cannonball.fire(current_power,-cannon_barrel.global_basis.z)
			print(current_power)
		
