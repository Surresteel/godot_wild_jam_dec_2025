extends SealionBaseState
class_name CirclingSealionState

var speed:= 10.0
var swimming_distance: float = 50.0
var swimming_distance_drain_speed:= 2.0
var clockwise:bool = false

func enter(_sealion: Sealion) -> void:
	print("circling")
	swimming_distance = randf_range(25, 80)
	swimming_distance_drain_speed = randf_range(1, 3)
	clockwise = randi() % 2

func exit(sealion: Sealion) -> void:
	sealion.velocity = Vector3.ZERO

func pre_update(sealion: Sealion) -> void:
	if swimming_distance <= 20:
		var dir_to_ship:= sealion.global_position.direction_to(sealion.ship.global_position)
		sealion.dot_sealion_to_ship = abs(dir_to_ship.dot(-sealion.ship.global_basis.z))
		#Back to Front = 0 to +- 180, from the second mast
		if sealion.dot_sealion_to_ship < 0.5:
			sealion.change_state(SealionStates.BOARDING)

func update(sealion: Sealion, delta) -> void:
	if swimming_distance > 20:
		swimming_distance -= delta * swimming_distance_drain_speed
	
	
	var nextpoint:= get_next_pos(sealion,sealion.ship.global_position)
	nextpoint.y = sealion.global_position.y
	#print(nextpoint)
	#set velocity
	var dir = nextpoint - sealion.global_position
	sealion.velocity.x = move_toward(sealion.velocity.x, dir.x + sealion.ship.linear_velocity.x, 4 * delta)
	sealion.velocity.z = move_toward(sealion.velocity.z, dir.z + sealion.ship.linear_velocity.z, 4 * delta)
	
	#Turn Towards Target
	var radians_to_turn: float = atan2(-dir.x, -dir.z)
	var turn_amount = lerp_angle(sealion.global_rotation.y, radians_to_turn, 7 * delta)
	sealion.global_rotation.y = turn_amount


func get_next_pos(sealion: Sealion, target: Vector3) -> Vector3:
	var to_point := sealion.global_position - target
	var dir := to_point.normalized()
	
	# Calculate next waypoint in orbit:
	var to_point_next: Vector3
	if true:
		to_point_next = dir.rotated(Vector3.UP, 0.2)
	else:
		to_point_next = dir.rotated(Vector3.UP, -0.2)
	
	# Go to waypoint:
	var point_next := target + to_point_next * swimming_distance
	
	return point_next
