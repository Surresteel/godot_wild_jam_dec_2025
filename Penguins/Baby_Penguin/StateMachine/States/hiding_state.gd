extends BabyState

var active: bool = false
var scared: bool = false
var reload_timer := 5.0
var current_time := 0.0

func enter() -> void:
	active = true
	scared = true
	baby.hiding = true
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
	
	baby.global_transform = baby.freezer.global_transform
		
	if not scared:
		reload_out_door()
		return
		
	if current_time < reload_timer:
		current_time += delta
	else:
		scared = false
		print("scared timer timeout")
	
	baby.animation_player.play("Baby_HidingIdle", 1)
	

func reload_out_door() -> void:
	if baby.animation_player.current_animation != "Baby_HidingSnowbalIdle":
		baby.animation_player.play("Baby_HidingSnowball")
	if baby.reload_ready:
		baby.reload_signal.emit()

func window_sitting() -> void:
	if not active:
		return
	baby.animation_player.play("Baby_HidingIdle",0.1)
	baby.reload_ready = false
	scared = true
	current_time = 0.0
	baby.hiding_timer.start()
