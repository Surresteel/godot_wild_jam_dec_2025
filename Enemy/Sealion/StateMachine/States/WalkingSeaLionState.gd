extends SealionBaseState
class_name WalkingSeaLionState


var speed:= 2

func enter(_sealion: Sealion) -> void:
	print("entered ", self) #delete me

func exit(_sealion: Sealion) -> void:
	pass

func pre_update(_sealion: Sealion) -> void:
	pass

func update(sealion: Sealion, delta) -> void:
	
	#Move The Sealion towards it's target
	sealion.nav_agent.target_position = sealion.target.global_position
	var dir: Vector3 = (sealion.nav_agent.get_next_path_position() 
						- sealion.global_position).normalized()
	
	if not sealion.nav_agent.is_navigation_finished():
		#set velocity
		sealion.velocity = sealion.velocity.move_toward(Vector3(dir.x,0,dir.z) * speed, 0.25)
		
		#Turn Towards Target
		var radians_to_turn: float = atan2(dir.x, dir.z)
		var turn_amount = lerp_angle(sealion.global_rotation.y, radians_to_turn, 0.5)
		sealion.global_rotation.y = turn_amount
	else:
		sealion.velocity = sealion.velocity.move_toward(Vector3.ZERO,0.2)
	
	#Apply Gravity
	if not sealion.is_on_floor():
		sealion.velocity.y += sealion.get_gravity().y
	print(sealion.velocity.length())
