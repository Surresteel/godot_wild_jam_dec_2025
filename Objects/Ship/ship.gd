#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Ship
extends RigidBody3D


#===============================================================================
#	NODE INITIALISATION:
#===============================================================================
# ENUMS:
enum EVENTS {WAVE, ICEBERG, SEALION}

# CONSTANTS:
const BUOYANCY_OFFSET_FOR: float = 0.4
const BUOYANCY_OFFSET_MID: float = 0.3
const BUOYANCY_OFFSET_AFT: float = 0.2
const SAMPLE_COUNT: int = 9
const BUOYANCY_MAX: float = 60_000.0
const BUOYANCY_MIN: float = 20_000.0
const DAMPING_COEF: float = 250.0
const MAX_DEPTH: float = 3.0 

const MAX_SPEED: float = 10.0
const MAX_ROTATION: float = 10.0

const WP_RADIUS: float = 50.0


# SIGNALS:
signal bow_hit_water()
signal wave_inbound()
signal enemy_spotted(sector: PenguinLookout.DIRECTIONS)

# BUOYANCY PRIVATE
var _buoyancy_coef: float = BUOYANCY_MAX / SAMPLE_COUNT
var _sample_points: PackedVector3Array

# FORCE PRIVATE:
var _force_to_apply := Vector3.ZERO
var _torque_to_apply := Vector3.ZERO

# NAVIGATION PRIVATE:
var _spawn := Vector3.ZERO
var _has_destination: bool = false
var _waypoint: Vector3 = Vector3.ZERO
var _waypoint_prev: Vector3 = Vector3.ZERO

# SETUP PUBLIC:
@export_group("Setup")
@export var spawner: Spawner
@export var wave_manager: WaveManager
@export var initial_waypoint := Vector3.ZERO

# GAMEPLAY PUBLIC:
@export_group("Gameplay")
@export var max_hitpoints: int = 100
@export var speed_base: float = 1.0
@export var momentum_gain: float = 0.01
@export var callout_distance: float = 200

# GAMEPLAY PRIVATE:
var _hitpoints: int = 100
var _speed_limit: float = MAX_SPEED
var _speed_mult: float = 1.0
var _timeout_hit_wave: float = 0.0
var _interval_hit_wave: float = 5.0
var _timeout_hit_icerberg: float = 0.0
var _interval_hit_iceberg: float = 30.0

# ENEMY LOOKOUT:
@onready var lookout: PenguinLookout = $PenguinLookout
var _callout_radius_wave: float = 50.0


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	_spawn = global_position
	
	if initial_waypoint.distance_squared_to(global_position) > 25:
		set_waypoint(initial_waypoint)
	
	# Forward
	_sample_points.append(Vector3(3.0, -BUOYANCY_OFFSET_FOR, 6.0))
	_sample_points.append(Vector3(0.0, -BUOYANCY_OFFSET_FOR, 6.0))
	_sample_points.append(Vector3(-3.0, -BUOYANCY_OFFSET_FOR, 6.0))
	# Mid
	_sample_points.append(Vector3(3.2, -BUOYANCY_OFFSET_MID, -1.0))
	_sample_points.append(Vector3(0.0, -BUOYANCY_OFFSET_MID, -1.0))
	_sample_points.append(Vector3(-3.2, -BUOYANCY_OFFSET_MID, -1.0))
	# Aft
	_sample_points.append(Vector3(2.0, -BUOYANCY_OFFSET_AFT, -8.0))
	_sample_points.append(Vector3(0.0, -BUOYANCY_OFFSET_AFT, -8.0))
	_sample_points.append(Vector3(-2.0, -BUOYANCY_OFFSET_AFT, -8.0))
	
	body_entered.connect(_handle_collisions)
	
	if not spawner:
		return
	
	lookout.setup(self, spawner)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	print(get_progress_wp())
	if _has_destination:
		_go_to_point(_waypoint)
	
	_apply_buoyancy_forces(state)
	_apply_internal_forces(state)
	_handle_momentum_gain(state)


