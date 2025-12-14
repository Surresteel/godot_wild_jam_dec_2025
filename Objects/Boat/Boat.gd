extends RigidBody3D



func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	state.linear_velocity = -state.transform.basis.z * 5
	Singletons.boat_velocity = state.linear_velocity

func takeHit(_body: Node) -> void:
	pass
