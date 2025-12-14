extends RigidBody3D

var boat : Node3D
var speed := 5.0


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var dir := position.direction_to(boat.position)
	state.apply_central_force((dir * speed + Singletons.boat_velocity))

#func _process(_delta: float) -> void:
	#var dir := position.direction_to(boat.position)
	#apply_central_force(dir * speed)


func OnCollision(body: Node) -> void:
	print("Im an Iceberg and i hit ", str(body))
	await get_tree().create_timer(0.1).timeout
	queue_free()
