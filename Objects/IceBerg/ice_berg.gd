extends RigidBody3D

var boat : RigidBody3D
var speed := 5.0


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var dir := position.direction_to(boat.position)
	state.apply_central_force((dir * speed + boat.linear_velocity * 0.5))
	


func OnCollision(body: Node) -> void:
	print("Im an Iceberg and i hit ", str(body))
	boat.apply_impulse(basis * Vector3(0,0,-500), global_position)
	queue_free()
