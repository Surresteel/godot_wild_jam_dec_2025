extends PlayerState
class_name SwimmingState

const SWIM_SPEED = 5

func enter() -> void:
	pass

func exit() -> void:
	pass

func pre_update() -> void:
	if player.is_on_floor():
		transition.emit(player.movement_state_machine.state.WALKING)
	elif player.global_position.y - 0.5 > player.get_water_height():
		transition.emit(PlayerStateMachine.state.FALLING)
	#elif Input.is_action_just_pressed("jump"):
		#transition.emit(player.movement_state_machine.state.JUMPING)

func update(delta: float) -> void:
	
	var input_dir: Vector2 = Input.get_vector("left","right","forward","backward")
	var dir: Vector3 = (player.transform.basis * Vector3(input_dir.x, 0 ,input_dir.y)).normalized()
	
	if dir:
		player.velocity.x = move_toward(player.velocity.x, dir.x * SWIM_SPEED * 2, delta * 3)
		player.velocity.z = move_toward(player.velocity.z, dir.z * SWIM_SPEED * 2, delta * 3)
	else:
		var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, delta * 10)
		#This preserves direction, before i was shifting to the greater cardinal direction
		player.velocity.x = horizontal_velocity.x
		player.velocity.z = horizontal_velocity.z
	
	if Input.is_action_just_pressed("jump"):
		player.velocity.y += 8
	player.velocity.y += player.get_gravity().y * delta
