extends RigidBody3D

func _physics_process(delta: float) -> void:
	linear_velocity.z = -5

func takeHit(_body: Node) -> void:
	pass
