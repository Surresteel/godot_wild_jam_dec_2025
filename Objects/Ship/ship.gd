#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Ship
extends RigidBody3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
# ENUMS:
enum EVENTS {WAVE, ICEBERG, SEALION}

# CONSTANTS - BUOYANCY:
const BUOYANCY_OFFSET_FOR: float = 0.4
const BUOYANCY_OFFSET_MID: float = 0.3
const BUOYANCY_OFFSET_AFT: float = 0.2
const SAMPLE_COUNT: int = 9
const BUOYANCY_MAX: float = 60_000.0
const BUOYANCY_MIN: float = 20_000.0
const DAMPING_COEF: float = 250.0
const MAX_DEPTH: float = 3.0 

# CONSTANTS: - NAVIGATION
const MAX_SPEED: float = 10.0
const MAX_ROTATION: float = 10.0
const WP_RADIUS: float = 30.0


#===============================================================================
#	INSTANCE MEMBERS:
#===============================================================================
# SIGNALS:
signal bow_hit_water()
signal wave_inbound()
signal iceberg_hit(did_damage: bool)
signal enemy_spotted(sector: PenguinLookout.DIRECTIONS)

# PHYSICS PRIVATE
var _buoyancy_coef: float = BUOYANCY_MAX / SAMPLE_COUNT
var _sample_points: PackedVector3Array
var _force_to_apply := Vector3.ZERO
var _torque_to_apply := Vector3.ZERO

# SETUP PUBLIC:
@export_group("Setup")
@export var spawner: Spawner
@export var wave_manager: WaveManager
@export var helmsman: HelmsmenPenguin

# NAVIGATION PUBLIC:
@export_group("Navigation")
@export var initial_waypoint := Vector3.ZERO
@export var waypoint_override_object: Node3D = null

# NAVIGATION PRIVATE:
var _spawn := Vector3.ZERO
var _has_destination: bool = false
var _waypoint: Vector3 = Vector3.ZERO
var _waypoint_prev: Vector3 = Vector3.ZERO

# GAMEPLAY PUBLIC:
@export_group("Gameplay")
@export var max_hitpoints: int = 100
@export var speed_base: float = 1.0
@export var momentum_gain: float = 0.05
@export var callout_distance: float = 200

# GAMEPLAY PRIVATE:
var _hitpoints: int = 100
var _speed_limit: float = MAX_SPEED
var _speed_mult: float = 1.0
var _damage_thresh: float = 0.75
var _timeout_hit_wave: float = 0.0
var _interval_hit_wave: float = 5.0 * 1000.0
var _timeout_hit_ice: float = 0.0
var _interval_hit_ice: float = 5.0 * 1000.0
var _timeout_sealion: float = 0.0
var _interval_sealion: float = 2.0 * 1000.0
var _has_driver: bool = true
var _veer_dir: bool = true
var _has_failed: bool = false

# ENEMY LOOKOUT:
@onready var lookout: PenguinLookout = $PenguinLookout
var _callout_radius_wave: float = 50.0

# SEALION DETECTION:
@onready var sealion_detector: Area3D = $SealionDetector
var sealion_amount: int = 0

# CANNON REFERENCES:
var cannons: Array[Cannon]


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	# Enqueue post ready call:
	call_deferred("_post_ready")
	
	# Logging initial spawn point:
	_spawn = global_position
	
	# Handling initial waypoint:
	if waypoint_override_object:
		var wp := waypoint_override_object.global_position
		var dir := (global_position - wp).normalized()
		wp = wp + dir * 10
		set_waypoint(wp)
	elif initial_waypoint.distance_squared_to(global_position) > 25:
		set_waypoint(initial_waypoint)
	
	# Assiging buoyancy points:
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
	
	# Setup lookout node:
	if spawner:
		lookout.setup(self, spawner)


