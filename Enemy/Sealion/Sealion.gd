extends CharacterBody3D
class_name Sealion


@onready var animation_player: AnimationPlayer = $AnimationPlayer
#movement code related
var target_node: Node3D
var target_pos: Vector3
var dot_sealion_to_ship: float
#nav agent things
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var next_target_pos: Vector3

#References To Ship
@onready var ship: Ship = $"../Ship"

var do_buoy: bool = true

var state: SealionBaseState = SealionStates.CIRCLING

# Buoyancy PID controller:
const KP := 5.0
const KI := 1.0
const KD := 2.0
var integral := 0.0
var last_error := 0.0

var submerge_amount := 0


func _ready() -> void:
	#states ready function
	state.enter(self)

func _physics_process(delta: float) -> void:
	#print(dot_sealion_to_ship)
	#update the Nav Agent
	if target_node != null:
		next_target_pos = nav_agent.get_next_path_position()
		nav_agent.target_position = target_node.global_position
	
	#check to change state
	state.pre_update(self)
	#states update function
	state.update(self, delta)
	
	if do_buoy:
		_handle_buoyancy(delta)
	
	#Apply Gravity - Always want to apply gravity so its here
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	move_and_slide()
	
	

func change_state(new_state: SealionBaseState) -> void:
	state.exit(self)
	state = new_state
	state.enter(self)

func change_target_pos(new_pos: Vector3) -> void:
	target_pos = new_pos
func change_target_node(new_Node: Node3D) -> void:
	target_node = new_Node

# Handles buoyancy forces when the player is in the water:
func _handle_buoyancy(delta: float) -> void:
	var data := Vector3(global_position.x, global_position.z, 
				(Time.get_ticks_msec() / 1000.0))
	var water_height = NoiseFunc.sample_at_pos_time(data)
	
	if global_position.y + submerge_amount < water_height:
		var error = water_height - global_position.y + submerge_amount
		integral += error * delta
		var derivative = (error - last_error) / delta
		last_error = error
		
		var output = KP * error + KI * integral + KD * derivative
		velocity.y += output * delta
		
func get_water_height() -> float:
	var data := Vector3(global_position.x, global_position.z, 
				(Time.get_ticks_msec() / 1000.0))
	return NoiseFunc.sample_at_pos_time(data)
