extends CanvasLayer

@onready var button: TextureButton = $Control/TextureButton


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	button.button_down.connect(_handle_next_level)


func _handle_next_level() -> void:
	ProgressionManager.mission_start()
