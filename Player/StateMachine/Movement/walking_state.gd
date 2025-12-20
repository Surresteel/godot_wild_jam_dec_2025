extends PlayerState
class_name WalkingState

var rotation_lerp_ratio: float

func enter() -> void:
	rotation_lerp_ratio = 0.1

func exit() -> void:
	pass

func pre_update() -> void:
	if Input.is_action_just_pressed("jump"):
		transition.emit(player.movement_state_machine.state.JUMPING)
	elif not player.is_on_floor():
		transition.emit(player.movement_state_machine.state.FALLING)
	elif player.is_interacting:
		transition.emit(player.movement_state_machine.state.INTERACTING)

func update(delta: float) -> void:
	#walking
	var input_dir: Vector2 = Input.get_vector("left","right","forward","backward")
	var dir: Vector3 = (player.transform.basis * Vector3(input_dir.x, 0 ,input_dir.y)).normalized()
	
	if dir:
		# Feel free to move this to its own function if you want:
		if not player.audio_emitter.playing:
			var next_sample = AudioManager.WALK_SOUNDS.pick_random()
			while next_sample == player.audio_emitter.stream:
				next_sample = AudioManager.WALK_SOUNDS.pick_random()
			player.audio_emitter.stream = next_sample
			player.audio_emitter.play()
		
		player.velocity.x = dir.x * player.speed
		player.velocity.z = dir.z * player.speed
	else:
		var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, delta * 10)
		#This preserves direction, before i was shifting to the greater cardinal direction
		player.velocity.x = horizontal_velocity.x
		player.velocity.z = horizontal_velocity.z
	
	#rotating with ship
	if rotation_lerp_ratio < 1:
		rotation_lerp_ratio += delta * 0.25
		if rotation_lerp_ratio > 1: # clamping to 1
			rotation_lerp_ratio = 1
	player.rotate_with_ship(rotation_lerp_ratio)
	
