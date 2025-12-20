extends BabyState

var active: bool = false

func enter() -> void:
	active = true
	ready_reload()

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
	#elif baby.ship.sealion_amount > 0:
		#transition.emit(BabyPenguinStateMachine.state.Chased)

func update(delta: float) -> void:
	baby.velocity = baby.velocity.move_toward(Vector3.ZERO, delta * 5)
	if not baby.is_on_floor():
		baby.velocity.y += baby.get_gravity().y * delta
	baby.move_and_slide()
	if baby.reload_ready:
		baby.reload_signal.emit()

func ready_reload() -> void:
	baby.reload_ready = false
	
	baby.animation_player.play("Baby_GrabbingSnowball", 0.2)
