// Made by Yni
// Licensed under CC0

uniform sampler2D glitchy_noise_texture;

vec4 glitchy_view(vec2 screen_uv) {
	vec4 noise = texture(glitchy_noise_texture, screen_uv);
	noise += sin(TIME / 2.0) - 1.0;
	noise = clamp(noise, 0.0, 1.0);
	return noise;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
