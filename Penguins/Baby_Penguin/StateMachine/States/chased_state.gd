extends BabyState


func enter() -> void:
	baby.chased_signal.emit()
	
	baby.target = baby.freezer

func exit() -> void:
	pass

func pre_update() -> void:
	if baby.nav_agent.is_navigation_finished():
		transition.emit(BabyPenguinStateMachine.state.Hiding)
	elif not baby.being_chased:
		transition.emit(BabyPenguinStateMachine.state.Player_Follow)

func update(delta: float) -> void:
	baby.move(delta,2)
