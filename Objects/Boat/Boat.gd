extends RigidBody3D


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if abs(state.linear_velocity.length()) < abs(50):
		state.apply_central_force(-state.transform.basis.z * 500)
		print(state.linear_velocity)
		
	Singletons.boat_velocity = state.linear_velocity

func takeHit(_body: Node) -> void:
	pass
