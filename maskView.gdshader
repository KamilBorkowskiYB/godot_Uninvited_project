shader_type canvas_item;

uniform sampler2D mask_texture;
uniform sampler2D unseen;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 mask = texture(mask_texture, UV);
	vec4 outview = texture(unseen, UV);
	float alpha = mask.a;
	color.a = 1.0 - mask.r;
	/*
	if(mask.r > 0.7) {
		color.rgb = outview.rgb;
		float lumi = (color.r + color.g + color.b) / 3.0;
		color.rgb = vec3(lumi);
	}*/

	COLOR = color;
}
