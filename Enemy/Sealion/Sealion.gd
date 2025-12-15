extends CharacterBody3D
class_name Sealion


@export var player: Player

var state: SealionBaseState = SealionStates.SWIMMING

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
var speed:= 2


func _ready() -> void:
	state.enter(self)

func _physics_process(delta: float) -> void:
	nav_agent.target_position = player.global_position
	var dir: Vector3 = (nav_agent.get_next_path_position() - global_position).normalized()
	velocity = Vector3(dir.x,0,dir.z) * speed
	
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	move_and_slide()
