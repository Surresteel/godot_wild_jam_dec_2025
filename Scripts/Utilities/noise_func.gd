#===============================================================================
#	CLASS PROPERTIES:
#===============================================================================
class_name NoiseFunc

# CONSTANTS:
const WAVE_AMP: float = 2.0
const WAVE_FREQ: float = 0.3
const WAVE_SPEED: float = 0.4


#===============================================================================
#	PRIVATE STATIC FUNCTIONS:
#===============================================================================
static func _hash(p: Vector3) -> float:
	p = (p * 0.3183099 + Vector3(0.1, 0.1, 0.1)) - floor((p * 0.3183099 + 
			Vector3(0.1, 0.1, 0.1)))
	p *= 17.0;
	return (p.x * p.y * p.z * (p.x + p.y + p.z)) - floor(p.x * p.y * p.z * 
			(p.x + p.y + p.z))


static func _smoothNoise(p: Vector3) -> float:
	var i: Vector3 = floor(p)
	var f: Vector3 = p - floor(p)
	
	f = f * f * (Vector3(3.0, 3.0, 3.0) - f * 2.0)
	
	var n000: float = _hash(i + Vector3(0.0, 0.0, 0.0));
	var n001: float = _hash(i + Vector3(0.0, 0.0, 1.0));
	var n010: float = _hash(i + Vector3(0.0, 1.0, 0.0));
	var n011: float = _hash(i + Vector3(0.0, 1.0, 1.0));
	var n100: float = _hash(i + Vector3(1.0, 0.0, 0.0));
	var n101: float = _hash(i + Vector3(1.0, 0.0, 1.0));
	var n110: float = _hash(i + Vector3(1.0, 1.0, 0.0));
	var n111: float = _hash(i + Vector3(1.0, 1.0, 1.0));
	
	var n00: float = lerp(n000, n001, f.z);
	var n01: float = lerp(n010, n011, f.z);
	var n10: float = lerp(n100, n101, f.z);
	var n11: float = lerp(n110, n111, f.z);
	
	var n0: float = lerp(n00, n01, f.y);
	var n1: float = lerp(n10, n11, f.y);
	
	return lerp(n0, n1, f.x)


static func _fbm(p: Vector3) -> float:
	var sum: float = 0.0;
	var amp: float = 1.5
	var freq: float = 0.4
	
	for i in 5:
		sum += amp * _smoothNoise(p * freq)
		freq *= 2.2
		amp *= 0.2
	
	return sum


#===============================================================================
#	PUBLIC STATIC FUNCTIONS:
#===============================================================================

static func sample_at_pos_time(pos_time: Vector3) -> float:
	var t: float = pos_time.z * WAVE_SPEED
	#var pos_shift := Vector2(2.0 * t, 2.0 * t)
	pos_time += Vector3(2.0 * t, 2.0 * t, 0.0)
	
	return _fbm(Vector3(pos_time.x * WAVE_FREQ, pos_time.y * WAVE_FREQ, t)) \
			* WAVE_AMP
