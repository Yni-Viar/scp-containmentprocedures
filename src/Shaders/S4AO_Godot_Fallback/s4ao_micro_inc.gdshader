// S4AO (Stupid Simple Screen Space Ambient Occlusion) - Jonathan Dummer (O1S)
/**************************************************************************/
/*                         This file is part of:                          */
/*                             GODOT ENGINE                               */
/*                        https://godotengine.org                         */
/**************************************************************************/
/* Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). */
/* Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/
// This micro version uses only 3 depth samples, the midpoint and a randomly-rotated, balanced pair.
shader_type spatial;
render_mode unshaded;


const vec2 ssao_prn_UV = vec2(
	1.087f * ((1.0f + sqrt(5.0f)) / 2.0f), 1.087f * ((9.0f + sqrt(221.0f)) / 10.0f)
);

uniform float ssao_strength = 2.0;
uniform float ssao_radius = 0.5;
uniform sampler2D depth_buffer: hint_depth_texture;
uniform sampler2D screen_texture: hint_screen_texture;

const mediump float ssao_falloff_frac = 0.25;

void fragment() {
	// Perform the SSAO.
	mediump float depth = texture(depth_buffer, SCREEN_UV).r;
	mediump float inv_falloff = 1.0f / max(1e-4f, depth * ssao_falloff_frac);
	// Random 2D rotation per pixel (0..1 -> parabola approximating a 180 deg arc)
	mediump float r01 = fract(dot(SCREEN_UV, ssao_prn_UV));
	mediump vec2 duv = vec2(r01 - 0.5f, 2.0f * (r01 - r01 * r01)) * (2.0f * depth * ssao_radius); // 180 degrees.
	// Grab the samples and determine the occlusion.
	mediump float occlusion = 0.0f;
	for (int s = 0; s < 2; ++s) {
		mediump float dz = texture(depth_buffer, SCREEN_UV + duv).r - depth;
		// How 'directly overhead' is it?  Factor in the falloff depth.
		occlusion += normalize(vec3(duv, dz)).z * mix(1.0f, 0.0f, dz * inv_falloff);
		// Mirror the next sample.
		duv = -duv;
	}
	// Adjust the occlusion for intensity, and # samples.
	occlusion = 1.0f - clamp(occlusion * 0.5f * ssao_strength, 0.0f, 1.0f);
	
	//vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	//color *= occlusion * occlusion;
	ALBEDO = vec3(0.0);
	ALPHA = 1.0 - occlusion * occlusion;
}