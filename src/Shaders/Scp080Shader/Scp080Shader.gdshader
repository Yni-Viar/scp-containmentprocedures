shader_type spatial;
//Basically, combined SCP-939/1223's amnesia and SCP-2028's nightmare shaders.
//made by Yni, licensed under CC0.

uniform sampler2D noise_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 noise = texture(noise_texture, SCREEN_UV + vec2(TIME * 0.1, 0.0));
	noise += sin(TIME / 2.0) - 1.0;
	noise = clamp(noise, 0.0, 1.0);
	ALBEDO = noise.rgb;
	ALPHA = noise.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
