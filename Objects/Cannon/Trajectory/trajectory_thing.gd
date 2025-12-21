extends Node3D
class_name TrajectoryRenderer

const TRAJECTORY_POINT = preload("uid://luw7usrb8uhm")

@export var line_amounts: int = 20
##Lower = Higher Resolution
@export_range(0.01, 1, 0.01) var resolution: float

var every_point: Array[Node3D]

func draw_trajectory(startPosition: Vector3, startVelocity: Vector3) -> void:
	if not every_point.is_empty():
		delete_all()
	
	var time: float = 0
	var gravity := Vector3(0, -9.8, 0)
	var newscale: float = 0.2
	while time < line_amounts:
		var point: Vector3 = startPosition
		point += startVelocity * time
		point += 0.5 * gravity * time * time
		
		if point.y < 0.0:
			break
		
		spawn_point(point)
		every_point[-1].scale = Vector3(newscale,newscale,newscale)
		newscale += 0.05
		time += resolution

func spawn_point(spawnPosition: Vector3) -> void:
	var point: Node3D = TRAJECTORY_POINT.instantiate()
	get_tree().get_root().add_child(point)
	point.global_position = spawnPosition
	every_point.append(point)

func delete_all() -> void:
	for i in every_point:
		if is_instance_valid(i):
			i.queue_free()
