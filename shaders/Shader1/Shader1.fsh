// shd_crt.fsh
varying vec2 v_texcoord;
varying vec4 v_colour;

uniform vec2  u_resolution;    // tamanho da tela (largura, altura)
uniform float u_tempo;         // tempo para animação do ruído
uniform float u_intensidade;   // força do efeito (0.0 a 1.0)
uniform float u_curvatura;     // curvatura da tela (0 = flat, 4 = forte)
uniform float u_scanlines;     // visibilidade das scanlines (0.0 a 1.0)

// ---- Curvatura (barrel distortion) ----
vec2 curvarUV(vec2 uv, float curv) {
    uv = uv * 2.0 - 1.0;                // converte 0..1 para -1..1
    uv.x *= 1.0 + pow(uv.y / curv, 2.0);
    uv.y *= 1.0 + pow(uv.x / curv, 2.0);
    uv = uv * 0.5 + 0.5;                // volta para 0..1
    return uv;
}

// ---- Ruído ----
float ruido(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = v_texcoord;
    
    // === 1. CURVATURA DA TELA ===
    vec2 uv_curved = curvarUV(uv, u_curvatura);
    
    // Se o UV saiu da tela, pinta de preto (borda do monitor)
    if (uv_curved.x < 0.0 || uv_curved.x > 1.0 ||
        uv_curved.y < 0.0 || uv_curved.y > 1.0) {
        gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }
    
    // === 2. ABERRAÇÃO CROMÁTICA (fringe RGB) ===
    float deslocamento = u_intensidade * 0.003;
    float r = texture2D(gm_BaseTexture, uv_curved + vec2( deslocamento, 0.0)).r;
    float g = texture2D(gm_BaseTexture, uv_curved                          ).g;
    float b = texture2D(gm_BaseTexture, uv_curved - vec2( deslocamento, 0.0)).b;
    vec4 cor = vec4(r, g, b, 1.0);
    
    // === 3. SCANLINES ===
    float linha = sin(uv_curved.y * u_resolution.y * 3.14159) * 0.5 + 0.5;
    linha = pow(linha, 1.0 - u_scanlines * 0.8);
    cor.rgb *= mix(1.0, linha, u_scanlines * u_intensidade);
    
    // === 4. VINHETA ===
    vec2 centro = uv_curved - 0.5;
    float vignette = 1.0 - dot(centro, centro) * 2.5 * u_intensidade;
    vignette = clamp(vignette, 0.0, 1.0);
    cor.rgb *= vignette;
    
    // === 5. RUÍDO DE PELÍCULA ===
    float grain = ruido(uv_curved + vec2(u_tempo * 0.1)) * 0.05 * u_intensidade;
    cor.rgb += grain;
    
    // === 6. BRILHO FRACO NAS SCANLINES (fosforescência) ===
    cor.rgb = clamp(cor.rgb * 1.1, 0.0, 1.0);
    
    gl_FragColor = v_colour * cor;
}
