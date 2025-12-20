extends Node


const LEVEL_1 = preload("uid://dgld7qc03yurl")
const TEMPLATE_LEVEL = preload("uid://dwdq4qvh5hryc")
const LEVEL_TRANSITION_RES = preload("uid://p5m50im4t3er")
const LEVEL_TRANSITION = preload("uid://c3guus2ws8ywh")

const LEVELS: Array = \
[
	LEVEL_1,
	TEMPLATE_LEVEL,
]


var current_level: int = 0


func mission_complete() -> void:
	current_level = (current_level + 1) % LEVELS.size()
	call_deferred("transition_switch_def")


func mission_failed() -> void:
	call_deferred("restart_switch_def")


func transition_switch_def() -> void:
	get_tree().change_scene_to_packed(LEVEL_TRANSITION)


func restart_switch_def() -> void:
	get_tree().change_scene_to_packed(LEVEL_TRANSITION_RES)


func mission_switch() -> void:
	call_deferred("mission_switch_def")


func mission_switch_def() -> void:
	get_tree().change_scene_to_packed(LEVELS[current_level])
