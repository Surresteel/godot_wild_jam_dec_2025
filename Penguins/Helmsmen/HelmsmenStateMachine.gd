extends Node
class_name HelmsmenStateMachine


@onready var parent: HelmsmenPenguin = $".."

enum state {Steering, Chased} # should be in order of nodes
var current_state: state = state.Steering
var all_states: Array[helmsmenState]

func get_current_state_object() -> helmsmenState:
	return all_states.get(current_state)

func _ready() -> void:
	#set up states
	var children = get_children()
	for states: helmsmenState in children:
		all_states.append(states)
		states.penguin = parent
		states.transition.connect(change_state)
	#get_current_state_object().enter()

func _physics_process(delta: float) -> void:
	get_current_state_object().pre_update()
	get_current_state_object().update(delta)

func change_state(new_state: state):
	get_current_state_object().exit()
	current_state = new_state
	get_current_state_object().enter()
