extends SealionBaseState
class_name WalkingSeaLionState

var change_target: bool = false
var speed:= 2
var walk_target: Node3D

func enter(sealion: Sealion) -> void:
	
	#animation
	sealion.animation_player.play("Chase")
	

func exit(sealion: Sealion) -> void:
	
	change_target = false
	
	sealion.chaseing_started.emit(false)
	
	if sealion.target_node and sealion.target_node.has_method("set_chased"):
		if sealion.chaseing_started.is_connected(sealion.target_node.set_chased):
			sealion.chaseing_started.disconnect(sealion.target_node.set_chased)

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
		
		sealion.nav_agent.velocity = sealion.velocity
		
		sealion.animation_player.play("Chase",1)
	
	#Turn Towards Target
	var radians_to_turn: float = atan2(-dir.x, -dir.z)
	var turn_amount = lerp_angle(sealion.global_rotation.y, radians_to_turn, 0.5)
	sealion.global_rotation.y = turn_amount
	
	if not sealion.target_node:
		printerr("WalkingSeaLionState - update: target_node is null")
		return
	
	if sealion.target_node.global_position.distance_to(sealion.global_position) <= 1:
		sealion.velocity = Vector3.ZERO
		sealion.animation_player.play("Attack")
		
		if Time.get_ticks_msec() > sealion.timeout_grunt:
			sealion.audio_emitter.stream = \
					AudioManager.SEALION_GRUNTS.pick_random()
			sealion.audio_emitter.play()
			sealion.timeout_grunt = Time.get_ticks_msec() \
					+ sealion.interval_grunt
		
		if sealion.target_node.has_method("take_damage") and sealion.can_attack:
			sealion.target_node.take_damage()
			sealion.can_attack = false
		
		if sealion.target_node is BabyPenguin:
			if sealion.target_node.hiding:
				change_target = true
