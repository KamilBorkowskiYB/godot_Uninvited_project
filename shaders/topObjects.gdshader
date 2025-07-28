shader_type canvas_item;
// camera_control.gd sets values via code
// needs to match the number of values being sent
const int MAX_POSITIONS = 2;

uniform vec2 CircleCentres[MAX_POSITIONS];
uniform int NumCircleCentres : hint_range(0, 2, 1) = 1;
uniform float PlayerCircleRadius = 100.0;
uniform float CursosCircleRadius = 70.0;
uniform float CircleBlur : hint_range(0.0, 1.0, 0.01) = 0.0;

void fragment() 
{
    float circle_signal = 0.0;
	
	//Cursor
	float cursor_circle_dist = distance( CircleCentres[0], FRAGCOORD.xy );
	circle_signal = max( circle_signal, smoothstep( CursosCircleRadius, CursosCircleRadius*(1.0-CircleBlur), cursor_circle_dist ) );
	
	//Player
	float player_circle_dist = distance( CircleCentres[1], FRAGCOORD.xy );
	circle_signal = max( circle_signal, smoothstep( PlayerCircleRadius, PlayerCircleRadius*(1.0-CircleBlur), player_circle_dist ) );
	
    // grayscale
    vec4 tex_color = texture( TEXTURE, UV );
    float lumi = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
    COLOR.rgb = vec3(lumi);

    //COLOR = tex_color;
    COLOR.a *= ( 1.0 - circle_signal );
}
