shader_type spatial;


// Parameters to control a single wave feature in world space:
instance uniform vec2 size = vec2(20.0, 40.0);
instance uniform vec3 colour = vec3(0.0, 0.2, 0.5);
//instance uniform vec2 swave_dir = vec2(0.0, 0.0);
instance uniform float swave_amp = 0.0;

const vec2 swave_dir = vec2(0.0, 1.0);


// Creates a wave mask based on the swave parameters:
float swave_height(vec2 pos)
{
	float swave_length = size.x * 0.5;
	float swave_width = size.y * 0.25;
	// Direction from wave origin to vert:
	//vec2 to_vert = pos - vec2(0.0, 1.0);
	vec2 to_vert = pos;

	// Projection of wave direction onto to_vert:
	float along = dot(to_vert, swave_dir);
	along = max(along, 0.0);

	// Controls width falloff
	vec2 perp = to_vert - swave_dir * along;
	float lateral = length(perp);

	// Controls length falloff.
	float t = clamp(along / swave_width, 0.0, 1.0);
	float lead_steep = 0.6;
	float trail_soft = 1.8;
	float t_warped;
	if (t < 0.5) {
	    t_warped = 0.5 * pow(t * 2.0, lead_steep);
	} else {
	    t_warped = 1.0 - 0.5 * pow((1.0 - t) * 2.0, trail_soft);
	}

	// Combine bases into one and query height:
	float wave_shape = sin(t_warped * PI);
	//float lateral_mask = exp(-lateral * lateral / (swave_width * swave_width));
	float x = lateral / swave_width;
	float lateral_mask = exp(-pow(x, 2.5));
	float length_mask = smoothstep(swave_length, 0.0, along);
	float height = swave_amp * wave_shape * lateral_mask * length_mask;

	return height;
}

void vertex() {
	float height = swave_height(VERTEX.xz);
	VERTEX.y = height;

	float eps = 0.1;
	float hL = swave_height(VERTEX.xz - vec2(eps, 0.0));
	float hR = swave_height(VERTEX.xz + vec2(eps, 0.0));
	float hD = swave_height(VERTEX.xz - vec2(0.0, eps));
	float hU = swave_height(VERTEX.xz + vec2(0.0, eps));

	vec3 normal = normalize(vec3(-(hR - hL) / (2.0 * eps), 1.0,
			-(hU - hD) / (2.0 * eps)));

	NORMAL = normal;
}

void fragment() {
	ALBEDO = colour;
	ROUGHNESS = 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
