extends RigidBody3D

var boat : RigidBody3D
var speed := 50.0


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var dir := position.direction_to(boat.position)
	state.apply_central_force((dir * speed + boat.linear_velocity))
	


func OnCollision(body: Node) -> void:
	print("Im an Iceberg and i hit ", str(body))
	boat.apply_impulse(basis * Vector3(0,0,-500), global_position)
	await get_tree().create_timer(0.1).timeout
	queue_free()
