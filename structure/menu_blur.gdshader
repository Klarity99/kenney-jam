shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float blur = 2.0;

void fragment() {
    vec2 size = vec2(textureSize(screen_texture, 0));
    vec2 px = blur / size;

    vec4 col = vec4(0.0);

    col += texture(screen_texture, SCREEN_UV + vec2(-px.x, -px.y));
    col += texture(screen_texture, SCREEN_UV + vec2( 0.0, -px.y));
    col += texture(screen_texture, SCREEN_UV + vec2( px.x, -px.y));

    col += texture(screen_texture, SCREEN_UV + vec2(-px.x,  0.0));
    col += texture(screen_texture, SCREEN_UV);
    col += texture(screen_texture, SCREEN_UV + vec2( px.x,  0.0));

    col += texture(screen_texture, SCREEN_UV + vec2(-px.x,  px.y));
    col += texture(screen_texture, SCREEN_UV + vec2( 0.0,  px.y));
    col += texture(screen_texture, SCREEN_UV + vec2( px.x,  px.y));

    COLOR = col / 9.0;
}