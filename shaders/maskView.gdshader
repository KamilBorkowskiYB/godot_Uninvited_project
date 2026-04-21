shader_type canvas_item;

uniform sampler2D mask_texture;
uniform sampler2D unseen;
const float darkness = 0.8;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 mask = texture(mask_texture, UV);
	vec4 outview = texture(unseen, UV);
	float alpha = mask.a;
	//color.a = 1.0 - mask.r;
	
	float blend = mask.r;
	
	float lumi = (outview.r + outview.g + outview.b) / 3.0 * darkness;
	outview.rgb = vec3(lumi);
	
	vec4 final_color = mix(color, outview, blend);
	COLOR = final_color;
}