#===============================================================================
#	GAMEPLAY:
#===============================================================================
func _handle_momentum_gain(state: PhysicsDirectBodyState3D) -> void:
	if _speed_mult >= _speed_limit:
		return
	
	_speed_mult += momentum_gain * state.step


func _handle_events(event: EVENTS, severity: float = 1.0) -> void:
	match event:
		EVENTS.WAVE:
			if Time.get_ticks_msec() > _timeout_hit_wave:
				_hitpoints -= 5 * int(severity)
				_speed_mult = max(_speed_mult - severity, 1.0)
				_timeout_hit_wave = Time.get_ticks_msec() + _interval_hit_wave \
						* 1000
		EVENTS.ICEBERG:
			if Time.get_ticks_msec() > _timeout_hit_icerberg:
				_hitpoints -= 5 * int(severity)
				_speed_mult = max(_speed_mult - severity, 1.0)
				_timeout_hit_icerberg = Time.get_ticks_msec() + \
						_interval_hit_iceberg * 1000
		EVENTS.SEALION:
			pass
	
	if _hitpoints < float(max_hitpoints) * 0.5:
		_speed_limit = remap(_hitpoints, 0, max_hitpoints, 1, MAX_SPEED)
		var new_buoyancy = remap(_hitpoints, 0, max_hitpoints, 
				BUOYANCY_MIN, BUOYANCY_MAX)
		_buoyancy_coef = new_buoyancy / SAMPLE_COUNT


#===============================================================================
#	COLLISION HANDLING:
#===============================================================================
func _handle_collisions(body: Node) -> void:
	if body is IcebergBase or body is IcebergBaseSimple:
		var speed_sqr = linear_velocity.length_squared()
		var berg_strength = body.onion_layers * body.onion_layers
		var dif = speed_sqr - berg_strength
		if dif < 0:
			_handle_events(EVENTS.ICEBERG, abs(dif))


#===============================================================================
#	PRIVATE FUNCTIONS:
#===============================================================================
# Compute and apply buoyancy forces:
func _apply_buoyancy_forces(state: PhysicsDirectBodyState3D) -> void:
	# Loop through buoyancy sample points and compute their forces:
	for point in _sample_points:
		# Buoyancy forces:
		var pos_glb_point = state.transform.origin + state.transform.basis \
				* point
		var data := Vector3(pos_glb_point.x, pos_glb_point.z, 
				(Time.get_ticks_msec() / 1000.0))
				
		# Wave heights:
		var h1: float = -100.0
		var highest_wave: WaveManager.WaveData = null
		if wave_manager:
			var w_data: Array[WaveManager.WaveData] = wave_manager.get_waves()
			for wave in w_data:
				var offset = Vector2(pos_glb_point.x - wave.pos.x,
						pos_glb_point.z - wave.pos.y)
				_callout_wave(offset, wave.dir)
				var h_temp = WaveFunc.sample_wave_height(wave.pos, offset, 
						wave.dir, wave.amp)
				if h_temp != 0 and h_temp > h1:
					highest_wave = wave
					h1 = h_temp
			
		
		var h2: float = NoiseFunc.sample_at_pos_time(data)
		var water_height = maxf(h1, h2)
		var depth: float = water_height - pos_glb_point.y
		var depth_fraction = clamp(depth / MAX_DEPTH, 0.0, 1.0)
		var buoyancy_force = _buoyancy_coef * depth_fraction
		
		# Audio Stuff:
		if point == _sample_points[1] and water_height > 2.5:
			bow_hit_water.emit()
		
		# Wave forces:
		var wave_force := Vector3.ZERO
		if (h1 > h2) and highest_wave:
			_handle_events(EVENTS.WAVE)
			wave_force = highest_wave.vel.normalized() * \
					highest_wave.vel.length() * highest_wave.vel.length() \
					* 5000 * highest_wave.amp * 10 + Vector3(0, 1000, 0) * \
					highest_wave.amp
			wave_force /= SAMPLE_COUNT
			state.apply_force(wave_force, pos_glb_point - 
					state.transform.origin)
		
		# Dampening forces:
		var damping_force := 0.0
		if depth > -0.5:
			var point_velocity := state.get_velocity_at_local_position(
					pos_glb_point - state.transform.origin)
			var vertical_velocity := point_velocity.dot(Vector3.UP)
			damping_force = -vertical_velocity * DAMPING_COEF
		
		# Apply forces
		var point_force: Vector3 = Vector3.UP * (buoyancy_force + damping_force)
		state.apply_force(point_force, pos_glb_point - state.transform.origin)


