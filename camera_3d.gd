extends Camera3D
class_name PlayerCamera

var pos: Vector3
var rot: Vector3
var follow_target: Node3D

var transitioning: bool = false
signal finished_transitioning
var mouse_input: Vector2

@export var sensitivity = 10

func _process(_delta: float) -> void:
	if transitioning:
		transition_to_position()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var new_rotation_x: float = -event.screen_relative.y * sensitivity * get_process_delta_time()
		var new_rotation_y: float = -event.screen_relative.x * sensitivity * get_process_delta_time()
		mouse_input = Vector2(new_rotation_x,new_rotation_y)

func rotate_camera_x() -> void:
	rotation_degrees.x = clampf(rotation_degrees.x + mouse_input.x,-90,90)

func rotate_camera_y() -> void:
	rotation_degrees.y += mouse_input.y

func transition_to_position() -> void:
	position = position.move_toward(Vector3.ZERO, get_process_delta_time() * 2)
	rotation = rotation.slerp(Vector3.ZERO, get_process_delta_time() * 5)
	if (position).length() <= 0.02 and (rotation).length() <= 0.05:
		position = Vector3.ZERO
		rotation = Vector3.ZERO
		transitioning = false
		finished_transitioning.emit()

func transfer_camera(new_parent: Node3D) -> void:
	follow_target = new_parent
	reparent(new_parent, true)
	transitioning = true
