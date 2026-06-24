shader_type canvas_item; // SHADER FOR CANVAS GROUP
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float strength: hint_range(0.0, 1.0);
uniform float seed: hint_range(0.01, 1.0) = 0.5;

uniform float mask_vignette_strength: hint_range(0.0, 1.0) = 0.5;
uniform vec2 mask_vignette_center = vec2(0.5, 0.3);

float random(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

vec2 random_dir(vec2 p) {
    float a = random(p * seed) * 6.2831853;
    return vec2(cos(a), sin(a));
}

void fragment() {

    vec2 uv = SCREEN_UV;

    float n = random(uv * seed);
    vec2 dir = random_dir(uv * seed);

    if (n < strength) {
        discard;
    }

    vec2 offset_uv = uv + dir * strength * 0.02;
    vec4 c = textureLod(screen_texture, offset_uv, 0.0);

    if (c.a > 0.0001) {
        c.rgb /= c.a;
    }

    float vignette = distance(uv, mask_vignette_center);
    float fade = vignette * mask_vignette_strength * strength;

    c.a -= fade;

    COLOR = c;
}