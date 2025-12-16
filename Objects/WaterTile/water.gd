#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name Water
extends Node3D


const COLOUR_DARK_DEFAULT := Vector3(0.0, 0.25, 0.5)
const COLOUR_LIGHT_DEFAULT := Vector3(0.0, 0.4, 0.5)
const COLOUR_FOAM_DEFAULT := Vector3(0.1, 0.5, 0.8)


# Static members:
static var material: ShaderMaterial = \
		preload("res://Materials/Shaders/water_shader_mat.tres")
static var is_set_default := false


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	_initialise_defaults()


#===============================================================================
#	PRIVATE STATIC FUNCTIONS:
#===============================================================================
static func _initialise_defaults() -> void:
	if (is_set_default):
		return
	
	# Set default wave characteristics:
	material.set_shader_parameter("wave_amp", NoiseFunc.wave_amp)
	material.set_shader_parameter("wave_freq", NoiseFunc.wave_freq)
	material.set_shader_parameter("wave_speed", NoiseFunc.wave_speed)
	
	# Set default colour characteristics:
	material.set_shader_parameter("colour_dark", COLOUR_DARK_DEFAULT)
	material.set_shader_parameter("colour_light", COLOUR_LIGHT_DEFAULT)
	material.set_shader_parameter("colour_foam", COLOUR_FOAM_DEFAULT)
	
	is_set_default = true


#===============================================================================
#	PUBLIC STATIC FUNCTIONS:
#===============================================================================
static func advance_time() -> void:
	material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	
	
static func set_water_colour_dark(colour: Vector3) -> void:
	material.set_shader_parameter("colour_dark", colour)

static func set_water_colour_light(colour: Vector3) -> void:
	material.set_shader_parameter("colour_light", colour)

static func set_water_colour_foam(colour: Vector3) -> void:
	material.set_shader_parameter("colour_foam", colour)


static func set_wave_amplitude(value: float) -> void:
	material.set_shader_parameter("wave_amp", value)
	NoiseFunc.set_wave_amplitude(value)

static func set_wave_frequency(value: float) -> void:
	material.set_shader_parameter("wave_freq", value)
	NoiseFunc.set_wave_frequency(value)

static func set_wave_speed(value: float) -> void:
	material.set_shader_parameter("wave_speed", value)
	NoiseFunc.set_wave_speed(value)

static func set_single_wave(pos: Vector2, dir: Vector2, amp: float):
	material.set_shader_parameter("swave_origin", pos)
	material.set_shader_parameter("swave_dir", dir)
	material.set_shader_parameter("swave_amp", amp)


#===============================================================================
#	EOF:
#===============================================================================