func _post_ready() -> void:
	# Initialise hitpoints:
	_hitpoints = max_hitpoints
	
	# Connect collision signals:
	body_entered.connect(_handle_collisions)
	
	# Connect to helmsman signals:
	if helmsman:
		helmsman.steering_started.connect(_driver_toggle.bind(true))
		helmsman.steering_stopped.connect(_driver_toggle.bind(false))
	
	# Connect to sealion detection area signals:
	sealion_detector.body_entered.connect(_sealion_tally.bind(true))
	sealion_detector.body_exited.connect(_sealion_tally.bind(false))
	
	# Fill cannons array for power meter UI:
	cannons.append($Cannons/Cannon)
	cannons.append($Cannons/Cannon2)
	cannons.append($Cannons/Cannon3)
	cannons.append($Cannons/Cannon4)
	cannons.append($Cannons/Cannon5)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# Determine ship behaviour based on driver presence:
	if _has_driver and _has_destination:
		_go_to_point(_waypoint)
	elif not _has_driver and _has_destination:
		move_forwards()
		turn_left()
	
	# Handle gameplay elements:
	_check_upside_down()
	_handle_momentum_gain(state)
	if not _has_driver:
		_handle_events(EVENTS.SEALION, 1.0)
	
	# Handle physics-based elements:
	_apply_buoyancy_forces(state)
	_apply_internal_forces(state)


#===============================================================================
#	GAMEPLAY:
#===============================================================================
# Slowly builds the ship's speed modifier over time:
func _handle_momentum_gain(state: PhysicsDirectBodyState3D) -> void:
	if _speed_mult >= _speed_limit:
		return
	
	_speed_mult += momentum_gain * state.step


# Handle the outcomes of events that the ship encounters:
func _handle_events(event: EVENTS, severity: float = 1.0) -> void:
	match event:
		EVENTS.WAVE:
			if Time.get_ticks_msec() > _timeout_hit_wave:
				_hitpoints -= 10 * int(severity)
				_speed_mult = max(_speed_mult - severity, 1.0)
				_timeout_hit_wave = Time.get_ticks_msec() + _interval_hit_wave
		EVENTS.ICEBERG:
			if Time.get_ticks_msec() > _timeout_hit_ice:
				_hitpoints -= 10 * int(severity)
				_speed_mult = max(_speed_mult - severity, 1.0)
				_timeout_hit_ice = Time.get_ticks_msec() + _interval_hit_ice
		EVENTS.SEALION:
			if Time.get_ticks_msec() > _timeout_sealion:
				_hitpoints -= 1 * int(severity)
				_speed_mult = max(_speed_mult - severity * 0.2, 1.0)
				_timeout_sealion = Time.get_ticks_msec() + _interval_sealion
	
	# Handicap the ship if health is lower than _damage_thresh:
	var upper_bound = float(max_hitpoints) * _damage_thresh
	if _hitpoints < upper_bound:
		_speed_limit = remap(_hitpoints, 0, upper_bound, 1, MAX_SPEED)
		var new_buoyancy = remap(_hitpoints, 0, upper_bound, 
				BUOYANCY_MIN, BUOYANCY_MAX)
		_buoyancy_coef = new_buoyancy / SAMPLE_COUNT
	
	# End the game if hitpoints hit zero:
	if _hitpoints <= 0:
		_game_over()


#===============================================================================
#	COLLISION HANDLING:
#===============================================================================
# Handle collisions between the ship and other objects:
func _handle_collisions(body: Node) -> void:
	if body is IcebergBase or body is IcebergBaseSimple:
		var speed = linear_velocity.length()
		if speed < body.break_velocity:
			_handle_events(EVENTS.ICEBERG, ceil(speed))
		
		iceberg_hit.emit(speed < body.break_velocity)


#===============================================================================
#	PRIVATE FUNCTIONS:
#===============================================================================
# Tally sealions on board:
func _sealion_tally(body:Node3D, toggle: bool) -> void:
	if body is Sealion:
		if toggle:
			sealion_amount += 1
		else:
			sealion_amount -= 1


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
		
		
		# Determine if wave or water is higher:
		var h2: float = NoiseFunc.sample_at_pos_time(data)
		var water_height = maxf(h1, h2)
		var depth: float = water_height - pos_glb_point.y
		var depth_fraction = clamp(depth / MAX_DEPTH, 0.0, 1.0)
		var buoyancy_force = _buoyancy_coef * depth_fraction
		
		# Play the audio bow splash if height change is enough:
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


# Emit a signal if a wave is approaching the ship:
func _callout_wave(to_wave: Vector2, wave_dir: Vector2) -> void:
	if to_wave.length_squared() > _callout_radius_wave * _callout_radius_wave:
		return
	
	if wave_dir.dot(-to_wave) > 0.7:
		wave_inbound.emit()


