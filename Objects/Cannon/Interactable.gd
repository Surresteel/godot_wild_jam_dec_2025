extends Area3D
class_name Interactable

var player: Player = null
@export var interactable_node: Node3D
@export var change_camera: bool = false

func _process(delta: float) -> void:
	global_position = interactable_node.global_position

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body
		player.connect("Interact",toggle_interaction)

func _on_body_exited(body: Node3D) -> void:
	if body == player:
		player.disconnect("Interact",toggle_interaction)
		player = null
	print(body)

func toggle_interaction() -> void:
	if interactable_node.is_active: #Turn Off
		interactable_node.is_active = false
		player.is_interacting = false
		if change_camera:
			player.camera.current = true
			interactable_node.camera.current = false
	else:                          #Turn On
		interactable_node.is_active = true
		player.is_interacting = true
		if change_camera:
			interactable_node.camera.current = true
			player.camera.current = false
