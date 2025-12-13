extends Node3D

@export var boat : Node3D

const ICE_BERG = preload("uid://c6ieiq6giwbp8")


func _process(delta: float) -> void:
	global_rotation = Vector3.ZERO

func _on_timer_timeout() -> void:
	var new_ice_berg = ICE_BERG.instantiate()
	new_ice_berg.boat = boat
	
	var x = randf_range(-20,20)
	var z = randf_range(-20,20)
	new_ice_berg.position = position + Vector3(x + (sign(x) * 10),0,z + (sign(z) * 10),)
	get_tree().get_root().add_child(new_ice_berg)
	
