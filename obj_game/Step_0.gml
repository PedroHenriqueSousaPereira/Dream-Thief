// =============================================================================
// obj_game â€” STEP EVENT
// =============================================================================
// REGRA: O Step processa INPUT e ESTADO. NÃƒO define visual, NÃƒO cria coordenadas.
//        Todas as posiÃ§Ãµes vÃªm de global.ui_config (fonte Ãºnica da verdade).
//        Hitboxes usam funÃ§Ãµes utilitÃ¡rias (scr_get_item_hitbox, etc.)
//        Coleta usa scr_coletar_item() (zero switches duplicados).
// =============================================================================

// --- LOGICA PARA A SALA DE TRANSIÃ‡ÃƒO ---
if (!scr_globals_ui_prontos()) exit;

if (room == rm_transicao) {
    if (fade_estado == "" || fade_estado == "parado") {
        fade_alpha = 0;
    }
}

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// O intertitulo e uma camada modal: ele recebe o frame inteiro de input antes
// dos corredores, eventos, inventario ou mundo. Assim o clique que abre ou
// fecha um card jamais vaza para a cena abaixo.
if (scr_narrativa_ativa()) {
    var _acao_narrativa = scr_narrativa_atualizar(delta_time / 1000000);

    if (is_struct(_acao_narrativa) && variable_struct_exists(_acao_narrativa, "tipo")) {
        switch (_acao_narrativa.tipo) {
            case "mudar_sala":
                if (variable_struct_exists(_acao_narrativa, "destino")
                    && _acao_narrativa.destino != noone) {
                    fade_alvo_sala = _acao_narrativa.destino;
                    fade_estado = "escurecendo";
                }
            break;

            case "lembrar_passado":
                global.narrativa_flags.chose_remember_past = true;
                global.narrativa_flags.memory_fragment_01_unlocked = true;
                global.narrativa_flags.current_memory_stage = 1;
                scr_rpg_registrar_memoria("fragmento_01", "lembrar_passado", 1);
                global.ui_state.mensagem_contexto = "As imagens ainda sao confusas, mas algo em voce se fortaleceu.";
                global.ui_state.mensagem_timer = 240;

                if (variable_struct_exists(_acao_narrativa, "destino")
                    && _acao_narrativa.destino != noone) {
                    fade_alvo_sala = _acao_narrativa.destino;
                    fade_estado = "escurecendo";
                }
            break;
        }
    }

    exit;
}

// A combinacao de duas ondas evita uma pulsacao mecanica e previsivel.
global.luminancia_tempo += delta_time / 1000000;
global.luminancia_brilho = (sin(global.luminancia_tempo * 0.55) * 0.014)
    + (sin(global.luminancia_tempo * 1.37) * 0.003);
global.luminancia_contraste = 1.04
    + (sin(global.luminancia_tempo * 0.38) * 0.020)
    + (sin(global.luminancia_tempo * 1.11) * 0.005);

var _inventario_perks_ativo = global.ui_state.menu_tab_aberto
    && global.ui_state.inventario_tela == "perks";
if (_inventario_perks_ativo) {
    if (!inventario_perks_ativo_anterior) {
        inventario_perks_tempo = 0;
    }
    else {
        inventario_perks_tempo += delta_time / 1000000;
    }
}
inventario_perks_ativo_anterior = _inventario_perks_ativo;
var _inventario_perks_em_entrada = _inventario_perks_ativo
    && inventario_perks_tempo < inventario_perks_duracao_entrada;

// A variante preta de cada categoria acompanha o hover com uma entrada curta.
if (_inventario_perks_ativo && !_inventario_perks_em_entrada) {
    var _layout_hover_titulo = global.ui_config.inventario_perks;
    var _hitboxes_titulo = _layout_hover_titulo.titulos_laterais_hitboxes;
    var _titulo_hover = -1;

    for (var _titulo_i = 0; _titulo_i < array_length(_hitboxes_titulo); _titulo_i++) {
        var _hitbox_titulo = _hitboxes_titulo[_titulo_i];
        if (point_in_rectangle(_mx, _my, _hitbox_titulo.x1, _hitbox_titulo.y1,
            _hitbox_titulo.x2, _hitbox_titulo.y2)) {
            _titulo_hover = _titulo_i;
            break;
        }
    }

    var _hover_lerp = min(1, (delta_time / 1000000) * 12);
    for (var _titulo_alpha_i = 0; _titulo_alpha_i < array_length(inventario_titulo_hover_alpha); _titulo_alpha_i++) {
        var _titulo_alvo = (_titulo_alpha_i == _titulo_hover) ? 1 : 0;
        inventario_titulo_hover_alpha[_titulo_alpha_i] = lerp(
            inventario_titulo_hover_alpha[_titulo_alpha_i], _titulo_alvo, _hover_lerp
        );
    }
}
else {
    for (var _titulo_reset_i = 0; _titulo_reset_i < array_length(inventario_titulo_hover_alpha); _titulo_reset_i++) {
        inventario_titulo_hover_alpha[_titulo_reset_i] = 0;
    }
}

// LÃª posiÃ§Ã£o do NAV da fonte Ãºnica (global.ui_config)
var _mouse_no_nav = point_in_rectangle(_mx, _my,
    global.ui_config.nav_x1, global.ui_config.nav_y1,
    global.ui_config.nav_x2, global.ui_config.nav_y2);
var _inventory_click_consumed = false;
var _ui_cancel_pressed = keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right);

if (global.ui_state.mensagem_timer > 0) {
    global.ui_state.mensagem_timer -= 1;
    if (global.ui_state.mensagem_timer <= 0) {
        global.ui_state.mensagem_contexto = "";
    }
}

if (room == rm_combate_teste) exit;

// -----------------------------------------------------------------------------
// HUB DOS TRES CORREDORES
// -----------------------------------------------------------------------------
// Esta sala recebe o input antes da navegacao comum. Trocar de opcao nao muda
// de sala: apenas inicia o fade entre o cenario e a legenda correspondentes.
if (navegacao_corredor_ativo && fade_estado == "parado") {
    if (!is_struct(global.current_room)
        || !variable_struct_exists(global.current_room, "navegacao_corredores")) {
        navegacao_corredor_ativo = false;
        navegacao_corredor_hover = -1;
    }
    else {
        var _hub_corredores = global.current_room.navegacao_corredores;
        var _opcoes_corredor = _hub_corredores.opcoes;
        var _hover_corredor = -1;

        for (var _botao_i = 0; _botao_i < array_length(_hub_corredores.botoes); _botao_i++) {
            var _botao_corredor = _hub_corredores.botoes[_botao_i];
            if (point_in_rectangle(_mx, _my, _botao_corredor.x1, _botao_corredor.y1,
                _botao_corredor.x2, _botao_corredor.y2)) {
                _hover_corredor = _botao_i;
                break;
            }
        }

        navegacao_corredor_hover = _hover_corredor;
        navegacao_corredor_alpha = min(1, navegacao_corredor_alpha + navegacao_corredor_velocidade);
        if (navegacao_corredor_aviso > 0) navegacao_corredor_aviso -= 1;

        if (mouse_check_button_pressed(mb_left)) {
            if (_hover_corredor >= 0 && _hover_corredor != navegacao_corredor_indice) {
                navegacao_corredor_anterior = navegacao_corredor_indice;
                navegacao_corredor_indice = _hover_corredor;
                navegacao_corredor_alpha = 0;
            }
            else if (point_in_rectangle(_mx, _my, _hub_corredores.entrar.x1, _hub_corredores.entrar.y1,
                _hub_corredores.entrar.x2, _hub_corredores.entrar.y2)) {
                var _opcao_ativa = _opcoes_corredor[navegacao_corredor_indice];
                if (_opcao_ativa.disponivel && _opcao_ativa.destino != noone) {
                    navegacao_corredor_ativo = false;
                    navegacao_corredor_hover = -1;

                    // A primeira entrada recebe um intertitulo curto. Nas
                    // visitas seguintes o corredor mantem o corte normal.
                    if (!global.narrativa_flags.seen_card_corredor_01) {
                        global.narrativa_flags.seen_card_corredor_01 = true;
                        scr_narrativa_iniciar("entrada_corredor", {
                            tipo : "mudar_sala",
                            destino : _opcao_ativa.destino
                        });
                    }
                    else {
                        fade_alvo_sala = _opcao_ativa.destino;
                        fade_estado = "escurecendo";
                    }
                }
                else {
                    navegacao_corredor_aviso = 120;
                }
            }
        }
        exit;
    }
}

