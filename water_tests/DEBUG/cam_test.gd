extends Camera3D

@export var ship: Ship

func _process(_delta: float) -> void:
	transform.origin = ship.transform.origin + ship.global_basis * Vector3(2.0, 3.5, -3.0)
	var fward := ship.global_basis.x.cross(Vector3.UP)
	var b := Basis.looking_at(fward, Vector3.UP)
	transform.basis = b
