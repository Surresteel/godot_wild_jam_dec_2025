extends Camera3D

@export var target: Node3D

func _process(_delta: float) -> void:
	transform.origin = target.transform.origin + target.global_basis \
			* Vector3(-2.0, 5.5, -15.0)
	var fward := target.global_basis.x.cross(Vector3.UP)
	var b := Basis.looking_at(fward, Vector3.UP)
	transform.basis = b
