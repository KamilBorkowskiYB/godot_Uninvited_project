shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D noise_texture;

uniform float dissolve : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	
	vec4 c = texture(screen_texture, SCREEN_UV);
	
	if (c.a <= 0.001) {
		discard;
	}
	
	if (c.a > 0.0) {
		c.rgb /= c.a;
	}
	
	float n = texture(noise_texture, UV).r;
	
	if (n < dissolve) {
		discard;
	}
	
	
	COLOR *= c;
}