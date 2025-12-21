extends Node3D
class_name Cannon

@onready var audio_emitter: AudioStreamPlayer3D = $AudioEmitter
@onready var cannon_rack: MeshInstance3D = $"Mesh/Cannon Rack"
@onready var wheels_front: MeshInstance3D = $"Mesh/Cannon Rack/Wheels/Wheel Jointer Front"
@onready var wheels_back: MeshInstance3D = $"Mesh/Cannon Rack/Wheels/Wheel Joiner Back"
@onready var cannon_barrel: MeshInstance3D = $"Mesh/Cannon Rack/Barrel/Cannon Barrel"

@onready var camera_positon: Node3D = $"Mesh/Cannon Rack/Barrel/Cannon Barrel/Camera_positon"

const CANNONBALL = preload("uid://jifqhmqqi4ym")

var player: Player
@onready var cannon_interact: CannonInteract = $CannonInteract
@onready var animation_player: AnimationPlayer = $"Mesh/Cannon Rack/Barrel/Cannon Barrel/AnimationPlayer"
@onready var animaiton_mesh_parent: Node3D = $"Mesh/Cannon Rack/Barrel/Cannon Barrel/FPArms"

@export_category("Stats")
@export var rotation_speed: float = 2.0
@export var max_power: float = 30.0
var current_power: float = 0.0
@onready var power_timer: Timer = $PowerTimer
@export_range(0.5, 10, 0.5, "suffix:Seconds") var charge_time: float = 1.5
@export var exit_range: float = 0.65

var projectile_Offset := Vector3(0,0,-1).length()
var last_pos: Vector3
var Velocity: Vector3
var is_active: bool = false
var reloaded: bool = true
var shoot_bool: bool = false

@export_category("TurnAngle")
@onready var initial_angle:Vector3 = rotation
@export var max_angle_x: float = 28.0
@export var min_angle_y: float = -6.0
@export var max_angle_y: float = 10.0


signal cannon_exit()
signal cannon_reload()

signal ui_cannon_enter
signal ui_cannon_exit
signal cannon_power

func activate() -> void:
	is_active = true
	animaiton_mesh_parent.visible = true
	ui_cannon_enter.emit()

func deactivate() -> void:
	is_active = false
	animaiton_mesh_parent.visible = false                      #Player Height
	cannon_exit.emit(exit_range * global_basis.z + global_position,
			 global_rotation)
	ui_cannon_exit.emit()

func _ready() -> void:
	power_timer.wait_time = charge_time
	last_pos = global_position
	
	cannon_interact.cannon = self
	
	animation_player.play(&"Cannon/P_FPArms_Cannon_Idle")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_active:
		var new_rotation_x: float = -event.screen_relative.y * rotation_speed * get_process_delta_time()
		var new_rotation_y: float = -event.screen_relative.x * rotation_speed * get_process_delta_time()
		rotate_cannon_within_clamp(new_rotation_x,new_rotation_y)


func _physics_process(delta: float) -> void:
	#rotation_degrees.x += 10 # - debugging the rotaiton bug
	if is_active:
		if power_timer.is_stopped() and shoot_bool:
			cannon_power.emit(100.0)
		elif shoot_bool:
			cannon_power.emit((1 - (power_timer.time_left / power_timer.wait_time)) * 100)
		else:
			cannon_power.emit(0)
		
		##camera_positon shenanigans
		#camera_positon.position = camera_positon.position.move_toward(Vector3.ZERO, delta * 2)
		#camera_positon.rotation = camera_positon.rotation.slerp(Vector3.ZERO, delta * 5)
		
		Velocity = (global_position - last_pos) / delta
		last_pos = global_position
		
		if reloaded:
		#check if reloaded on each if, maybe looks nicer doubt it matters
			if Input.is_action_just_pressed("Main Action"):
				power_timer.start(charge_time)
				shoot_bool = true
			elif Input.is_action_just_released("Main Action") and shoot_bool:
				shoot_bool = false
				var new_cannonball = instance_new_cannonball()
				shoot(new_cannonball)
				reloaded = false
				# Audio stuff:
				audio_emitter.stream = AudioManager.CANNON_SOUNDS.pick_random()
				audio_emitter.play(0.5)
		else:
			#if is_active then player shouldnt be null
			if Input.is_action_just_pressed("Reload") or Input.is_action_just_pressed("Main Action"):
				cannon_reload.emit()
				

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
				if event.keycode == KEY_BACKSPACE:
					get_tree().paused = true

