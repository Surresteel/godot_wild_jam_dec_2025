extends SealionBaseState
class_name WalkingSeaLionState


var speed:= 2
var walk_target: Node3D

func enter(sealion: Sealion) -> void:
	print("entered Walking state")
	sealion.change_target_node(sealion.get_tree().get_first_node_in_group("SealionInteractables")) #TODO the sealion should go to targeting to get a new target, either the player or the helmsmen and maybe the baby penguins
	
	#Set NavigationAgentLayer
	sealion.nav_agent.set_navigation_layer_value(1,true)
	
	#sealion.animation_player.play("Penguin_Base/Penguin_Waddle") #TODO get sealion animations

func exit(_sealion: Sealion) -> void:
	pass

func pre_update(sealion: Sealion) -> void:
	if sealion.velocity == Vector3.ZERO and sealion.nav_agent.is_navigation_finished():
		sealion.change_state(SealionStates.TARGETING)
	if sealion.global_position.y < sealion.get_water_height():
		sealion.change_state(SealionStates.CIRCLING)

func update(sealion: Sealion, delta) -> void:
	#Move The Sealion towards it's target
	var dir: Vector3 = (sealion.next_target_pos
						- sealion.global_position).normalized()
	
	if not sealion.nav_agent.is_navigation_finished():
		#set velocity
		sealion.velocity.x = dir.x * speed
		sealion.velocity.z = dir.z * speed
	else:
		sealion.velocity.x = move_toward(sealion.velocity.x, 0.0, delta * 7)
		sealion.velocity.z = move_toward(sealion.velocity.x, 0.0, delta * 7)
	
	#Turn Towards Target
	var radians_to_turn: float = atan2(-dir.x, -dir.z)
	var turn_amount = lerp_angle(sealion.global_rotation.y, radians_to_turn, 0.5)
	sealion.global_rotation.y = turn_amount
