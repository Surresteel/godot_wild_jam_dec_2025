extends BabyState


func enter() -> void:
	baby.visible = false #TODO change this to play an animaiton that ends with him physically moves maybe, or the freezer can have its own animaiton player
	baby.hiding_timer.start()
	baby.remove_from_group("SealionInteractables")

func exit() -> void:
	baby.visible = true
	baby.add_to_group("SealionInteractables")

func pre_update() -> void:
	if baby.hiding_timer.is_stopped() and not baby.being_chased:
		transition.emit(BabyPenguinStateMachine.state.Player_Follow)

func update(_delta: float) -> void:
	pass
