extends PlayerState
class_name On_Cannon_State


func enter() -> void:
	pass

func exit() -> void:
	pass

func pre_update() -> void:
	if not player.is_interacting:
		transition.emit(WeaponStateMachine.state.Nothing)
	

func update(_delta: float) -> void:
	pass

 
