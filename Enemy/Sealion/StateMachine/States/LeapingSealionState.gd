extends SealionBaseState
class_name LeapingSealionState

var missed: bool = false


func enter(sealion: Sealion) -> void:
	var b:= Basis.looking_at((sealion.ship.global_position - sealion.global_position).normalized(), Vector3.UP)
	sealion.transform.basis = b
	#sealion.look_at(sealion.ship.global_position + sealion.ship.global_basis.z * Vector3(0, 0, -10))
	sealion.do_buoy = false
	missed = false
	print("entered leaping state")
			   #Up and Backwards Vector - default(7.5,4.5) 
	sealion.velocity = (sealion.ship.global_position 
			- sealion.global_position).normalized() * 5.25 + sealion.ship.linear_velocity
	sealion.velocity.y = 9.5  
	
	await sealion.get_tree().create_timer(0.1).timeout
	sealion.do_buoy = true
	
	await sealion.get_tree().create_timer(3).timeout
	missed = true
	

func exit(sealion: Sealion) -> void:
	sealion.rotation.x = 0

func pre_update(sealion: Sealion) -> void:
	if sealion.is_on_floor():
		sealion.change_state(SealionStates.WALKING)
	elif missed:
		sealion.change_state(SealionStates.CIRCLING)

func update(sealion: Sealion, delta) -> void:
	sealion.velocity.x = move_toward(sealion.velocity.x, sealion.ship.linear_velocity.x, delta * 2)
	sealion.velocity.z = move_toward(sealion.velocity.z, sealion.ship.linear_velocity.z, delta * 2)
	sealion.look_at(sealion.global_position + sealion.velocity)
