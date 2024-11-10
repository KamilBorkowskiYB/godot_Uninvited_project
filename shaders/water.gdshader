shader_type canvas_item;

uniform sampler2D noise: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform vec2 scroll = vec2(0.05,0.05);
uniform vec2 scroll2 = vec2(-0.05,-0.05);
uniform vec4 tone_color : source_color;
uniform float min_brightness = 0.3;

void fragment() {
	vec4 noise_col = texture(noise,UV+scroll*(TIME*0.3)) * texture(noise2,UV+scroll2*(TIME*0.3));
	vec4 dark_green = vec4(tone_color.rgb * min_brightness, tone_color.a);
	 COLOR = mix(dark_green, tone_color, noise_col.r);
}


