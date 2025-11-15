shader_type canvas_item;

const int MAX_POSITIONS = 2;

uniform bool transparent = true;
uniform bool fog_dont_show = false; //true - coursor isn't revealing, set on viewport2 -fogViewport
uniform vec2 CircleCentres[MAX_POSITIONS];
uniform int NumCircleCentres : hint_range(0, 2, 1) = 2;
uniform float PlayerCircleRadius = 400.0;
uniform float CursosCircleRadius = 100.0;
uniform float CircleBlur : hint_range(0.0, 1.0, 0.01) = 0.35;

uniform bool wind_on = true;
uniform float wind_strength = 5.0;
uniform float wind_speed = 1.0;
uniform vec2 wind_direction = vec2(1.0, 0.0);
uniform float distortion_scale = 5.0;

void fragment() 
{
    // WIND
	vec2 warped_uv = UV;
	if (wind_on == true){
	    float time = TIME * wind_speed;
	    float dist_from_center = distance(UV, vec2(0.5));
	    float wind_factor = smoothstep(0.0, 0.5, dist_from_center); //center isn't affected
	
	    vec2 offset = wind_direction * sin(UV.y * wind_strength + time) * distortion_scale * wind_factor * TEXTURE_PIXEL_SIZE;
	    warped_uv = UV + offset;
	}
    //
    
    // MOUSE AND PLAYER TRANSPARENCY
	float circle_signal = 0.0;
	if(transparent){
		if(!fog_dont_show){
			float cursor_circle_dist = distance(CircleCentres[0], FRAGCOORD.xy);
			circle_signal = max(circle_signal, smoothstep(CursosCircleRadius, CursosCircleRadius * (1.0 - CircleBlur), cursor_circle_dist));
		}
	
	    float player_circle_dist = distance(CircleCentres[1], FRAGCOORD.xy);
	    circle_signal = max(circle_signal, smoothstep(PlayerCircleRadius, PlayerCircleRadius * (1.0 - CircleBlur), player_circle_dist));
	}
    //

    vec4 tex_color = texture(TEXTURE, warped_uv);
    float lumi = (tex_color.r + tex_color.g + tex_color.b) / 3.0; //grayscale
    COLOR.rgb = vec3(lumi);
    COLOR.a = tex_color.a * (1.0 - circle_signal);
}
