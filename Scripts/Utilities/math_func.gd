class_name MathFunc

const FLOAT_EPSILON: float = 1.1920929e-07
const LINEAR_TOLERANCE: float = 1e-15


## Copies the sign of float 'y' to float 'x':
static func copy_sign(x: float, y: float) -> float:
	return abs(x) if y >= 0 else -abs(x)


## Solver for quadratic equations - avoids precision errors:
static func solve_quadratic(a: float, b: float, c: float) -> Array[float]:
	# Return nothing when 'a' and 'b' are 0:
	if a == 0.0 and b == 0.0:
		return [] as Array[float]
	
	# Reduce to linear if 'a' is incredibly small:
	if abs(a) <= LINEAR_TOLERANCE * max(1.0, abs(b)):
		return [-c / b]
	
	# Scale 'a', 'b', and 'c' to range 0-1:
	var s: float = max(abs(a), abs(b), abs(c))
	a /= s
	b /= s
	c /= s     
	
	# Compute discriminant: 
	var disc := b * b - 4.0 * a * c
	var eps_d: float = 8.0 * FLOAT_EPSILON * abs(b * b)
	if disc < 0.0 and disc > -eps_d:
		disc = 0.0
	
	# Return nothing if discriminant is invalid:
	if disc < 0:
		return [] as Array[float]
	
	# Return single root if discriminant is 0:
	if disc == 0.0:
		return [-b / (2.0 * a)]
	
	# Compute both roots:
	var sqrt_disc = sqrt(disc)
	var q := -0.5 * (b + copy_sign(sqrt_disc, b))
	var root1: float = q / a
	var root2: float = c / q if q != 0.0 else -b / a
	var roots : Array[float] = [root1, root2]
	
	# Sort and return roots:
	roots.sort()
	return roots
