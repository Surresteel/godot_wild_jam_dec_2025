extends Node


const LEVEL_1 = preload("uid://dgld7qc03yurl")
const LEVEL_2 = preload("uid://bwgr8xk2v6nbq")
const LEVEL_3 = preload("uid://cj4b0enjdlrf0")
const LEVEL_4 = preload("uid://v83e6qskbeih")
const LEVEL_5 = preload("uid://baw7marflqavm")
const LEVEL_6 = preload("uid://b8v72wifgfegc")
const LEVEL_B = preload("uid://bhwx1ckn7gmcg")

const LEVEL_TRANSITION_RES = preload("uid://p5m50im4t3er")
const LEVEL_TRANSITION = preload("uid://c3guus2ws8ywh")

const LEVELS: Array = \
[
	LEVEL_1,
	LEVEL_2,
	LEVEL_3,
	LEVEL_4,
	LEVEL_5,
	LEVEL_6,
	LEVEL_B,
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
