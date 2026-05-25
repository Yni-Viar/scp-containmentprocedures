shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform sampler2D DEPTH_TEXTURE: hint_screen_texture;
#include "res://Shaders/OverlayShaders/GlitchyViewShader/glitchy_view.gdshaderinc"
void fragment() {
vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
color = mix(color, glitchy_view(SCREEN_UV).rgb, glitchy_view(SCREEN_UV).a);
ALBEDO = color;
}
