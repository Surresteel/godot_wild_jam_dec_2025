extends PlayerState
class_name JumpingState

func enter() -> void:
	#if player.global_position.y - 0.5 < player.get_water_height():
		#player.velocity.y += 8
	#else:
	player.velocity.y += 5

func exit() -> void:
	pass

func pre_update() -> void:
	transition.emit(player.movement_state_machine.state.FALLING)

func update(_delta: float) -> void:
	pass
