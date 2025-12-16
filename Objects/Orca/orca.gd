#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends CharacterBody3D

const SPEED_MAX: float = 20.0
const CALC_SPEED: float = 11.0
const SPEED_ORBIT_MAX: float = 7.0
const ACC_MAX: float = 5.0
const DRAG: float = 1.0
enum STATES {IDLE, SEARCH, SWIM, CIRCLE, ATTACK}
enum STATES_ATK {OUT, IN, JUMP, CHARGE, DIVE}
static var scene_wave := preload("res://Objects/Wave/wave.tscn")


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
@export var _wave_manager: WaveManager
@export var _target: RigidBody3D

# State stuff:
var _state: STATES = STATES.IDLE
var _state_atk: STATES_ATK = STATES_ATK.OUT

# Navigation stuff:
var _waypoint := Vector3.ZERO
var _radius_orbit: float = 50.0
var _orbit_dir: bool = false
var _allow_pitch: bool = false

# Attack stuff:
var _dist_attack_start = 200.0
var _dist_attack_jump = 150.0
var _dist_attack_dive = 30.0
var _can_attack = false
var _jump_triggered = false;
var _is_jumping = false
var _jump_impulse := Vector3(0.0, 15.0, 0.0) 
var _dive_timeout: float

# Buoyancy PID controller:
const KP := 20.0
const KI := 2.0
const KD := 8.0
var _integral := 0.0
var _last_error := 0.0
var _inv_height := 0.0


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	_waypoint = Vector3(0.0, 0, 0.0)
	_state = STATES.ATTACK
	#_state = STATES.CIRCLE
	pass


func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	
	_handle_buoyancy(delta)
	_update_orientation(delta)
	#_apply_drag(delta)
	
	match _state:
		STATES.IDLE:
			pass
		STATES.SEARCH:
			pass
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
		
	move_and_slide()


#===============================================================================
#	SETUP:
#===============================================================================
func set_target(t: Node3D, wm: WaveManager) -> void:
	_jump_triggered = false
	_is_jumping = false
	_state_atk = STATES_ATK.OUT
	_target = t
	_wave_manager = wm


func _set_state(s: STATES) -> void:
	_end_attack()
	_state = s


#===============================================================================
#	STATES:
#===============================================================================
func _do_state_swim(delta: float, destination: Vector3) -> void:
	if global_position.distance_squared_to(destination) < 9:
		_state = STATES.IDLE
		return
	
	# GATE - Orca must be below max speed:
	if velocity.length() >= SPEED_MAX:
		return
	
	# Apply acceleration towards destination:
	var heading_desired = (destination - global_position).normalized()
	velocity += ACC_MAX * heading_desired * delta


func _do_state_circle(delta: float, target: Vector3) -> void:
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
		_state_atk = STATES_ATK.IN
		return
	
	var point_start := global_position + (-to_target.normalized() * 
			dist_to_start)
	_go_to_point(delta, point_start)
	return


func _do_atk_state_in(delta: float, target: Node3D) -> void:
	var to_target := target.global_position - global_position
	var dir = _compute_wave_solution()
	if not _can_attack:
		print("Orca has no attack solution...")
		_end_attack()
		return
	
	_go_to_point(delta, dir * to_target.length() * 2)
	
	if to_target.length_squared() <= _dist_attack_jump * _dist_attack_jump:
		_state_atk = STATES_ATK.JUMP
	
	return


