#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name IcebergBase
extends RigidBody3D

signal iceberg_split(layers_rem: Vector3, pos: Vector3, mult: int)
signal iceberg_destroyed()

const HIGHEST_LAYER: int = 4
const MAX_DEPTH: float = 3.0
const DIST_DESPAWN: float = 50.0

@export var _buoyancy_total: float = 15_000.0
@export var _buoyancy_width: float = 4.0
@export var _buoyancy_height: float = -1.0
@export var _buoyancy_damping: float = 250.0

var _buoyancy_array: PackedVector3Array
var _buoyancy_coef: float

var _noise_drift := FastNoiseLite.new()
var _drift_amount: float = 1.0

@export var break_velocity: float = 5.0
@export var onion_layers: int = 2

var scene_icicle := preload("res://Particle_Effects/Icicles.tscn")
var _target: RigidBody3D = null
var is_sinking: bool = false

@onready var audio_emitter: AudioStreamPlayer3D = $AudioEmitter


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:

	var _buoyancy_point_1 := Vector3(_buoyancy_width, _buoyancy_height, 0.0)
	var _buoyancy_point_2 := Vector3(-_buoyancy_width, _buoyancy_height, 0.0)
	var _buoyancy_point_3 := Vector3(0.0, _buoyancy_height, _buoyancy_width)
	var _buoyancy_point_4 := Vector3(0.0, _buoyancy_height, -_buoyancy_width)
	contact_monitor = true
	max_contacts_reported = 4
	
	_buoyancy_array.push_back(_buoyancy_point_1)
	_buoyancy_array.push_back(_buoyancy_point_2)
	_buoyancy_array.push_back(_buoyancy_point_3)
	_buoyancy_array.push_back(_buoyancy_point_4)
	
	_buoyancy_coef = _buoyancy_total / _buoyancy_array.size()
	
	_noise_drift.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise_drift.frequency = 0.2
	
	body_entered.connect(_handle_collisions)


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_handle_lifecycle()
	_apply_buoyancy(state)
	_apply_drift(state)


#===============================================================================
#	LIFECYCLE:
#===============================================================================
func _handle_lifecycle() -> void:
	if not _target:
		return
	
	if _target.linear_velocity.length_squared() < 1.0:
		return
	
	var tgt_to_self = global_position - _target.global_position
	var project = _target.linear_velocity.normalized().dot(
			tgt_to_self.normalized())
	var allowance = remap(_target.linear_velocity.length(), 0.0, 5.0, -1, -0.5)
	if project < allowance and tgt_to_self.length_squared() > \
			DIST_DESPAWN * DIST_DESPAWN:
		sink_and_melt()


func set_target(t: Node3D) -> void:
	_target = t


func sink_and_melt(split: int = -1) -> void:
	is_sinking = true
	_buoyancy_coef = 0.0
	if split != -1:
		_mitosis(split)
	await get_tree().create_timer(2.0).timeout
	_break_apart()


#===============================================================================
#	COLLISION:
#===============================================================================
func _handle_collisions(body: Node) -> void:
	if body is CannonBall and not is_sinking:
		_play_hit_effect()
		if onion_layers > 0:
			sink_and_melt(onion_layers - 1)
		else:
			sink_and_melt()
	
	if body is Ship:
		var tgt_to_self = global_position - _target.global_position
		var vel_to_self = body.linear_velocity.dot(tgt_to_self.normalized())
		if is_sinking or vel_to_self > break_velocity:
			_play_hit_effect()
			#_mitosis(onion_layers - 1)
			_break_apart()


func _play_hit_effect() -> void:
	audio_emitter.stream = AudioManager.ICE_SOUNDS.pick_random()
	audio_emitter.play()
	var ice: Node3D = scene_icicle.instantiate()
	get_tree().get_root().add_child(ice)
	ice.global_position = global_position


func _break_apart() -> void:
	iceberg_destroyed.emit()
	queue_free()


func _mitosis(layers_rem: int) -> void:
	var mult := randi_range(1, 3)
	iceberg_split.emit(layers_rem, global_position, mult)


#===============================================================================
#	PHYSICS:
#===============================================================================
func _apply_buoyancy(state: PhysicsDirectBodyState3D) -> void:
		# Loop through buoyancy sample points and compute their forces:
	for point in _buoyancy_array:
		# Buoyancy forces:
		var pos_glb_point = state.transform.origin + state.transform.basis \
				* point
		var data := Vector3(pos_glb_point.x, pos_glb_point.z, 
				(Time.get_ticks_msec() / 1000.0))
		
		var water_height = NoiseFunc.sample_at_pos_time(data)
		var depth: float = water_height - pos_glb_point.y
		var depth_fraction = clamp(depth / MAX_DEPTH, 0.0, 1.0)
		var buoyancy_force = _buoyancy_coef * depth_fraction
		
		var damping_force := 0.0
		if depth > -0.5:
			var point_velocity := state.get_velocity_at_local_position(
					pos_glb_point - state.transform.origin)
			var vertical_velocity := point_velocity.dot(Vector3.UP)
			damping_force = -vertical_velocity * _buoyancy_damping
		
		var point_force: Vector3 = Vector3.UP * (buoyancy_force + damping_force)
		state.apply_force(point_force, pos_glb_point - state.transform.origin)
	
	return


func _apply_drift(state: PhysicsDirectBodyState3D) -> void:
	var t = Time.get_ticks_msec() / 1000.0
	var drift_x = _noise_drift.get_noise_2d(global_position.x + t, 
			global_position.z + t)
	var drift_z = _noise_drift.get_noise_2d(global_position.x - t, 
			global_position.z - t)
	var force = Vector3(drift_x, 0.0, drift_z) * mass * _drift_amount
	state.apply_central_force(force)