func instance_new_cannonball() -> CannonBall:
	var local_offset: Vector3 = -cannon_barrel.global_basis.z * projectile_Offset
	var new_cannonball: RigidBody3D = CANNONBALL.instantiate()
	
	get_tree().current_scene.add_child(new_cannonball)
	new_cannonball.freeze = true
	new_cannonball.global_position = cannon_barrel.global_position + local_offset
	new_cannonball.rotate_x(randf() * TAU)
	new_cannonball.rotate_y(randf() * TAU)
	new_cannonball.freeze = false
	return new_cannonball

func shoot(new_cannonball: RigidBody3D) -> void:
	if power_timer.is_stopped():
		current_power = max_power
	else:
		current_power = lerpf(5, max_power, #Min-Max Power based on powertimer
				 1 - (power_timer.time_left / power_timer.wait_time))
	new_cannonball.fire(current_power, -cannon_barrel.global_basis.z.rotated(cannon_barrel.global_basis.x,deg_to_rad(4)), Velocity)
	recoil(current_power)
	
	power_timer.stop()

func reload() -> void:
	reloaded = true

func reload_start() -> void:
	animation_player.play(&"Cannon/P_FPArms_Cannon_Reload")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"Cannon/P_FPArms_Cannon_Reload":
		#reloaded = true
		animation_player.play(&"Cannon/P_FPArms_Cannon_Idle")

func noninput_reload() -> void:
	if not is_active and not reloaded:
		reloaded = true
		print("reloading")

func rotate_cannon_within_clamp(new_rotation_x: float, new_rotation_y: float) -> void:
	cannon_barrel.rotation_degrees.x = clampf(cannon_barrel.rotation_degrees.x + new_rotation_x,-6,max_angle_x)
	cannon_rack.rotation_degrees.y = clampf(cannon_rack.rotation_degrees.y + new_rotation_y,min_angle_y,max_angle_y)

func recoil(power: float) -> void:
	var recoil_angle:= 70 - max_angle_x + 4.3
	
	var ratio: float= (power-5) / (max_power-5)
	var cannon_x: float = cannon_barrel.rotation_degrees.x +(
			(max_angle_x - cannon_barrel.rotation_degrees.x) * ratio)
	var player_x: float = cannon_x - recoil_angle * ratio
	
	var cannon_y: float = 15.0 * ratio
	if randi_range(0,1) == 1:
		cannon_y *= -1
	if cannon_y > 0:
		cannon_y = clampf(cannon_rack.rotation_degrees.y + cannon_y,min_angle_y,max_angle_y)
	else:
		cannon_y = clampf(cannon_rack.rotation_degrees.y - cannon_y,min_angle_y,max_angle_y)
	
	var cannon_tween := create_tween()
	cannon_tween.set_parallel(true)
	cannon_tween.tween_property(cannon_barrel,"rotation_degrees",Vector3(cannon_x,0,0),0.02)
	cannon_tween.tween_property(cannon_rack,"rotation_degrees",Vector3(0,cannon_y,0),0.1)
	cannon_tween.set_parallel(false)
	cannon_tween.tween_property(cannon_barrel,"rotation_degrees",Vector3(cannon_x - 4.8,0,0),0.25)
	await get_tree().create_timer(0.05).timeout
	if player_x < 0:
		var player_tween := create_tween()
		player_tween.tween_property(camera_positon,"rotation_degrees",Vector3(player_x,0,0),0.2)
		player_tween.tween_property(camera_positon,"rotation_degrees",Vector3.ZERO,0.5)
