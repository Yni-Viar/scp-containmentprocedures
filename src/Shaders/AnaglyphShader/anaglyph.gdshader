shader_type spatial;
render_mode unshaded;

//Made by Unhinged Dev
//License: CC0
//Edited by Yni.

uniform sampler2D screen_texture: hint_screen_texture, repeat_enable;

uniform lowp float red_shift;
uniform lowp float blue_shift;

void fragment() {
	vec2 uvs = SCREEN_UV;
	vec4 final_texture = texture(screen_texture, uvs);

	float r = texture(screen_texture, uvs + vec2((1.0 / VIEWPORT_SIZE) * red_shift), 0.0).r;
	float g = texture(screen_texture, uvs + vec2((1.0 / VIEWPORT_SIZE) * blue_shift), 0.0).g;
	float b = texture(screen_texture, uvs + vec2((1.0 / VIEWPORT_SIZE) * blue_shift), 0.0).b;

	ALBEDO = vec3(r, g, b);
	ALPHA = 0.5;
}