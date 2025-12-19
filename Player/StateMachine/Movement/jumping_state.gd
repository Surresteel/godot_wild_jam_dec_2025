extends PlayerState
class_name JumpingState

func enter() -> void:
	player.velocity.y += 5

func exit() -> void:
	pass

func pre_update() -> void:
	transition.emit(player.movement_state_machine.state.FALLING)

func update(_delta: float) -> void:
	pass