// -----------------------------------------------------------------------------
// SEQUENCIA DE NAVEGACAO DA SALA
// -----------------------------------------------------------------------------
// Cada sala pode fornecer uma sequencia propria. Enquanto uma etapa visual esta
// ativa, ela recebe o input; ao terminar, a exploracao normal volta a funcionar.
if (navegacao_sequencia_estado != "inativo" && fade_estado == "parado") {
    if (!is_struct(global.current_room)
        || !variable_struct_exists(global.current_room, "navegacao_sequencia")) {
        navegacao_sequencia_estado = "inativo";
        navegacao_sequencia_alpha = 0;
    }
    else {
        var _sequencia = global.current_room.navegacao_sequencia;

        if (variable_struct_exists(_sequencia, "modo")
            && _sequencia.modo == "cinematica_memorias"
            && variable_struct_exists(_sequencia, "cinematica")) {
            var _cinematica = _sequencia.cinematica;
            var _delta_cinematica = min(0.10, delta_time / 1000000);
            navegacao_cinematica_tempo += _delta_cinematica;

            switch (navegacao_sequencia_estado) {
                case "cinematica_menu":
                    var _hover_menu_andar = point_in_rectangle(_mx, _my,
                        _cinematica.menu_andar.x1, _cinematica.menu_andar.y1,
                        _cinematica.menu_andar.x2, _cinematica.menu_andar.y2);
                    var _hover_menu_voltar = point_in_rectangle(_mx, _my,
                        _cinematica.menu_voltar.x1, _cinematica.menu_voltar.y1,
                        _cinematica.menu_voltar.x2, _cinematica.menu_voltar.y2);
                    var _clicou_menu_andar = mouse_check_button_pressed(mb_left) && _hover_menu_andar;
                    var _clicou_menu_voltar = mouse_check_button_pressed(mb_left) && _hover_menu_voltar;

                    if (_hover_menu_andar || keyboard_check_pressed(vk_up)) navegacao_sequencia_selecao = 0;
                    if (_hover_menu_voltar || keyboard_check_pressed(vk_down)) navegacao_sequencia_selecao = 1;

                    if (_clicou_menu_andar
                        || (keyboard_check_pressed(vk_enter) && navegacao_sequencia_selecao == 0)
                        || keyboard_check_pressed(vk_right)) {
                        navegacao_sequencia_estado = "cinematica_relatorio_cards";
                        navegacao_cinematica_tempo = 0;
                        navegacao_cinematica_cartao_indice = 0;
                        navegacao_cinematica_fragmento_indice = 0;
                        navegacao_cinematica_lembre_indice = 0;
                    }
                    else if (_clicou_menu_voltar
                        || (keyboard_check_pressed(vk_enter) && navegacao_sequencia_selecao == 1)
                        || keyboard_check_pressed(vk_escape)
                        || keyboard_check_pressed(vk_left)) {
                        navegacao_sequencia_estado = "inativo";
                        fade_alvo_sala = _sequencia.destino_voltar;
                        fade_estado = "escurecendo";
                    }
                break;

                case "cinematica_relatorio_cards":
                    var _card_relatorio = _cinematica.relatorio_cards[navegacao_cinematica_cartao_indice];
                    if (navegacao_cinematica_tempo >= _card_relatorio.duracao) {
                        if (navegacao_cinematica_cartao_indice < array_length(_cinematica.relatorio_cards) - 1) {
                            navegacao_cinematica_cartao_indice += 1;
                            navegacao_cinematica_tempo = 0;
                        }
                        else {
                            navegacao_sequencia_estado = "cinematica_relatorio_fragmentos";
                            navegacao_cinematica_tempo = 0;
                            navegacao_cinematica_fragmento_indice = 0;
                        }
                    }
                break;

                case "cinematica_relatorio_fragmentos":
                    var _fragmento_relatorio = _cinematica.relatorio_fragmentos[navegacao_cinematica_fragmento_indice];
                    if (navegacao_cinematica_tempo >= _fragmento_relatorio.duracao) {
                        if (navegacao_cinematica_fragmento_indice < array_length(_cinematica.relatorio_fragmentos) - 1) {
                            navegacao_cinematica_fragmento_indice += 1;
                            navegacao_cinematica_tempo = 0;
                        }
                        else {
                            navegacao_sequencia_estado = "cinematica_relatorio_lembre";
                            navegacao_cinematica_tempo = 0;
                            navegacao_cinematica_lembre_indice = 0;
                        }
                    }
                break;

                case "cinematica_relatorio_lembre":
                    var _lembre_relatorio = _cinematica.relatorio_lembre[navegacao_cinematica_lembre_indice];
                    if (navegacao_cinematica_tempo >= _lembre_relatorio.duracao) {
                        if (navegacao_cinematica_lembre_indice < array_length(_cinematica.relatorio_lembre) - 1) {
                            navegacao_cinematica_lembre_indice += 1;
                            navegacao_cinematica_tempo = 0;
                        }
                        else {
                            navegacao_sequencia_estado = "cinematica_relatorio_preto";
                            navegacao_cinematica_tempo = 0;
                        }
                    }
                break;

                case "cinematica_relatorio_preto":
                    if (navegacao_cinematica_tempo >= _cinematica.duracao_preto) {
                        navegacao_sequencia_estado = "cinematica_relatorio_interrogacao";
                        navegacao_cinematica_tempo = 0;
                    }
                break;

                case "cinematica_relatorio_interrogacao":
                    if (navegacao_cinematica_tempo >= _cinematica.duracao_interrogacao) {
                        navegacao_sequencia_estado = "cinematica_relatorio_escurecer";
                        navegacao_cinematica_tempo = 0;
                    }
                break;

                case "cinematica_relatorio_escurecer":
                    if (navegacao_cinematica_tempo >= _cinematica.duracao_escurecer) {
                        navegacao_sequencia_estado = "cinematica_signalis_entrada";
                        navegacao_cinematica_tempo = 0;
                    }
                break;

                case "cinematica_signalis_entrada":
                    if (navegacao_cinematica_tempo >= _cinematica.duracao_signalis_entrada) {
                        navegacao_sequencia_estado = "cinematica_signalis_escolha";
                        navegacao_cinematica_tempo = 0;
                        navegacao_sequencia_selecao = 0;
                    }
                break;

                case "cinematica_signalis_escolha":
                    var _hover_seguir = point_in_rectangle(_mx, _my,
                        _cinematica.escolha_seguir.x1, _cinematica.escolha_seguir.y1,
                        _cinematica.escolha_seguir.x2, _cinematica.escolha_seguir.y2);
                    var _hover_lembrar = point_in_rectangle(_mx, _my,
                        _cinematica.escolha_lembrar.x1, _cinematica.escolha_lembrar.y1,
                        _cinematica.escolha_lembrar.x2, _cinematica.escolha_lembrar.y2);
                    var _clicou_seguir_final = mouse_check_button_pressed(mb_left) && _hover_seguir;
                    var _clicou_lembrar_final = mouse_check_button_pressed(mb_left) && _hover_lembrar;

                    if (_hover_seguir || keyboard_check_pressed(vk_up)) navegacao_sequencia_selecao = 0;
                    if (_hover_lembrar || keyboard_check_pressed(vk_down)) navegacao_sequencia_selecao = 1;

                    if (_clicou_seguir_final
                        || (keyboard_check_pressed(vk_enter) && navegacao_sequencia_selecao == 0)
                        || keyboard_check_pressed(vk_right)) {
                        _sequencia.decisao_memoria = "seguir";
                        if (is_struct(global.run_atual)) global.run_atual.etapa = "memoria_01_suprimida";
                        navegacao_sequencia_estado = "inativo";
                        magi_ativo = false;
                        alpha_magi = 0;
                        current_destination = noone;
                        fade_alvo_sala = _sequencia.destino_seguir;
                        fade_estado = "escurecendo";
                    }
                    else if (_clicou_lembrar_final
                        || (keyboard_check_pressed(vk_enter) && navegacao_sequencia_selecao == 1)) {
                        _sequencia.decisao_memoria = "lembrar";
                        global.narrativa_flags.chose_remember_past = true;
                        global.narrativa_flags.memory_fragment_01_unlocked = true;
                        global.narrativa_flags.current_memory_stage = 1;
                        if (is_struct(global.run_atual)) global.run_atual.etapa = "memoria_01_lembrada";
                        scr_rpg_registrar_memoria("fragmento_01", "lembrar_passado", 1);
                        global.ui_state.mensagem_contexto = "As imagens ainda sao confusas, mas algo em voce se fortaleceu.";
                        global.ui_state.mensagem_timer = 240;
                        navegacao_sequencia_estado = "inativo";
                        magi_ativo = false;
                        alpha_magi = 0;
                        current_destination = noone;
                        fade_alvo_sala = _sequencia.destino_lembrar;
                        fade_estado = "escurecendo";
                    }
                break;
            }
            exit;
        }

        switch (navegacao_sequencia_estado) {
            case "entrada_escolha":
                navegacao_sequencia_alpha = min(1, navegacao_sequencia_alpha + navegacao_sequencia_velocidade);
                if (navegacao_sequencia_alpha >= 1) {
                    navegacao_sequencia_estado = "escolha_entrada";
                }
            break;

            case "escolha_entrada":
                var _tecla_cima_entrada = keyboard_check_pressed(vk_up);
                var _tecla_baixo_entrada = keyboard_check_pressed(vk_down);
                var _tecla_confirmar_entrada = keyboard_check_pressed(vk_enter);
                var _clique_andar = mouse_check_button_pressed(mb_left)
                    && point_in_rectangle(_mx, _my, _sequencia.escolha_andar.x1, _sequencia.escolha_andar.y1,
                        _sequencia.escolha_andar.x2, _sequencia.escolha_andar.y2);
                var _clique_voltar = mouse_check_button_pressed(mb_left)
                    && point_in_rectangle(_mx, _my, _sequencia.escolha_voltar.x1, _sequencia.escolha_voltar.y1,
                        _sequencia.escolha_voltar.x2, _sequencia.escolha_voltar.y2);

                if (point_in_rectangle(_mx, _my, _sequencia.escolha_andar.x1, _sequencia.escolha_andar.y1,
                    _sequencia.escolha_andar.x2, _sequencia.escolha_andar.y2)) {
                    navegacao_sequencia_selecao = 0;
                }
                else if (point_in_rectangle(_mx, _my, _sequencia.escolha_voltar.x1, _sequencia.escolha_voltar.y1,
                    _sequencia.escolha_voltar.x2, _sequencia.escolha_voltar.y2)) {
                    navegacao_sequencia_selecao = 1;
                }

                if (_tecla_cima_entrada) navegacao_sequencia_selecao = 0;
                if (_tecla_baixo_entrada) navegacao_sequencia_selecao = 1;

                if (_clique_andar || (_tecla_confirmar_entrada && navegacao_sequencia_selecao == 0)) {
                    navegacao_sequencia_estado = "saida_escolha";
                }
                else if (_clique_voltar || (_tecla_confirmar_entrada && navegacao_sequencia_selecao == 1)) {
                    navegacao_sequencia_estado = "inativo";
                    fade_alvo_sala = _sequencia.destino_voltar;
                    fade_estado = "escurecendo";
                }
            break;

            case "saida_escolha":
                navegacao_sequencia_alpha = max(0, navegacao_sequencia_alpha - navegacao_sequencia_velocidade);
                if (navegacao_sequencia_alpha <= 0) {
                    navegacao_sequencia_estado = "entrada_legenda";
                }
            break;

            case "entrada_legenda":
                navegacao_sequencia_alpha = min(1, navegacao_sequencia_alpha + navegacao_sequencia_velocidade);
                if (navegacao_sequencia_alpha >= 1) {
                    navegacao_sequencia_estado = "legenda_entrada";
                }
            break;

            case "legenda_entrada":
                var _clique_seta_legenda = mouse_check_button_pressed(mb_left)
                    && point_in_rectangle(_mx, _my, _sequencia.seta_legenda.x1, _sequencia.seta_legenda.y1,
                        _sequencia.seta_legenda.x2, _sequencia.seta_legenda.y2);
                if (_clique_seta_legenda || keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_right)) {
                    navegacao_sequencia_estado = "saida_legenda";
                }
            break;

            case "saida_legenda":
                navegacao_sequencia_alpha = max(0, navegacao_sequencia_alpha - navegacao_sequencia_velocidade);
                if (navegacao_sequencia_alpha <= 0) {
                    navegacao_sequencia_estado = "entrada_memoria";
                }
            break;

            case "entrada_memoria":
                navegacao_sequencia_alpha = min(1, navegacao_sequencia_alpha + navegacao_sequencia_velocidade);
                if (navegacao_sequencia_alpha >= 1) {
                    navegacao_sequencia_estado = "escolha_memoria";
                }
            break;

            case "escolha_memoria":
                var _tecla_cima_memoria = keyboard_check_pressed(vk_up);
                var _tecla_baixo_memoria = keyboard_check_pressed(vk_down);
                var _tecla_confirmar_memoria = keyboard_check_pressed(vk_enter);
                var _clique_lembrar = mouse_check_button_pressed(mb_left)
                    && point_in_rectangle(_mx, _my, 1260, 720, 1660, 800);
                var _clique_seguir = mouse_check_button_pressed(mb_left)
                    && point_in_rectangle(_mx, _my, 1260, 820, 1660, 900);

                if (point_in_rectangle(_mx, _my, 1260, 720, 1660, 800)) {
                    navegacao_sequencia_selecao = 0;
                }
                else if (point_in_rectangle(_mx, _my, 1260, 820, 1660, 900)) {
                    navegacao_sequencia_selecao = 1;
                }

                if (_tecla_cima_memoria) navegacao_sequencia_selecao = 0;
                if (_tecla_baixo_memoria) navegacao_sequencia_selecao = 1;

                if (_clique_lembrar || (_tecla_confirmar_memoria && navegacao_sequencia_selecao == 0)) {
                        _sequencia.decisao_memoria = "lembrar";
                        navegacao_sequencia_estado = "inativo";
                        magi_ativo = false;
                        alpha_magi = 0;
                        current_destination = noone;
                        scr_narrativa_iniciar("lembrar_passado", {
                            tipo : "lembrar_passado",
                            destino : _sequencia.destino_lembrar
                        });
                }
                else if (_clique_seguir || (_tecla_confirmar_memoria && navegacao_sequencia_selecao == 1)) {
                        _sequencia.decisao_memoria = "seguir";
                        navegacao_sequencia_estado = "inativo";
                        magi_ativo = false;
                        alpha_magi = 0;
                        current_destination = noone;
                        fade_alvo_sala = _sequencia.destino_seguir;
                        fade_estado = "escurecendo";
                }
            break;
        }
        exit;
    }
}

