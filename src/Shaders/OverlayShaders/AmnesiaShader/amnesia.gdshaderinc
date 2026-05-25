//Made by Yni
//License: CC0

uniform sampler2D amnesia_noise_texture: source_color, repeat_enable;

vec4 amnesia(vec2 screen_uv) {
	vec4 noise = texture(amnesia_noise_texture, screen_uv + vec2(TIME * 0.1, 0.0));
	return noise;
}