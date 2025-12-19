extends Node
class_name BabyPenguinStateMachine

@export var parent: BabyPenguin

enum state {Player_Follow, Cannon_Reload, Chased, Hiding, Reloading} # should be in order of nodes
var current_state: state
var all_states: Array[BabyState]

func get_current_state_object() -> BabyState:
	return all_states.get(current_state)

func _ready() -> void:
	#set up states
	var children = get_children()
	for states: BabyState in children:
		all_states.append(states)
		states.baby = parent
		states.transition.connect(change_state)
	#get_current_state_object().enter()
	current_state = state.Player_Follow

func _physics_process(delta: float) -> void:
	get_current_state_object().pre_update()
	get_current_state_object().update(delta)

func change_state(new_state: state):
	get_current_state_object().exit()
	current_state = new_state
	get_current_state_object().enter()
