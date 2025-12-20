extends CharacterBody3D
class_name HelmsmenPenguin


@export var speed: float = 2

@onready var statemachine: HelmsmenStateMachine = $Statemachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer

#navagent stuff
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var target: Node3D
var next_position: Vector3

@export var wheel_position: Node3D
@export var chase_points: Array[Node3D]

var being_chased: bool = false

@warning_ignore_start("unused_signal")
signal steering_started
signal steering_stopped
signal chased
@warning_ignore_restore("unused_signal")


func _ready() -> void:
	statemachine.get_current_state_object().enter()


#Set Next Target Position For Nav Agent
func set_next_target_position() -> void:
	if target != null:
		nav_agent.target_position = target.global_position
		next_position = nav_agent.get_next_path_position()

#Move towards the target wit the nav agent
func move(delta: float, speed_modifier:float = 1) -> void:
	var dir: Vector3 = (next_position - global_position).normalized()
	
	if not nav_agent.is_navigation_finished():
		#set velocity
		velocity.x = dir.x * (speed * speed_modifier)
		velocity.z = dir.z * (speed * speed_modifier)
	else:
		velocity.x = move_toward(velocity.x, 0.0, delta * 7)
		velocity.z = move_toward(velocity.x, 0.0, delta * 7)
	
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	#Turn Towards Target
	var radians_to_turn: float = atan2(-dir.x, -dir.z)
	var turn_amount = lerp_angle(global_rotation.y, radians_to_turn, 0.5)
	global_rotation.y = turn_amount
	
	move_and_slide()

func set_next_target() -> void:
	if not being_chased:
		target = wheel_position
	else:
		target = chase_points.pick_random()


func set_chased(_state: bool) -> void:
	animation_player.play("Alert")
	being_chased = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Scouting":
		animation_player.play("Steering")
