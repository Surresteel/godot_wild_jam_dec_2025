class_name CannonBall
extends RigidBody3D

var _has_hit_water: bool = false
static var scene_splash := preload("res://Particle_Effects/splash.tscn")

func onHit() -> void:
	await get_tree().create_timer(0.1).timeout


func fire(power: float, dir: Vector3, initial_velocity: Vector3) -> void:
	linear_velocity = initial_velocity
	apply_central_impulse(dir * power)


func _physics_process(_delta: float) -> void:
	if _has_hit_water:
		return
	
	var data := Vector3(global_position.x, global_position.z, 
				(Time.get_ticks_msec() / 1000.0))
	var water_height = NoiseFunc.sample_at_pos_time(data)
	
	if global_position.y <= water_height:
		var splash: Node3D = scene_splash.instantiate()
		get_tree().get_root().add_child(splash)
		splash.global_position = global_position
		_has_hit_water = true
