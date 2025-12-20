#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Orca
extends CharacterBody3D

const LAYER_CANNONBALL := (1 << 3)

enum STATES {IDLE, FOLLOW, SWIM, CIRCLE, ATTACK}
enum STATES_ATK {OUT, IN, JUMP, CHARGE, DIVE}
const STATES_ARR_PASSIVE: Array[STATES] = [STATES.FOLLOW, STATES.CIRCLE]
const SPEED_MAX: float = 20.0
const CALC_SPEED: float = 10.0
const SPEED_ORBIT_MAX: float = 7.0
const ACC_MAX: float = 5.0
const DRAG: float = 1.0
static var scene_wave := preload("res://Objects/Wave/wave.tscn")
static var scene_death := preload(
		"res://Particle_Effects/death_chunks_generic.tscn")


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
@export var _wave_manager: WaveManager
@export var _target: RigidBody3D
#@export var debug: Node3D

@onready var _area_3d: Area3D = $CollisionArea
@onready var _anim_player: AnimationPlayer = $Orca_AnimatedDone/AnimationPlayer
@onready var _audio_emitter: AudioStreamPlayer3D = $AudioEmitter

# State stuff:
var _state: STATES = STATES.IDLE
var _state_atk: STATES_ATK = STATES_ATK.OUT
var _state_interval: float = 30.0
var _attack_interval: float = 60.0
var _state_timeout: float = 0.0
var _attack_timeout: float = 0.0

# Navigation stuff:
var _waypoint := Vector3.ZERO
var _waypoint_radius: float = 100.0
var _radius_orbit: float = 50.0
var _orbit_dir: bool = false
var _allow_pitch: bool = true
var _lateral_fraction := 0.1
var _set_orientation := Vector3.ZERO
var _timout_impact: float = 0.0
var _interval_impact: float = 15.0 * 1000

# Follow stuff:
var _dist_follow: float = 30.0
var _var_follow: float = 5.0
var _dir_follow := Vector3.RIGHT

# Attack stuff:
var _dist_attack_start = 200.0
var _dist_attack_jump = 150.0
var _dist_attack_dive = 40.0
var _can_attack = false
var _jump_triggered = false;
var _is_jumping = false
var _jump_impulse := Vector3(0.0, 20.0, 0.0) 
var _dive_timeout: float

# Buoyancy PID controller:
const KP := 5.0
const KI := 2.0
const KD := 8.0
var _integral := 0.0
var _last_error := 0.0
var _inv_height := -1.0


# Collision stuff:
const IMPACT_DEATH_THRESH: float = 4


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	_attack_timeout = Time.get_ticks_msec() + _attack_interval * 1000
	_area_3d.body_entered.connect(_handle_collision)
	_state = STATES.FOLLOW
	pass


func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	
	_handle_state()
	_handle_buoyancy(delta)
	_update_orientation(delta)
	if Engine.get_physics_frames() % (30 * 60) == 0:
		_update_state_characteristics()
	
	match _state:
		STATES.IDLE:
			pass
		STATES.FOLLOW:
			if _target:
				_do_state_follow(delta, _target)
			else:
				print("Orca has no target; it cannot follow.")
				_state = STATES.IDLE
		STATES.SWIM:
			if _target:
				_do_state_swim(delta, _target.global_position)
			else:
				_do_state_swim(delta, _waypoint)
		STATES.CIRCLE:
			if _target:
				_do_state_circle(delta, _target.global_position)
			else:
				_do_state_circle(delta, _waypoint)
		STATES.ATTACK:
			if _target:
				_do_state_attack(delta, _target)
			else:
				print("Orca has no target; it cannot attack.")
				_state = STATES.IDLE
		
	move_and_slide()


#===============================================================================
#	SETUP:
#===============================================================================
func assign_wave_manager(wm: WaveManager) -> void:
	_wave_manager = wm


func set_target(t: Node3D, go_to: bool = true) -> void:
	_jump_triggered = false
	_is_jumping = false
	_state_atk = STATES_ATK.OUT
	_target = t
	
	if go_to:
		_set_state(STATES.SWIM)


func _set_state(s: STATES, reset_TO: bool = false, anim: String = "") -> void:
	if anim != "":
		_play_anim(anim)
	if reset_TO:
		_state_timeout = Time.get_ticks_msec() + _state_interval * 1000
	
	_set_orientation = Vector3.ZERO
	
	_state = s


