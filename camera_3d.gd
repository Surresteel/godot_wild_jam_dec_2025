extends Camera3D
class_name PlayerCamera

@onready var pos: Vector3 = position
var mouse_input: Vector2

@export var sensitivity = 10

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var new_rotation_x: float = -event.screen_relative.y * sensitivity * get_process_delta_time()
		var new_rotation_y: float = -event.screen_relative.x * sensitivity * get_process_delta_time()
		mouse_input = Vector2(new_rotation_x,new_rotation_y)

func rotate_camera_x() -> void:
	rotation_degrees.x = clampf(rotation_degrees.x + mouse_input.x,-90,90)

func rotate_camera_y() -> void:
	rotation_degrees.y += mouse_input.y
