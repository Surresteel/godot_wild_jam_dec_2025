extends PlayerState
class_name SnowballState

var already_have_snowball: bool = true

func enter() -> void:
	if already_have_snowball:
		player.play_animaiton_interupt("P_FPArms__Snowball_Equip")
	else:
		player.play_animaiton_interupt("P_FPArms__Snowball_Take")
		already_have_snowball = true

func exit() -> void:
	pass

func pre_update() -> void:
	
	if player.snowball_action.ammo == 0 and player.snowball_action.snowball_ready:
		transition.emit(WeaponStateMachine.state.Nothing)
		already_have_snowball = false
	elif player.movement_state_machine.current_state == PlayerStateMachine.state.INTERACTING:
		transition.emit(WeaponStateMachine.state.OnCannon)

func update(_delta: float) -> void:
	if Input.is_action_just_pressed("Main Action"):
		player.snowball_action.throw_snowball()
	
	
 