func _set_state_rand(s_arr: Array[STATES], reset_timeout: bool = false) -> void:
	var item = s_arr[randi() % s_arr.size()] 
	_set_state(item, reset_timeout, "Swimming")


func _update_state_characteristics() -> void:
	_orbit_dir = randi() & 1
	match (randi() & 1):
		0:
			_dir_follow = Vector3.RIGHT * ((randi() % 3) - 1)
		1:
			_dir_follow = Vector3.FORWARD * ((randi() % 3) - 1)
	
	_dist_follow = randf_range(20.0, 50.0)


#===============================================================================
#	COLLISION HANDLING:
#===============================================================================
func _handle_collision(body: Node3D) -> void:
	# If they hit a ship and the velocity transfers, it kills them.
	if body is Ship:
		var to_self = (global_position - body.global_position).normalized()
		var vel := Vector3(body.linear_velocity.x, 0.0, body.linear_velocity.z)
		var vel_transfer = vel.dot(to_self)
		
		if vel_transfer < IMPACT_DEATH_THRESH:
			if Time.get_ticks_msec() > _timout_impact:
				velocity += _jump_impulse
				_timout_impact = Time.get_ticks_msec() + _interval_impact
		else:
			_die()
		return
	
	# If a cannonball hits them, they die:
	if body is CannonBall:
		_die()
	
	# If they hit an iceberg, they go underwater:
	if body is IcebergBase or body is IcebergBaseSimple:
		velocity += Vector3(0.0, -15.0, 0.0)
	
	if body is Orca:
		_play_anim("Surface")


func _die() -> void:
	var blood: Node3D = scene_death.instantiate()
	get_tree().current_scene.add_child(blood)
	blood.global_position = global_position
	queue_free()


#===============================================================================
#	ANIMATIONS:
#===============================================================================
func _play_anim(anim: String, blend: float = 1, speed: float = 1.0) -> void:
	_anim_player.play(anim, blend, speed)
	_anim_player.queue("Swimming")


#===============================================================================
#	STATES:
#===============================================================================
func _handle_state() -> void:
	if _state == STATES.ATTACK or _state == STATES.SWIM:
		return
	
	if Time.get_ticks_msec() > _attack_timeout:
		_audio_emitter.stream = AudioManager.ORCA_ATTACK_START
		_audio_emitter.play()
		_set_state(STATES.ATTACK, false, "Surface")
		return
	
	if Time.get_ticks_msec() > _state_timeout:
		_set_state_rand(STATES_ARR_PASSIVE, true)
		return


func _do_state_swim(delta: float, destination: Vector3) -> void:
	if global_position.distance_squared_to(destination) < _waypoint_radius \
			* _waypoint_radius:
		_audio_emitter.stream = AudioManager.ORCA_ARRIVE
		_audio_emitter.play()
		_state = STATES.IDLE
		return
	
	_go_to_point(delta, destination)


func _do_state_follow(delta: float, target: Node3D) -> void:
	# Determin follow position
	var dir_global = target.global_basis * (_dir_follow * _dist_follow)
	var wp = target.global_position + dir_global
	
	# Apply variation to the follow position:
	var t = Time.get_ticks_msec() / 1000.0
	var vari_lat = _var_follow * target.global_basis.x * sin(TAU * t / 10.0)
	var vari_long = _var_follow * target.global_basis.z * sin(TAU * t / 12.0)
	wp += vari_lat + vari_long
	wp.y = global_position.y
	
	# Follow behaviour when close versus far away:
	if (wp - global_position).length() < 1:
		var lookat_point = target.global_position + -target.global_basis.z * 50
		_set_orientation = (lookat_point - global_position).normalized()
		#global_position.x = wp.x
		#global_position.z = wp.z
		_go_to_point(delta, wp)
		_allow_pitch = true
		#_go_to_point(delta, wp, SPEED_ORBIT_MAX, false)
	else:
		_set_orientation = Vector3.ZERO
		_go_to_point(delta, wp)
	


func _do_state_circle(delta: float, target: Vector3) -> void:
	if (_target.global_position - global_position).length_squared() < 100:
		_set_swim_height(10)
	else:
		_set_swim_height(1)
	
	var to_point := global_position - target
	var dir := to_point.normalized()
	
	# Calculate next waypoint in orbit:
	var to_point_next: Vector3
	if _orbit_dir:
		to_point_next = dir.rotated(Vector3.UP, 0.2)
	else:
		to_point_next = dir.rotated(Vector3.UP, -0.2)
	
	# Go to waypoint:
	var point_next := target + to_point_next * _radius_orbit
	if to_point.length_squared() > (_radius_orbit * _radius_orbit) * 1.2:
		_go_to_point(delta, point_next)
	else:
		_go_to_point(delta, point_next, SPEED_ORBIT_MAX)
	
	return


