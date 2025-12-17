extends GPUParticles3D

@onready var _duration = self.lifetime
var _timeout: float

func _ready() -> void:
	emitting = true
	_timeout = Time.get_ticks_msec() + _duration * 1000.0

func _process(_delta: float) -> void:
	if Time.get_ticks_msec() > _timeout:
		queue_free()
