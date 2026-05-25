//Made by Unhinged Dev
//License: CC0
//Edited by Yni.

uniform lowp float anaglyph_red_shift = 2.0;
uniform lowp float anaglyph_blue_shift = -2.0;

vec4 anaglyph(sampler2D screen_texture, vec2 screen_uv, vec2 viewport_size) {

	float r = texture(screen_texture, screen_uv + vec2((1.0 / viewport_size) * anaglyph_red_shift), 0.0).r;
	float g = texture(screen_texture, screen_uv + vec2((1.0 / viewport_size) * anaglyph_blue_shift), 0.0).g;
	float b = texture(screen_texture, screen_uv + vec2((1.0 / viewport_size) * anaglyph_blue_shift), 0.0).b;

	return vec4(r, g, b, 0.5);
}