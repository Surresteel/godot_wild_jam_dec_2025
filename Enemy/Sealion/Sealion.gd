extends CharacterBody3D
class_name Sealion


@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@export var target: Node3D
var next_target_pos: Vector3

var state: SealionBaseState = SealionStates.WALKING

# Buoyancy PID controller:
const KP := 20.0
const KI := 2.0
const KD := 8.0
var integral := 0.0
var last_error := 0.0


func _ready() -> void:
	#states ready function
	state.enter(self)

func _physics_process(delta: float) -> void:
	#update the Nav Agent
	next_target_pos = nav_agent.get_next_path_position()
	nav_agent.target_position = target.global_position
	
	#check to change state
	state.pre_update(self)
	#states update function
	state.update(self, delta)
	
	move_and_slide()

func change_state(new_state: SealionBaseState) -> void:
	state.exit(self)
	state = new_state
	state.enter(self)

# Handles buoyancy forces when the player is in the water:
func _handle_buoyancy(delta: float) -> void:
	var data := Vector3(global_position.x, global_position.z, 
				(Time.get_ticks_msec() / 1000.0))
	var water_height = NoiseFunc.sample_at_pos_time(data)
	
	if global_position.y < water_height:
		var error = water_height - global_position.y
		integral += error * delta
		var derivative = (error - last_error) / delta
		last_error = error
		
		var output = KP * error + KI * integral + KD * derivative
		velocity.y += output * delta
		
