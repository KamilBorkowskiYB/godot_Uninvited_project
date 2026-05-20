shader_type canvas_item;

uniform sampler2D mask_texture;
uniform sampler2D unseen;

uniform sampler2D od_portal;
uniform sampler2D od_occluders;

uniform sampler2D od_mask_texture;
uniform sampler2D od_seen;
uniform sampler2D od_unseen;
const float darkness = 0.8;
uniform float swap_fog_progress : hint_range(0.0, 1.0) = 1.0;


void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec4 mask = texture(mask_texture, UV);
	vec4 outview = texture(unseen, UV);
	
	vec4 od_color = texture(od_seen, UV);
	vec4 od_mask = texture(od_mask_texture, UV);
	vec4 od_outview = texture(od_unseen, UV);
	
	vec4 dim_split = texture(od_portal, UV);
	vec4 dim_occluders = texture(od_occluders, UV);
	vec3 inverted_dim_occluders = vec3(1.0) - dim_occluders.rgb; //inverts black with white
	vec3 dimension_mask = dim_split.rgb * inverted_dim_occluders; // white - other dimension
	
	float blend = mask.r;
	float outview_grayscale = (outview.r + outview.g + outview.b) / 3.0 * darkness;
	float other_outview_grayscale = (od_outview.r + od_outview.g + od_outview.b) / 3.0 * darkness;
	vec3 animated_outview = vec3(mix(outview_grayscale, other_outview_grayscale, swap_fog_progress));
	outview.rgb = vec3(animated_outview);
	vec4 main_dimension_final = mix(color, outview, blend); //main dimension final
	
	blend = od_mask.r;
	animated_outview = vec3(mix(other_outview_grayscale, outview_grayscale, swap_fog_progress));
	od_outview.rgb = vec3(animated_outview);
	vec4 other_dimension_final = mix(od_color, od_outview, blend); //other dimension final
	
	blend = dimension_mask.r;
	vec4 final_vision = mix(main_dimension_final, other_dimension_final, blend);
	
	COLOR = final_vision;
}
