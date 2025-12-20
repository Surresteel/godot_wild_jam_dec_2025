extends BabyState

var active: bool = false

func enter() -> void:
	active = true
	baby.global_rotation = baby.freezer.global_rotation
	window_sitting()
	baby.hiding_timer.start()
	baby.remove_from_group("SealionInteractables")

func exit() -> void:
	baby.skeleton_no_arms.visible  = true
	baby.add_to_group("SealionInteractables")

func pre_update() -> void:
	if baby.hiding_timer.is_stopped() and not baby.being_chased:
		transition.emit(BabyPenguinStateMachine.state.Player_Follow)

func update(_delta: float) -> void:
	pass

func reload_out_door() -> void:
	baby.animation_player.play("Baby_HidingSnowball")
	if baby.reload_ready:
		baby.reload_signal.emit()

func window_sitting() -> void:
	if not active:
		return
	baby.animation_player.play("Baby_HidingIdle")
	baby.reload_ready = false
