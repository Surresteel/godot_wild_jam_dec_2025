extends CharacterBody3D
class_name BabyPenguin

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready() -> void:
	pass


func move(speed:float, delta: float) -> void:
	pass



	#Move The  towards it's target
	var dir: Vector3 = (.next_target_pos
						- .global_position).normalized()
	
	if not .nav_agent.is_navigation_finished():
		#set velocity
		.velocity.x = dir.x * speed
		.velocity.z = dir.z * speed
	else:
		.velocity.x = move_toward(.velocity.x, 0.0, delta * 7)
		.velocity.z = move_toward(.velocity.x, 0.0, delta * 7)
	
	#Turn Towards Target
	var radians_to_turn: float = atan2(-dir.x, -dir.z)
	var turn_amount = lerp_angle(.global_rotation.y, radians_to_turn, 0.5)
	.global_rotation.y = turn_amount
