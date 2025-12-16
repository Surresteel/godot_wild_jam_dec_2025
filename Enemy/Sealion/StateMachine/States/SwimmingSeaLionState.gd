extends SealionBaseState
class_name SwimmingSealionState

var speed = 6
var buoyancy:= 1

func enter(sealion: Sealion) -> void:
	print("entered Swimming state")
	#Find the SealionJumpAreas
	var all_targets: = sealion.get_tree().get_nodes_in_group("SealionJumpArea")
	#Get The Closest One
	var closest_Node := all_targets[0] as Node3D
	var closest_distance:= sealion.global_position.distance_squared_to(closest_Node.global_position)
	for target in all_targets:
		var node = target as Node3D
		if sealion.global_position.distance_squared_to(node.global_position) < closest_distance:
			closest_Node = node
			closest_distance = sealion.global_position.distance_squared_to(node.global_position)
	
	sealion.change_target(closest_Node)
	
	#Set NavigationAgentLayer
	sealion.nav_agent.set_navigation_layer_value(2,true)
	sealion.nav_agent.path_postprocessing = NavigationPathQueryParameters3D.PATH_POSTPROCESSING_CORRIDORFUNNEL
	
	sealion.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING

func exit(sealion: Sealion) -> void:
	#Set NavigationAgent and characterbody bakc to defaults
	sealion.nav_agent.set_navigation_layer_value(2,false)
	sealion.nav_agent.path_postprocessing = NavigationPathQueryParameters3D.PATH_POSTPROCESSING_EDGECENTERED
	sealion.motion_mode = CharacterBody3D.MOTION_MODE_GROUNDED

func pre_update(sealion: Sealion) -> void:
	#Needed for is_target_reached to update? for some reason
	sealion.nav_agent.is_navigation_finished()
	
	if sealion.nav_agent.is_target_reached():
		sealion.change_state(SealionStates.LEAPING)
	

func update(sealion: Sealion, delta) -> void:
	
	#if sealion.submerge_amount < 0.5:
		#buoyancy = 1
	#elif sealion.submerge_amount > 0.5
	#sealion.submerge_amount +=
	
		#Move The Sealion towards it's target
	var dir: Vector3 = (Vector3(sealion.next_target_pos.x,0,sealion.next_target_pos.z)
						- Vector3(sealion.global_position.x, 0 ,sealion.global_position.z)
						).normalized()
	
	if not sealion.nav_agent.is_navigation_finished():
		#set velocity
		sealion.velocity.x = move_toward(sealion.velocity.x, dir.x * speed, 0.2)
		sealion.velocity.z = move_toward(sealion.velocity.z, dir.z * speed, 0.2)
		
		#Turn Towards Target
		var radians_to_turn: float = atan2(-dir.x, -dir.z)
		var turn_amount = lerp_angle(sealion.global_rotation.y, radians_to_turn, 0.5)
		sealion.global_rotation.y = turn_amount
	else:
		sealion.velocity.x = move_toward(sealion.velocity.x, 0.0, delta * 7)
		sealion.velocity.z = move_toward(sealion.velocity.x, 0.0, delta * 7)
	
	#print(sealion.velocity)
