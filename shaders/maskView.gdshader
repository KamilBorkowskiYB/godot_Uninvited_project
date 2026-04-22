shader_type canvas_item;

uniform sampler2D mask_texture;
uniform sampler2D unseen;
uniform sampler2D od_mask_texture;
uniform sampler2D od_seen;
uniform sampler2D od_unseen;
const float darkness = 0.8;


void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 mask = texture(mask_texture, UV);
	vec4 outview = texture(unseen, UV);
	
	vec4 od_color = texture(od_seen, UV);
	vec4 od_mask = texture(od_mask_texture, UV);
	vec4 od_outview = texture(od_unseen, UV);
	
	float blend = mask.r;
	float lumi = (outview.r + outview.g + outview.b) / 3.0 * darkness;
	outview.rgb = vec3(lumi);
	
	vec4 final_color = mix(color, outview, blend);
	COLOR = final_color;
}
