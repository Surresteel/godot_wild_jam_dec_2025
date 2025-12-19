extends BabyState


func enter() -> void:
	baby.target = baby.player
	
	baby.reload_area.set_collision_mask_value(3,1)
	baby.reload_area.set_collision_mask_value(7,0)
	
	baby.animation_player.play("Baby_Run",0.2)
	print("entering")

func exit() -> void:
	pass

func pre_update() -> void:
	if baby.unloaded_cannon != null and not baby.unloaded_cannon.is_active:
		transition.emit(BabyPenguinStateMachine.state.Cannon_Reload)
	elif baby.nav_agent.is_navigation_finished():
		transition.emit(BabyPenguinStateMachine.state.Reloading)
	elif baby.being_chased:
		transition.emit(BabyPenguinStateMachine.state.Chased)
	

func update(delta: float) -> void:
	baby.move(delta)