func _do_state_attack(delta: float, target: Node3D) -> void:
	match _state_atk:
		STATES_ATK.OUT:
			_do_atk_state_out(delta, target)
		STATES_ATK.IN:
			_do_atk_state_in(delta, target)
		STATES_ATK.JUMP:
			_do_atk_state_jump(target)
		STATES_ATK.CHARGE:
			_do_atk_state_charge(delta, target)
		STATES_ATK.DIVE:
			_do_atk_state_dive(delta)


func _do_atk_state_out(delta: float, target: Node3D) -> void:
	var to_target := target.global_position - global_position
	var dist_to_start: float = _dist_attack_start - to_target.length()
	
	if dist_to_start <= 5:
		_state_timeout = Time.get_ticks_msec() + 30 * 1000
		_state_atk = STATES_ATK.IN
		return
	
	var point_start := global_position + (-to_target.normalized() * 
			dist_to_start)
	_go_to_point(delta, point_start)
	return


func _do_atk_state_in(delta: float, target: Node3D) -> void:
	var to_target := target.global_position - global_position
	var dir = _compute_wave_solution()
	if not _can_attack or Time.get_ticks_msec() > _state_timeout:
		print("Orca has no attack solution...")
		_end_attack()
		return
	
	_go_to_point(delta, global_position + dir * to_target.length() * 1.25)
	
	if to_target.length_squared() <= _dist_attack_jump * _dist_attack_jump:
		_state_atk = STATES_ATK.JUMP
	
	return


func _do_atk_state_jump(target: Node3D) -> void:
	var data := Vector3(global_position.x, global_position.z, 
				(Time.get_ticks_msec() / 1000.0))
	var water_height = NoiseFunc.sample_at_pos_time(data)
	
	if not _jump_triggered:
		_audio_emitter.stream = AudioManager.ORCA_JUMP
		_audio_emitter.play()
		_play_anim("Dive Bomb", -1, 1.5)
		_set_swim_height(4)
		_allow_pitch = true
		velocity += _jump_impulse
		_jump_triggered = true
	
	if not _is_jumping and global_position.y > water_height + 0.5:
		_is_jumping = true
	
	if _is_jumping and global_position.y <= water_height:
		#_allow_pitch = false
		_is_jumping = false
		
		#var par = get_parent()
		var to_target := target.global_position - global_position
		var wave: Wave = scene_wave.instantiate()
		get_tree().current_scene.add_child(wave)
		var pos := Vector3(global_position.x, 0.0, global_position.z)
		var dir := Vector3(-basis.z.x, 0.0, -basis.z.z).normalized()
		var tgt_point: Vector3 = pos + dir * to_target.length()
		wave.global_position = pos + -dir * 10.0
		wave.activate_wave(tgt_point, SPEED_MAX, 6.0, 
					_wave_manager)
		_state_atk = STATES_ATK.CHARGE
	
	return


func _do_atk_state_charge(delta: float, target: Node3D) -> void:
	_set_swim_height(1)
	var to_target := target.global_position - global_position
	
	_go_to_point(delta, global_position + -global_basis.z * 100, SPEED_MAX, 
			false)
	
	if to_target.length_squared() <= _dist_attack_dive * _dist_attack_dive \
		or to_target.length_squared() > _dist_attack_jump * _dist_attack_jump:
		_dive_timeout = Time.get_ticks_msec() + 5000
		_play_anim("Dive")
		_state_atk = STATES_ATK.DIVE
	
	return


func _do_atk_state_dive(delta: float) -> void:
	_set_swim_height(5)
	_go_to_point(delta, global_position + -global_basis.z * 100)
	
	if Time.get_ticks_msec() > _dive_timeout:
		_end_attack()
	
	return


