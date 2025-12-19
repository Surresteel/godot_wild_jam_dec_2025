extends Area3D



func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.Interact.connect(body.snowball_action.reload)


func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		body.Interact.disconnect(body.snowball_action.reload)
