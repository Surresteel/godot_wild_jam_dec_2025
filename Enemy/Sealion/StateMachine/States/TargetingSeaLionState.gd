extends SealionBaseState
class_name TargetingSeaLionState



func enter(sealion: Sealion) -> void:
	var new_target: Node3D = sealion.get_tree().get_nodes_in_group("SealionInteractables").pick_random()
	sealion.change_target_node(new_target)
	if new_target.has_method("set_chased"):
		sealion.chaseing_started.connect(new_target.set_chased)
		sealion.chaseing_started.emit(true)

func exit(_sealion: Sealion) -> void:
	pass

func pre_update(sealion: Sealion) -> void:
	sealion.change_state(SealionStates.WALKING)

func update(_sealion: Sealion, _delta) -> void:
	pass
