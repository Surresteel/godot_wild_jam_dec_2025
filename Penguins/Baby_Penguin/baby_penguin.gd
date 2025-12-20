extends CharacterBody3D
class_name BabyPenguin


@onready var statemachine: BabyPenguinStateMachine = $BabyPenguinStateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var skeleton_no_arms: Skeleton3D = $Armature_001/Skeleton3D

@export_category("Stats")
@export var speed: float = 2

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var target: Node3D
var next_position: Vector3
@export var ship: Ship


var cannon_needs_reload: bool = false
var being_chased: bool = false
var hiding: bool = false
var reload_ready: bool = false


@export_category("Avaliable Targets")
@export var player: Player
@export var freezer: Node3D
var unloaded_cannon: Cannon

@onready var reload_area: Area3D = $ReloadArea
@onready var hiding_timer: Timer = $"Hiding Timer"

@warning_ignore_start("unused_signal")
signal chased_signal()
signal hiding_start
signal hiding_stop

signal reload_signal()
@warning_ignore_restore("unused_signal")

func _ready() -> void:
	statemachine.get_current_state_object().enter()
	set_next_target_position()

func _process(_delta: float) -> void:
	set_next_target_position()
	
	if ship.sealion_amount > 0 and\
	 		statemachine.get_current_state_object() != statemachine.all_states[BabyPenguinStateMachine.state.Chased]\
			and statemachine.get_current_state_object() != statemachine.all_states[BabyPenguinStateMachine.state.Hiding]:
		statemachine.change_state(BabyPenguinStateMachine.state.Chased)

#Set Next Target Position For Nav Agent - updates the path
func set_next_target_position() -> void:
	if target != null:
		nav_agent.target_position = target.global_position
		

#Move towards the target wit the nav agent
func move(delta: float, speed_modifier:float = 1) -> void:
	var dir: Vector3 = (next_position - global_position).normalized()
	
	next_position = nav_agent.get_next_path_position()
	next_position.y = global_position.y
	
	if not nav_agent.is_navigation_finished():
		#set velocity
		velocity.x = dir.x * (speed * speed_modifier)
		velocity.z = dir.z * (speed * speed_modifier)
	else:
		velocity.x = move_toward(velocity.x, 0.0, delta * 2)
		velocity.z = move_toward(velocity.x, 0.0, delta * 2)
	
	#Turn Towards Target
	var radians_to_turn: float = atan2(-dir.x, -dir.z)
	var turn_amount = lerp_angle(global_rotation.y, radians_to_turn, 0.5)
	global_rotation.y = turn_amount
	
	move_and_slide()

func set_closest_unloaded_cannon() -> void:
	var cannon_array = get_tree().get_nodes_in_group("Cannon")
	var closest_cannon: Cannon = null
	var closest_distance: float = 100
	for cannon: Cannon in cannon_array as Array[Cannon]:
		if not cannon.reloaded and not cannon.is_active:
			var distance:= (global_position - cannon.global_position).length()
			if distance < closest_distance:
				closest_distance = distance
				closest_cannon = cannon
	
	unloaded_cannon = closest_cannon
	print(closest_cannon," is the closest unloaded cannon")

func set_reload_ready() -> void:
	reload_ready = true
func set_chased(state: bool) -> void:
	being_chased = state

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Baby_GrabbingSnowball":
		animation_player.play("Baby_HoldingSnowballIdle",1)
		set_reload_ready()
	if anim_name == "Baby_HidingSnowball":
		animation_player.play("Baby_HidingSnowbalIdle")
		set_reload_ready()


func hide_in_freezer() -> void:
	pass
