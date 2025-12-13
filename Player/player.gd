extends CharacterBody3D


func _physics_process(delta: float) -> void:
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y += 5
	else:
		velocity.y += get_gravity().y * delta
	
	
	var input_dir := Input.get_vector("left","right","forward","backward")
	
	var speed := 10.0
	if input_dir:
		velocity.x = input_dir.x * speed
		velocity.z = input_dir.y * speed
	elif is_on_floor():
		velocity.x = lerp(velocity.x, 0.0, delta * 7.0)
		velocity.z = lerp(velocity.z, 0.0, delta * 7.0)
	
	
	
	
	
	move_and_slide()
	







func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()
