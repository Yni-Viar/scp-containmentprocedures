shader_type spatial;
// Made by Yni
// Licensed under CC0
render_mode unshaded;

uniform sampler2D noise_texture;
uniform sampler2D screen_texture: hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 noise = texture(noise_texture, SCREEN_UV);
	noise += sin(TIME / 2.0) - 1.0;
	//noise = clamp(noise, 0.0, 1.0);
	ALBEDO = noise.rgb;
	ALPHA = noise.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
