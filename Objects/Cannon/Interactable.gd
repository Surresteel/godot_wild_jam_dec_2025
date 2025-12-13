extends Area3D
class_name Interactable

var player: Player = null
@export var interactable_node: Node3D


func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		player = body
		player.connect("Interact",toggle_interaction)

func _on_body_exited(body: Node3D) -> void:
	if body == player:
		player.disconnect("Interact",toggle_interaction)
		player = null

func toggle_interaction() -> void:
	if interactable_node.is_active:
		interactable_node.is_active = false
		player.is_interacting = false
	else:
		interactable_node.is_active = true
		player.is_interacting = true
