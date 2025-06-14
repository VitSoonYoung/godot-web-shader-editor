shader_type canvas_item;

uniform vec4 color_white : source_color = vec4(1.0);
uniform vec4 color_black : source_color = vec4(0.0);
uniform float size = 32.0; // Size of each square in pixels

void fragment() {
    vec2 uv = FRAGCOORD.xy / size;
    int checker = int(floor(uv.x) + floor(uv.y)) % 2;
    COLOR = checker == 0 ? color_white : color_black;
}