extends GPUParticles3D

@onready var _audio_emitter: AudioStreamPlayer3D = $AudioEmitter
@onready var _duration = self.lifetime
var _timeout: float

func _ready() -> void:
	_audio_emitter.stream = AudioManager.ORCA_EXPLOSION
	var length = _audio_emitter.stream.get_length()
	if length > _duration:
		_duration = length
	emitting = true
	_timeout = Time.get_ticks_msec() + _duration * 1000.0
	_audio_emitter.play()

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() > _timeout:
		queue_free()