# Apply forces internal to the ship (steering, propulsion):
func _apply_internal_forces(state: PhysicsDirectBodyState3D) -> void:
	# Apply linear forces:
	var force := _force_to_apply
	var v := Vector3(state.linear_velocity.x, 0.0, state.linear_velocity.z)
	var speed_cap = clampf(speed_base * _speed_mult, 0.0, MAX_SPEED)
	if v.length() >= speed_cap and v.length() > 0.001:
		var v_dir := v.normalized()
		var forward_force := v_dir * force.dot(v_dir)
		force -= forward_force
	
	state.apply_force(force, state.center_of_mass)
	
	# Apply rotational forces:
	var torque := _torque_to_apply
	if state.angular_velocity.length() < MAX_ROTATION:
		state.apply_torque(torque)
	
	# Zero frame force tallies:
	_force_to_apply = Vector3.ZERO
	_torque_to_apply = Vector3.ZERO
	
	return


# Steers and propels the ship to point 'p':
func _go_to_point(p: Vector3) -> void:
	# Get signed angle to point p:
	var to_point = global_position - p
	var dir = to_point.normalized()
	var angle = dir.signed_angle_to(global_basis.z, Vector3.UP)
	
	# Determine turn direction:
	if angle < -0.05 or angle > 0.05:
		if angle < 0:
			turn_left()
		else:
			turn_right()
	
	# Determine if point p is reached:
	if to_point.length_squared() <= WP_RADIUS * WP_RADIUS:
		_has_destination = false
		ProgressionManager.mission_complete()
	else:
		move_forwards()


# Toggles the _has_driver bool and randomises veer direction:
func _driver_toggle(value: bool) -> void:
	_has_driver = value
	if not value:
		_veer_dir = randi() & 1


# Triggers the _fail_mission co-routine:
func _game_over() -> void:
	_has_failed = true
	_fail_mission()


# Checks if the ship is up-side-down:
func _check_upside_down() -> void:
	if self.global_basis.y.dot(Vector3.DOWN) > 0.4 and not _has_failed:
		_has_failed = true
		_fail_mission()


# Provides a small delay to a failed mission to avoid abrupt end:
func _fail_mission() -> void:
	await get_tree().create_timer(10.0).timeout
	ProgressionManager.mission_failed()
	


#===============================================================================
#	PUBLIC FUNCTIONS:
#===============================================================================
## Moves the ship forwards:
func move_forwards() -> void:
	_force_to_apply += 2000.0 * -self.transform.basis.z


## Turns the ship left by the provided torque:
func turn_left(torque: float = 250.0) -> void:
	var vel_forward = linear_velocity.dot(global_basis.z)
	var momentum =  remap(vel_forward, 0.0, 2.0, 0.0, 1.0)
	_torque_to_apply -= torque * Vector3.UP * momentum


## Turns the ship right by the provided torque:
func turn_right(torque: float = 250.0) -> void:
	var vel_forward = linear_velocity.dot(global_basis.z)
	var momentum =  remap(vel_forward, 0.0, 2.0, 0.0, 1.0)
	_torque_to_apply += torque * Vector3.UP * momentum


## Gives the ship a waypoint to go to:
func set_waypoint(wp: Vector3) -> void:
	_waypoint_prev = _waypoint
	_has_destination = true
	_waypoint = wp


## Returns the ship's health as a value from 0.0 to 1.0
func get_ship_health() -> float:
	return clampf(float(_hitpoints) / float(max_hitpoints), 0.0, 1.0)


## Gets the ships progress between waypoints as a value from 0.0 to 1.0:
func get_progress_wp() -> float:
	if not _has_destination:
		return 1.0
	
	var dist_wp := (_waypoint - _waypoint_prev).length()
	var dist_ship := (_waypoint - global_position).length()
	var prog = 1.0 - (dist_ship / dist_wp)
	prog = clampf(prog, 0.0, 1.0)
	return prog


## Gets ships progress to waypoint from spawn as a value from 0.0 to 1.0:
func get_progress_total() -> float:
	if not _has_destination:
		return 1.0
	
	var dist_wp := (_waypoint - _spawn).length()
	var dist_ship := (_waypoint - global_position).length()
	var prog = 1.0 - (dist_ship / dist_wp)
	prog = clampf(prog, 0.0, 1.0)
	return prog


## A wrapper function for PenguinLookout to emit signals through the ship:
func emit_spotted(sector: PenguinLookout.DIRECTIONS) -> void:
	enemy_spotted.emit(sector)


#===============================================================================
#	EOF:
#===============================================================================
