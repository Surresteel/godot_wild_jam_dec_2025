extends Node3D
class_name SnowballAction

const SNOWBALL = preload("uid://pj5t3u2p6vi2")

signal signal_animation(anim_name: StringName)
signal signal_throw()
signal cannon_reload
signal player_reload

var ammo: int = 3
var snowball_ready: bool = true
@export var power: float = 5

var throw_direction: Vector3

var last_pos: Vector3 = Vector3.ZERO
var velocity: Vector3


func _process(delta: float) -> void:
	velocity = (global_position - last_pos ) / delta
	last_pos = global_position


func _spawn_snowball() -> RigidBody3D:
	#var local_offset: Vector3 = -cannon_barrel.global_basis.z * projectile_Offset
	var new_snowball: RigidBody3D = SNOWBALL.instantiate()
	
	get_tree().current_scene.add_child(new_snowball)
	new_snowball.freeze = true
	new_snowball.global_position = global_position#cannon_barrel.global_position + local_offset
	new_snowball.freeze = false
	return new_snowball

func throw_snowball() -> void:
	if ammo <= 0 or not snowball_ready:
		return
	signal_animation.emit("P_FPArms__Snowball_Throw")
	signal_throw.emit()
	ammo -= 1
	snowball_ready = false

func _fire_snowball() -> void:
	var new_snowball:= _spawn_snowball()
	new_snowball.fire(power, -global_basis.z, velocity)

func reload() -> void:
	if ammo < 3:
		ammo = 3
		player_reload.emit()

func _ready_snowball() -> void:
	snowball_ready = true
	if ammo > 0:
		signal_animation.emit("P_FPArms__Snowball_Equip")


func reload_cannon() -> void:
	if ammo > 0:
		cannon_reload.emit()
		ammo -= 1
