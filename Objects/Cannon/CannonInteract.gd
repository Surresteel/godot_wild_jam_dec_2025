extends Area3D
class_name CannonInteract

var player: Player = null
var cannon: Cannon
@export var change_camera: bool = false


func _process(_delta: float) -> void:
	global_position = cannon.global_position

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body
		player.connect("Interact",toggle_interaction)

func _on_body_exited(body: Node3D) -> void:
	if body == player:		
		if player.is_interacting:
			toggle_interaction()
		
		player.disconnect("Interact",toggle_interaction)
		player = null

func toggle_interaction() -> void:
	if cannon.is_active: #Turn Off
		player.is_interacting = false
		if change_camera:
			player.camera.current = true
			cannon.camera.current = false
		cannon.player = null
		cannon.deactivate()
		
	else:                          #Turn On
		player.is_interacting = true
		if change_camera:
			cannon.camera.current = true
			player.camera.current = false
			cannon.camera.global_position = player.camera.global_position
			cannon.camera.global_rotation = player.camera.global_rotation
		cannon.player = player
		cannon.activate()
	
