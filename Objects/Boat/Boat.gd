extends RigidBody3D

func _physics_process(delta: float) -> void:
	linear_velocity.z = -500 * delta
	Singletons.boat_velocity = linear_velocity

func takeHit(_body: Node) -> void:
	pass
