extends helmsmenState

var timer:float = 10
var current_time := 0.0

func enter() -> void:
	penguin.animation_player.play("Steering", 1)
	penguin.steering_started.emit()

func exit() -> void:
	penguin.steering_stopped.emit()

func pre_update() -> void:
	if penguin.being_chased:
		transition.emit(HelmsmenStateMachine.state.Chased)

func update(_delta: float) -> void:
	penguin.global_transform = penguin.wheel_position.global_transform
	
	if penguin.animation_player.current_animation == "Steering":
		if current_time < timer:
			current_time += _delta
		else:
			current_time = 0
			penguin.animation_player.play("Scouting",1)
	
