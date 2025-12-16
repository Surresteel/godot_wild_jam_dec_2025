extends SealionBaseState
class_name SwimmingSealionState

var speed = 12
var buoyancy:= 1
var lerp_amount := 0.0

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


func exit(sealion: Sealion) -> void:
	pass

func pre_update(sealion: Sealion) -> void:
	
	if (sealion.target.global_position - sealion.global_position).length() < 2:
		sealion.change_state(SealionStates.LEAPING)
	

func update(sealion: Sealion, delta) -> void:
	##change how submerged it is
	#if sealion.submerge_amount < 0.5:
		#buoyancy = 1
	#elif sealion.submerge_amount > 0.5
	#sealion.submerge_amount +=
	
	#speed varying
	if lerp_amount >= 1:
		lerp_amount = 0
	speed = lerpf(12, 2, lerp_amount)
	lerp_amount += delta
	print(speed)
	
	#Move The Sealion towards it's target
	var dir: Vector3 = (Vector3(sealion.target.global_position.x,0,sealion.target.global_position.z)
						- Vector3(sealion.global_position.x, 0 ,sealion.global_position.z)
						).normalized()
	
	var target_speed := sealion.get_target_speed()
	
	if dir:
		#set velocity
		sealion.velocity.x = move_toward(sealion.velocity.x, dir.x * speed + target_speed.x, 0.2)
		sealion.velocity.z = move_toward(sealion.velocity.z, dir.z * speed + target_speed.z, 0.2)
		
		#Turn Towards Target
		var radians_to_turn: float = atan2(-dir.x, -dir.z)
		var turn_amount = lerp_angle(sealion.global_rotation.y, radians_to_turn, 0.5)
		sealion.global_rotation.y = turn_amount
	else:
		sealion.velocity.x = move_toward(sealion.velocity.x, 0.0, delta * 7)
		sealion.velocity.z = move_toward(sealion.velocity.x, 0.0, delta * 7)
	
	#print(sealion.velocity)
