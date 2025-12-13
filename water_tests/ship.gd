extends RigidBody3D

const SAMPLE_POINTS: int = 6
const BUOYANCY_COEF: float = 60_000.0 / SAMPLE_POINTS
const DAMPING_COEF: float = 50.0
const MAX_DEPTH: float = 3.0 
const BUOYANCY_OFFSET: float = 0.4

var offsets: PackedVector3Array
var area: float = 30.0

@onready var collider: CollisionShape3D = $Collider

func _ready() -> void:
	offsets.append(Vector3(3.0, -BUOYANCY_OFFSET -0.2, 5.0))
	offsets.append(Vector3(-3.0, -BUOYANCY_OFFSET -0.2, 5.0))
	offsets.append(Vector3(3.0, -BUOYANCY_OFFSET, 0.5))
	offsets.append(Vector3(-3.0, -BUOYANCY_OFFSET, 0.5))
	offsets.append(Vector3(3.0, -BUOYANCY_OFFSET + 0.2, -3.0))
	offsets.append(Vector3(-3.0, -BUOYANCY_OFFSET + 0.2, -3.0))

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	for offset in offsets:
		# Buoyancy:
		var pos_glb_point = state.transform.origin + state.transform.basis * offset
		var data := Vector3(pos_glb_point.x, pos_glb_point.z, (Time.get_ticks_msec() / 1000.0))
		var water_height = NoiseFunc.get_height_at_pos_time(data)
		var depth: float = water_height - pos_glb_point.y
		var depth_fraction = clamp(depth / MAX_DEPTH, 0.0, 1.0)
		var buoyancy_force = BUOYANCY_COEF * depth_fraction
		
		# Dampening
		# NOTE: THIS DOESN'T WORK!
		#var point_velocity := state.get_velocity_at_local_position(offset)
		var point_velocity := state.get_velocity_at_local_position(pos_glb_point - state.transform.origin)
		var vertical_velocity := point_velocity.dot(Vector3.UP)
		var damping_force = -vertical_velocity * DAMPING_COEF
		var force: Vector3 = Vector3.UP * (buoyancy_force + damping_force)
		#var force: Vector3 = Vector3.UP * (buoyancy_force)
		
		#if force.length_squared() < 0.0:
		#	continue
		
		var thrust := state.transform.origin + state.transform.basis * Vector3(0, 0, 1000)
		state.apply_force(force + thrust, pos_glb_point - state.transform.origin)
		#state.apply_torque(Vector3(0, 1000, 0))
	
	
	#var height_new = NoiseFunc.get_height_at_pos_time(data)
	#height_old.y = height_new
	#state.transform.origin = height_old
