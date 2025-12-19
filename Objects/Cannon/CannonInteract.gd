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
			player.camera.transfer_camera(player.camera_position)
		cannon.player = null
		cannon.deactivate()
		cannon.cannon_exit.disconnect(player.teleport_to_position)
		
	else:                          #Turn On
		player.is_interacting = true
		if change_camera:
			player.camera.transfer_camera(cannon.camera_positon)
		cannon.player = player
		cannon.cannon_exit.connect(player.teleport_to_position)
		cannon.activate()
	
