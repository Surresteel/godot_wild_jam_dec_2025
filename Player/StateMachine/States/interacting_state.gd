extends PlayerState
class_name InteractingState

var last_offset: Vector3

func enter() -> void:
	player.velocity = Vector3.ZERO
	player.mesh.visible = false

func exit() -> void:
	player.mesh.visible = true

func pre_update() -> void:
	if not player.is_interacting:
		transition.emit(player.state_machine.state.WALKING)

func update(delta: float) -> void:
	player.velocity.y += player.get_gravity().y * delta
