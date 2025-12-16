shader_type spatial;

// Parameters to control wave properties:
uniform float time = 0.0;
uniform float wave_amp = 2.7;
uniform float wave_freq = 0.2;
uniform float wave_speed = 0.5;
uniform vec3 colour_dark = vec3(0.0, 0.25, 0.5);
uniform vec3 colour_light = vec3(0.0, 0.4, 0.5);
uniform vec3 colour_foam = vec3(0.1, 0.5, 0.8);


// Hashing function for noise generation:
float hash(vec3 p) {
	p  = fract(p * 0.3183099 + vec3(0.1,0.1,0.1));
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

// Noise function:
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

// Fractal brownian motion:
// Sums the noise function at different octaves for more granular noise.
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

// Vertex shader:
void vertex() {
	// Get vertex position in world space:
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	// Apply wave speed modifier to time:
	float t = time * wave_speed;

	// Add linear wave movement vector:
	world_pos.xz += vec2(2.0 * t, 2.0 * t);

	// Sample noise based on computed position and time:
	float height = fbm(vec3(world_pos.xz * wave_freq, t));
	//float height = h1 + h2;

	// Apply it to the vertext Y axis.
	VERTEX.y += height * wave_amp;

	// Sample proximat points in noise to generate normals (central differences)
	float eps = 0.1;
	float hL = fbm(vec3((world_pos.xz - vec2(eps, 0.0)) * wave_freq, t));
	float hR = fbm(vec3((world_pos.xz + vec2(eps, 0.0)) * wave_freq, t));
	float hD = fbm(vec3((world_pos.xz - vec2(0.0, eps)) * wave_freq, t));
	float hU = fbm(vec3((world_pos.xz + vec2(0.0, eps)) * wave_freq, t));

	// Generate normal based on proximate point sampling:
	vec3 normal = normalize(vec3(-(hR - hL) / (2.0 * eps), 1.0,
			-(hU - hD) / (2.0 * eps)));

	NORMAL = normal;

	// Colour:
	float sample_offset = fbm(vec3((world_pos.xz + vec2(100.0, 100.0)) * 0.1, t));
	float edge0 = 0.9;
	float edge1 = 1.6;
	float edge3 = 0.8;
	float edge4 = 1.2;
	float mask_foam = smoothstep(edge0, edge1, height);
	float mask_light = smoothstep(edge3, edge4, sample_offset);
	vec3 colour_dfoam = mix(colour_dark, colour_foam, mask_foam);
	vec3 colour_lfoam = mix(colour_light, colour_foam, mask_foam);
	COLOR.xyz = mix(colour_dfoam, colour_lfoam, mask_light);
}

// Fragment shader:
void fragment() {
	// Set fixed albedo and roughness values for now.
	//ALBEDO = vec3(0.0, 0.2, 0.5);
	ALBEDO = COLOR.xyz;
	ROUGHNESS = 0.5;

	// TODO: apply different colours based on wave height.
}

// Light shader (UNUSED)
//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
