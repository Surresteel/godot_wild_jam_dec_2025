extends Node3D

@export var boat : RigidBody3D

const ICE_BERG = preload("uid://c6ieiq6giwbp8")


func _process(_delta: float) -> void:
	global_rotation = Vector3.ZERO

func _on_timer_timeout() -> void:
	var new_ice_berg: Node3D = ICE_BERG.instantiate()
	new_ice_berg.boat = boat
	
	var x := randf_range(-20,20)
	var z := randf_range(-5,5)
	get_tree().get_root().add_child(new_ice_berg)
	new_ice_berg.global_position = global_position + Vector3(x + (sign(x) * 50),0,z)
	
