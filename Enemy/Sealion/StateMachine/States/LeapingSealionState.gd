extends SealionBaseState
class_name LeapingSealionState

var missed: bool = false


func enter(sealion: Sealion) -> void:
	print("entered leaping state")
	sealion.velocity.y = 7.5              #Up and Backwards Vector - default(7.5,4.5) 
	sealion.velocity += sealion.transform.basis * Vector3(0,0,4.5)
	
	await sealion.get_tree().create_timer(5).timeout
	print("I missed")
	missed = true
	

func exit(sealion: Sealion) -> void:
	sealion.rotation.x = 0

func pre_update(sealion: Sealion) -> void:
	if sealion.is_on_floor():
		sealion.change_state(SealionStates.WALKING)
	if missed:
		sealion.change_state(SealionStates.CIRCLING)

func update(sealion: Sealion, delta) -> void:
	sealion.velocity.x = move_toward(sealion.velocity.x, sealion.ship.linear_velocity.x, delta * 2)
	sealion.velocity.z = move_toward(sealion.velocity.z, sealion.ship.linear_velocity.z, delta * 2)
	sealion.look_at(sealion.global_position + sealion.velocity)
