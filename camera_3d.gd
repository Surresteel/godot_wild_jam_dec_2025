extends Camera3D

@onready var parent : Node3D = get_parent()
@onready var current_pos = position


func _process(delta: float) -> void:
	position = current_pos + parent.global_position
