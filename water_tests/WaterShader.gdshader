shader_type spatial;

uniform float wave_amp = 2.7;
uniform float wave_freq = 0.2;
uniform float wave_speed = 0.5;

float hash(vec3 p) {
	p  = fract(p * 0.3183099 + vec3(0.1,0.1,0.1));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float smoothNoise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	
	f = f*f*(3.0-2.0*f);
	
	float n000 = hash(i + vec3(0.0, 0.0, 0.0));
	float n001 = hash(i + vec3(0.0, 0.0, 1.0));
	float n010 = hash(i + vec3(0.0, 1.0, 0.0));
	float n011 = hash(i + vec3(0.0, 1.0, 1.0));
	float n100 = hash(i + vec3(1.0, 0.0, 0.0));
	float n101 = hash(i + vec3(1.0, 0.0, 1.0));
	float n110 = hash(i + vec3(1.0, 1.0, 0.0));
	float n111 = hash(i + vec3(1.0, 1.0, 1.0));
	
	float n00 = mix(n000, n001, f.z);
	float n01 = mix(n010, n011, f.z);
	float n10 = mix(n100, n101, f.z);
	float n11 = mix(n110, n111, f.z);
	
	float n0 = mix(n00, n01, f.y);
	float n1 = mix(n10, n11, f.y);
	
	return mix(n0, n1, f.x);
}

float waveNoise(vec3 p, float scale) {
	return smoothNoise(p * scale) * 2.0 - 1.0;
}

float fbm(vec3 p) {
	float sum = 0.0;
	float amp = 1.5;
	float freq = 0.4;
	
	for (int i = 0; i < 5; i++) {
		sum += amp * smoothNoise(p * freq);
		freq *= 2.2;
		amp *= 0.2;
	}
	
	return sum;
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float t = TIME * wave_speed;
	world_pos.xz += vec2(2.0 * t, 2.0 * t);
	
	float height = fbm(vec3(world_pos.xz * wave_freq, t));
	VERTEX.y += height * wave_amp;
	
	float eps = 0.1;
	float hL = fbm(vec3((world_pos.xz - vec2(eps, 0.0)) * wave_freq, t));
	float hR = fbm(vec3((world_pos.xz + vec2(eps, 0.0)) * wave_freq, t));
	float hD = fbm(vec3((world_pos.xz - vec2(0.0, eps)) * wave_freq, t));
	float hU = fbm(vec3((world_pos.xz + vec2(0.0, eps)) * wave_freq, t));
	
	vec3 normal = normalize(vec3(-(hR - hL) / (2.0 * eps), 1.0, -(hU - hD) / (2.0 * eps)));

	NORMAL = normal;
}

void fragment() {
	ALBEDO = vec3(0.0, 0.2, 0.5);
	ROUGHNESS = 0.5;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
