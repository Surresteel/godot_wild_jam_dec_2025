#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Ship
extends RigidBody3D


#===============================================================================
#	NODE INITIALISATION:
#===============================================================================
# CONSTANTS:
const SAMPLE_POINTS: int = 9
const BUOYANCY_COEF: float = 60_000.0 / SAMPLE_POINTS
#const DAMPING_COEF: float = 400.0
const DAMPING_COEF: float = 250.0
const MAX_DEPTH: float = 3.0 

const BUOYANCY_OFFSET_FOR: float = 0.4
const BUOYANCY_OFFSET_MID: float = 0.3
const BUOYANCY_OFFSET_AFT: float = 0.2
const MAX_SPEED: float = 10.0
const MAX_ROTATION: float = 10.0
const WP_RADIUS: float = 10.0


# BUOYANCY PARAMETERS
var sample_points: PackedVector3Array
var area: float = 30.0


# FORCE CALCULATIONS:
var _force_to_apply := Vector3.ZERO
var _torque_to_apply := Vector3.ZERO


# NAVIGATIONS:
var _has_destination: bool = false
var _waypoint: Vector3 = Vector3.ZERO


# WAVE INTERACTIONS:
@export var wave_manager: WaveManager
@export var initial_waypoint := Vector3.ZERO


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	if initial_waypoint.distance_squared_to(global_position) > 25:
		set_waypoint(initial_waypoint)
	
	# Forward
	sample_points.append(Vector3(3.0, -BUOYANCY_OFFSET_FOR, 6.0))
	sample_points.append(Vector3(0.0, -BUOYANCY_OFFSET_FOR, 6.0))
	sample_points.append(Vector3(-3.0, -BUOYANCY_OFFSET_FOR, 6.0))
	# Mid
	sample_points.append(Vector3(3.2, -BUOYANCY_OFFSET_MID, -1.0))
	sample_points.append(Vector3(0.0, -BUOYANCY_OFFSET_MID, -1.0))
	sample_points.append(Vector3(-3.2, -BUOYANCY_OFFSET_MID, -1.0))
	# Aft
	sample_points.append(Vector3(2.0, -BUOYANCY_OFFSET_AFT, -8.0))
	sample_points.append(Vector3(0.0, -BUOYANCY_OFFSET_AFT, -8.0))
	sample_points.append(Vector3(-2.0, -BUOYANCY_OFFSET_AFT, -8.0))


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if _has_destination:
		_go_to_point(_waypoint)
	
	_apply_buoyancy_forces(state)
	#_apply_external_forces(state)
	_apply_internal_forces(state)


#===============================================================================
#	PRIVATE FUNCTIONS:
#===============================================================================
# Compute and apply buoyancy forces:
func _apply_buoyancy_forces(state: PhysicsDirectBodyState3D) -> void:
	# Loop through buoyancy sample points and compute their forces:
	for point in sample_points:
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
				var h_temp = WaveFunc.sample_wave_height(wave.pos, offset, 
						wave.dir, wave.amp)
				if h_temp != 0 and h_temp > h1:
					highest_wave = wave
					h1 = h_temp
			
		
		var h2: float = NoiseFunc.sample_at_pos_time(data)
		#var water_height = NoiseFunc.sample_at_pos_time(data)
		var water_height = maxf(h1, h2)
		var depth: float = water_height - pos_glb_point.y
		var depth_fraction = clamp(depth / MAX_DEPTH, 0.0, 1.0)
		var buoyancy_force = BUOYANCY_COEF * depth_fraction
		
		# Wave forces:
		var wave_force := Vector3.ZERO
		if (h1 > h2) and highest_wave:
			wave_force = highest_wave.vel.normalized() * \
					highest_wave.vel.length() * highest_wave.vel.length() \
					* 5000 * highest_wave.amp * 10 + Vector3(0, 1000, 0) * \
					highest_wave.amp
			wave_force /= SAMPLE_POINTS
			state.apply_force(wave_force, pos_glb_point - state.transform.origin)
		
		# Dampening forces:
		var damping_force := 0.0
		if depth > -0.5:
			var point_velocity := state.get_velocity_at_local_position(
					pos_glb_point - state.transform.origin)
			var vertical_velocity := point_velocity.dot(Vector3.UP)
			damping_force = -vertical_velocity * DAMPING_COEF
		var point_force: Vector3 = Vector3.UP * (buoyancy_force + damping_force)
		
		# Apply forces
		state.apply_force(point_force, pos_glb_point - state.transform.origin)


# Apply forces external to the ship (waves):
func _apply_external_forces(state: PhysicsDirectBodyState3D) -> void:
	if not wave_manager:
		return
	
	var w_data: Array[WaveManager.WaveData] = wave_manager.get_waves()
	var force := Vector3.ZERO
	for wave in w_data:
		#print(wave.vel)
		if wave.pos.distance_to(Vector2(state.transform.origin.x, 
				state.transform.origin.z)) < 7.0:
			force += wave.vel.normalized() * wave.vel.length() * wave.vel.length() * 50000 * wave.amp * 10 \
					+ Vector3(0, 80000, 0) * wave.amp
	
	state.apply_force(force, Vector3(center_of_mass.x, center_of_mass.y - 1, center_of_mass.z))


# Apply forces internal to the ship (steering, propulsion):
func _apply_internal_forces(state: PhysicsDirectBodyState3D) -> void:
	var force := _force_to_apply
	var v := state.linear_velocity
	if v.length() >= MAX_SPEED and v.length() > 0.001:
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
	_has_destination = true
	_waypoint = wp


#===============================================================================
#	EOF:
#===============================================================================
