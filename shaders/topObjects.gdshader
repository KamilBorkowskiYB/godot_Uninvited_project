shader_type canvas_item;

uniform float light_opacity : hint_range(0, 1);

void fragment() {
	COLOR = texture(TEXTURE, UV);
	
	if (AT_LIGHT_PASS) COLOR.a *= light_opacity;
	else COLOR.a *= (1.0 - light_opacity);
}
