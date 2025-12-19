extends PlayerState
class_name FallingState

var rotation_lerp_ratio: float

func enter() -> void:
	rotation_lerp_ratio = 1

func exit() -> void:
	pass

func pre_update() -> void:
	if player.is_on_floor():
		player.velocity = Vector3.ZERO
		transition.emit(player.movement_state_machine.state.WALKING)
	
	if player.global_position.y - 0.5 < player.get_water_height():
		transition.emit(player.movement_state_machine.state.SWIMMING)

func update(delta: float) -> void:
	var input_dir: Vector2 = Input.get_vector("left","right","forward","backward")
	var dir: Vector3 = (player.transform.basis * Vector3(input_dir.x, 0 ,input_dir.y)).normalized()
	
	if dir:
		player.velocity.x = dir.x * player.speed + player.get_ship_velocity().x
		player.velocity.z = dir.z * player.speed + player.get_ship_velocity().z
	else:
		#take out the y
		var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
		#Get the ships Rotational Velcoity and cross product it to do magic and make it a translation
		var offset = player.global_position - player.ship.global_position
		var rotational_velocity = player.ship.angular_velocity.cross(offset)
		#Slow/Speed the Player to the ships velocity
		horizontal_velocity = horizontal_velocity.move_toward(
				player.get_ship_velocity() + rotational_velocity,delta * 5) 
				#should stick to the ship even with rotation
		
		player.velocity.x = horizontal_velocity.x
		player.velocity.z = horizontal_velocity.z
	
	player.velocity.y += player.get_gravity().y * delta
	
	#rotating with ship
	if rotation_lerp_ratio > 0:
		rotation_lerp_ratio -= delta * 0.25
		if rotation_lerp_ratio < 0:
			rotation_lerp_ratio = 0
		player.rotate_with_ship(rotation_lerp_ratio)
	
