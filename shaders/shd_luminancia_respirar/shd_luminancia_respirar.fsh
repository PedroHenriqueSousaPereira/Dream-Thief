varying vec2 v_texcoord;
varying vec4 v_colour;

uniform float u_brightness;
uniform float u_contrast;

void main() {
    vec4 colour = texture2D(gm_BaseTexture, v_texcoord) * v_colour;

    // Mantem o tratamento correto para pixels transparentes das camadas.
    vec3 rgb = (colour.rgb - (0.5 * colour.a)) * u_contrast;
    rgb += (0.5 + u_brightness) * colour.a;

    colour.rgb = clamp(rgb, 0.0, colour.a);
    gl_FragColor = colour;
}
