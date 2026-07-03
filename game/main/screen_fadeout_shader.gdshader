shader_type canvas_item;

uniform sampler2D noise;
uniform float progress : hint_range(0.0,1.0);

void fragment()
{
    float value = texture(noise, UV).r;

    if (value < progress)
        COLOR = vec4(0.0);
    else
        COLOR = vec4(0.0,0.0,0.0,1.0);
}