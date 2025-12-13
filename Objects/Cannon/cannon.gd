extends Node3D

@onready var cannon_rack: MeshInstance3D = $"Mesh/Cannon Rack"
@onready var wheels_front: MeshInstance3D = $"Mesh/Cannon Rack/Wheels/Wheel Jointer Front"
@onready var wheels_back: MeshInstance3D = $"Mesh/Cannon Rack/Wheels/Wheel Joiner Back"
@onready var cannon_barrel: MeshInstance3D = $"Mesh/Cannon Rack/Barrel/Cannon Barrel"
@onready var camera: Camera3D = $Camera3D

const CANNONBALL = preload("uid://jifqhmqqi4ym")

@export_category("Stats")
@export var max_power: float = 100.0
@export var rotation_speed: float = 1.0

var projectile_Offset := Vector3(0,0,-0.9).length()
var is_active: bool = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_active:
		cannon_rack.rotate_y(-event.screen_relative.x * rotation_speed * get_process_delta_time())
		cannon_barrel.rotate_x(-event.screen_relative.y * rotation_speed * get_process_delta_time())
	
	if event is InputEvent and is_active:
		if event.is_action_pressed("Main Action"):
			var local_offset: Vector3 = -cannon_barrel.global_basis.z * projectile_Offset
			var new_cannonball: RigidBody3D = CANNONBALL.instantiate()
			get_tree().get_root().add_child(new_cannonball)
			new_cannonball.global_position = cannon_barrel.global_position + local_offset
			new_cannonball.fire(max_power,-cannon_barrel.global_basis.z)
		
