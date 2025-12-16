extends SealionBaseState
class_name CirclingSealionState

var speed:= 10.0
var swimming_distance: float = 50.0
var swimming_distance_drain_speed:= 2.0

func enter(_sealion: Sealion) -> void:
	swimming_distance = randf_range(25, 80)

func exit(sealion: Sealion) -> void:
	sealion.velocity = Vector3.ZERO

func pre_update(sealion: Sealion) -> void:
	if swimming_distance <= 20:
		var dir_from_ship:= sealion.ship.global_position.direction_to(sealion.global_position)
		var angle_from_ship_degrees = rad_to_deg(atan2(dir_from_ship.x,dir_from_ship.z))
		#Back to Front = 0 to +- 180, from the second mast
		if abs(angle_from_ship_degrees) >= 90 and abs(angle_from_ship_degrees) <= 130:
			sealion.change_state(SealionStates.BOARDING)

func update(sealion: Sealion, delta) -> void:
	#get the next 15degree angle from the ship and close the distance
	sealion.change_target_pos(get_next_circling_point(sealion))
	swimming_distance -= delta * swimming_distance_drain_speed
	
	#Move The Sealion towards it's target
	var dir: Vector3 = (Vector3(sealion.target_pos.x, 0 ,sealion.target_pos.z)
						- Vector3(sealion.global_position.x, 0 ,sealion.global_position.z))
	dir = dir.normalized()
	
	var target_speed := sealion.ship.linear_velocity
	
	if dir:
		#set velocity
		sealion.velocity.x = move_toward(sealion.velocity.x, dir.x * speed + target_speed.x, 4 * delta)
		sealion.velocity.z = move_toward(sealion.velocity.z, dir.z * speed + target_speed.z, 4 * delta)
		
		#Turn Towards Target
		var radians_to_turn: float = atan2(-dir.x, -dir.z)
		var turn_amount = lerp_angle(sealion.global_rotation.y, radians_to_turn, 7 * delta)
		sealion.global_rotation.y = turn_amount
	else:
		sealion.velocity.x = move_toward(sealion.velocity.x, 0.0, delta * 7)
		sealion.velocity.z = move_toward(sealion.velocity.x, 0.0, delta * 7)
	
	

func get_next_circling_point(sealion: Sealion) -> Vector3:
	var initial_direction = sealion.ship.global_position.direction_to(sealion.global_position)
	var next_direction = initial_direction.rotated(Vector3.UP,deg_to_rad(15))
	return next_direction * swimming_distance + sealion.ship.global_position
