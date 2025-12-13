shader_type spatial;

uniform float wave_amp = 0.7;
uniform float wave_freq = 0.2;
uniform float wave_speed = 0.5;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	float t = TIME * wave_speed;
	float wave = sin((world_pos.x) * wave_freq + t) + 
			sin((world_pos.z) * wave_freq + t);
	
	VERTEX.y += wave * wave_amp;
}

void fragment() {
	ALBEDO = vec3(0.0, 0.2, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
