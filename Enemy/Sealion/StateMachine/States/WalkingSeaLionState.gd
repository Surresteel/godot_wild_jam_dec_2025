extends SealionBaseState
class_name WalkingSeaLionState


var speed:= 1

func enter(_sealion: Sealion) -> void:
	pass
	#sealion.animation_player.play("WaddleCycle",-1, 3) #TODO get sealion animations

func exit(_sealion: Sealion) -> void:
	pass
	#sealion.animation_player.stop()

func pre_update(sealion: Sealion) -> void:
	if sealion.velocity == Vector3.ZERO:
		sealion.change_state(SealionStates.TARGETING)

func update(sealion: Sealion, _delta) -> void:
	#Move The Sealion towards it's target
	var dir: Vector3 = (sealion.next_target_pos
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
