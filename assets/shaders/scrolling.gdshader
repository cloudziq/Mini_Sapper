shader_type canvas_item;

uniform float x_scroll = 160;
uniform float y_scroll = 120;


void fragment() {
    vec2 uv  = vec2(UV.x+TIME/x_scroll, UV.y+TIME/y_scroll);
    vec4 col = texture(TEXTURE, uv);
    COLOR = col;
}