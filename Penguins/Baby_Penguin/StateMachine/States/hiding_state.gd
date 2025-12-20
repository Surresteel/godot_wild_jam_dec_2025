extends BabyState

var active: bool = false
var scared: bool = false
var reload_timer := 5.0
var current_time := 0.0

func enter() -> void:
	active = true
	scared = true
	baby.hiding = true
	baby.global_rotation = baby.freezer.global_rotation
	window_sitting()
	baby.hiding_timer.start()
	baby.remove_from_group("SealionInteractables")

func exit() -> void:
	baby.hiding = false
	baby.skeleton_no_arms.visible  = true
	baby.add_to_group("SealionInteractables")
	active = false

func pre_update() -> void:
	if baby.hiding_timer.is_stopped() and not baby.being_chased:
		transition.emit(BabyPenguinStateMachine.state.Player_Follow)

func update(delta: float) -> void:
	if current_time < reload_timer:
		current_time += delta
	else:
		current_time = 0.0
		scared = false
		print("scared timer timeout")
	
	if baby.animation_player.current_animation == "Baby_HidingIdle":
		baby.global_position = baby.freezer.global_position
	else:
		baby.global_position = baby.freezer.global_position - Vector3(0,0.25,0)
		
	if baby.player.global_position.distance_to(baby.global_position) <= 1 and not scared:
		reload_out_door()
	

func reload_out_door() -> void:
	if baby.animation_player.current_animation != "Baby_HidingSnowbalIdle":
		baby.animation_player.play("Baby_HidingSnowball")
	if baby.reload_ready:
		baby.reload_signal.emit()

func window_sitting() -> void:
	if not active:
		return
	baby.animation_player.play("Baby_HidingIdle")
	baby.reload_ready = false
	scared = true
