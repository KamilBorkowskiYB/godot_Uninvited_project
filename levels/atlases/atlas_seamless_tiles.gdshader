shader_type canvas_item;

uniform sampler2D overlay_grass_texture_one: repeat_enable, filter_nearest;
uniform sampler2D overlay_grass_texture_two: repeat_enable, filter_nearest;
uniform sampler2D grass_noise: repeat_enable, filter_nearest;
uniform sampler2D overlay_texture_two: repeat_enable, filter_nearest;
uniform sampler2D overlay_texture_three: repeat_enable, filter_nearest;
uniform sampler2D water_noise: repeat_enable, filter_nearest;
uniform sampler2D water_noise2: repeat_enable, filter_nearest;

uniform float scale = 0.01;
const float grass_blend_threshold = 0.5;
const float grass_blend_softness = 0.426;
const float GRASS_TILE_COUNT = 5.0;

const float water_scale = 0.001;        // frequency of water noise
const float water_threshold = 0.41;      // coverage threshold
const vec3 water_color = vec3(0.078, 0.086, 0.075);
const vec3 water_color2 = vec3(0.122, 0.129, 0.098);
const float time_speed = 0.002;          // water animation speed
varying vec2 world_pos;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	if (COLOR.a > 0.01){
		// Grass overlay
		vec3 mask_color = vec3(1.0, 0.0, 0.6941);
		float mix_amount = float(distance(COLOR.rgb, mask_color) < 0.01);
		vec2 tile_uv = fract(world_pos * scale);
		vec2 noise_uv = fract(world_pos * scale / 5.0);
		vec4 tex_a = texture(overlay_grass_texture_one, tile_uv);
		vec4 tex_b = texture(overlay_grass_texture_two, tile_uv);
		float noise = texture(grass_noise, noise_uv).r;
		float blend = smoothstep(
			grass_blend_threshold - grass_blend_softness,
			grass_blend_threshold + grass_blend_softness,
			noise
		);
		COLOR = mix(COLOR, mix(tex_a, tex_b, blend), mix_amount);
		
		// Brick overlay
		mask_color = vec3(0.2, 0.17647, 0.17647);
		float original_alpha = COLOR.a;
		mix_amount = float(distance(COLOR.rgb, mask_color) < 0.01);
		vec4 overlay_color_two = texture(overlay_texture_two, world_pos * scale);
		COLOR = mix(COLOR, overlay_color_two, mix_amount);
		COLOR.a = original_alpha;
		
		// WoodPanels overlay
		mask_color = vec3(0.59608, 0.38431, 0.11373);
		original_alpha = COLOR.a;
		mix_amount = float(distance(COLOR.rgb, mask_color) < 0.01);
		vec4 overlay_color_three = texture(overlay_texture_three, world_pos * scale);
		COLOR = mix(COLOR, overlay_color_three, mix_amount);
		COLOR.a = original_alpha;
		
		// Water overlay on tiles with #1f10bd
		mask_color = vec3(0.7412, 0.0627, 0.0627);
		mix_amount = float(distance(COLOR.rgb, mask_color) < 0.01);
		
		if (mix_amount > 0.0) {
			// Sample two noise textures moving in opposite directions
			vec2 uv1 = world_pos * water_scale + TIME * time_speed;
			vec2 uv2 = world_pos * water_scale - TIME * time_speed;
		
			float n1 = texture(water_noise, uv1).r;
			float n2 = texture(water_noise2, uv2).r;
			float combined_noise = (n1 + n2) * 0.5;
		
		if (combined_noise > water_threshold) {
				COLOR = mix(COLOR, vec4(water_color, 1.0), 1.0);
			}
			else{
				COLOR = mix(COLOR, vec4(water_color2, 1.0), 1.0);
			}
		}
	} 
}