if (room != rm_transicao && room != rm_autopsia && scr_evento_ui_ativo() && !scr_contexto_aguardando_item()) {
        if (scr_evento_transicao_painel_ativa()) {
            scr_evento_atualizar_transicao_painel();
            exit;
        }

        if (_ui_cancel_pressed) {
            var _destino_evento_cancelar = scr_contexto_get_sair_destino();
            if (scr_contexto_ativo()) scr_contexto_fechar();
            else scr_evento_fechar();
            if (_destino_evento_cancelar != noone) {
                fade_alvo_sala = _destino_evento_cancelar;
                fade_estado = "escurecendo";
            }
            exit;
        }

        if (mouse_check_button_pressed(mb_left) && fade_estado == "parado") {
            if (global.evento_runtime.apresentacao.icones_liberados) {
                var _evento_camadas = scr_get_evento_data(global.evento_runtime.evento_id);
                var _icones_evento = _evento_camadas.apresentacao.icones;
                for (var ei = 0; ei < array_length(_icones_evento); ei++) {
                    var _icone_evento = _icones_evento[ei];
                    if (point_in_rectangle(_mx, _my, _icone_evento.x1, _icone_evento.y1, _icone_evento.x2, _icone_evento.y2)
                        && scr_evento_executar_icone(_icone_evento.id)) {
                        exit;
                    }
                }
            }

            var _escolhas_evento = scr_evento_get_escolhas();
            for (var ee = 0; ee < array_length(_escolhas_evento); ee++) {
                var _rect_escolha_evento = scr_evento_get_escolha_rect(ee);
                if (point_in_rectangle(_mx, _my, _rect_escolha_evento.x1, _rect_escolha_evento.y1, _rect_escolha_evento.x2, _rect_escolha_evento.y2)) {
                    var _resultado_evento = scr_evento_executar_escolha(_escolhas_evento[ee].id);
                    if (_resultado_evento == "abrir_autopsia") {
                        global.ui_state.container_atual = noone;
                        global.ui_state.inventario_aberto = false;
                        global.ui_state.menu_tab_aberto = false;
                        global.ui_state.categoria_selecionada = "";
                        scr_inventory_reset_item_menu();
                        magi_ativo = false;
                        current_destination = noone;
                        fade_alvo_sala = rm_autopsia;
                        fade_estado = "escurecendo";
                    } else if (_resultado_evento == "fechou") {
                        var _destino_evento_fechar = scr_contexto_get_sair_destino();
                        if (_destino_evento_fechar != noone) {
                            fade_alvo_sala = _destino_evento_fechar;
                            fade_estado = "escurecendo";
                        }
                    } else if (_resultado_evento == "seguir_destino") {
                        var _destino_evento_passagem = scr_contexto_get_passagem_destino();
                        scr_contexto_fechar();
                        if (_destino_evento_passagem != noone) {
                            fade_alvo_sala = _destino_evento_passagem;
                            fade_estado = "escurecendo";
                        }
                    }
                    exit;
                }
            }
        }
        exit;
}

