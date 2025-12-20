extends SealionBaseState
class_name CirclingSealionState

var speed:= 10.0
var swimming_distance: float = 50.0
var swimming_distance_drain_speed:= 2.0
var clockwise:bool = false

var animation_timer: float = 20
var animation_current_time: float = 0

func enter(sealion: Sealion) -> void:
	swimming_distance = randf_range(25, 80)
	swimming_distance_drain_speed = randf_range(1, 3)
	clockwise = randi() % 2
	
	sealion.animation_player.play("Swimming")

func exit(sealion: Sealion) -> void:
	sealion.velocity = Vector3.ZERO

func pre_update(sealion: Sealion) -> void:
	if swimming_distance <= 20:
		var dir_to_ship:= sealion.global_position.direction_to(sealion.ship.global_position)
		sealion.dot_sealion_to_ship = abs(dir_to_ship.dot(-sealion.ship.global_basis.z))
		#Back to Front = 0 to +- 180, from the second mast
		if sealion.dot_sealion_to_ship < 0.5:
			sealion.change_state(SealionStates.BOARDING)
	if sealion.defeated:
		sealion.change_state(SealionStates.DEFEATED)


func update(sealion: Sealion, delta) -> void:
	if swimming_distance > 20 and _is_at_circle(sealion, 
			sealion.ship.global_position):
		swimming_distance -= delta * swimming_distance_drain_speed
	
	var nextpoint:= get_next_pos(sealion,sealion.ship.global_position)
	nextpoint.y = sealion.global_position.y
	
	#set velocity
	var dir = nextpoint - sealion.global_position
	var dir_norm = dir.normalized()
	var vel_add: Vector3 = dir_norm * 4 * delta
	var vel_new: Vector3 = sealion.velocity + vel_add
	vel_new.y = 0
	if vel_new.length_squared() > speed * speed:
		var vel_vec: Vector3 = sealion.velocity.normalized()
		sealion.velocity += -vel_vec * vel_add.length()
		sealion.velocity += vel_add
	else:
		sealion.velocity += vel_add
	
	
	#Turn Towards Target
	var t := sealion.transform
	t.basis = Basis.looking_at(dir.normalized(), Vector3.UP)
	sealion.transform = sealion.transform.interpolate_with(t, 7 * delta)
	return


func get_next_pos(sealion: Sealion, target: Vector3) -> Vector3:
	var to_point := sealion.global_position - target
	var dir := to_point.normalized()
	
	# Calculate next waypoint in orbit:
	var to_point_next: Vector3
	if true:
		to_point_next = dir.rotated(Vector3.UP, 0.2)
	else:
		to_point_next = dir.rotated(Vector3.UP, -0.2)
	
	# Go to waypoint:
	var point_next := target + to_point_next * swimming_distance
	
	return point_next


func _get_dist_to_target(sealion: Sealion, target: Vector3) -> float:
	return (target - sealion.global_position).length()


func _is_at_circle(sealion: Sealion, target: Vector3) -> bool:
	return _get_dist_to_target(sealion, target) < swimming_distance + 20
