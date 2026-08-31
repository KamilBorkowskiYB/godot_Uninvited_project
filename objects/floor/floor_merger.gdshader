shader_type canvas_item;

uniform sampler2D texture_a;
uniform sampler2D texture_b;
uniform sampler2D noise_texture;

uniform float blend_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float blend_softness : hint_range(0.001, 1.0) = 0.15;

const float TILE_COUNT = 5.0;

void fragment() {
	vec2 tile_uv = fract(UV * TILE_COUNT);
	vec2 noise_uv = UV;
	
	vec4 tex_a = texture(texture_a, tile_uv);
	vec4 tex_b = texture(texture_b, tile_uv);
	
	float noise = texture(noise_texture, noise_uv).r;
	
	float blend = smoothstep(
		blend_threshold - blend_softness,
		blend_threshold + blend_softness,
		noise
	);
	
	COLOR = mix(tex_a, tex_b, blend);
}