if (room != rm_transicao && room != rm_autopsia && scr_encounter_ativo()) {
    scr_encounter_update();

    if (_ui_cancel_pressed && !global.encounter.auto_start) {
        scr_encounter_recuar();
        exit;
    }

    if (mouse_check_button_pressed(mb_left) && global.encounter.estado == "escolha") {
        var _btn_enfrentar = scr_get_encounter_button_rect(0);
        var _btn_recuar = scr_get_encounter_button_rect(1);

        if (point_in_rectangle(_mx, _my, _btn_enfrentar.x1, _btn_enfrentar.y1, _btn_enfrentar.x2, _btn_enfrentar.y2)) {
            scr_encounter_enfrentar();
            exit;
        }

        if (point_in_rectangle(_mx, _my, _btn_recuar.x1, _btn_recuar.y1, _btn_recuar.x2, _btn_recuar.y2)) {
            scr_encounter_recuar();
            exit;
        }
    }

    exit;
}

if (room != rm_transicao && room != rm_autopsia
    && scr_contexto_ativo() && !scr_contexto_aguardando_item()) {
    if (_ui_cancel_pressed) {
        var _destino_cancelar_contexto = scr_contexto_get_sair_destino();
        scr_contexto_fechar();
        if (_destino_cancelar_contexto != noone) {
            fade_alvo_sala = _destino_cancelar_contexto;
            fade_estado = "escurecendo";
        }
        exit;
    }

    if (mouse_check_button_pressed(mb_left) && fade_estado == "parado") {
        var _back_contexto = scr_get_contexto_back_rect();
        if (point_in_rectangle(_mx, _my,
            _back_contexto.x1, _back_contexto.y1,
            _back_contexto.x2, _back_contexto.y2)) {
            var _destino_botao_voltar = scr_contexto_get_sair_destino();
            scr_contexto_fechar();
            if (_destino_botao_voltar != noone) {
                fade_alvo_sala = _destino_botao_voltar;
                fade_estado = "escurecendo";
            }
            exit;
        }

        var _contexto_dados = global.contexto_interacao.dados;
        if (is_struct(_contexto_dados) && variable_struct_exists(_contexto_dados, "elementos")) {
            var _contexto_elemento_index = 0;
            for (var ce = 0; ce < array_length(_contexto_dados.elementos); ce++) {
                var _elemento = _contexto_dados.elementos[ce];
                if (variable_struct_exists(_elemento, "id") && _elemento.id == "voltar") {
                    continue;
                }

                var _elemento_rect = scr_get_contexto_elemento_rect(_contexto_elemento_index);
                _contexto_elemento_index += 1;
                if (point_in_rectangle(_mx, _my,
                    _elemento_rect.x1, _elemento_rect.y1,
                    _elemento_rect.x2, _elemento_rect.y2)) {
                    scr_contexto_selecionar_elemento(_elemento.id);
                    exit;
                }
            }
        }

        var _elemento_atual = scr_contexto_get_elemento_atual();
        var _acoes_contexto = scr_contexto_get_acoes_elemento(_elemento_atual);
        for (var ca = 0; ca < array_length(_acoes_contexto); ca++) {
            var _acao_rect = scr_get_contexto_action_rect(ca);
            if (point_in_rectangle(_mx, _my,
                _acao_rect.x1, _acao_rect.y1,
                _acao_rect.x2, _acao_rect.y2)) {
                var _resultado_contexto = scr_contexto_executar_acao(_acoes_contexto[ca].id);

                if (_resultado_contexto == "abrir_autopsia") {
                    global.ui_state.container_atual = noone;
                    global.ui_state.inventario_aberto = false;
                    global.ui_state.menu_tab_aberto = false;
                    global.ui_state.categoria_selecionada = "";
                    scr_inventory_reset_item_menu();
                    magi_ativo = false;
                    current_destination = noone;
                    fade_alvo_sala = rm_autopsia;
                    fade_estado = "escurecendo";
                }
                else if (_resultado_contexto == "abrir_evento") {
                    global.game_state = "contexto";
                }
                else if (_resultado_contexto == "fechou") {
                    var _destino_fechar_contexto = scr_contexto_get_sair_destino();
                    if (_destino_fechar_contexto != noone) {
                        fade_alvo_sala = _destino_fechar_contexto;
                        fade_estado = "escurecendo";
                    }
                }
                else if (_resultado_contexto == "seguir_destino") {
                    var _destino_passagem_contexto = scr_contexto_get_passagem_destino();
                    scr_contexto_fechar();
                    if (_destino_passagem_contexto != noone) {
                        fade_alvo_sala = _destino_passagem_contexto;
                        fade_estado = "escurecendo";
                    }
                }
                exit;
            }
        }
    }

    exit;
}

