extends BabyState


func enter() -> void:
	baby.reload_area.set_collision_mask_value(7,1)
	baby.reload_area.set_collision_mask_value(3,0)
	
	baby.animation_player.play("Baby_Run",1)
	
	baby.target = baby.unloaded_cannon

func exit() -> void:
	pass

func pre_update() -> void:
	if baby.unloaded_cannon == null:
		transition.emit(BabyPenguinStateMachine.state.Player_Follow)
	elif baby.nav_agent.is_navigation_finished():
		transition.emit(BabyPenguinStateMachine.state.Reloading)
	elif baby.being_chased:
		transition.emit(BabyPenguinStateMachine.state.Chased)
	#elif baby.ship.sealion_amount > 0:
		#transition.emit(BabyPenguinStateMachine.state.Chased)

func update(delta: float) -> void:		#gravity
	if not baby.is_on_floor():
		baby.velocity.y += baby.get_gravity().y * delta
	baby.move(delta)
	
