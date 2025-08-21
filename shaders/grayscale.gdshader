shader_type canvas_item;

const float darkness = 0.7;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float lumi = (color.r + color.g + color.b) / 3.0;
	lumi *= darkness;
	color.rgb = vec3(lumi);
	COLOR = color;
}