if (room != rm_transicao && room != rm_autopsia && keyboard_check_pressed(vk_f8)) {
    magi_ativo = false;
    esta_carregando = false;
    mostrar_sprite_sucesso = false;
    mostrar_sprite_erro = false;
    current_destination = noone;
    global.ui_state.inventario_aberto = false;
    global.ui_state.menu_tab_aberto = false;
    global.ui_state.categoria_selecionada = "";
    scr_inventory_reset_item_menu();
    scr_iniciar_combate_teste();
    exit;
}

if (room != rm_transicao && room != rm_autopsia) {

// =========================================================================
// 1. CLIQUE PARA LIGAR/DESLIGAR NAV
// =========================================================================
if (_ui_cancel_pressed) {
    if (scr_contexto_aguardando_item()) {
        scr_contexto_cancelar_selecao_item();
        _inventory_click_consumed = true;
    }
    else if (global.ui_state.obstaculo_menu_aberto) {
        if (global.ui_state.obstaculo_selecao_item_ativa) {
            global.ui_state.menu_tab_aberto = false;
            global.ui_state.inventario_aberto = false;
            global.ui_state.categoria_selecionada = "";
            scr_inventory_reset_item_menu();
        }
        scr_fechar_menu_obstaculo();
        _inventory_click_consumed = true;
    }
    else if (global.ui_state.item_menu_aberto) {
        scr_inventory_reset_item_menu();
        _inventory_click_consumed = true;
    }
    else if (magi_ativo) {
        magi_ativo = false;
        alpha_magi = 0;
        esta_carregando = false;
        mostrar_sprite_sucesso = false;
        mostrar_sprite_erro = false;
        carga_time_actual = 0;
        charging_direction = "";
        key_to_hold = noone;
        current_destination = noone;
        _inventory_click_consumed = true;
    }
    else if (estado_ui != UI_STATE.NONE) {
        estado_ui = UI_STATE.NONE;
        global.ui_state.container_atual = noone;
        tempo_segurando = 0;
        _inventory_click_consumed = true;
    }
    else if (global.ui_state.inventario_aberto || global.ui_state.categoria_selecionada != "") {
        global.ui_state.inventario_aberto = false;
        global.ui_state.categoria_selecionada = "";
        scr_inventory_reset_item_menu();
        _inventory_click_consumed = true;
    }
    else if (global.ui_state.menu_tab_aberto) {
        global.ui_state.menu_tab_aberto = false;
        global.ui_state.inventario_tela = "";
        global.ui_state.perk_selecionada = -1;
        scr_inventory_reset_item_menu();
        _inventory_click_consumed = true;
    }
}

if (_mouse_no_nav && mouse_check_button_pressed(mb_left)
    && !_inventory_click_consumed && estado_ui == UI_STATE.NONE && !global.ui_state.menu_tab_aberto
    && !global.ui_state.obstaculo_menu_aberto && !scr_contexto_ativo()) {
    magi_ativo = !magi_ativo;
    if (magi_ativo) {
        alpha_magi = 0;
        global.ui_state.inventario_aberto = false;
        global.ui_state.menu_tab_aberto = false;
        global.ui_state.categoria_selecionada = "";
        scr_inventory_reset_item_menu();
    }
}

if (!_inventory_click_consumed && !magi_ativo && estado_ui == UI_STATE.NONE
    && fade_estado == "parado" && keyboard_check_pressed(vk_tab)
    && !global.ui_state.obstaculo_menu_aberto && !scr_contexto_aguardando_item()) {
    global.ui_state.menu_tab_aberto = !global.ui_state.menu_tab_aberto;
    global.ui_state.inventario_aberto = false;
    global.ui_state.categoria_selecionada = "";
    global.ui_state.inventario_tela = global.ui_state.menu_tab_aberto ? "perks" : "";
    global.ui_state.perk_selecionada = -1;
    if (global.ui_state.menu_tab_aberto) {
        inventario_perks_tempo = 0;
        inventario_perks_ativo_anterior = true;
    }
    else {
        inventario_perks_ativo_anterior = false;
    }
    scr_inventory_reset_item_menu();
}

// A primeira versao da nova tela e somente de leitura: o clique registra a
// area de perks, mas nivel e atributos continuam sem regras de evolucao.
if (!_inventory_click_consumed && global.ui_state.menu_tab_aberto
    && global.ui_state.inventario_tela == "perks"
    && !_inventario_perks_em_entrada
    && mouse_check_button_pressed(mb_left)) {
    var _layout_perks = global.ui_config.inventario_perks;
    var _painel_perks = _layout_perks.painel_perks;
    if (point_in_rectangle(_mx, _my, _painel_perks.x1, _painel_perks.y1,
        _painel_perks.x2, _painel_perks.y2)) {
        global.ui_state.perk_selecionada = 0;
    }
    _inventory_click_consumed = true;
}

// =========================================================================
// 2. SISTEMA MAGI (NAVEGAÃ‡ÃƒO ENTRE SALAS)
// =========================================================================
if (magi_ativo) {
    if (alpha_magi < 1) alpha_magi += velocidade_fade_magi;

    if (!esta_carregando && !mostrar_sprite_erro && !mostrar_sprite_sucesso) {
        if (keyboard_check_pressed(ord("W"))) {
            current_destination = variable_struct_exists(global.current_room, "norte") ? global.current_room.norte : noone;
            charging_direction = "n"; key_to_hold = ord("W"); esta_carregando = true; carga_time_actual = 0;
        }
        else if (keyboard_check_pressed(ord("S"))) {
            current_destination = variable_struct_exists(global.current_room, "sul") ? global.current_room.sul : noone;
            charging_direction = "s"; key_to_hold = ord("S"); esta_carregando = true; carga_time_actual = 0;
        }
        else if (keyboard_check_pressed(ord("A"))) {
            current_destination = variable_struct_exists(global.current_room, "oeste") ? global.current_room.oeste : noone;
            charging_direction = "o"; key_to_hold = ord("A"); esta_carregando = true; carga_time_actual = 0;
        }
        else if (keyboard_check_pressed(ord("D"))) {
            current_destination = variable_struct_exists(global.current_room, "leste") ? global.current_room.leste : noone;
            charging_direction = "l"; key_to_hold = ord("D"); esta_carregando = true; carga_time_actual = 0;
        }
    }

    if (esta_carregando) {
        if (keyboard_check(key_to_hold)) {
            carga_time_actual += 1;
            if (carga_time_actual >= carga_time_max) {
                esta_carregando = false;
                if (current_destination != noone) { mostrar_sprite_sucesso = true; timer_sucesso = 60; }
                else { mostrar_sprite_erro = true; timer_erro = 90; }
            }
        } else { esta_carregando = false; carga_time_actual = 0; }
    }

    if (mostrar_sprite_sucesso && timer_sucesso-- <= 0 && fade_estado == "parado") {
        fade_alvo_sala = current_destination;
        fade_estado = "escurecendo";
        magi_ativo = false;
    }
    if (mostrar_sprite_erro && timer_erro-- <= 0) mostrar_sprite_erro = false;
}

} // Fecha trava da transicao 1

