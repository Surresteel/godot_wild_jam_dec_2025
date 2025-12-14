extends RigidBody3D

func onHit() -> void:
	await get_tree().create_timer(0.1).timeout


func fire(power: float, dir: Vector3) -> void:
	linear_velocity = Singletons.boat_velocity
	apply_central_impulse(dir * power)
	await get_tree().create_timer(5).timeout
