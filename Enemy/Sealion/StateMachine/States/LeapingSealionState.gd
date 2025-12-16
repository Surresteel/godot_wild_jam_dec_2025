extends SealionBaseState
class_name LeapingSealionState


func enter(sealion: Sealion) -> void:
	print("entered leaping state")
	#look at the desiginated landing point node and jump forward
	sealion.look_at(sealion.target.get_parent().global_position)
	sealion.velocity += sealion.global_basis * Vector3(0,6.5,-6.5)
	print("h")
	await sealion.get_tree().create_timer(5).timeout
	if sealion.state == self:
		sealion.change_state(SealionStates.SWIMMING)
	

func exit(sealion: Sealion) -> void:
	sealion.rotation.x = 0

func pre_update(sealion: Sealion) -> void:
	if sealion.is_on_floor():
		sealion.change_state(SealionStates.WALKING)

func update(sealion: Sealion, delta) -> void:
	sealion.velocity.x = move_toward(sealion.velocity.x, 0.0, delta * 0.5)
	sealion.velocity.z = move_toward(sealion.velocity.x, 0.0, delta * 0.5)
	sealion.look_at(sealion.velocity)
