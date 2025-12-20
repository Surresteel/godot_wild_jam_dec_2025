extends CharacterBody3D
class_name Sealion


const SCENE_DEATH = preload("uid://dx7qtwbmcd1er")


@onready var audio_emitter: AudioStreamPlayer3D = $AudioEmitter
var timeout_grunt: float = 0.0
var interval_grunt: float = 5.0 * 1000.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
#movement code related
var target_node: Node3D
var target_pos: Vector3
var dot_sealion_to_ship: float
#nav agent things
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var next_target_pos: Vector3

#References To Ship
#@onready var ship: Ship = $"../Ship"
@export var ship: Ship

var do_buoy: bool = true
var can_attack: bool = true

var state: SealionBaseState = SealionStates.CIRCLING

# Buoyancy PID controller:
const KP := 3.0
const KI := 1.0
const KD := 4.0
var integral := 0.0
var last_error := 0.0

var submerge_amount := 0

#health stuff
var health: int = 3
var defeated: bool = false

@warning_ignore("unused_signal")
signal chaseing_started
@warning_ignore("unused_signal")
signal defeated_signal

func _ready() -> void:
	#states ready function
	state.enter(self)

func _physics_process(delta: float) -> void:
	#print(dot_sealion_to_ship)
	#update the Nav Agent
	if target_node:
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


func play_animaiton_interupt(anim_name: String, replay_current: bool = false,
		 blend_speed: float = -1) -> void:
	var current_animation:= animation_player.current_animation
	animation_player.play("FirstPerson_Player/" + anim_name, blend_speed)
	if replay_current:
		animation_player.queue(current_animation)

func take_damage_real(damage: int = 1) -> void:
	if health <= 0:
		return
	
	audio_emitter.stream = AudioManager.PUNCH
	audio_emitter.play()
	health -= damage
	if health <= 0:
		defeated = true
		await get_tree().create_timer(0.25).timeout
		audio_emitter.stream = AudioManager.SEALION_DEATH
		audio_emitter.play()


func take_damage(body: Node3D) -> void:
	if body is CannonBall:
		var vel = body.linear_velocity.length()
		if target_node and target_node is RigidBody3D and state == SealionStates.WALKING:
			vel -= target_node.linear_velocity.length()
		if vel > 10.0:
			take_damage_real(3)
		else:
			take_damage_real()
	

func set_target(t: RigidBody3D) -> void:
	ship = t



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Attack":
		can_attack = true
