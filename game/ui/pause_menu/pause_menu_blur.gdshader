shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 2.0) = 0.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 col = vec4(0.0);
    float total = 0.0;
    for (float x = -blur_amount; x <= blur_amount; x += 1.0) {
        for (float y = -blur_amount; y <= blur_amount; y += 1.0) {
            col += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(x, y) * SCREEN_PIXEL_SIZE);
            total += 1.0;
        }
    }
    COLOR = col / total;
}