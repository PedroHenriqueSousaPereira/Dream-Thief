precision highp float;

varying vec2 v_texcoord;
varying vec4 v_colour;

uniform float u_amount;
uniform float u_palette_phase;

vec3 rgb_to_hsv(vec3 colour) {
    vec4 k = vec4(0.0, -0.3333333, 0.6666667, -1.0);
    vec4 p = mix(vec4(colour.bg, k.wz), vec4(colour.gb, k.xy), step(colour.b, colour.g));
    vec4 q = mix(vec4(p.xyw, colour.r), vec4(colour.r, p.yzx), step(p.x, colour.r));
    float d = q.x - min(q.w, q.y);
    float e = 0.000001;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv_to_rgb(vec3 colour) {
    vec3 p = abs(fract(colour.xxx + vec3(0.0, 0.6666667, 0.3333333)) * 6.0 - 3.0);
    return colour.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), colour.y);
}

void main() {
    vec4 colour = texture2D(gm_BaseTexture, v_texcoord) * v_colour;
    vec3 hsv = rgb_to_hsv(colour.rgb);

    // Tres paletas: roxo/vermelho, ciano/magenta e azul/rosa.
    // As curvas senoidais cruzam uma paleta na outra sem troca abrupta.
    float angle = u_palette_phase * 6.2831853;
    float cool_hue = 0.6267 + (cos(angle) * 0.0933) - (sin(angle) * 0.0577);
    float warm_hue = 0.9133 + (cos(angle) * 0.0467) - (sin(angle) * 0.0346);

    // Tons azulados e roxos recebem a metade fria; vermelhos recebem a quente.
    float cool_weight = smoothstep(0.48, 0.57, hsv.x)
        * (1.0 - smoothstep(0.82, 0.96, hsv.x));
    float target_hue = mix(warm_hue, cool_hue, cool_weight);
    float colour_mask = smoothstep(0.12, 0.38, hsv.y)
        * smoothstep(0.04, 0.16, hsv.z);

    hsv.x = fract(target_hue);
    hsv.y = clamp((hsv.y * 1.05) + 0.025, 0.0, 1.0);
    hsv.z = clamp(pow(hsv.z, 0.96) * 1.04, 0.0, 1.0);

    vec3 palette_colour = hsv_to_rgb(hsv);
    colour.rgb = mix(colour.rgb, palette_colour, u_amount * colour_mask);
    gl_FragColor = colour;
}
