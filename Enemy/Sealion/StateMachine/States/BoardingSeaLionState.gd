extends SealionBaseState
class_name BoardingSealionState

var speed = 8 #changing this will affect leaping
var too_long: bool = false

func enter(sealion: Sealion) -> void:
	too_long = false
	#print("entered Boarding state")
	sealion.change_target_node(sealion.ship)
	await sealion.get_tree().create_timer(5).timeout


func exit(sealion: Sealion) -> void:
	sealion.change_target_pos(sealion.target_node.global_position)

func pre_update(sealion: Sealion) -> void:                                              #seems good length
	if (get_ship_with_offset(sealion) - sealion.global_position).length() < 8:
		sealion.change_state(SealionStates.LEAPING)
	if too_long:
		sealion.change_state(SealionStates.CIRCLING)
	
	

func update(sealion: Sealion, delta) -> void:
	
	#Move The Sealion towards it's target
	var dir: Vector3 = (Vector3(get_ship_with_offset(sealion).x, 0 ,get_ship_with_offset(sealion).z)
						- Vector3(sealion.global_position.x, 0 ,sealion.global_position.z))
	dir = dir.normalized()
	var target_speed := sealion.ship.linear_velocity
	
	var horizontal_velocity = Vector3(sealion.velocity.x, 0 ,sealion.velocity.z)	
	var offset = sealion.global_position - sealion.ship.global_position
	var rotational_velocity = sealion.ship.angular_velocity.cross(offset)
	horizontal_velocity = sealion.ship.linear_velocity + rotational_velocity
	
	
	#set velocity
	sealion.velocity.x = move_toward(sealion.velocity.x, dir.x * speed +
			horizontal_velocity.x + target_speed.x, 4 * delta)
	sealion.velocity.z = move_toward(sealion.velocity.z, dir.z * speed +
			horizontal_velocity.z + target_speed.z, 4 * delta)
	
	#Turn Towards Target
	var radians_to_turn: float = atan2(-dir.x, -dir.z)
	var turn_amount = lerp_angle(sealion.global_rotation.y, radians_to_turn, 7 * delta)
	sealion.global_rotation.y = turn_amount

func get_ship_with_offset(sealion: Sealion) -> Vector3:
	return sealion.ship.global_position + sealion.ship.global_basis.z * Vector3(0, 1.5, 0)