func _callout_wave(to_wave: Vector2, wave_dir: Vector2) -> void:
	if to_wave.length_squared() > _callout_radius_wave * _callout_radius_wave:
		return
	
	if wave_dir.dot(-to_wave) > 0.7:
		wave_inbound.emit()


# Apply forces internal to the ship (steering, propulsion):
func _apply_internal_forces(state: PhysicsDirectBodyState3D) -> void:
	var force := _force_to_apply
	var v := Vector3(state.linear_velocity.x, 0.0, state.linear_velocity.z)
	var speed_cap = clampf(speed_base * _speed_mult, 0.0, MAX_SPEED)
	if v.length() >= speed_cap and v.length() > 0.001:
		var v_dir := v.normalized()
		var forward_force := v_dir * force.dot(v_dir)
		force -= forward_force
	
	state.apply_force(force, state.center_of_mass)
	
	var torque := _torque_to_apply
	if state.angular_velocity.length() < MAX_ROTATION:
		state.apply_torque(torque)
	
	_force_to_apply = Vector3.ZERO
	_torque_to_apply = Vector3.ZERO
	
	return


# Steers and propels the ship to point 'p':
func _go_to_point(p: Vector3) -> void:
	var to_point = global_position - p
	var dir = to_point.normalized()
	var angle = dir.signed_angle_to(global_basis.z, Vector3.UP)
	
	if angle < -0.05 or angle > 0.05:
		if angle > 0:
			turn_left()
		else:
			turn_right()
	
	if to_point.length_squared() <= WP_RADIUS:
		_has_destination = false
		print("WP reached")
	else:
		move_forwards()


#===============================================================================
#	PUBLIC FUNCTIONS:
#===============================================================================
# Moves the ship forwards:
func move_forwards() -> void:
	_force_to_apply += 2000.0 * -self.transform.basis.z


func turn_left(torque: float = 250.0) -> void:
	var vel_forward = linear_velocity.dot(global_basis.z)
	var momentum =  remap(vel_forward, 0.0, 2.0, 0.0, 1.0)
	_torque_to_apply += torque * Vector3.UP * momentum


func turn_right(torque: float = 250.0) -> void:
	var vel_forward = linear_velocity.dot(global_basis.z)
	var momentum =  remap(vel_forward, 0.0, 2.0, 0.0, 1.0)
	_torque_to_apply -= torque * Vector3.UP * momentum


func set_waypoint(wp: Vector3) -> void:
	_waypoint_prev = _waypoint
	_has_destination = true
	_waypoint = wp


func get_progress_wp() -> float:
	if not _has_destination:
		return 1.0
	
	var dist_wp := (_waypoint - _waypoint_prev).length()
	var dist_ship := (_waypoint - global_position).length()
	var prog = 1.0 - (dist_ship / dist_wp)
	prog = clampf(prog, 0.0, 1.0)
	return prog


func get_progress_total() -> float:
	if not _has_destination:
		return 1.0
	
	var dist_wp := (_waypoint - _spawn).length()
	var dist_ship := (_waypoint - global_position).length()
	var prog = 1.0 - (dist_ship / dist_wp)
	prog = clampf(prog, 0.0, 1.0)
	return prog


func emit_spotted(sector: PenguinLookout.DIRECTIONS) -> void:
	enemy_spotted.emit(sector)


#===============================================================================
#	EOF:
#===============================================================================
