shader_type canvas_item;

uniform sampler2D noise: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform vec2 scroll = vec2(0.05,0.05);
uniform vec2 scroll2 = vec2(-0.05,-0.05);
uniform vec4 color1 : source_color;
uniform vec4 color2 : source_color;
uniform	vec4 color3 : source_color;
uniform float min_brightness = 0.3;

void fragment() {
	vec4 noise_col = texture(noise,UV+scroll*(TIME*0.3)) * texture(noise2,UV+scroll2*(TIME*0.3));
	float noise_value = noise_col.r;
	vec4 final_color;
	if (noise_value < 0.20) {
		final_color = color1;
	} else if (noise_value < 0.50) {
		final_color = color2; 
	} else {
		final_color = color3;
	}
	COLOR = final_color;
	}


