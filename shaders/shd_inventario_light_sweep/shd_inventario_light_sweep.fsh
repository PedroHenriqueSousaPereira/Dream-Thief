precision highp float;

varying vec2 v_texcoord;
varying vec4 v_colour;

uniform float u_progress;
uniform float u_width;
uniform float u_intensity;
uniform float u_tilt;
uniform vec4 u_uv_rect;

void main() {
    vec4 texel = texture2D(gm_BaseTexture, v_texcoord) * v_colour;
    vec2 uv = (v_texcoord - u_uv_rect.xy) / (u_uv_rect.zw - u_uv_rect.xy);

    float distance_to_sweep = abs(uv.x + ((uv.y - 0.5) * u_tilt) - u_progress);
    float sweep = 1.0 - smoothstep(0.0, u_width, distance_to_sweep);

    // Limita o reflexo aos pixels em que azul e a cor dominante da moldura.
    float blue_amount = texel.b - ((texel.r * 0.70) + (texel.g * 0.25));
    float blue_mask = smoothstep(0.025, 0.22, blue_amount) * step(0.01, texel.a);
    float alpha = sweep * blue_mask * u_intensity * texel.a;

    gl_FragColor = vec4(vec3(0.62, 0.88, 1.0), alpha);
}