#===============================================================================
#	PRIVATE FUNCTIONS:
#===============================================================================
func _compute_wave_solution() -> Vector3:
	# Exit if cannon has no target
	if not _target:
		_can_attack = false
		return Vector3.ZERO
	
	# Get target position and velocity relative to cannon:
	var pos_self := Vector3(global_position.x, 0.0, global_position.z)
	var pos_tgt := Vector3(_target.global_position.x, 0.0, 
			_target.global_position.z)
	var vel_tgt := Vector3(_target.linear_velocity.x, 0.0, 
			_target.linear_velocity.z)
	var pos_tgt_rel: Vector3 = pos_tgt - pos_self
	var vel_tgt_rel: Vector3 = vel_tgt
	
	# Form quadratic:
	var a := vel_tgt_rel.length_squared() - SPEED_MAX * SPEED_MAX
	var b := 2 * pos_tgt_rel.dot(vel_tgt_rel)
	var c := pos_tgt_rel.length_squared()
	
	# Solve quadratic for time to intercept:
	var roots: Array[float] = MathFunc.solve_quadratic(a, b, c)
	
	# Extract relevant root:
	var roots_positive := roots.filter(func(r): return r > 0.0)
	if roots_positive.is_empty():
		_can_attack = false
		return Vector3.ZERO
	var time_intercept: float = roots_positive.min()
	
	# Apply time to target trajectory to get intercept point:
	var pos_intercept := pos_tgt_rel + vel_tgt_rel * time_intercept
	var dir_fire := pos_intercept.normalized()
	
	# Signal vaild solution and return:
	_can_attack = true
	return dir_fire


func _end_attack(s_arr: Array[STATES] = STATES_ARR_PASSIVE) -> void:
	_set_swim_height(1.0)
	_jump_triggered = false
	_is_jumping = false
	_state_atk = STATES_ATK.OUT
	_attack_timeout = Time.get_ticks_msec() + _attack_interval * 1000
	_set_state_rand(s_arr)


func _update_orientation(delta: float) -> void:
	if velocity.is_zero_approx():
		return
	
	var turn_speed := 1.0
	var tgt_tform := transform
	
	if not _set_orientation.is_zero_approx():
		tgt_tform.basis = Basis.looking_at(_set_orientation, Vector3.UP)
		transform = transform.interpolate_with(tgt_tform, turn_speed * delta)
		return
	
	# GATE - Orca can't already be oriented:
	var v_norm: Vector3
	if _allow_pitch:
		v_norm = velocity.normalized()
	else:
		v_norm = Vector3(velocity.x, 0.0, velocity.z).normalized()
		
	if v_norm.is_zero_approx():
		return
	
	if basis.z.dot(v_norm) < -0.999 or abs(Vector3.UP.dot(v_norm)) > 0.999:
		return
	
	tgt_tform.basis = Basis.looking_at(v_norm, Vector3.UP)
	transform = transform.interpolate_with(tgt_tform, turn_speed * delta)


## Gets turn direction
func _get_turn_direction() -> float:
	if velocity.length_squared() == 0.0:
		return 0.0
	
	var forward := -basis.z
	var forward_ideal := velocity.normalized()
	var cross := forward.cross(forward_ideal)
	var s := signf(cross.dot(Vector3.UP))
	
	return s


func _get_lateral_velocity(point: Vector3) -> Vector3:
	var to_point := (point - global_position).normalized()
	var longitudinal := to_point * velocity.dot(to_point)
	var lateral = velocity - longitudinal
	return Vector3(lateral.x, 0.0, lateral.z)


func _go_to_point(delta:float, point: Vector3, ms: float = SPEED_MAX, 
		cancel_lat: bool = true) -> void:
	var heading_desired = (point - global_position).normalized()
	#debug.global_position = point
	
	# Cancel lateral velocity:
	if cancel_lat:
		var vel_lateral = _get_lateral_velocity(point)
		velocity -= vel_lateral * _lateral_fraction
	
	var new_vel = velocity + ACC_MAX * heading_desired * delta
	if new_vel.length_squared() > ms * ms:
		return
	
	velocity += ACC_MAX * heading_desired * delta
	return


## Handles buoyancy forces when the node is in the water:
func _handle_buoyancy(delta: float) -> void:
	var data := Vector3(global_position.x, global_position.z, 
				(Time.get_ticks_msec() / 1000.0))
	var water_height = NoiseFunc.sample_at_pos_time(data)
	
	if global_position.y - _inv_height < water_height:
		var error = water_height - (global_position.y - _inv_height)
		_integral += error * delta
		var derivative = (error - _last_error) / delta
		_last_error = error
		
		var output = KP * error + KI * _integral + KD * derivative
		velocity.y += output * delta
		
	return


func _set_swim_height(height: float) -> void:
	_inv_height = -height


#===============================================================================
#	EOF:
#===============================================================================
