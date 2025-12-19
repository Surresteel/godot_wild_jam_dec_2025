extends BabyState


func enter() -> void:
	baby.reload_ready = false
	
	baby.animation_player.play("Baby_GrabbingSnowball", 0.2)
	print("reloading")

func exit() -> void:
	pass

func pre_update() -> void:
	#check if anything is reloaded
	if not baby.nav_agent.is_navigation_finished() and baby.reload_ready:
		transition.emit(BabyPenguinStateMachine.state.Player_Follow)
	elif baby.unloaded_cannon != null:
		if baby.unloaded_cannon.reloaded:
			baby.set_closest_unloaded_cannon()
			transition.emit(BabyPenguinStateMachine.state.Cannon_Reload)


func update(_delta: float) -> void:
	baby.velocity = baby.velocity.move_toward(Vector3.ZERO, _delta * 5)
	if baby.reload_ready:
		baby.reload_signal.emit()
