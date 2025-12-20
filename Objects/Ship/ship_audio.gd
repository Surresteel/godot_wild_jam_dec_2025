extends Node3D

@onready var bow_emitter: AudioStreamPlayer3D = $BowSounds
@onready var crash_emitter: AudioStreamPlayer3D = $CrashSounds
var _emitters_wood: Array[AudioStreamPlayer3D] = []
var _emitters_wave: Array[AudioStreamPlayer3D] = []
var _timeouts_wood: Array[float]
var _intervals_wood: Array[float]
var _timeouts_wave: Array[float]
var _intervals_wave: Array[float]
var _ship: Ship

var _timeout_bow_splash: float = 0.0
var _interval_bow_splash: float = 5.0 * 1000.0
var _timeout_crash: float = 0.0
var _interval_crash: float = 10.0 * 1000.0


func _ready() -> void:
	_emitters_wood.push_back($ShipSounds1)
	_emitters_wood.push_back($ShipSounds2)
	_emitters_wood.push_back($ShipSounds3)
	_emitters_wave.push_back($WaveSounds1)
	_emitters_wave.push_back($WaveSounds2)
	_emitters_wave.push_back($WaveSounds3)
	
	for i in _emitters_wood.size():
		_timeouts_wood.push_back(0.0)
		_intervals_wood.push_back(5.0 * 1000)
	
	for i in _emitters_wave.size():
		_timeouts_wave.push_back(0.0)
		_intervals_wave.push_back(15.0 * 1000)
	
	_ship = get_parent_node_3d()
	
	bow_emitter.stream = AudioManager.SEA_SPRAY
	if _ship:
		_ship.bow_hit_water.connect(_bow_splash)
		_ship.iceberg_hit.connect(_ice_hit)


func _process(_delta: float) -> void:
	_handle_sounds_wood()
	_handle_sounds_waves()


func _handle_sounds_wood() -> void:
	for i in _emitters_wood.size():
		if Time.get_ticks_msec() < _timeouts_wood[i]:
			return
		
		if _emitters_wood[i].playing:
			return
		
		_timeouts_wood[i] = Time.get_ticks_msec() + _intervals_wood[i] + \
				randf() * 5000.0
		_emitters_wood[i].stream = AudioManager.SHIP_SOUNDS.pick_random()
		_emitters_wood[i].play()


func _handle_sounds_waves() -> void:
	for i in _emitters_wave.size():
		if Time.get_ticks_msec() < _timeouts_wave[i]:
			return
		
		if _emitters_wave[i].playing:
			return
		
		_timeouts_wave[i] = Time.get_ticks_msec() + _intervals_wave[i] + \
				randf() * 5000.0
		_emitters_wave[i].stream = AudioManager.WAVE_SOUNDS.pick_random()
		_emitters_wave[i].play()



func _bow_splash() -> void:
	if Time.get_ticks_msec() > _timeout_bow_splash:
		bow_emitter.play()
		_timeout_bow_splash = Time.get_ticks_msec() + _interval_bow_splash


func _ice_hit(did_damage: bool = false) -> void:
	if did_damage and Time.get_ticks_msec() > _timeout_crash:
		crash_emitter.stream = AudioManager.CRASH_SOUNDS.pick_random()
		crash_emitter.play()
		_timeout_crash = Time.get_ticks_msec() + _interval_crash
