extends PlayerState
class_name NothingState


func enter() -> void:
	player.play_animaiton_interupt("P_FPArms__Idle", false, 0.5)
	pass

func exit() -> void:
	pass

func pre_update() -> void:
	if player.snowball_action.ammo > 0:
		transition.emit(WeaponStateMachine.state.Snowball)

func update(_delta: float) -> void:
	pass
	

 
