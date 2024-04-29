shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	float lumi = (color.r + color.g + color.b) / 3.0;
	color.rgb = vec3(lumi);
	COLOR = color;
}
