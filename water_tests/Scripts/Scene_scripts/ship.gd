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
const BUOYANCY_COEF: float = 50_000.0 / SAMPLE_POINTS
const DAMPING_COEF: float = 400.0
const MAX_DEPTH: float = 3.0 

const BUOYANCY_OFFSET: float = 0.4
const MAX_SPEED: float = 2.0
const MAX_ROTATION: float = 10.0


# BUOYANCY PARAMETERS
var sample_points: PackedVector3Array
var area: float = 30.0


# FORCE CALCULATIONS:
var _force_to_apply := Vector3.ZERO
var _torque_to_apply := Vector3.ZERO


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	sample_points.append(Vector3(4.0, -BUOYANCY_OFFSET +1.2, 10.0))
	sample_points.append(Vector3(0.0, -BUOYANCY_OFFSET +1.2, 10.0))
	sample_points.append(Vector3(-4.0, -BUOYANCY_OFFSET +1.2, 10.0))
	sample_points.append(Vector3(4.0, -BUOYANCY_OFFSET - 1.5, 1.8))
	sample_points.append(Vector3(0.0, -BUOYANCY_OFFSET - 1.5, 1.8))
	sample_points.append(Vector3(-4.0, -BUOYANCY_OFFSET - 1.5, 1.8))
	sample_points.append(Vector3(4.0, -BUOYANCY_OFFSET + 1.2, -8.0))
	sample_points.append(Vector3(0.0, -BUOYANCY_OFFSET + 1.2, -8.0))
	sample_points.append(Vector3(-4.0, -BUOYANCY_OFFSET + 1.2, -8.0))


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_apply_buoyancy_forces(state)
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
		var water_height = NoiseFunc.sample_at_pos_time(data)
		var depth: float = water_height - pos_glb_point.y
		var depth_fraction = clamp(depth / MAX_DEPTH, 0.0, 1.0)
		var buoyancy_force = BUOYANCY_COEF * depth_fraction
		
		# Dampening forces:
		var point_velocity := state.get_velocity_at_local_position(
				pos_glb_point - state.transform.origin)
		var vertical_velocity := point_velocity.dot(Vector3.UP)
		var damping_force = -vertical_velocity * DAMPING_COEF
		var point_force: Vector3 = Vector3.UP * (buoyancy_force + damping_force)
		
		# Apply forces
		state.apply_force(point_force, pos_glb_point - state.transform.origin)


# Apply forces internal to the ship (steering, propultion):
func _apply_internal_forces(state: PhysicsDirectBodyState3D) -> void:
	var force := _force_to_apply
	if state.linear_velocity.length() < MAX_SPEED:
		state.apply_force(force, state.center_of_mass)
		return
	
	var torque := _torque_to_apply
	if state.angular_velocity.length() < MAX_ROTATION:
		state.apply_torque(torque)
		return


#===============================================================================
#	PUBLIC FUNCTIONS:
#===============================================================================
# Moves the ship forwards:
func move_forwards() -> void:
	_force_to_apply += 10.0 * self.transform.basis.z


func turn_left() -> void:
	_torque_to_apply += 10.0 * Vector3.UP


func turn_right() -> void:
	_torque_to_apply -= 10.0 * Vector3.UP


#===============================================================================
#	EOF:
#===============================================================================
