extends Node
class_name BabyState

var baby: BabyPenguin
@warning_ignore("unused_signal")
signal transition(new_state)

func enter() -> void:
	pass

func exit() -> void:
	pass

func pre_update() -> void:
	pass

func update(_delta: float) -> void:
	pass
