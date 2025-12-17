extends PlayerState
class_name InteractingState

var last_offset: Vector3

func enter() -> void:
	player.velocity = Vector3.ZERO

func exit() -> void:
	pass

func pre_update() -> void:
	if not player.is_interacting:
		transition.emit(player.state_machine.state.WALKING)

func update(delta: float) -> void:
	player.velocity.y += player.get_gravity().y * delta
