shader_type canvas_item;

// needs to match the number of values being sent
const int MAX_POSITIONS = 2;

uniform vec2 CircleCentres[MAX_POSITIONS];
uniform int NumCircleCentres : hint_range(0, 2, 1) = 1;
uniform float CircleRadius = 50.0;
uniform float CircleBlur : hint_range(0.0, 1.0, 0.01) = 0.0;

void fragment() 
{
    float circle_signal = 0.0;
    for ( int i = 0; i < NumCircleCentres; ++i )
    {
        float circle_dist = distance( CircleCentres[i], FRAGCOORD.xy );
        circle_signal = max( circle_signal, smoothstep( CircleRadius, CircleRadius*(1.0-CircleBlur), circle_dist ) );
    }
    vec4 tex_color = texture( TEXTURE, UV );
    float lumi = (tex_color.r + tex_color.g + tex_color.b) / 3.0;
    COLOR.rgb = vec3(lumi);
    //COLOR = tex_color;
    COLOR.a *= ( 1.0 - circle_signal );
}
