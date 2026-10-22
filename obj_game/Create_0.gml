// Guarda contra duplicações de instâncias persistentes
if (instance_number(obj_game) > 1) {
    instance_destroy();
    exit;
}

// =============================================================================
// BLINDAGEM DE RESOLUÇÃO (Força o 1080p ignorando bugs do Room Editor)
// =============================================================================
scr_configurar_resolucao(1920, 1080, -1, "ajustar");

// =============================================================================
// obj_game — CREATE EVENT
// =============================================================================
// Inicializa o banco de dados e configura estados locais do controller.
// Coordenadas de UI estão em global.ui_config (banco de dados).
// Estados de UI estão em global.ui_state (banco de dados).
// =============================================================================

// 1. Inicializa TODOS os dados globais (ui_config, ui_state, inventários, db_itens, salas)
scr_inicializar_mapa();

// 2. Referências de sala
global.current_room = global.antechamber_room;

// ... (o resto do seu código de MAGI e Fade continua normal para baixo) ...

// =============================================================================
// SISTEMA DO BOTÃO NAV (MAGI)
// =============================================================================
// Posições do NAV agora estão em global.ui_config.nav_x1/y1/x2/y2
magi_ativo = false;
alpha_magi = 0;
velocidade_fade_magi = 0.1;
alpha_cenario = 1;

// Iluminacao organica do cenario. Interface e itens nao usam este shader.
global.luminancia_tempo = 0;
global.luminancia_brilho = 0;
global.luminancia_contraste = 1;
global.luminancia_uniform_brilho = shader_get_uniform(shd_luminancia_respirar, "u_brightness");
global.luminancia_uniform_contraste = shader_get_uniform(shd_luminancia_respirar, "u_contrast");

// Animacoes visuais exclusivas do inventario de perks.
inventario_perks_ativo_anterior = false;
inventario_perks_tempo = 0;
inventario_perks_duracao_entrada = 1.35;
inventario_perks_surface = -1;
inventario_titulo_hover_alpha = [0, 0, 0];
inventario_sweep_progresso = shader_get_uniform(shd_inventario_light_sweep, "u_progress");
inventario_sweep_largura = shader_get_uniform(shd_inventario_light_sweep, "u_width");
inventario_sweep_intensidade = shader_get_uniform(shd_inventario_light_sweep, "u_intensity");
inventario_sweep_inclinacao = shader_get_uniform(shd_inventario_light_sweep, "u_tilt");
inventario_sweep_uv = shader_get_uniform(shd_inventario_light_sweep, "u_uv_rect");
inventario_flash_intensidade = shader_get_uniform(shd_inventario_flash_paleta, "u_amount");
inventario_flash_fase = shader_get_uniform(shd_inventario_flash_paleta, "u_palette_phase");
inventario_dissolve_progresso = shader_get_uniform(shd_inventario_noise_dissolve, "u_progress");
inventario_dissolve_ruido = shader_get_uniform(shd_inventario_noise_dissolve, "u_noise_amount");

// --- MOTOR DO MAGI ---
sprites_sequencia_n = [bussola_norte_1];
sprites_sequencia_s = [bussola_sul_1];
sprites_sequencia_l = [bussola_leste_1];
sprites_sequencia_o = [bussola_oeste_1];

esta_carregando = false;
carga_time_actual = 0;
carga_time_max = 50;
mostrar_sprite_erro = false;
mostrar_sprite_sucesso = false;
timer_erro = 0;
timer_sucesso = 0;
charging_direction = "";
key_to_hold = noone;
current_destination = noone;

// =============================================================================
// SISTEMA DE FADE
// =============================================================================
fade_alpha = 0;
fade_estado = "parado";
fade_alvo_sala = noone;
fade_velocidade = 0.05;

// Intertitulos narrativos: estado central que permanece entre as salas junto
// com este controller. As sequencias nao dependem de uma room intermediaria.
global.narrativa_transicao = {
    ativa : false,
    cards : [],
    indice : -1,
    atual : noone,
    fase : "idle",
    tempo : 0,
    alpha : 0,
    bloquear_ate_soltar : false,
    acao_final : noone
};

// Persistencia em save/load entra numa fase posterior; estas flags ja evitam
// repeticoes durante a sessao atual e definem a mesma interface de estado.
global.narrativa_flags = {
    seen_card_corredor_01 : false,
    chose_remember_past : false,
    memory_fragment_01_unlocked : false,
    current_memory_stage : 0
};

// Sequencia de navegacao opt-in por sala. As demais salas mantem o fluxo legado.
navegacao_sequencia_estado = "inativo";
navegacao_sequencia_alpha = 0;
navegacao_sequencia_selecao = 0;
navegacao_sequencia_velocidade = 0.06;
navegacao_cinematica_tempo = 0;
navegacao_cinematica_cartao_indice = 0;
navegacao_cinematica_fragmento_indice = 0;
navegacao_cinematica_lembre_indice = 0;

// Hub de corredores: troca apenas o cenario e a legenda da opcao ativa.
navegacao_corredor_ativo = false;
navegacao_corredor_indice = 0;
navegacao_corredor_anterior = 0;
navegacao_corredor_hover = -1;
navegacao_corredor_alpha = 1;
navegacao_corredor_velocidade = 0.06;
navegacao_corredor_aviso = 0;

// =============================================================================
// ESTADOS DA UI
// =============================================================================
// inventario_aberto e categoria_selecionada agora estão em global.ui_state
// container_atual agora está em global.ui_state.container_atual

enum UI_STATE {
    NONE,
    CONTAINER_SELECT,
    HOLD_SEARCH,
    LOOT_OPEN
}
estado_ui = UI_STATE.NONE;

// --- SISTEMA DE "SEGURAR" PARA ABRIR CONTAINER ---
tempo_segurando = 0;
tempo_necessario = 45;

// =============================================================================
// ÂNCORAS DE UI — REMOVIDAS (Agora em global.ui_config)
// =============================================================================
// loot_anchor_x     → global.ui_config.loot_icon_x
// loot_anchor_y     → global.ui_config.loot_icon_y
// loot_sub_aba_offset → global.ui_config.loot_sub_aba_offset
// nav_hitbox_x1/y1/x2/y2 → global.ui_config.nav_x1/y1/x2/y2
// =============================================================================
