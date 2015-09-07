
void main(void)
{
vec2 cPos = vec2(-1.0 + 2.0 * v_tex_coord.x, -v_tex_coord.y);
float cLength = length(cPos);

vec2 uv = v_tex_coord+(cPos/cLength)*cos(cLength*2.0-time)*0.035;
vec4 col = texture2D(u_texture,uv);

gl_FragColor = col;
}