// =========================================================================
// 3. SISTEMA DE FADE (Roda sempre, inclusive durante transiÃ§Ãµes)
// =========================================================================
if (fade_estado == "escurecendo") {
    fade_alpha += fade_velocidade;

    if (fade_alpha >= 1) {
        fade_alpha = 1;
        if (fade_alvo_sala != noone) {
            if (is_struct(fade_alvo_sala)) {
                global.current_room = fade_alvo_sala;
                if (variable_struct_exists(global.current_room, "navegacao_corredores")) {
                    navegacao_corredor_ativo = true;
                    navegacao_corredor_indice = 0;
                    navegacao_corredor_anterior = 0;
                    navegacao_corredor_hover = -1;
                    navegacao_corredor_alpha = 1;
                    navegacao_corredor_aviso = 0;
                    navegacao_sequencia_estado = "inativo";
                } else if (variable_struct_exists(global.current_room, "navegacao_sequencia")) {
                    // O fade de troca revela cenario e painel inicial juntos.
                    var _tem_cinematica = variable_struct_exists(global.current_room.navegacao_sequencia, "modo")
                        && global.current_room.navegacao_sequencia.modo == "cinematica_memorias";
                    navegacao_sequencia_estado = _tem_cinematica ? "cinematica_menu" : "escolha_entrada";
                    navegacao_sequencia_alpha = 1;
                    navegacao_sequencia_selecao = 0;
                    navegacao_cinematica_tempo = 0;
                    navegacao_cinematica_cartao_indice = 0;
                    navegacao_cinematica_fragmento_indice = 0;
                    navegacao_cinematica_lembre_indice = 0;
                    navegacao_corredor_ativo = false;
                } else {
                    navegacao_sequencia_estado = "inativo";
                    navegacao_corredor_ativo = false;
                }
                if (variable_struct_exists(global.current_room, "interacao_auto_abrir")
                    && global.current_room.interacao_auto_abrir) {
                    global.current_room.interacao_inicial_aberta = false;
                }
                if (variable_struct_exists(global.current_room, "contexto_auto_abrir")
                    && global.current_room.contexto_auto_abrir) {
                    var _fade_contexto_id = variable_struct_exists(global.current_room, "contexto_id") ? global.current_room.contexto_id : "";
                    var _fade_contexto_elemento = variable_struct_exists(global.current_room, "contexto_elemento_inicial") ? global.current_room.contexto_elemento_inicial : "porta";
                    if (_fade_contexto_id != "") {
                        scr_contexto_abrir(_fade_contexto_id, _fade_contexto_elemento);
                    }
                }
                if (room != rm_game) {
                    room_goto(rm_game);
                }
            } else if (room_exists(fade_alvo_sala)) {
                room_goto(fade_alvo_sala);
            }
        }
        alpha_cenario = 0;
        fade_estado = "clareando";
    }
}
else if (fade_estado == "clareando") {
    fade_alpha -= fade_velocidade;
    if (alpha_cenario < 1) alpha_cenario += fade_velocidade;

    if (fade_alpha <= 0.01) {
        fade_alpha = 0;
        alpha_cenario = 1;
        fade_estado = "parado";
        esta_carregando = false;
        mostrar_sprite_sucesso = false;
        mostrar_sprite_erro = false;
        current_destination = noone;
    }
}

if (room != rm_transicao && room != rm_autopsia && room != rm_combate_teste
    && fade_estado == "parado" && !scr_encounter_ativo() && !scr_contexto_ativo()
    && !scr_evento_ui_ativo() && is_struct(global.current_room)
    && variable_struct_exists(global.current_room, "interacao_auto_abrir")
    && global.current_room.interacao_auto_abrir
    && (!variable_struct_exists(global.current_room, "interacao_inicial_aberta")
        || !global.current_room.interacao_inicial_aberta)) {

    var _interacao_inicial = variable_struct_exists(global.current_room, "interacao_inicial") ? global.current_room.interacao_inicial : "";
    var _no_inicial = variable_struct_exists(global.current_room, "interacao_no_inicial") ? global.current_room.interacao_no_inicial : "";

    if (_interacao_inicial != "" && scr_interacao_abrir(_interacao_inicial, _no_inicial)) {
        global.current_room.interacao_inicial_aberta = true;
        exit;
    }
}

if (room != rm_transicao && room != rm_autopsia && room != rm_combate_teste
    && fade_estado == "parado" && !scr_encounter_ativo() && !scr_contexto_ativo()
    && is_struct(global.current_room)
    && variable_struct_exists(global.current_room, "contexto_auto_abrir")
    && global.current_room.contexto_auto_abrir) {

    var _auto_contexto_id = variable_struct_exists(global.current_room, "contexto_id") ? global.current_room.contexto_id : "";
    var _auto_elemento = variable_struct_exists(global.current_room, "contexto_elemento_inicial") ? global.current_room.contexto_elemento_inicial : "porta";

    if (_auto_contexto_id != "") {
        scr_contexto_abrir(_auto_contexto_id, _auto_elemento);
        exit;
    }
}