func _do_atk_state_jump(target: Node3D) -> void:
	var data := Vector3(global_position.x, global_position.z, 
				(Time.get_ticks_msec() / 1000.0))
	var water_height = NoiseFunc.sample_at_pos_time(data)
	
	if not _jump_triggered:
		_allow_pitch = true
		velocity += _jump_impulse
		_jump_triggered = true
	
	if not _is_jumping and global_position.y > water_height + 0.5:
		_is_jumping = true
	
	if _is_jumping and global_position.y <= water_height:
		_allow_pitch = false
		_is_jumping = false
		
		var par = get_parent()
		if par:
			var to_target := target.global_position - global_position
			var wave: Wave = scene_wave.instantiate()
			par.add_child(wave)
			var pos := Vector3(global_position.x, 0.0, global_position.z)
			var dir := Vector3(-basis.z.x, 0.0, -basis.z.z).normalized()
			var tgt_point: Vector3 = pos + dir * to_target.length()
			wave.global_position = pos + -dir * 10.0
			wave.activate_wave(tgt_point, SPEED_MAX, 6.0, 
					_wave_manager)
		_state_atk = STATES_ATK.CHARGE
	
	return


func _do_atk_state_charge(delta: float, target: Node3D) -> void:
	var to_target := target.global_position - global_position
	#var dir = _compute_wave_solution()
	#if not _can_attack:
	#	print("Orca has no attack solution...")
	#	_end_attack()
	#	return
	
	#_go_to_point(delta, dir * to_target.length() * 2)
	_go_to_point(delta, global_position + -global_basis.z * 100)
	
	if to_target.length_squared() <= _dist_attack_dive * _dist_attack_dive \
		or to_target.length_squared() > _dist_attack_jump * _dist_attack_jump:
		_dive_timeout = Time.get_ticks_msec() + 5000
		_state_atk = STATES_ATK.DIVE
	
	return


func _do_atk_state_dive(delta: float) -> void:
	_set_swim_height(3)
	_go_to_point(delta, global_position + -global_basis.z * 100)
	
	if Time.get_ticks_msec() > _dive_timeout:
		_end_attack()
	
	return


#===============================================================================
#	PRIVATE FUNCTIONS:
#===============================================================================
func _apply_drag(delta: float) -> void:
	velocity -= velocity.normalized() * DRAG * delta


func _compute_wave_solution() -> Vector3:
	# Exit if cannon has no target
	if not _target:
		_can_attack = false
		return Vector3.ZERO
	
	# Get target position and velocity relative to cannon:
	var pos_self := Vector3(global_position.x, 0.0, global_position.z)
	var pos_tgt := Vector3(_target.global_position.x, 0.0, _target.global_position.z)
	#var vel_self := Vector3(velocity.x, 0.0, velocity.z)
	var vel_tgt := Vector3(_target.linear_velocity.x, 0.0, _target.linear_velocity.z)
	var pos_tgt_rel: Vector3 = pos_tgt - pos_self
	#var vel_tgt_rel: Vector3 = vel_tgt + vel_self
	var vel_tgt_rel: Vector3 = vel_tgt * 1.3
	
	# Form quadratic:
	#var a := vel_tgt_rel.length_squared() - CALC_SPEED * CALC_SPEED
	var a := vel_tgt_rel.length_squared() - CALC_SPEED * CALC_SPEED
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


func _end_attack(s: STATES = STATES.CIRCLE) -> void:
	print("Orca is ending attack.")
	_set_swim_height(1.0)
	_jump_triggered = false
	_is_jumping = false
	_state_atk = STATES_ATK.OUT
	_state = s


func _update_orientation(delta: float) -> void:
	if velocity.is_zero_approx():
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
	
	var tgt_tform := transform
	tgt_tform.basis = Basis.looking_at(v_norm, Vector3.UP)
	var turn_speed := 2.0
	transform = transform.interpolate_with(tgt_tform, turn_speed * delta)


# Gets turn direction
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
	
	# Cancel lateral velocity:
	if cancel_lat:
		var vel_lateral = _get_lateral_velocity(point)
		velocity -= vel_lateral
	
	if velocity.length_squared() > ms * ms:
		return
	
	velocity += ACC_MAX * heading_desired * delta
	return


# Handles buoyancy forces when the player is in the water:
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
#	PUBLIC FUNCTIONS:
#===============================================================================


#===============================================================================
#	EOF:
#===============================================================================
