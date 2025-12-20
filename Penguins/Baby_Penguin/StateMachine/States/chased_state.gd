extends BabyState


func enter() -> void:
	baby.chased_signal.emit()
	
	baby.target = baby.freezer

func exit() -> void:
	pass

func pre_update() -> void:
	if baby.nav_agent.is_navigation_finished():
		transition.emit(BabyPenguinStateMachine.state.Hiding)
	elif not baby.being_chased:
		transition.emit(BabyPenguinStateMachine.state.Player_Follow)

func update(delta: float) -> void:		#gravity
	if not baby.is_on_floor():
		baby.velocity.y += baby.get_gravity().y * delta
	
	if baby.global_position.distance_to(baby.freezer.global_position) <= 5:
		baby.animation_player.play("Baby_Slide")
		baby.move(delta,3)
	else:
		baby.move(delta,1.2)
