precision highp float;

varying vec2 v_texcoord;
varying vec4 v_colour;

uniform float u_progress;
uniform float u_noise_amount;

float pixel_noise(vec2 uv) {
    vec2 cell = floor(uv * vec2(240.0, 135.0));
    return fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec4 colour = texture2D(gm_BaseTexture, v_texcoord) * v_colour;
    float noise = (pixel_noise(v_texcoord) - 0.5) * u_noise_amount;
    float threshold = v_texcoord.y + noise;
    float visible = step(threshold, u_progress);

    gl_FragColor = vec4(colour.rgb, colour.a * visible);
}
