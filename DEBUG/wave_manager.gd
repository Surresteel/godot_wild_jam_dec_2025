#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name WaveManager
extends Node3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
class WaveData extends RefCounted:
	var pos: Vector2
	var dir: Vector2
	var amp: float
	var vel: Vector3


# Private members:
var _waves: Array[Wave]


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	_cleanup_wave_array()


#===============================================================================
#	PRIVATE FUNCTIONS:
#===============================================================================
func _cleanup_wave_array() -> void:
	for i in range(_waves.size() - 1, -1, -1):
		if not _waves[i]:
			_waves.remove_at(i)
			continue
		if _waves[i].is_done:
			_waves.remove_at(i)


#===============================================================================
#	PUBLIC FUNCTIONS:
#===============================================================================
func register_wave(wave: Wave) -> void:
	_waves.push_back(wave)


func unregister_wave(wave: Wave) -> bool:
	for i in range(_waves.size() - 1, -1, -1):
		if _waves[i] == wave:
			_waves.remove_at(i)
			return true
	
	return false


func get_waves() -> Array[WaveData]:
	var data: Array[WaveData]
	for wave in _waves:
		if not wave:
			continue
		
		if wave.is_done:
			continue
		
		var wave_data := WaveData.new()
		wave_data.pos = Vector2(wave.global_position.x, wave.global_position.z)
		wave_data.dir = Vector2(wave.global_basis.z.x, 
				wave.global_basis.z.z).normalized()
		wave_data.amp = wave.amplitude
		wave_data.vel = wave.velocity
		data.push_back(wave_data)
	
	return data


#===============================================================================
#	EOF:
#===============================================================================
