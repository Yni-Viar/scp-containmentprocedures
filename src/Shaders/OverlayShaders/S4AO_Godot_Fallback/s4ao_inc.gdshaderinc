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
// The sample_width should be even, else the midpoint is at SCREEN_UV.
// Takes sample_width^2 samples in a grid, with the corners notched.
#define USE_SSAO_LOW

#if defined(USE_SSAO_LOW)
const int ssao_sample_width = 2;
#elif defined(USE_SSAO_HIGH)
const int ssao_sample_width = 6;
#else
const int ssao_sample_width = 4;
#endif
const int ssao_notch_01 = int(ssao_sample_width > 3); // Set to 1 to skip the corner samples, 0 to include them.
const float ssao_sample_mid = (float(ssao_sample_width) - 1.0) * 0.50001; // Can't be exactly 0.5 in case sample_width is odd.
#if defined(USE_SSAO_LOW)
const float ssao_inv_half_width = 1.0 / ssao_sample_mid; // The 2x2 sampling looks wider as all samples are at radius.
#else
const float ssao_inv_half_width = 1.7 / ssao_sample_mid; // Bake in the 1.7 scale for the random rotation.
#endif
const float ssao_average_samples = 1.0 / float(ssao_sample_width * ssao_sample_width - 4 * ssao_notch_01); //  1 / number_of_samples
const float ssao_falloff_frac = 0.25;

const vec2 ssao_prn_UV = vec2(
	1.087f * ((1.0f + sqrt(5.0f)) / 2.0f), 1.087f * ((9.0f + sqrt(221.0f)) / 10.0f)
);

uniform float ssao_strength = 2.0;
uniform float ssao_radius = 0.5;

vec4 ssao(sampler2D depth_buffer, vec2 screen_uv) {
	float depth = texture(depth_buffer, screen_uv).r;
	float radius = max(1e-4f, depth * ssao_radius);
	float inv_falloff = 1.0f / max(1e-4f, depth * ssao_falloff_frac);
	// Random 2D rotation per pixel (+/-45 deg, with 0 having a lower probability).
	// The random cosine vector is vec2( 0.5, -0.5 to +0.5 ) and *1.7 makes the average length ~ 1.
	vec2 rcos = (ssao_inv_half_width * radius) * vec2(0.5f, fract(dot(screen_uv, ssao_prn_UV)) - 0.5f);
	vec2 rsin = rcos.yx * vec2(-1, 1); // Perpendicular to the random cosine vector.
	// Grab the samples and determine the occlusion.
	float occlusion = 0.0f;
	vec2 base_duv = -ssao_sample_mid * rsin;
	for (int j = ssao_sample_width; --j >= 0;) {
#if defined(USE_SSAO_LOW)
		// Low quality uses 2x2 samples, no notching.
		vec2 duv = -ssao_sample_mid * rcos + base_duv;
		for (int i = ssao_sample_width; --i >= 0;) {
#else
		//	Will uses 4x4 or 6x6 samples, with the corners notched out.
		int o = /*notch_01 &*/ int((j <= 0) || (j >= (ssao_sample_width - 1))); // Notch corners of the grid.
		vec2 duv = (float(o) - ssao_sample_mid) * rcos + base_duv;
		for (int i = ssao_sample_width - o - o; --i >= 0;) {
#endif
			float dz = texture(depth_buffer, screen_uv + duv).r - depth;
			float validity = smoothstep(1.0f, 0.0f, dz * inv_falloff);
			occlusion += normalize(vec3(duv, dz)).z * validity; // How 'directly overhead' is it?
			duv += rcos; // March along the rcos direction with i.
		}
		base_duv += rsin; // March along the rsin direction with j.
	}
	// Adjust the occlusion for intensity, and # samples.
	occlusion *= ssao_strength * ssao_average_samples;
	occlusion = clamp(1.0f - occlusion, 0.0f, 1.0f);
	return vec4(0.0, 0.0, 0.0, 1.0-occlusion * occlusion);
}
