extends RigidBody3D

func onHit() -> void:
	await get_tree().create_timer(0.1).timeout


func fire(power: float, dir: Vector3) -> void:
	linear_velocity = Vector3(0,0,-5) #TODO set Vector3 to ship velocity
	apply_central_impulse(dir * power)
	await get_tree().create_timer(5).timeout
