extends helmsmenState


func enter() -> void:
	penguin.chased.emit()
	penguin.animation_player.queue("Chase")

func exit() -> void:
	pass

func pre_update() -> void:
	if not penguin.being_chased:
		transition.emit(HelmsmenStateMachine.state.Steering)

func update(_delta: float) -> void:
	if penguin.nav_agent.is_navigation_finished():
		penguin.set_next_target()
	penguin.set_next_target_position()
	penguin.move(_delta)
