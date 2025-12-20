extends SealionBaseState
class_name DefeatedSealionState


func enter(sealion: Sealion) -> void:
	sealion.velocity = Vector3.ZERO
	#sealion.visible = false
	#do death gibs and animation maybe and what ever
	sealion.animation_player.play_section_backwards("Ship Enter") 
	sealion.chaseing_started.emit(false)
	await sealion.animation_player.animation_finished
	
	var blood: Node3D = Sealion.SCENE_DEATH.instantiate()
	sealion.get_tree().current_scene.add_child(blood)
	blood.global_position = sealion.global_position
	
	sealion.defeated_signal.emit()
	sealion.queue_free()

func exit(_sealion: Sealion) -> void:
	pass

func pre_update(_sealion: Sealion) -> void:
	pass

func update(_sealion: Sealion, _delta) -> void:
	pass
