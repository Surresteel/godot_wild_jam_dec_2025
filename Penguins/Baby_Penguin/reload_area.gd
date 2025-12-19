extends Area3D

@export var baby_penguin: BabyPenguin


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		baby_penguin.reload_signal.connect(body.snowball_action.reload)
		print("player entered")

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		baby_penguin.reload_signal.disconnect(body.snowball_action.reload)

func _on_area_entered(area: Area3D) -> void:
	if area is CannonInteract:
		baby_penguin.reload_signal.connect(area.cannon.noninput_reload)
		print("cannon entered")

func _on_area_exited(area: Area3D) -> void:
	if area is CannonInteract:
		baby_penguin.reload_signal.disconnect(area.cannon.noninput_reload)
		print("cannon exited")
