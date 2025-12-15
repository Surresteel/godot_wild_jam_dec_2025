extends CharacterBody3D
class_name Sealion


@export var target: Node3D
@export var targets: Array[MeshInstance3D]

var state: SealionBaseState = SealionStates.WALKING

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D


func _ready() -> void:
	#states ready function
	state.enter(self)

func _physics_process(delta: float) -> void:
	#essentially change state
	state.pre_update(self)
	#states update function
	state.update(self, delta)
	
	move_and_slide()


func get_random_target() -> void:
	target = targets.pick_random()
