#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Wave
extends Node3D


#===============================================================================
#	NODE INITIALISATION:
#===============================================================================
# Public members:
var amplitude: float = 0.0
var is_done: bool = false
var velocity := Vector3.ZERO


# Private members:
@onready var _mesh: MeshInstance3D = $Mesh
var _pos_old := Vector3.ZERO
var _target: Vector3
var _speed: float
var _dist: float
var _max_amp: float
var _wave_manager: WaveManager
var _target_reached: bool = false


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	_pos_old = global_position


func _physics_process(delta: float) -> void:
	# Make wave as 'done' once it's passed the target and low in amplitude:
	if _target_reached and amplitude <= 0.0:
		is_done = true
	
	# Remove node from scene tree if done:
	if is_done:
		queue_free()
	
	# Update Velocity:
	velocity = global_position - _pos_old
	_pos_old = global_position
	
	# Move wave:
	position += -basis.z * _speed * delta
	amplitude = lerpf(_max_amp, 0, (global_position - _target).length() / _dist)
	
	# Check if target is reached:
	if global_position.distance_squared_to(_target) < 25.0:
		_target_reached = true
	
	# Update shader:
	_mesh.set_instance_shader_parameter("swave_amp", amplitude)


#===============================================================================
#	PUBLIC FUNCTIONS:
#===============================================================================
func activate_wave(t: Vector3, s: float, a: float, wm: WaveManager) -> void:
	_target = t
	_speed = s
	_dist = (_target - global_position).length()
	var b := Basis.looking_at(t - global_position, Vector3.UP)
	basis = b
	_max_amp = a
	_wave_manager = wm
	wm.register_wave(self)


#===============================================================================
#	EOF:
#===============================================================================
