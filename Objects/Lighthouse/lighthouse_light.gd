#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
extends Node3D

#===============================================================================
#	INSTANCE MEMBERS:
#===============================================================================
@export var lighthouse: Node3D
@export var player: Node3D

@onready var mesh: MeshInstance3D = $Mesh
@onready var light: SpotLight3D = $Light

var _offset_vert_light := Vector3(0.0, 65.0, 0.0)
var _offset_dist_light: float = 500.0


func _process(_delta: float) -> void:
	if not lighthouse or not player:
		return
	
	_update_point_offset()
	_update_orientation()
	_update_alpha()


#===============================================================================
#	TRANSFORM FUNCTIONS:
#===============================================================================
func _update_point_offset() -> void:
	var l_pos = lighthouse.global_position + _offset_vert_light
	var p_pos = player.global_position
	var p_to_l = l_pos - p_pos
	var dir = p_to_l.normalized()
	if p_to_l.length() <= _offset_dist_light:
		global_position = l_pos
	else:
		global_position = p_pos + dir * _offset_dist_light


func _update_orientation() -> void:
	var l_pos = lighthouse.global_position + _offset_vert_light
	var p_pos = player.global_position
	var l_to_p = p_pos - l_pos
	var b := Basis.looking_at(l_to_p.normalized(), Vector3.UP)
	basis = b


#===============================================================================
#	MATERIAL FUNCTIONS:
#===============================================================================
func _update_alpha() -> void:
	var mat = mesh.get_active_material(0)
	var alpha_val: float = sin(Time.get_ticks_msec() * 0.001)
	alpha_val = (alpha_val + 1) * 0.5
	var c: Color = mat.albedo_color
	c.a = alpha_val
	mat.albedo_color = c
	light.spot_range = remap(alpha_val, 0.0, 1.0, 0.0, 1024.0)
