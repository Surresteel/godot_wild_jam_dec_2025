extends SealionBaseState
class_name WalkingSeaLionState

var change_target: bool = false
var speed:= 2
var walk_target: Node3D

func enter(sealion: Sealion) -> void:
	
	#animation
	sealion.animation_player.play("Chase",1)
	
	#Set NavigationAgentLayer
	sealion.nav_agent.set_navigation_layer_value(1,true)

func exit(_sealion: Sealion) -> void:
	change_target = false

func pre_update(sealion: Sealion) -> void:
	if sealion.global_position.y < sealion.get_water_height():
		sealion.change_state(SealionStates.CIRCLING)
	if sealion.defeated:
		sealion.change_state(SealionStates.DEFEATED)
	if change_target:
		sealion.change_state(SealionStates.TARGETING)

func update(sealion: Sealion, _delta) -> void:
	#Move The Sealion towards it's target
	var dir: Vector3 = (sealion.next_target_pos
						- sealion.global_position).normalized()
	
	if not sealion.nav_agent.is_navigation_finished() and sealion.animation_player.current_animation != "Attack":
		#set velocity
		sealion.velocity.x = dir.x * speed
		sealion.velocity.z = dir.z * speed
		
		sealion.animation_player.play("Chase",1)
	else:
		sealion.velocity = Vector3.ZERO
		sealion.animation_player.play("Attack")
		if sealion.target_node.has_method("take_damage"):
			sealion.target_node.take_damage()
		if sealion.target_node is BabyPenguin:
			if sealion.target_node.hiding:
				change_target = true
	
	#Turn Towards Target
	var radians_to_turn: float = atan2(-dir.x, -dir.z)
	var turn_amount = lerp_angle(sealion.global_rotation.y, radians_to_turn, 0.5)
	sealion.global_rotation.y = turn_amount
