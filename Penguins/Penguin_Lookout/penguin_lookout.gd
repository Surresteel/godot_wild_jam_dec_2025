#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name PenguinLookout
extends Node3D


#===============================================================================
#	CLASS MEMBERS:
#===============================================================================
@onready var _audio_emitter: AudioStreamPlayer3D = $AudioEmitter
@onready var _anim_player: AnimationPlayer = \
		$PenguinAlertScoutSteer/AnimationPlayer

var dist_callout: float = 500
var dist_callout_sqr: float

var _ship: Ship
var _spawner: Spawner
var _target: Node3D = null

var _timeout_wave_callout: float = 0.0
var _interval_wave_callout: float = 10.0 * 1000.0


#===============================================================================
#	CALLBACKS:
#===============================================================================
func _ready() -> void:
	_play_anim("Scouting")
	if _spawner:
		_spawner.enemy_spawned.connect(_callout_enemy)
	
	if _ship:
		_ship.wave_inbound.connect(_callout_wave)


func _process(_delta: float) -> void:
	if not _target:
		return
	
	_track_target()


## Executes code based on the quadrant that an enemy is in relative to the ship:
func _callout_enemy(enemy: Node3D) -> void:
	if not _ship and not _target:
		return
	
	_target = enemy


func _callout_wave() -> void:
	if Time.get_ticks_msec() > _timeout_wave_callout:
		_play_sound(AudioManager.WAVE_INCOMING)
		_play_anim("Alert")
		_timeout_wave_callout  = Time.get_ticks_msec() + _interval_wave_callout


#===============================================================================
#	SETUP:
#===============================================================================
func _play_anim(anim: String, blend: float = 1, speed: float = 1.0) -> void:
	_anim_player.play(anim, blend, speed)
	_anim_player.queue("Scouting")


#===============================================================================
#	SETUP:
#===============================================================================
## Sets up the external references of the node:
func setup(s: Ship, spwn: Spawner) -> void:
	if _ship and _ship.wave_inbound.is_connected(_callout_wave):
		_ship.wave_inbound.disconnect(_callout_wave)
	_ship = s
	dist_callout = _ship.callout_distance
	dist_callout_sqr = dist_callout * dist_callout
	if not _ship.wave_inbound.is_connected(_callout_wave):
		_ship.wave_inbound.connect(_callout_wave)
	
	if _spawner and _spawner.enemy_spawned.is_connected(_callout_enemy):
		_spawner.enemy_spawned.disconnect(_callout_enemy)
	_spawner = spwn
	if not _spawner.enemy_spawned.is_connected(_callout_enemy):
		_spawner.enemy_spawned.connect(_callout_enemy)


#===============================================================================
#	PRIVATE FUNCTIONS:
#===============================================================================
## Plays a sound if the stream player is available:
func _play_sound(stream: AudioStream) -> void:
	if not _audio_emitter.playing:
		_audio_emitter.stream = stream
		_audio_emitter.play()


func _track_target() -> void:
	var to_enemy := _target.global_position - global_position
	if to_enemy.length_squared() > dist_callout_sqr:
		return
	
	var dir = to_enemy.normalized()
	var dot_fwd = dir.dot(-_ship.global_basis.z)
	var dot_right = dir.dot(_ship.global_basis.x)
	
	if abs(dot_fwd) >= abs(dot_right):
		if dot_fwd > 0.0:
			_play_sound(AudioManager.PENGUIN_NORTH)
		else:
			_play_sound(AudioManager.PENGUIN_SOUTH)
	else:
		if dot_right > 0.0:
			_play_sound(AudioManager.PENGUIN_EAST)
		else:
			_play_sound(AudioManager.PENGUIN_WEST)
	
	_play_anim("Alert")
	_target = null
