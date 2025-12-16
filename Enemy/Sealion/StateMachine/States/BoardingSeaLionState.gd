extends SealionBaseState
class_name BoardingSealionState

var speed = 8 #changing this will affect leaping

func enter(sealion: Sealion) -> void:
	print("entered Boarding state")
	sealion.change_target_node(sealion.ship)


func exit(sealion: Sealion) -> void:
	sealion.change_target_pos(sealion.target_node.global_position)

func pre_update(sealion: Sealion) -> void:                                              #seems good length
	if (get_ship_with_offset(sealion) - sealion.global_position).length() < 5:
		sealion.change_state(SealionStates.LEAPING)
	

func update(sealion: Sealion, delta) -> void:
	sealion.change_target_pos(get_ship_with_offset(sealion))
	
	#Move The Sealion towards it's target
	var dir: Vector3 = (Vector3(sealion.target_pos.x, 0 ,sealion.target_pos.z)
						- Vector3(sealion.global_position.x, 0 ,sealion.global_position.z))
	dir = dir.normalized()
	var target_speed := sealion.ship.linear_velocity
	
	#set velocity
	sealion.velocity.x = move_toward(sealion.velocity.x, dir.x * speed + target_speed.x, 4 * delta)
	sealion.velocity.z = move_toward(sealion.velocity.z, dir.z * speed + target_speed.z, 4 * delta)
	
	#Turn Towards Target
	var radians_to_turn: float = atan2(-dir.x, -dir.z)
	var turn_amount = lerp_angle(sealion.global_rotation.y, radians_to_turn, 7 * delta)
	sealion.global_rotation.y = turn_amount

func get_ship_with_offset(sealion: Sealion) -> Vector3:
	return sealion.ship.global_position + sealion.ship.global_basis * Vector3(0, 1.5, -3.5)
