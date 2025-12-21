extends SealionBaseState
class_name TargetingSeaLionState



func enter(sealion: Sealion) -> void:
	var targets = sealion.get_tree().get_nodes_in_group("SealionInteractables")
	if targets.is_empty():
		printerr("Sealion has no targets to pick from.")
		return
	var new_target: Node3D = targets.pick_random()
	
	sealion.change_target_node(new_target)
	if new_target.has_method("set_chased"):
		if not sealion.chaseing_started.is_connected(new_target.set_chased):
			sealion.chaseing_started.connect(new_target.set_chased)
		sealion.chaseing_started.emit(true)

func exit(_sealion: Sealion) -> void:
	pass

func pre_update(sealion: Sealion) -> void:
	sealion.change_state(SealionStates.WALKING)

func update(_sealion: Sealion, _delta) -> void:
	pass
