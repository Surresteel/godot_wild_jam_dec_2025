extends CharacterBody3D
class_name BabyPenguin


@onready var statemachine: BabyPenguinStateMachine = $BabyPenguinStateMachine
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export_category("Stats")
@export var speed: float = 2

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var target: Node3D
var next_position: Vector3


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

@warning_ignore("unused_signal")
signal chased_signal()
@warning_ignore("unused_signal")
signal reload_signal()


func _ready() -> void:
	statemachine.get_current_state_object().enter()

func _physics_process(delta: float) -> void:
	#Nav Agent Update
	set_next_target_position()
	
	#gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	#Move
	move_and_slide()
	

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
	
	#Turn Towards Target
	var radians_to_turn: float = atan2(-dir.x, -dir.z)
	var turn_amount = lerp_angle(global_rotation.y, radians_to_turn, 0.5)
	global_rotation.y = turn_amount

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
		animation_player.play("Baby_HoldingSnowballIdle")
		set_reload_ready()


func hide_in_freezer() -> void:
	pass
