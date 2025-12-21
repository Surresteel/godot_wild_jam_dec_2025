extends PlayerState
class_name SnowballState


func enter() -> void:
	if player.snowball_action.ammo > 0:
		player.play_animaiton_interupt("P_FPArms__Snowball_Equip")
	else:
		player.play_animaiton_interupt("P_FPArms__Snowball_Take")

func exit() -> void:
	pass

func pre_update() -> void:
	
	if player.snowball_action.ammo == 0:
		transition.emit(WeaponStateMachine.state.Nothing)
	elif player.movement_state_machine.current_state == PlayerStateMachine.state.INTERACTING:
		transition.emit(WeaponStateMachine.state.OnCannon)

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("Main Action"):
		player.snowball_action.throw_snowball()
	
	
 