if (room != rm_transicao && room != rm_autopsia) {

// =============================================================================
// 3.5. INTERAÇÃO COM ITENS DO CENÁRIO
// =============================================================================

if (!_inventory_click_consumed
    && global.ui_state.obstaculo_menu_aberto
    && !global.ui_state.obstaculo_selecao_item_ativa
    && mouse_check_button_pressed(mb_left)
    && fade_estado == "parado") {

    var _mx_obstaculo = device_mouse_x_to_gui(0);
    var _my_obstaculo = device_mouse_y_to_gui(0);

    var _rect_obstaculo = scr_get_obstaculo_menu_rect();

    if (point_in_rectangle(
        _mx_obstaculo,
        _my_obstaculo,
        _rect_obstaculo.x1,
        _rect_obstaculo.y1,
        _rect_obstaculo.x2,
        _rect_obstaculo.y2
    )) {
        scr_fechar_menu_obstaculo();
        exit;
    }
}


// -----------------------------------------------------------------------------
// CLIQUE EM PONTOS DO CENÁRIO
// -----------------------------------------------------------------------------

if (estado_ui == UI_STATE.NONE
    && mouse_check_button_pressed(mb_left)
    && !_mouse_no_nav
    && !magi_ativo
    && fade_estado == "parado"
    && !global.ui_state.inventario_aberto
    && !global.ui_state.menu_tab_aberto
    && !global.ui_state.obstaculo_menu_aberto) {

    if (is_struct(global.current_room)
        && variable_struct_exists(global.current_room, "itens")) {

        var _itens = global.current_room.itens;

        for (var i = 0; i < array_length(_itens); i++) {

            var _item = _itens[i];

            var _removido =
                variable_struct_exists(_item, "removido")
                && _item.removido;

            if (!_item.coletado && !_removido) {

                // -------------------------------------------------------------
                // A HITBOX CONTINUA SENDO DEFINIDA PELO BANCO DA SALA
                // -------------------------------------------------------------
                var _hb = scr_get_item_hitbox(_item);

                var _hitbox_manual =
                    variable_struct_exists(_hb, "manual")
                    && _hb.manual;

                if (_hb.sprite == noone && !_hitbox_manual) {
                    continue;
                }


                // -------------------------------------------------------------
                // CLIQUE NA HITBOX
                // -------------------------------------------------------------
                if (point_in_rectangle(
                    _mx,
                    _my,
                    _hb.x1,
                    _hb.y1,
                    _hb.x2,
                    _hb.y2
                )) {

                    var _tipo_item =
                        variable_struct_exists(_item, "tipo")
                        ? _item.tipo
                        : "";


                    // =========================================================
                    // PONTO DE INTERAÇÃO / CADÁVER / CONTEXTO
                    // =========================================================
                    //
                    // O cenário apenas informa:
                    //
                    // "esse ponto pode ser clicado"
                    //
                    // O painel continua sendo controlado pelo banco/contexto.
                    // =========================================================

                    if (_tipo_item == "cadaver"
                        || _tipo_item == "contexto"
                        || _tipo_item == "obstaculo") {

                        var _contexto_id = "";

                        if (variable_struct_exists(_item, "contexto_id")) {
                            _contexto_id = _item.contexto_id;
                        }
                        else if (is_struct(global.current_room)
                            && variable_struct_exists(global.current_room, "contexto_id")) {

                            _contexto_id = global.current_room.contexto_id;
                        }


                        if (_contexto_id != "") {

                            var _elemento_inicial = "porta";

                            if (variable_struct_exists(
                                _item,
                                "elemento_inicial"
                            )) {

                                _elemento_inicial =
                                    _item.elemento_inicial;
                            }


                            // -------------------------------------------------
                            // CADÁVER
                            // -------------------------------------------------
                            if (_tipo_item == "cadaver") {
                                _elemento_inicial = "cadaver";
                            }


                            // -------------------------------------------------
                            // TEIAS
                            // -------------------------------------------------
                            else if (_tipo_item == "obstaculo") {
                                _elemento_inicial = "teias";
                            }


                            // -------------------------------------------------
                            // ABRE O PAINEL EXISTENTE
                            // -------------------------------------------------
                            scr_contexto_abrir(
                                _contexto_id,
                                _elemento_inicial
                            );

                            exit;
                        }
                    }


                    // =========================================================
                    // AUTÓPSIA DIRETA
                    // =========================================================
                    //
                    // Mantido para qualquer cadáver que NÃO possua contexto.
                    // =========================================================

                    else if (_tipo_item == "cadaver") {

                        global.autopsia_retorno_room_real = room;
                        global.autopsia_retorno_sala_logica =
                            global.current_room;

                        global.autopsia_cadaver_atual = _item;

                        global.autopsia_id_atual =
                            variable_struct_exists(
                                _item,
                                "autopsia_id"
                            )
                            ? _item.autopsia_id
                            : "escavador_01";

                        global.ui_state.container_atual = noone;
                        global.ui_state.inventario_aberto = false;
                        global.ui_state.menu_tab_aberto = false;
                        global.ui_state.categoria_selecionada = "";

                        scr_inventory_reset_item_menu();

                        magi_ativo = false;
                        current_destination = noone;

                        fade_alvo_sala = rm_autopsia;
                        fade_estado = "escurecendo";

                        exit;
                    }


                    // =========================================================
                    // OBSTÁCULO SEM CONTEXTO
                    // =========================================================

                    else if (_tipo_item == "obstaculo") {

                        scr_abrir_menu_obstaculo(_item);
                        exit;
                    }


                    // =========================================================
                    // ENCONTRO
                    // =========================================================

                    else if (_tipo_item == "encontro") {

                        var _encounter_id =
                            variable_struct_exists(
                                _item,
                                "encounter_id"
                            )
                            ? _item.encounter_id
                            : "";

                        if (_encounter_id != "") {

                            scr_iniciar_encontro(
                                _encounter_id,
                                _item
                            );
                        }

                        exit;
                    }


                    // =========================================================
                    // CONTAINER
                    // =========================================================

                    else if (_tipo_item == "container") {

                        global.ui_state.container_atual = _item;

                        estado_ui =
                            UI_STATE.CONTAINER_SELECT;

                        tempo_segurando = 0;

                        show_debug_message(
                            "Abrindo contêiner: "
                            + string(_item.nome)
                        );

                        exit;
                    }


                    // =========================================================
                    // ITEM NORMAL
                    // =========================================================

                    else {

                        if (scr_coletar_item(_item)) {
                            _item.coletado = true;
                        }

                        exit;
                    }
                }
            }
        }
    }
}

// =========================================================================
// 4. CLIQUE NO INVENTÃRIO (SISTEMA DATA-DRIVEN)
// =========================================================================
if (global.ui_state.menu_tab_aberto && global.ui_state.inventario_aberto && global.ui_state.categoria_selecionada != "") {
    if (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right)) {
        global.ui_state.inventario_aberto = false;
        global.ui_state.categoria_selecionada = "";
        scr_inventory_reset_item_menu();
        _inventory_click_consumed = true;
    }

    if (!_inventory_click_consumed && mouse_check_button_pressed(mb_left)) {
        if (global.ui_state.item_menu_aberto) {
            var _menu_x = global.ui_state.item_menu_x;
            var _menu_y = global.ui_state.item_menu_y;
            var _menu_w = global.ui_config.inv_context_w;
            var _row_h = global.ui_config.inv_context_row_h;
            var _acoes = global.ui_state.item_menu_acoes;
            var _menu_h = array_length(_acoes) * _row_h;

            if (point_in_rectangle(_mx, _my, _menu_x, _menu_y, _menu_x + _menu_w, _menu_y + _menu_h)) {
                var _acao_idx = floor((_my - _menu_y) / _row_h);
                if (_acao_idx >= 0 && _acao_idx < array_length(_acoes)) {
                    scr_inventory_apply_action(_acoes[_acao_idx]);
                }
                _inventory_click_consumed = true;
            } else {
                scr_inventory_reset_item_menu();
            }
        }

        if (!_inventory_click_consumed) {
            var _back_rect = scr_get_inventory_back_rect();
            if (point_in_rectangle(_mx, _my,
                _back_rect.x1, _back_rect.y1,
                _back_rect.x2, _back_rect.y2)) {

                global.ui_state.inventario_aberto = false;
                global.ui_state.categoria_selecionada = "";
                scr_inventory_reset_item_menu();
                if (scr_contexto_aguardando_item()) {
                    scr_contexto_cancelar_selecao_item();
                }
                else if (global.ui_state.obstaculo_menu_aberto) {
                    global.ui_state.obstaculo_selecao_item_ativa = false;
                    global.ui_state.menu_tab_aberto = true;
                    scr_resetar_texto_menu_obstaculo();
                }
                _inventory_click_consumed = true;
            }
        }

        if (!_inventory_click_consumed) {
            var _cat_nome = global.ui_state.categoria_selecionada;
            var _array_alvo = scr_inventario_get_categoria(_cat_nome);
            var _limite = min(array_length(_array_alvo), scr_get_inventory_slot_limit(_cat_nome));

            for (var s = 0; s < _limite; s++) {
                var _slot_rect = scr_get_inventory_slot_rect(s);
                if (point_in_rectangle(_mx, _my, _slot_rect.x1, _slot_rect.y1, _slot_rect.x2, _slot_rect.y2)) {
                    if (scr_contexto_aguardando_item()) {
                        var _item_contexto = _array_alvo[s];
                        scr_contexto_usar_item(_item_contexto);
                    }
                    else if (global.ui_state.obstaculo_menu_aberto
                        && global.ui_state.obstaculo_selecao_item_ativa) {
                        var _item_escolhido = _array_alvo[s];

                        if (scr_resolver_obstaculo_cenario(global.ui_state.obstaculo_menu_obstaculo, _item_escolhido)) {
                            global.ui_state.menu_tab_aberto = false;
                            global.ui_state.inventario_aberto = false;
                            global.ui_state.categoria_selecionada = "";
                            scr_inventory_reset_item_menu();
                            scr_fechar_menu_obstaculo();
                        } else {
                            global.ui_state.obstaculo_menu_texto = "Este item nao corta as teias.";
                            global.ui_state.obstaculo_selecao_item_ativa = true;
                        }
                    } else {
                        scr_inventory_open_item_menu(_array_alvo[s], _cat_nome, s, _mx + 12, _my + 12);
                    }
                    _inventory_click_consumed = true;
                    break;
                }
            }
        }

        if (!_inventory_click_consumed) {
            if (!point_in_rectangle(_mx, _my,
                global.ui_config.inv_panel_x, global.ui_config.inv_panel_y,
                global.ui_config.inv_panel_x + global.ui_config.inv_panel_w,
                global.ui_config.inv_panel_y + global.ui_config.inv_panel_h)) {

                global.ui_state.inventario_aberto = false;
                global.ui_state.categoria_selecionada = "";
                scr_inventory_reset_item_menu();
                if (scr_contexto_aguardando_item()) {
                    scr_contexto_cancelar_selecao_item();
                }
                else if (global.ui_state.obstaculo_menu_aberto) {
                    global.ui_state.obstaculo_selecao_item_ativa = false;
                    global.ui_state.menu_tab_aberto = true;
                    scr_resetar_texto_menu_obstaculo();
                }
                _inventory_click_consumed = true;
            }
        }
    }
}

