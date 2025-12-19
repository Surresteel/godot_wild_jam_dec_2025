extends Node3D

@onready var bow_emitter: AudioStreamPlayer3D = $BowSounds
var _emitters: Array[AudioStreamPlayer3D] = []
var _timeouts: Array[float]
var _intervals: Array[float]
var _ship: Ship

var _timeout_bow_splash: float = 0.0
var _interval_bow_splash: float = 5.0 * 1000.0


func _ready() -> void:
	_emitters.push_back($ShipSounds1)
	_emitters.push_back($ShipSounds2)
	_emitters.push_back($ShipSounds3)
	
	for i in _emitters.size():
		_timeouts.push_back(0.0)
		_intervals.push_back(5.0 * 1000)
	
	_ship = get_parent_node_3d()
	
	bow_emitter.stream = AudioManager.SEA_SPRAY
	if _ship:
		_ship.bow_hit_water.connect(_bow_splash)


func _process(_delta: float) -> void:
	for i in _emitters.size():
		if Time.get_ticks_msec() < _timeouts[i]:
			return
		
		if _emitters[i].playing:
			return
		
		_timeouts[i] = Time.get_ticks_msec() + _intervals[i] + randf() * 5000.0
		_emitters[i].stream = AudioManager.SHIP_SOUNDS.pick_random()
		_emitters[i].play()


func _bow_splash() -> void:
	if Time.get_ticks_msec() > _timeout_bow_splash:
		bow_emitter.play()
		_timeout_bow_splash = Time.get_ticks_msec() + _interval_bow_splash
