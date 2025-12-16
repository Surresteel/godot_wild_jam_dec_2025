#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name WaveFunc


# STATIC MEMBERS:
static var size := Vector2(20.0, 40.0)


#===============================================================================
#	PRIVATE STATIC FUNCTIONS:
#===============================================================================
static func sample_wave_height(_pos: Vector2, offset: Vector2, 
		dir: Vector2, amp: float) -> float:
	var length := size.x * 0.5
	var width := size.y * 0.25
	
	#var to_vert: Vector2 = (pos + offset) - Vector2(0.0, 2.0);
	var to_vert: Vector2 = offset - Vector2(0.0, 2.0);
	
	var along: float = to_vert.dot(dir)
	along = max(along, 0.0);
	
	var perp: Vector2 = to_vert - dir * along
	var lateral: float = perp.length()
	
	var t: float = clampf(along / width, 0.0, 1.0)
	var lead_steep := 0.6;
	var trail_soft := 1.8;
	var t_warped: float;
	if (t < 0.5):
		t_warped = 0.5 * pow(t * 2.0, lead_steep)
	else :
		t_warped = 1.0 - 0.5 * pow((1.0 - t) * 2.0, trail_soft)
	
	var wave_shape: float = sin(t_warped * PI)
	var x: float = lateral / width
	var mask_lateral: float = exp(-pow(x, 2.5))
	var mask_length: float = smoothstep(length, 0.0, along)
	var height: float = amp * wave_shape * mask_lateral * mask_length
	
	return height


#===============================================================================
#	EOF:
#===============================================================================