if (!_inventory_click_consumed && global.ui_state.menu_tab_aberto && !global.ui_state.inventario_aberto
    && global.ui_state.inventario_tela != "perks"
    && mouse_check_button_pressed(mb_left) && !_mouse_no_nav) {
    var _btn_clicado = noone;

    for (var i = 0; i < array_length(global.botoes_hud); i++) {
        var _btn = global.botoes_hud[i];
        if (point_in_rectangle(_mx, _my, _btn.x1, _btn.y1, _btn.x2, _btn.y2)) {
            _btn_clicado = _btn;
            break;
        }
    }

    if (_btn_clicado != noone) {
        magi_ativo = false;
        
        var _ja_aberto = (global.ui_state.categoria_selecionada == _btn_clicado.categoria);
        
        if (_ja_aberto) {
            global.ui_state.inventario_aberto = false;
            global.ui_state.categoria_selecionada = "";
            scr_inventory_reset_item_menu();
        } else {
            global.ui_state.inventario_aberto = true;
            global.ui_state.categoria_selecionada = _btn_clicado.categoria;
            scr_inventory_reset_item_menu();
        }
    }
}

// =========================================================================
// 5. SISTEMA DE LOOT (STATE MACHINE) â€” Usa global.ui_config + funÃ§Ãµes utilitÃ¡rias
// =========================================================================
if (estado_ui != UI_STATE.NONE && global.ui_state.container_atual != noone) {

    // Ã‚ncoras lidas da fonte Ãºnica

    var _modelo_nome = variable_struct_exists(global.ui_state.container_atual, "modelo")
        ? global.ui_state.container_atual.modelo : "barril";
    var _modelo = scr_get_container_template(_modelo_nome);
    if (_modelo == noone) exit;

    var _icon_hb = scr_get_loot_icon_rect(_modelo);

        // Hitbox do Ã­cone do container (painel principal)
        // Hitbox do icone do container desenhado em Draw GUI.

    switch (estado_ui) {
            case UI_STATE.CONTAINER_SELECT:
            case UI_STATE.HOLD_SEARCH:
                if (point_in_rectangle(_mx, _my, _icon_hb.x1, _icon_hb.y1, _icon_hb.x2, _icon_hb.y2)
                    && mouse_check_button_pressed(mb_left)) {
                    estado_ui = UI_STATE.LOOT_OPEN;
                    tempo_segurando = 0;
                }
                break;

            case UI_STATE.LOOT_OPEN:
                // --- AQUI ESTÃ A CORREÃ‡ÃƒO: LÃª a posiÃ§Ã£o independente da sub-aba! ---
                var _sub_aba_x = global.ui_config.loot_sub_aba_x;
                var _sub_aba_y = global.ui_config.loot_sub_aba_y;

                var _lista_loot = global.ui_state.container_atual.itens_dentro;
                for (var i = 0; i < array_length(_lista_loot); i++) {
                    var _item_loot = _lista_loot[i];

                    // PosiÃ§Ã£o do slot via funÃ§Ã£o utilitÃ¡ria (mesma do Draw_64)
                    var _item_hb = scr_get_loot_slot_rect(_modelo, i, _sub_aba_x, _sub_aba_y);

                        // Hitbox do item via funÃ§Ã£o utilitÃ¡ria
                        // Usa o quadrado inteiro desenhado no Draw GUI.

                        if (point_in_rectangle(_mx, _my, _item_hb.x1, _item_hb.y1, _item_hb.x2, _item_hb.y2)
                            && mouse_check_button_pressed(mb_left)) {

                            // COLETA UNIFICADA
                            if (scr_coletar_item(_item_loot)) {
                                array_delete(_lista_loot, i, 1);
                            }
                            break;
                        }
                }
                break;
    }

    // Fechar o Loot (BotÃ£o direito ou ESC)
    if (mouse_check_button_pressed(mb_right) || keyboard_check_pressed(vk_escape)) {
        estado_ui = UI_STATE.NONE;
        global.ui_state.container_atual = noone;
        tempo_segurando = 0;
    }
}
} // Fecha trava da transicao 2
