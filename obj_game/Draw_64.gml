// =============================================================================
// obj_game - DRAW GUI EVENT
// =============================================================================
// Interface: HUD, NAV, MAGI, inventario, loot e fade final.
// Mundo fica no Draw normal.
// =============================================================================

if (!scr_globals_ui_prontos()) exit;

// O card ocupa toda a GUI e encerra o Draw antes de qualquer HUD ou cenario.
// Isso preserva o efeito de corte cinematografico sem revelar o menu abaixo.
if (scr_narrativa_ativa()) {
    scr_narrativa_desenhar();
    exit;
}

if (room == rm_transicao) {
    if (fade_alpha > 0) {
        scr_draw_dither_fade(fade_alpha);
    }
    exit;
}

if (room == rm_autopsia) {
    if (fade_alpha > 0) {
        scr_draw_dither_fade(fade_alpha);
    }
    exit;
}

if (room == rm_combate_teste) exit;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

// Hub temporario para escolher entre tres corredores. O painel da direita se
// mantem fixo; somente a descricao e o cenario escolhido fazem crossfade.
if (navegacao_corredor_ativo
    && is_struct(global.current_room)
    && variable_struct_exists(global.current_room, "navegacao_corredores")) {
    var _hub_gui = global.current_room.navegacao_corredores;
    var _opcoes_gui = _hub_gui.opcoes;
    var _opcao_gui = _opcoes_gui[navegacao_corredor_indice];
    var _opcao_anterior_gui = _opcoes_gui[navegacao_corredor_anterior];
    var _fade_opcao = navegacao_corredor_alpha;
    // Painel e comandos sao fixos. Somente a arte do corredor troca junto do cenario.
    var _painel_sprite = _hub_gui.painel_sprite;
    var _botao_sprite = _hub_gui.botao_sprite;
    var _fonte_atual = _opcao_gui.fonte_sprite;
    var _fonte_anterior = _opcao_anterior_gui.fonte_sprite;

    if (_painel_sprite != noone && sprite_exists(_painel_sprite)) {
        draw_sprite_ext(_painel_sprite, 0, 0, 0, 1, 1, 0, c_white, 1);
    }

    if (navegacao_corredor_anterior != navegacao_corredor_indice
        && _fade_opcao < 1 && _fonte_anterior != noone && sprite_exists(_fonte_anterior)) {
        draw_sprite_ext(_fonte_anterior, 0, 0, 0, 1, 1, 0, c_white, 1 - _fade_opcao);
    }

    if (_fonte_atual != noone && sprite_exists(_fonte_atual)) {
        draw_sprite_ext(_fonte_atual, 0, 0, 0, 1, 1, 0, c_white, _fade_opcao);
    }

    if (_botao_sprite != noone && sprite_exists(_botao_sprite)) {
        draw_sprite_ext(_botao_sprite, 0, 0, 0, 1, 1, 0, c_white, 1);
    }

    if (point_in_rectangle(_mx, _my, _hub_gui.entrar.x1, _hub_gui.entrar.y1,
        _hub_gui.entrar.x2, _hub_gui.entrar.y2)
        && sprite_exists(spr_painel_corredor_preto)) {
        draw_sprite(spr_painel_corredor_preto, 0, 0, 0);
    }

    if (navegacao_corredor_aviso > 0) {
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_color(make_color_rgb(255, 220, 100));
        draw_text(1532, 710, "ESTE CAMINHO AINDA ESTA FECHADO");
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);

    if (fade_alpha > 0) {
        scr_draw_dither_fade(fade_alpha);
    }
    exit;
}

// Sequencia visual da sala. Todas as etapas usam sprites em canvas completo.
if (navegacao_sequencia_estado != "inativo"
    && is_struct(global.current_room)
    && variable_struct_exists(global.current_room, "navegacao_sequencia")) {
    var _sequencia_nav = global.current_room.navegacao_sequencia;
    var _estado_nav = navegacao_sequencia_estado;
    var _alpha_nav = navegacao_sequencia_alpha;

    if (variable_struct_exists(_sequencia_nav, "modo")
        && _sequencia_nav.modo == "cinematica_memorias"
        && variable_struct_exists(_sequencia_nav, "cinematica")) {
        var _cinematica_gui = _sequencia_nav.cinematica;
        var _tempo_cinematica = navegacao_cinematica_tempo;
        var _sprite_cinematica = noone;
        var _largura_cinematica = 0;
        var _altura_cinematica = 0;
        var _alpha_cinematica = 1;
        var _progresso_cinematica = 0;
        var _alpha_escolha = 1;
        var _indice_signalis = 0;

        if (_estado_nav == "cinematica_menu") {
            var _sprite_andar_cinema = navegacao_sequencia_selecao == 0
                ? _sequencia_nav.escolha_andar_vermelho
                : _sequencia_nav.escolha_andar_branco;
            var _sprite_voltar_cinema = navegacao_sequencia_selecao == 0
                ? _sequencia_nav.escolha_voltar_branco
                : _sequencia_nav.escolha_voltar_vermelho;

            if (sprite_exists(_sprite_andar_cinema)) {
                draw_sprite(_sprite_andar_cinema, 0, 0, 0);
            }
            if (sprite_exists(_sprite_voltar_cinema)) {
                draw_sprite(_sprite_voltar_cinema, 0, 0, 0);
            }
        }
        else if (_estado_nav == "cinematica_relatorio_cards"
            || _estado_nav == "cinematica_relatorio_fragmentos"
            || _estado_nav == "cinematica_relatorio_lembre") {
            var _quadro_relatorio = noone;
            var _tema_relatorio = "preto";
            var _titulo_relatorio = "";
            var _subtitulo_relatorio = "";
            var _rodape_relatorio = "";
            var _scene_relatorio = "";
            var _escala_relatorio = 1;
            var _fundo_relatorio = make_color_rgb(10, 10, 12);
            var _texto_relatorio = make_color_rgb(245, 242, 237);

            if (_estado_nav == "cinematica_relatorio_cards") {
                _quadro_relatorio = _cinematica_gui.relatorio_cards[navegacao_cinematica_cartao_indice];
            }
            else if (_estado_nav == "cinematica_relatorio_fragmentos") {
                _quadro_relatorio = _cinematica_gui.relatorio_fragmentos[navegacao_cinematica_fragmento_indice];
            }
            else {
                _quadro_relatorio = _cinematica_gui.relatorio_lembre[navegacao_cinematica_lembre_indice];
                _titulo_relatorio = "LEMBRE.";
            }

            if (variable_struct_exists(_quadro_relatorio, "tipo")
                && _quadro_relatorio.tipo == "sprite") {
                _sprite_cinematica = _quadro_relatorio.sprite;
                _largura_cinematica = sprite_get_width(_sprite_cinematica);
                _altura_cinematica = sprite_get_height(_sprite_cinematica);
                if (_sprite_cinematica != noone && sprite_exists(_sprite_cinematica)) {
                    draw_sprite_part_ext(_sprite_cinematica, 0, 0, 0,
                        _largura_cinematica, _altura_cinematica,
                        0, 0,
                        1920 / _largura_cinematica, 1080 / _altura_cinematica,
                        c_white, 1);
                }
            }
            else if (variable_struct_exists(_quadro_relatorio, "tipo")
                && _quadro_relatorio.tipo == "silhueta") {
                draw_set_color(make_color_rgb(156, 8, 8));
                draw_set_alpha(1);
                draw_rectangle(0, 0, 1920, 1080, false);
                draw_set_color(c_black);
                draw_rectangle(0, 0, 1920, 150, false);
                draw_rectangle(0, 915, 1920, 1080, false);

                _sprite_cinematica = _cinematica_gui.silhueta;
                _largura_cinematica = sprite_get_width(_sprite_cinematica);
                _altura_cinematica = sprite_get_height(_sprite_cinematica);
                if (_sprite_cinematica != noone && sprite_exists(_sprite_cinematica)) {
                    draw_sprite_part_ext(_sprite_cinematica, 0, 0, 0,
                        _largura_cinematica, _altura_cinematica,
                        560, 70, 0.95, 0.95, c_black, 1);
                }
            }
            else {
                if (_titulo_relatorio == "") _titulo_relatorio = _quadro_relatorio.titulo;
                if (variable_struct_exists(_quadro_relatorio, "subtitulo")) _subtitulo_relatorio = _quadro_relatorio.subtitulo;
                if (variable_struct_exists(_quadro_relatorio, "rodape")) _rodape_relatorio = _quadro_relatorio.rodape;
                if (variable_struct_exists(_quadro_relatorio, "scene")) _scene_relatorio = _quadro_relatorio.scene;
                if (variable_struct_exists(_quadro_relatorio, "tema")) _tema_relatorio = _quadro_relatorio.tema;
                if (variable_struct_exists(_quadro_relatorio, "escala")) _escala_relatorio = _quadro_relatorio.escala;

                switch (_tema_relatorio) {
                    case "azul":
                        _fundo_relatorio = make_color_rgb(29, 40, 178);
                        _texto_relatorio = c_white;
                    break;

                    case "vermelho":
                        _fundo_relatorio = make_color_rgb(213, 0, 49);
                        _texto_relatorio = c_white;
                    break;

                    case "off_white":
                        _fundo_relatorio = make_color_rgb(244, 241, 234);
                        _texto_relatorio = make_color_rgb(160, 20, 37);
                    break;
                }

                draw_set_color(_fundo_relatorio);
                draw_set_alpha(1);
                draw_rectangle(0, 0, 1920, 1080, false);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_set_color(_texto_relatorio);

                if (_scene_relatorio != "") {
                    draw_text_transformed(960, 390, _scene_relatorio, 1.1, 1.1, 0);
                }
                draw_text_transformed(960, 505, _titulo_relatorio, _escala_relatorio, _escala_relatorio, 0);
                if (_subtitulo_relatorio != "") {
                    draw_text_transformed(960, 610, _subtitulo_relatorio, 1.35, 1.35, 0);
                }
                if (_rodape_relatorio != "") {
                    draw_text_transformed(960, 700, _rodape_relatorio, 1.25, 1.25, 0);
                }
            }
        }
        else if (_estado_nav == "cinematica_relatorio_preto"
            || _estado_nav == "cinematica_relatorio_escurecer") {
            draw_set_alpha(1);
            draw_set_color(c_black);
            draw_rectangle(0, 0, 1920, 1080, false);
        }
        else if (_estado_nav == "cinematica_relatorio_interrogacao") {
            _progresso_cinematica = clamp(_tempo_cinematica / _cinematica_gui.duracao_interrogacao, 0, 1);
            _alpha_cinematica = _progresso_cinematica < 0.25
                ? _progresso_cinematica * 4
                : (1 - _progresso_cinematica) / 0.75;
            _sprite_cinematica = _cinematica_gui.interrogacao;
            _largura_cinematica = sprite_get_width(_sprite_cinematica);
            _altura_cinematica = sprite_get_height(_sprite_cinematica);
            draw_set_color(c_black);
            draw_set_alpha(1);
            draw_rectangle(0, 0, 1920, 1080, false);
            if (_sprite_cinematica != noone && sprite_exists(_sprite_cinematica)) {
                draw_sprite_part_ext(_sprite_cinematica, 0, 0, 0,
                    _largura_cinematica, _altura_cinematica,
                    0, 0,
                    1920 / _largura_cinematica, 1080 / _altura_cinematica,
                    c_white, _alpha_cinematica);
            }
        }
        else if (_estado_nav == "cinematica_signalis_entrada"
            || _estado_nav == "cinematica_signalis_escolha") {
            _indice_signalis = floor(_tempo_cinematica * _cinematica_gui.fps_signalis)
                mod array_length(_cinematica_gui.signalis_frames);
            _sprite_cinematica = _cinematica_gui.signalis_frames[_indice_signalis];
            _largura_cinematica = sprite_get_width(_sprite_cinematica);
            _altura_cinematica = sprite_get_height(_sprite_cinematica);
            _alpha_cinematica = _estado_nav == "cinematica_signalis_entrada"
                ? clamp(_tempo_cinematica / _cinematica_gui.duracao_signalis_entrada, 0, 1)
                : 1;

            draw_set_color(c_black);
            draw_set_alpha(1);
            draw_rectangle(0, 0, 1920, 1080, false);
            if (_sprite_cinematica != noone && sprite_exists(_sprite_cinematica)) {
                draw_sprite_part_ext(_sprite_cinematica, 0, 0, 0,
                    _largura_cinematica, _altura_cinematica,
                    0, 0,
                    1920 / _largura_cinematica, 1080 / _altura_cinematica,
                    c_white, _alpha_cinematica);
            }

            if (_estado_nav == "cinematica_signalis_escolha") {
                var _rect_seguir = _cinematica_gui.escolha_seguir;
                var _rect_lembrar = _cinematica_gui.escolha_lembrar;
                var _cor_escolhida = make_color_rgb(212, 25, 35);
                _alpha_escolha = clamp(_tempo_cinematica / 0.25, 0, 1);

                draw_set_alpha(0.78 * _alpha_escolha);
                draw_set_color(c_black);
                draw_rectangle(_rect_seguir.x1, _rect_seguir.y1, _rect_seguir.x2, _rect_seguir.y2, false);
                draw_rectangle(_rect_lembrar.x1, _rect_lembrar.y1, _rect_lembrar.x2, _rect_lembrar.y2, false);

                draw_set_alpha(_alpha_escolha);
                draw_set_color(navegacao_sequencia_selecao == 0 ? _cor_escolhida : c_white);
                draw_rectangle(_rect_seguir.x1, _rect_seguir.y1, _rect_seguir.x2, _rect_seguir.y2, true);
                draw_set_color(navegacao_sequencia_selecao == 1 ? _cor_escolhida : c_white);
                draw_rectangle(_rect_lembrar.x1, _rect_lembrar.y1, _rect_lembrar.x2, _rect_lembrar.y2, true);

                draw_set_halign(fa_left);
                draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text_transformed(_rect_seguir.x1 + 52, (_rect_seguir.y1 + _rect_seguir.y2) * 0.5,
                    "SEGUIR EM FRENTE", 1.25, 1.25, 0);
                draw_text_transformed(_rect_lembrar.x1 + 52, (_rect_lembrar.y1 + _rect_lembrar.y2) * 0.5,
                    "LEMBRAR QUEM VOCE E", 1.25, 1.25, 0);

                draw_set_color(_cor_escolhida);
                var _cursor_y = navegacao_sequencia_selecao == 0
                    ? (_rect_seguir.y1 + _rect_seguir.y2) * 0.5
                    : (_rect_lembrar.y1 + _rect_lembrar.y2) * 0.5;
                draw_triangle(_rect_seguir.x1 + 18, _cursor_y - 11,
                    _rect_seguir.x1 + 18, _cursor_y + 11,
                    _rect_seguir.x1 + 34, _cursor_y, false);
            }
        }

        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        if (fade_alpha > 0) {
            scr_draw_dither_fade(fade_alpha);
        }
        exit;
    }
    else if (_estado_nav == "entrada_escolha" || _estado_nav == "escolha_entrada" || _estado_nav == "saida_escolha") {
        var _painel_escolha = _sequencia_nav.painel_escolha;
        if (_sequencia_nav.escolha_sprite != noone
            && sprite_exists(_sequencia_nav.escolha_sprite)) {
            draw_sprite_part_ext(_sequencia_nav.escolha_sprite, 0,
                _painel_escolha.recorte_x, _painel_escolha.recorte_y,
                _painel_escolha.largura, _painel_escolha.altura,
                _painel_escolha.x, _painel_escolha.y,
                _painel_escolha.escala_x, _painel_escolha.escala_y,
                c_white, _alpha_nav);
        }

        if (variable_struct_exists(_sequencia_nav, "escolha_texto_dinamico")
            && _sequencia_nav.escolha_texto_dinamico) {
            draw_set_alpha(_alpha_nav);
            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);
            draw_set_color(c_white);
            draw_text_transformed(1370, _sequencia_nav.seta_andar_y, "ANDAR", 1.25, 1.25, 0);
            draw_text_transformed(1370, _sequencia_nav.seta_voltar_y, "VOLTAR", 1.25, 1.25, 0);
            draw_set_alpha(1);
        }

        // As escolhas sao camadas independentes: vermelho para a selecao atual
        // e branco para a alternativa. Assim elas podem receber efeitos depois.
        var _andar_ativo = navegacao_sequencia_selecao == 0;
        var _sprite_andar = _andar_ativo
            ? _sequencia_nav.escolha_andar_vermelho
            : _sequencia_nav.escolha_andar_branco;
        var _sprite_voltar = _andar_ativo
            ? _sequencia_nav.escolha_voltar_branco
            : _sequencia_nav.escolha_voltar_vermelho;

        draw_set_alpha(_alpha_nav);
        draw_set_color(c_white);
        if (sprite_exists(_sprite_andar)) {
            draw_sprite_ext(_sprite_andar, 0, 0, 0, 1, 1, 0, c_white, _alpha_nav);
        }
        if (sprite_exists(_sprite_voltar)) {
            draw_sprite_ext(_sprite_voltar, 0, 0, 0, 1, 1, 0, c_white, _alpha_nav);
        }
        draw_set_alpha(1);
    }
    else if (_estado_nav == "entrada_legenda" || _estado_nav == "legenda_entrada" || _estado_nav == "saida_legenda") {
        var _legenda_nav = _sequencia_nav.legenda;
        if (sprite_exists(_sequencia_nav.legenda_sprite)) {
            draw_sprite_part_ext(_sequencia_nav.legenda_sprite, 0,
                _legenda_nav.recorte_x, _legenda_nav.recorte_y,
                _legenda_nav.largura, _legenda_nav.altura,
                _legenda_nav.x, _legenda_nav.y,
                _legenda_nav.escala_x, _legenda_nav.escala_y,
                c_white, _alpha_nav);
        }

        draw_set_alpha(_alpha_nav);
        draw_set_color(c_white);
        draw_text_transformed(_sequencia_nav.seta_legenda_x, _sequencia_nav.seta_legenda_y, ">",
            _sequencia_nav.seta_legenda_escala, _sequencia_nav.seta_legenda_escala, 0);
        draw_set_alpha(1);
    }
    else if (_estado_nav == "entrada_memoria" || _estado_nav == "escolha_memoria") {
        if (_sequencia_nav.memoria_sprite != noone && sprite_exists(_sequencia_nav.memoria_sprite)) {
            draw_sprite_ext(_sequencia_nav.memoria_sprite, 0, 0, 0, 1, 1, 0, c_white, _alpha_nav);
        }

        var _memoria_y = navegacao_sequencia_selecao == 0
            ? _sequencia_nav.memoria_seta_lembrar_y
            : _sequencia_nav.memoria_seta_seguir_y;
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text_transformed(_sequencia_nav.memoria_seta_x, _memoria_y, ">",
            _sequencia_nav.memoria_seta_escala, _sequencia_nav.memoria_seta_escala, 0);
        draw_set_alpha(1);
    }

    if (fade_alpha > 0) {
        scr_draw_dither_fade(fade_alpha);
    }
    exit;
}

// Depuracao de encontros permanece desativada na versao jogavel.
var mostrar_hitbox_encontro = false;
if (mostrar_hitbox_encontro && is_struct(global.current_room) && variable_struct_exists(global.current_room, "itens")
    && !scr_encounter_ativo() && room != rm_transicao && room != rm_autopsia) {
    var _itens_debug_encontro = global.current_room.itens;

    for (var hd = 0; hd < array_length(_itens_debug_encontro); hd++) {
        var _debug_item = _itens_debug_encontro[hd];
        var _debug_ativo = variable_struct_exists(_debug_item, "debug_hitbox") && _debug_item.debug_hitbox;
        var _debug_coletado = variable_struct_exists(_debug_item, "coletado") && _debug_item.coletado;
        var _debug_removido = variable_struct_exists(_debug_item, "removido") && _debug_item.removido;

        if (_debug_ativo && !_debug_coletado && !_debug_removido) {
            var _debug_hb = scr_get_item_hitbox(_debug_item);
            var _debug_manual = variable_struct_exists(_debug_hb, "manual") && _debug_hb.manual;
            if (_debug_hb.sprite != noone || _debug_manual) {
                draw_set_alpha(0.22);
                draw_set_color(c_red);
                draw_rectangle(_debug_hb.x1, _debug_hb.y1, _debug_hb.x2, _debug_hb.y2, false);
                draw_set_alpha(1);
                draw_set_color(c_yellow);
                draw_rectangle(_debug_hb.x1, _debug_hb.y1, _debug_hb.x2, _debug_hb.y2, true);
                draw_set_color(c_white);
                draw_text(_debug_hb.x1 + 8, _debug_hb.y1 + 8, "ENCONTRO");
            }
        }
    }

    draw_set_alpha(1);
}

if (scr_encounter_ativo()) {
    var _alpha_encontro = global.encounter.alpha;
    var _panel_x = global.ui_config.encounter_panel_x;
    var _panel_y = global.ui_config.encounter_panel_y;
    var _panel_w = global.ui_config.encounter_panel_w;
    var _panel_h = global.ui_config.encounter_panel_h;
    var _dados_encontro = global.encounter.dados;
    var _titulo_encontro = variable_struct_exists(_dados_encontro, "nome") ? _dados_encontro.nome : "Encontro";

    if (global.encounter.auto_start) {
        draw_set_alpha(min(1, 0.88 * _alpha_encontro));
        draw_set_color(c_black);
        draw_rectangle(0, 0, 1920, 1080, false);

        draw_set_alpha(_alpha_encontro);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text_transformed(960, 430, _titulo_encontro, 1.7, 1.7, 0);
        draw_set_color(make_color_rgb(190, 190, 190));
        draw_text_ext(960, 520, global.encounter.texto, 18, 760);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_alpha(1);
        exit;
    }

    draw_set_alpha(0.52 * _alpha_encontro);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 1920, 1080, false);

    draw_set_alpha(0.96 * _alpha_encontro);
    draw_set_color(c_black);
    draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(96, 96, 96));
    draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true);
    draw_set_color(make_color_rgb(36, 36, 36));
    draw_rectangle(_panel_x + 5, _panel_y + 5, _panel_x + _panel_w - 5, _panel_y + _panel_h - 5, true);

    var _sil_x = _panel_x + (_panel_w * 0.5);
    var _sil_y = _panel_y + 185;
    draw_set_alpha(_alpha_encontro);
    draw_set_color(make_color_rgb(18, 18, 18));
    draw_rectangle(_sil_x - 90, _sil_y - 82, _sil_x + 90, _sil_y + 95, false);
    draw_set_color(make_color_rgb(120, 120, 120));
    draw_rectangle(_sil_x - 90, _sil_y - 82, _sil_x + 90, _sil_y + 95, true);
    draw_set_color(make_color_rgb(42, 42, 42));
    draw_rectangle(_sil_x - 42, _sil_y - 132, _sil_x + 42, _sil_y - 58, false);
    draw_set_color(make_color_rgb(120, 120, 120));
    draw_rectangle(_sil_x - 42, _sil_y - 132, _sil_x + 42, _sil_y - 58, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_text_transformed(_panel_x + (_panel_w * 0.5), _panel_y + 46, _titulo_encontro, 1.6, 1.6, 0);
    draw_text_ext(_panel_x + (_panel_w * 0.5), _panel_y + 342, global.encounter.texto, 18, _panel_w - 180);

    if (global.encounter.estado == "escolha") {
        var _btn_enfrentar = scr_get_encounter_button_rect(0);
        var _btn_recuar = scr_get_encounter_button_rect(1);
        var _hover_enfrentar = point_in_rectangle(_mx, _my, _btn_enfrentar.x1, _btn_enfrentar.y1, _btn_enfrentar.x2, _btn_enfrentar.y2);
        var _hover_recuar = point_in_rectangle(_mx, _my, _btn_recuar.x1, _btn_recuar.y1, _btn_recuar.x2, _btn_recuar.y2);

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        draw_set_color(_hover_enfrentar ? make_color_rgb(72, 72, 72) : make_color_rgb(16, 16, 16));
        draw_rectangle(_btn_enfrentar.x1, _btn_enfrentar.y1, _btn_enfrentar.x2, _btn_enfrentar.y2, false);
        draw_set_color(c_white);
        draw_rectangle(_btn_enfrentar.x1, _btn_enfrentar.y1, _btn_enfrentar.x2, _btn_enfrentar.y2, true);
        draw_text((_btn_enfrentar.x1 + _btn_enfrentar.x2) * 0.5, (_btn_enfrentar.y1 + _btn_enfrentar.y2) * 0.5, "Enfrentar");

        draw_set_color(_hover_recuar ? make_color_rgb(72, 72, 72) : make_color_rgb(16, 16, 16));
        draw_rectangle(_btn_recuar.x1, _btn_recuar.y1, _btn_recuar.x2, _btn_recuar.y2, false);
        draw_set_color(c_white);
        draw_rectangle(_btn_recuar.x1, _btn_recuar.y1, _btn_recuar.x2, _btn_recuar.y2, true);
        draw_text((_btn_recuar.x1 + _btn_recuar.x2) * 0.5, (_btn_recuar.y1 + _btn_recuar.y2) * 0.5, "Recuar");
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);

    if (fade_alpha > 0) {
        scr_draw_dither_fade(fade_alpha);
    }

    exit;
}


if (scr_evento_ui_ativo() && !scr_contexto_aguardando_item()) {
    var _evento_camadas = scr_get_evento_data(global.evento_runtime.evento_id);
    var _no_camadas = scr_evento_get_no_atual();
    var _usa_camadas = is_struct(_evento_camadas)
        && variable_struct_exists(_evento_camadas, "apresentacao")
        && is_struct(_no_camadas)
        && variable_struct_exists(_no_camadas, "apresentacao");

    if (_usa_camadas) {
        var _apresentacao = _evento_camadas.apresentacao;
        var _runtime_camadas = global.evento_runtime.apresentacao;
        var _cenario_camada = _apresentacao.cenarios[$ _runtime_camadas.cenario_id];
        var _legenda_camada = _apresentacao.legendas[$ _runtime_camadas.legenda_id];
        var _acao_camada = _apresentacao.acoes[$ _runtime_camadas.acao_id];
        var _alpha_cenario = scr_evento_apresentacao_alpha("cenario");
        var _alpha_legenda = scr_evento_apresentacao_alpha("legenda");
        var _alpha_acao = scr_evento_apresentacao_alpha("acao");

        draw_set_alpha(1);
        draw_set_color(c_black);
        draw_rectangle(0, 0, 1920, 1080, false);

          if (is_struct(_cenario_camada) && sprite_exists(_cenario_camada.sprite)) {
            scr_luminancia_respirar_iniciar();
            draw_sprite_ext(_cenario_camada.sprite, 0,
                 _cenario_camada.x, _cenario_camada.y,
                 _cenario_camada.escala_x, _cenario_camada.escala_y, 0, c_white, _alpha_cenario);
            scr_luminancia_respirar_terminar();
          }

        // O card-base e seus icones nunca entram na transicao.
        var _base_sprite = _apresentacao.base.sprite;
        draw_sprite_part(_base_sprite, 0, 0, 0, 520, 692, 0, 0);
        draw_sprite_part(_base_sprite, 0, 0, 100, 520, 64, 0, 692);
        draw_sprite_part(_base_sprite, 0, 0, 756, 520, 324, 0, 756);

        if (is_struct(_legenda_camada) && sprite_exists(_legenda_camada.sprite)) {
            var _legenda_x = variable_struct_exists(_legenda_camada, "x") ? _legenda_camada.x : 0;
            var _legenda_y = variable_struct_exists(_legenda_camada, "y") ? _legenda_camada.y : 0;
            var _legenda_sx = variable_struct_exists(_legenda_camada, "escala_x") ? _legenda_camada.escala_x : 1;
            var _legenda_sy = variable_struct_exists(_legenda_camada, "escala_y") ? _legenda_camada.escala_y : 1;
            if (variable_struct_exists(_legenda_camada, "recorte")) {
                var _recorte_legenda = _legenda_camada.recorte;
                draw_sprite_part_ext(_legenda_camada.sprite, 0, _recorte_legenda.x, _recorte_legenda.y,
                    _recorte_legenda.largura, _recorte_legenda.altura, _legenda_x, _legenda_y,
                    _legenda_sx, _legenda_sy, c_white, _alpha_legenda);
            } else {
                draw_sprite_ext(_legenda_camada.sprite, 0, _legenda_x, _legenda_y,
                    _legenda_sx, _legenda_sy, 0, c_white, _alpha_legenda);
            }

            if (variable_struct_exists(_legenda_camada, "titulo_sprite")
                && sprite_exists(_legenda_camada.titulo_sprite)) {
                draw_sprite_ext(_legenda_camada.titulo_sprite, 0, _legenda_camada.titulo_x,
                    _legenda_camada.titulo_y, _legenda_camada.titulo_escala,
                    _legenda_camada.titulo_escala, 0, c_white, _alpha_legenda);
            }
        }

        // O destaque da parte continua acima da legenda artistica.
        var _escolhas_camadas = scr_evento_get_escolhas();
        var _destaque_indice = -1;
        for (var lh = 0; lh < array_length(_escolhas_camadas); lh++) {
            var _retangulo_hover = scr_evento_get_escolha_rect(lh);
            if (point_in_rectangle(_mx, _my, _retangulo_hover.x1, _retangulo_hover.y1, _retangulo_hover.x2, _retangulo_hover.y2)
                && variable_struct_exists(_escolhas_camadas[lh], "sprite")
                && sprite_exists(_escolhas_camadas[lh].sprite)) {
                _destaque_indice = lh;
                break;
            }
        }
        if (_destaque_indice < 0 && global.evento_runtime.escolha_selecionada >= 0) {
            _destaque_indice = global.evento_runtime.escolha_selecionada;
        }
        if (is_struct(_acao_camada) && variable_struct_exists(_acao_camada, "sprite")
            && sprite_exists(_acao_camada.sprite)) {
            if (variable_struct_exists(_acao_camada, "canvas_completo") && _acao_camada.canvas_completo) {
                draw_sprite_ext(_acao_camada.sprite, 0, _acao_camada.x, _acao_camada.y,
                    1, 1, 0, c_white, _alpha_acao);
            } else {
                var _recorte_acao = _acao_camada.recorte;
                draw_sprite_part_ext(_acao_camada.sprite, 0, _recorte_acao.x, _recorte_acao.y,
                    _recorte_acao.largura, _recorte_acao.altura, _acao_camada.x, _acao_camada.y,
                    1, 1, c_white, _alpha_acao);
            }
        }

        for (var eb = 0; eb < array_length(_escolhas_camadas); eb++) {
            if (variable_struct_exists(_escolhas_camadas[eb], "sprite_base")
                && sprite_exists(_escolhas_camadas[eb].sprite_base)) {
                draw_sprite_ext(_escolhas_camadas[eb].sprite_base, 0, 0, 0,
                    1, 1, 0, c_white, _alpha_acao);
            }
        }

        // O hover entra por ultimo para substituir, e nao ficar oculto sob o painel-base.
        if (_destaque_indice >= 0 && _destaque_indice < array_length(_escolhas_camadas)
            && variable_struct_exists(_escolhas_camadas[_destaque_indice], "sprite")
            && sprite_exists(_escolhas_camadas[_destaque_indice].sprite)) {
            draw_sprite_ext(_escolhas_camadas[_destaque_indice].sprite, 0, 0, 0, 1, 1, 0, c_white, _alpha_acao);
        }

        draw_set_alpha(1);
        draw_set_color(c_white);
        exit;
    }

    var _evento_painel = scr_get_evento_data(global.evento_runtime.evento_id);
    var _no_evento = scr_evento_get_no_atual();
    var _painel_evento = _evento_painel.painel;
    var _cenario_evento = _evento_painel.cenario;
    var _titulo_evento = variable_struct_exists(_no_evento, "titulo") ? _no_evento.titulo : "Evento";
    var _mensagem_evento = variable_struct_exists(_no_evento, "mensagem") ? _no_evento.mensagem : "";
    if (global.evento_runtime.mensagem != "") _mensagem_evento = global.evento_runtime.mensagem;
    var _painel_sprite = variable_struct_exists(_no_evento, "painel_sprite")
        ? _no_evento.painel_sprite : _painel_evento.sprite;
    var _legenda_sprite = variable_struct_exists(_no_evento, "legenda_sprite")
        ? _no_evento.legenda_sprite : noone;
    var _tem_legenda = _legenda_sprite != noone && sprite_exists(_legenda_sprite);
    var _texto_embutido = variable_struct_exists(_no_evento, "texto_embutido")
        && _no_evento.texto_embutido;
    var _painel_alpha = 1;
    if (variable_struct_exists(global.evento_runtime, "transicao_painel")) {
        _painel_alpha = global.evento_runtime.transicao_painel.alpha;
    }
    var _escolhas_draw = scr_evento_get_escolhas();
    var _preview_index = -1;

    // O hover mostra a parte sob o mouse; a selecao anterior permanece como fallback.
    for (var eh = 0; eh < array_length(_escolhas_draw); eh++) {
        var _rect_hover = scr_evento_get_escolha_rect(eh);
        if (point_in_rectangle(_mx, _my, _rect_hover.x1, _rect_hover.y1, _rect_hover.x2, _rect_hover.y2)
            && variable_struct_exists(_escolhas_draw[eh], "sprite")
            && _escolhas_draw[eh].sprite != noone
            && sprite_exists(_escolhas_draw[eh].sprite)) {
            _preview_index = eh;
            break;
        }
    }

    if (_preview_index < 0) {
        for (var ep = 0; ep < array_length(_escolhas_draw); ep++) {
            if (global.evento_runtime.escolha_selecionada == ep
                && variable_struct_exists(_escolhas_draw[ep], "sprite")
                && _escolhas_draw[ep].sprite != noone
                && sprite_exists(_escolhas_draw[ep].sprite)) {
                _preview_index = ep;
                break;
            }
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_rectangle(0, 0, 1920, 1080, false);
    if (variable_struct_exists(_cenario_evento, "sprite") && sprite_exists(_cenario_evento.sprite)) {
        var _cenario_x = variable_struct_exists(_cenario_evento, "pos_x") ? _cenario_evento.pos_x : 0;
        var _cenario_y = variable_struct_exists(_cenario_evento, "pos_y") ? _cenario_evento.pos_y : 0;
        var _cenario_escala_x = variable_struct_exists(_cenario_evento, "escala_x") ? _cenario_evento.escala_x : 1;
        var _cenario_escala_y = variable_struct_exists(_cenario_evento, "escala_y") ? _cenario_evento.escala_y : 1;
        draw_sprite_ext(_cenario_evento.sprite, 0, _cenario_x, _cenario_y, _cenario_escala_x, _cenario_escala_y, 0, c_white, 1);
    }

    if (_painel_sprite != noone && sprite_exists(_painel_sprite)) {
        draw_sprite_ext(_painel_sprite, 0, _painel_evento.pos_x, _painel_evento.pos_y, 1, 1, 0, c_white, _painel_alpha);
    } else {
        draw_set_alpha(_painel_alpha);
        draw_set_color(c_black);
        draw_rectangle(_painel_evento.pos_x, _painel_evento.pos_y, _painel_evento.pos_x + _painel_evento.largura, _painel_evento.pos_y + _painel_evento.altura, false);
        draw_set_color(make_color_rgb(180, 180, 180));
        draw_rectangle(_painel_evento.pos_x, _painel_evento.pos_y, _painel_evento.pos_x + _painel_evento.largura, _painel_evento.pos_y + _painel_evento.altura, true);
        draw_set_alpha(1);
    }
    if (_tem_legenda) {
        draw_sprite_ext(_legenda_sprite, 0, _painel_evento.pos_x, _painel_evento.pos_y, 1, 1, 0, c_white, _painel_alpha);
    }

    for (var eb_base = 0; eb_base < array_length(_escolhas_draw); eb_base++) {
        if (variable_struct_exists(_escolhas_draw[eb_base], "sprite_base")
            && sprite_exists(_escolhas_draw[eb_base].sprite_base)) {
            draw_sprite_ext(_escolhas_draw[eb_base].sprite_base, 0, 0, 0, 1, 1, 0, c_white, _painel_alpha);
        }
    }

    if (_preview_index >= 0) {
        draw_sprite_ext(_escolhas_draw[_preview_index].sprite, 0, 0, 0, 1, 1, 0, c_white, _painel_alpha);
    }

    if (!_texto_embutido) {
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_text_transformed(_painel_evento.pos_x + 28, _painel_evento.pos_y + 28, _titulo_evento, 1.35, 1.35, 0);

    if (!_tem_legenda) {
        var _mensagem_alinhamento = variable_struct_exists(_no_evento, "mensagem_alinhamento") ? _no_evento.mensagem_alinhamento : fa_left;
        var _mensagem_x = _painel_evento.pos_x + (variable_struct_exists(_no_evento, "mensagem_x") ? _no_evento.mensagem_x : 28);
        var _mensagem_y = _painel_evento.pos_y + (variable_struct_exists(_no_evento, "mensagem_y") ? _no_evento.mensagem_y : 120);
        var _mensagem_largura = variable_struct_exists(_no_evento, "mensagem_largura") ? _no_evento.mensagem_largura : (_painel_evento.largura - 56);
        draw_set_color(make_color_rgb(210, 210, 210));
        draw_set_halign(_mensagem_alinhamento);
        draw_text_ext(_mensagem_x, _mensagem_y, _mensagem_evento, 18, _mensagem_largura);
        draw_set_halign(fa_left);
    }

    for (var ed = 0; ed < array_length(_escolhas_draw); ed++) {
        if (variable_struct_exists(_escolhas_draw[ed], "desenhada_na_sprite")
            && _escolhas_draw[ed].desenhada_na_sprite) continue;
        if (_preview_index == ed) continue;

        var _rect_draw = scr_evento_get_escolha_rect(ed);
        var _hover_draw = point_in_rectangle(_mx, _my, _rect_draw.x1, _rect_draw.y1, _rect_draw.x2, _rect_draw.y2);
        var _estilo_lista = variable_struct_exists(_escolhas_draw[ed], "estilo") && _escolhas_draw[ed].estilo == "lista";

        if (!_estilo_lista) {
            draw_set_color(_hover_draw ? make_color_rgb(55, 55, 55) : c_black);
            draw_rectangle(_rect_draw.x1, _rect_draw.y1, _rect_draw.x2, _rect_draw.y2, false);
            draw_set_color(c_white);
            draw_rectangle(_rect_draw.x1, _rect_draw.y1, _rect_draw.x2, _rect_draw.y2, true);
        }

        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(_rect_draw.x1 + ((_rect_draw.x2 - _rect_draw.x1) * 0.5), _rect_draw.y1 + ((_rect_draw.y2 - _rect_draw.y1) * 0.5), _escolhas_draw[ed].texto);
    }
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    exit;
}
if (scr_contexto_ativo() && !scr_contexto_aguardando_item()) {
    var _ctx = global.contexto_interacao;
    var _ctx_dados = _ctx.dados;
    var _ctx_elemento = scr_contexto_get_elemento_atual();
    var _ctx_texto = scr_contexto_get_texto_elemento(_ctx_elemento);
    var _ctx_acoes = scr_contexto_get_acoes_elemento(_ctx_elemento);

    var _menu_sprite_index = -1;
    if (is_struct(_ctx_dados) && variable_struct_exists(_ctx_dados, "sprite_menu")) {
        _menu_sprite_index = asset_get_index(_ctx_dados.sprite_menu);
    }
    var _usar_sprite_menu = sprite_exists(_menu_sprite_index);

    var _left_x = 0;
    var _left_y = 0;
    var _left_w = 430;
    var _left_h = 1080;

    if (_usar_sprite_menu) {
        if (variable_struct_exists(_ctx_dados, "sprite_menu_w")) {
            _left_w = _ctx_dados.sprite_menu_w;
        }
        if (variable_struct_exists(_ctx_dados, "sprite_menu_h")) {
            _left_h = _ctx_dados.sprite_menu_h;
        }
    }

    var _scene_x = _left_w;
    var _scene_y = 0;
    var _scene_w = 1920 - _left_w;
    var _scene_h = 1080;
    var _nome_elemento = is_struct(_ctx_elemento) && variable_struct_exists(_ctx_elemento, "nome") ? _ctx_elemento.nome : "";
    var _titulo_contexto = _nome_elemento;
    if (is_struct(_ctx_dados)) {
        if (variable_struct_exists(_ctx_dados, "titulo")) {
            _titulo_contexto = _ctx_dados.titulo;
        } else if (variable_struct_exists(_ctx_dados, "nome")) {
            _titulo_contexto = _ctx_dados.nome;
        }
    }

    draw_set_color(c_black);
    draw_rectangle(0, 0, 1920, 1080, false);

    // Fundo cinza como Ãºltima camada da cena (antes do background da sala e do cadÃ¡ver)
    draw_set_color(make_color_rgb(28, 28, 28));
    draw_rectangle(_scene_x, _scene_y, _scene_x + _scene_w, _scene_y + _scene_h, false);

    if (is_struct(global.current_room) && variable_struct_exists(global.current_room, "background")
        && sprite_exists(global.current_room.background)) {
        draw_set_alpha(0.78);
        draw_sprite_stretched(global.current_room.background, 0, _scene_x, _scene_y, _scene_w, _scene_h);
        draw_set_alpha(1);
    }

    var _autopsia_dados = scr_get_autopsia_data("escavador_01");
    if (is_struct(_autopsia_dados) && variable_struct_exists(_autopsia_dados, "sprite_base")
        && sprite_exists(_autopsia_dados.sprite_base)) {
        var _cad_spr_base = spr_painel_cadaver;
        var _cad_sw = sprite_get_width(_cad_spr_base);
        var _cad_sh = sprite_get_height(_cad_spr_base);
        var _cad_scale = min(_scene_w / _cad_sw, _scene_h / _cad_sh) * 1.0;
        var _cad_draw_w = _cad_sw * _cad_scale;
        var _cad_draw_h = _cad_sh * _cad_scale;
        var _cad_draw_x = _scene_x + (_scene_w - _cad_draw_w) * 0.5;
        var _cad_draw_y = _scene_y + (_scene_h - _cad_draw_h) * 0.5;
        draw_sprite_ext(_cad_spr_base, 0, _cad_draw_x, _cad_draw_y, _cad_scale, _cad_scale, 0, c_white, 1);
    }

    if (_usar_sprite_menu) {
        draw_sprite_ext(_menu_sprite_index, 0, _left_x, _left_y, 1, 1, 0, c_white, 1);
    } else {
        draw_set_color(c_black);
        draw_rectangle(_left_x, _left_y, _left_x + _left_w, _left_y + _left_h, false);
        draw_set_color(make_color_rgb(220, 220, 220));
        draw_rectangle(_left_x + 2, _left_y, _left_x + _left_w, _left_y + _left_h, true);
        draw_rectangle(_left_x + 2, _left_y + 78, _left_x + _left_w, _left_y + 78, false);
        draw_rectangle(_left_x + 2, _left_y + 386, _left_x + _left_w, _left_y + 386, false);
        draw_rectangle(_left_x + 2, _left_y + 772, _left_x + _left_w, _left_y + 772, false);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_white);
        draw_text_transformed(_left_x + 46, _left_y + 24, string_upper(_titulo_contexto), 1.35, 1.35, 0);
        draw_set_color(make_color_rgb(215, 215, 215));
        draw_text_ext(_left_x + 58, _left_y + 150, _ctx_texto, 25, _left_w - 116);

        if (_ctx.mensagem != "") {
            draw_set_color(c_white);
            draw_rectangle(_left_x + 42, _left_y + 500, _left_x + _left_w - 42, _left_y + 626, true);
            draw_set_color(make_color_rgb(215, 215, 215));
            draw_text_ext(_left_x + 58, _left_y + 524, _ctx.mensagem, 19, _left_w - 116);
        }
    }

    if (!_usar_sprite_menu) {
    var _back_contexto = scr_get_contexto_back_rect();
    var _hover_back_contexto = point_in_rectangle(_mx, _my,
        _back_contexto.x1, _back_contexto.y1,
        _back_contexto.x2, _back_contexto.y2);
    draw_set_color(_hover_back_contexto ? make_color_rgb(48, 48, 48) : c_black);
    draw_rectangle(_back_contexto.x1, _back_contexto.y1, _back_contexto.x2, _back_contexto.y2, false);
    draw_set_color(c_white);
    draw_rectangle(_back_contexto.x1, _back_contexto.y1, _back_contexto.x2, _back_contexto.y2, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text((_back_contexto.x1 + _back_contexto.x2) * 0.5,
        (_back_contexto.y1 + _back_contexto.y2) * 0.5,
        "< VOLTAR");
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    for (var ca = 0; ca < array_length(_ctx_acoes); ca++) {
        var _acao = _ctx_acoes[ca];
        var _acao_rect = scr_get_contexto_action_rect(ca);
        var _hover_acao = point_in_rectangle(_mx, _my,
            _acao_rect.x1, _acao_rect.y1, _acao_rect.x2, _acao_rect.y2);

        draw_set_color(_hover_acao ? make_color_rgb(52, 52, 52) : c_black);
        draw_rectangle(_acao_rect.x1, _acao_rect.y1, _acao_rect.x2, _acao_rect.y2, false);
        draw_set_color(c_white);
        draw_rectangle(_acao_rect.x1, _acao_rect.y1, _acao_rect.x2, _acao_rect.y2, true);
        draw_rectangle(_acao_rect.x1 + 8, _acao_rect.y1 + 8, _acao_rect.x2 - 8, _acao_rect.y2 - 8, true);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text_transformed((_acao_rect.x1 + _acao_rect.x2) * 0.5, (_acao_rect.y1 + _acao_rect.y2) * 0.5, string_upper(_acao.nome), 1.15, 1.15, 0);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    }
    }

    if (is_struct(_ctx_dados) && variable_struct_exists(_ctx_dados, "elementos")) {
        var _elemento_visivel_index = 0;
        for (var ce = 0; ce < array_length(_ctx_dados.elementos); ce++) {
            var _el = _ctx_dados.elementos[ce];
            if (variable_struct_exists(_el, "id") && _el.id == "voltar") {
                continue;
            }

            var _el_rect = scr_get_contexto_elemento_rect(_elemento_visivel_index);
            _elemento_visivel_index += 1;
            var _selecionado = is_struct(_ctx_elemento) && _ctx_elemento.id == _el.id;
            var _hover_el = point_in_rectangle(_mx, _my,
                _el_rect.x1, _el_rect.y1, _el_rect.x2, _el_rect.y2);

            draw_set_color((_hover_el || _selecionado) ? make_color_rgb(48, 48, 48) : c_black);
            draw_rectangle(_el_rect.x1, _el_rect.y1, _el_rect.x2, _el_rect.y2, false);
            draw_set_color(_selecionado ? c_white : make_color_rgb(132, 132, 132));
            draw_rectangle(_el_rect.x1, _el_rect.y1, _el_rect.x2, _el_rect.y2, true);

            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_white);
            draw_text_transformed((_el_rect.x1 + _el_rect.x2) * 0.5, _el_rect.y1 + 30,
                _el.icone, 1.45, 1.45, 0);
            draw_text_transformed((_el_rect.x1 + _el_rect.x2) * 0.5, _el_rect.y2 - 24, _el.nome, 0.75, 0.75, 0);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    exit;
}

var _mouse_no_nav = point_in_rectangle(_mx, _my,
    global.ui_config.nav_x1, global.ui_config.nav_y1,
    global.ui_config.nav_x2, global.ui_config.nav_y2);

if (global.ui_state.menu_tab_aberto
    && (!global.ui_state.obstaculo_menu_aberto || global.ui_state.obstaculo_selecao_item_ativa)) {
    draw_sprite_stretched(spr_hud, 0, 0, 0, 1920, 1080);
}

// =========================================================================
// 2. BOTAO NAV
// =========================================================================
if (!global.ui_state.menu_tab_aberto && fade_estado == "parado") {
    var _nav_ativo = _mouse_no_nav || magi_ativo;
    var _table_x = global.ui_config.nav_table_x;
    var _table_y = global.ui_config.nav_table_y;
    var _table_w = global.ui_config.nav_table_w;
    var _table_h = global.ui_config.nav_table_h;

    draw_set_alpha(0.94);
    draw_set_color(c_black);
    draw_rectangle(_table_x, _table_y, _table_x + _table_w, _table_y + _table_h, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(96, 96, 96));
    draw_rectangle(_table_x, _table_y, _table_x + _table_w, _table_y + _table_h, true);
    draw_set_color(make_color_rgb(42, 42, 42));
    draw_rectangle(_table_x + 4, _table_y + 4, _table_x + _table_w - 4, _table_y + _table_h - 4, true);

    var _portrait_x = global.ui_config.nav_portrait_x;
    var _portrait_y = global.ui_config.nav_portrait_y;
    var _portrait_w = global.ui_config.nav_portrait_w;
    var _portrait_h = global.ui_config.nav_portrait_h;

    draw_set_color(c_black);
    draw_rectangle(_portrait_x, _portrait_y, _portrait_x + _portrait_w, _portrait_y + _portrait_h, false);
    draw_set_color(make_color_rgb(82, 82, 82));
    draw_rectangle(_portrait_x, _portrait_y, _portrait_x + _portrait_w, _portrait_y + _portrait_h, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(_portrait_x + (_portrait_w * 0.5), _portrait_y + 34, "PROTAGONISTA", 1.0, 1.0, 0);
    draw_set_color(make_color_rgb(76, 76, 76));
    draw_rectangle(_portrait_x + 24, _portrait_y + 58, _portrait_x + _portrait_w - 24, _portrait_y + _portrait_h - 24, true);

    var _load_x = global.ui_config.nav_loadout_x;
    var _load_y = global.ui_config.nav_loadout_y;
    var _slot_w = global.ui_config.nav_loadout_slot_w;
    var _slot_h = global.ui_config.nav_loadout_slot_h;
    var _load_cx = _load_x + (global.ui_config.nav_loadout_w * 0.5);
    var _load_cy = _load_y + 130;
    var _load_weapon = global.inventario.equipados.weapon;
    var _load_def = noone;
    if (global.inventario.equipados.armor != noone) {
        _load_def = global.inventario.equipados.armor;
    } else {
        _load_def = global.inventario.equipados.helmet;
    }
    var _load_cura = array_length(global.inventarios.cura) > 0 ? global.inventarios.cura[0] : noone;
    var _load_slots = [
        { label: "MAG",  item: noone,        cx: _load_cx + global.ui_config.nav_loadout_mag_offset_x,  cy: _load_cy + global.ui_config.nav_loadout_mag_offset_y  },
        { label: "DEF",  item: _load_def,    cx: _load_cx + global.ui_config.nav_loadout_def_offset_x,  cy: _load_cy + global.ui_config.nav_loadout_def_offset_y  },
        { label: "ATQ",  item: _load_weapon, cx: _load_cx + global.ui_config.nav_loadout_atq_offset_x,  cy: _load_cy + global.ui_config.nav_loadout_atq_offset_y  },
        { label: "CURA", item: _load_cura,   cx: _load_cx + global.ui_config.nav_loadout_cura_offset_x, cy: _load_cy + global.ui_config.nav_loadout_cura_offset_y }
    ];

    for (var ls = 0; ls < array_length(_load_slots); ls++) {
        var _load = _load_slots[ls];
        var _lx1 = _load.cx - (_slot_w * 0.5);
        var _ly1 = _load.cy - (_slot_h * 0.5);
        var _lx2 = _load.cx + (_slot_w * 0.5);
        var _ly2 = _load.cy + (_slot_h * 0.5);

        draw_set_color(c_black);
        draw_rectangle(_lx1, _ly1, _lx2, _ly2, false);
        draw_set_color(make_color_rgb(92, 92, 92));
        draw_rectangle(_lx1, _ly1, _lx2, _ly2, true);

        if (is_struct(_load.item) && variable_struct_exists(_load.item, "sprite")
            && _load.item.sprite != noone && sprite_exists(_load.item.sprite)) {
            var _lspr_w = sprite_get_width(_load.item.sprite);
            var _lspr_h = sprite_get_height(_load.item.sprite);
            var _lspr_xoff = sprite_get_xoffset(_load.item.sprite);
            var _lspr_yoff = sprite_get_yoffset(_load.item.sprite);
            var _lscale = min(1, 46 / max(_lspr_w, _lspr_h));
            draw_sprite_ext(_load.item.sprite, 0,
                _load.cx - ((_lspr_w * _lscale) * 0.5) + (_lspr_xoff * _lscale),
                _load.cy - ((_lspr_h * _lscale) * 0.5) + (_lspr_yoff * _lscale),
                _lscale, _lscale, 0, c_white, 1);
        } else {
            draw_set_color(make_color_rgb(150, 150, 150));
            draw_text_transformed(_load.cx, _load.cy, _load.label, 0.75, 0.75, 0);
        }
    }

    var _nav_x1 = global.ui_config.nav_action_x;
    var _nav_y1 = global.ui_config.nav_action_y;
    var _nav_x2 = _nav_x1 + global.ui_config.nav_action_w;
    var _nav_y2 = _nav_y1 + global.ui_config.nav_action_h;

    draw_set_color(c_black);
    draw_rectangle(_nav_x1, _nav_y1, _nav_x2, _nav_y2, false);
    draw_set_color(_nav_ativo ? c_white : make_color_rgb(96, 96, 96));
    draw_rectangle(_nav_x1, _nav_y1, _nav_x2, _nav_y2, true);
    draw_set_color(make_color_rgb(42, 42, 42));
    draw_rectangle(_nav_x1 + 4, _nav_y1 + 4, _nav_x2 - 4, _nav_y2 - 4, true);

    if (magi_ativo) {
        draw_set_alpha(alpha_magi);
        var _magi_cx = (_nav_x1 + _nav_x2) * 0.5;
        var _magi_cy = (_nav_y1 + _nav_y2) * 0.5;
        var _nav_w = _nav_x2 - _nav_x1;
        var _nav_h = _nav_y2 - _nav_y1;
        var _key_w = min(58, _nav_w * 0.18);
        var _key_h = min(44, _nav_h * 0.17);
        var _key_gap_x = min(72, _nav_w * 0.22);
        var _key_gap_y = min(58, _nav_h * 0.22);

        draw_set_color(c_white);
        draw_text_transformed(_magi_cx, _nav_y1 + max(28, _nav_h * 0.14), "NAV", 1.25, 1.25, 0);

        var _keys = [
            { label: "W", dir: "n", cx: _magi_cx,              cy: _magi_cy - _key_gap_y },
            { label: "A", dir: "o", cx: _magi_cx - _key_gap_x, cy: _magi_cy              },
            { label: "D", dir: "l", cx: _magi_cx + _key_gap_x, cy: _magi_cy              },
            { label: "S", dir: "s", cx: _magi_cx,              cy: _magi_cy + _key_gap_y }
        ];

        for (var k = 0; k < array_length(_keys); k++) {
            var _key = _keys[k];
            var _key_selecionada = esta_carregando && charging_direction == _key.dir;
            var _kx1 = _key.cx - (_key_w * 0.5);
            var _ky1 = _key.cy - (_key_h * 0.5);
            var _kx2 = _key.cx + (_key_w * 0.5);
            var _ky2 = _key.cy + (_key_h * 0.5);

            draw_set_color(c_black);
            draw_rectangle(_kx1, _ky1, _kx2, _ky2, false);
            draw_set_color(_key_selecionada ? c_white : make_color_rgb(92, 92, 92));
            draw_rectangle(_kx1, _ky1, _kx2, _ky2, true);
            draw_set_color(c_white);
            draw_text_transformed(_key.cx, _key.cy, _key.label, 1.2, 1.2, 0);
        }

        draw_set_alpha(1);
    } else {
        var _button_x1 = global.ui_config.nav_x1;
        var _button_y1 = global.ui_config.nav_y1;
        var _button_x2 = global.ui_config.nav_x2;
        var _button_y2 = global.ui_config.nav_y2;

        draw_set_color(c_black);
        draw_rectangle(_button_x1, _button_y1, _button_x2, _button_y2, false);
        draw_set_color(_nav_ativo ? c_white : make_color_rgb(96, 96, 96));
        draw_rectangle(_button_x1, _button_y1, _button_x2, _button_y2, true);
        draw_set_color(make_color_rgb(42, 42, 42));
        draw_rectangle(_button_x1 + 4, _button_y1 + 4, _button_x2 - 4, _button_y2 - 4, true);
        draw_set_color(c_white);
        draw_text_transformed((_button_x1 + _button_x2) * 0.5, (_button_y1 + _button_y2) * 0.5, "NAV", 1.55, 1.55, 0);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// =========================================================================
// 4. BOTOES DO INVENTARIO + GRADE
// =========================================================================
if (estado_ui == UI_STATE.NONE && global.ui_state.menu_tab_aberto
    && global.ui_state.inventario_tela == "perks") {
    var _layout_perks = global.ui_config.inventario_perks;
    var _camadas_perks = _layout_perks.camadas_fixas;
    var _tempo_entrada = inventario_perks_tempo;
    var _entrada_duracao = inventario_perks_duracao_entrada;
    var _cartela_duracao = 0.62;
    var _painel_visivel = _tempo_entrada >= _cartela_duracao;
    var _revelacao_ativa = _painel_visivel && _tempo_entrada < _entrada_duracao;

    if (_revelacao_ativa && !surface_exists(inventario_perks_surface)) {
        inventario_perks_surface = surface_create(1920, 1080);
    }
    var _revelacao_em_surface = _revelacao_ativa && surface_exists(inventario_perks_surface);

    draw_set_alpha(1);
    draw_set_color(c_white);

    if (_revelacao_em_surface) {
        surface_set_target(inventario_perks_surface);
        draw_clear_alpha(c_black, 0);
    }

    // Cartela de transicao: um flash breve e uma imagem-base antes do inventario.
    if (_tempo_entrada < 0.06) {
        draw_set_color(make_color_rgb(184, 20, 36));
        draw_rectangle(0, 0, 1920, 1080, false);
    }
    else if (!_painel_visivel) {
        draw_set_color(c_black);
        draw_rectangle(0, 0, 1920, 1080, false);

        draw_set_color(make_color_rgb(178, 22, 39));
        draw_rectangle(0, 138, 1920, 942, false);

        // A cartela e opaca: nenhuma camada do inventario aparece por tras dela.
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text_transformed(960, 540, "INVENTARIO", 2.4, 2.4, 0);
    }

    if (_painel_visivel) {
        // A moldura azul e a base de toda a interface.
        draw_set_color(c_white);
        draw_sprite(_layout_perks.fundo_sprite, 0, 0, 0);

        // Reflexo discreto que percorre apenas os trechos azuis apos a montagem.
        if (_tempo_entrada >= _entrada_duracao) {
            var _sweep_inicio = 1.4;
            var _sweep_duracao = 1.45;
            var _sweep_ciclo = 7.5;
            var _sweep_fase = inventario_perks_tempo mod _sweep_ciclo;
            if (_sweep_fase >= _sweep_inicio && _sweep_fase < _sweep_inicio + _sweep_duracao) {
                var _sweep_t = (_sweep_fase - _sweep_inicio) / _sweep_duracao;
                var _sweep_uv = sprite_get_uvs(_layout_perks.fundo_sprite, 0);
                shader_set(shd_inventario_light_sweep);
                shader_set_uniform_f(inventario_sweep_progresso, -0.28 + (_sweep_t * 1.56));
                shader_set_uniform_f(inventario_sweep_largura, 0.16);
                shader_set_uniform_f(inventario_sweep_intensidade, 0.48);
                shader_set_uniform_f(inventario_sweep_inclinacao, 0.22);
                shader_set_uniform_f(inventario_sweep_uv, _sweep_uv[0], _sweep_uv[1], _sweep_uv[2], _sweep_uv[3]);
                draw_sprite(_layout_perks.fundo_sprite, 0, 0, 0);
                shader_reset();
            }
        }

        // A arte alterna suavemente entre as tres paletas do painel do personagem.
        var _paleta_duracao = 7.2;
        var _paleta_fase = (inventario_perks_tempo mod _paleta_duracao) / _paleta_duracao;
        shader_set(shd_inventario_flash_paleta);
        shader_set_uniform_f(inventario_flash_intensidade, 0.78);
        shader_set_uniform_f(inventario_flash_fase, _paleta_fase);
        draw_sprite(_layout_perks.painel_personagem_sprite, 0, 0, 0);
        shader_reset();

        for (var _camada_i = 0; _camada_i < array_length(_camadas_perks); _camada_i++) {
            var _camada_perk = _camadas_perks[_camada_i];
            if (_camada_perk != noone && sprite_exists(_camada_perk)) {
                draw_sprite(_camada_perk, 0, 0, 0);
            }
        }

        // A variante preta desliza sobre o titulo original quando recebe hover.
        var _titulos_laterais = _layout_perks.titulos_laterais;
        var _titulos_laterais_pretos = _layout_perks.titulos_laterais_pretos;
        var _hitboxes_titulo = _layout_perks.titulos_laterais_hitboxes;
        for (var _titulo_i = 0; _titulo_i < array_length(_titulos_laterais); _titulo_i++) {
            if (_tempo_entrada >= _entrada_duracao
                && _titulo_i < array_length(_titulos_laterais_pretos)
                && _titulo_i < array_length(inventario_titulo_hover_alpha)
                && inventario_titulo_hover_alpha[_titulo_i] > 0.01) {
                var _titulo_preto = _titulos_laterais_pretos[_titulo_i];
                var _titulo_layout = _hitboxes_titulo[_titulo_i];
                var _titulo_alpha = inventario_titulo_hover_alpha[_titulo_i];
                var _titulo_ease = 1 - power(1 - _titulo_alpha, 3);
                var _titulo_x = _titulo_layout.preto_x + lerp(-16, 14, _titulo_ease);

                if (_titulo_preto != noone && sprite_exists(_titulo_preto)) {
                    draw_sprite_ext(_titulo_preto, 0, _titulo_x, _titulo_layout.preto_y,
                        1, 1, 0, c_white, _titulo_alpha);
                }
            }

            // A fonte branca fica por cima e deixa a preta como uma sombra deslocada.
            var _titulo_sprite = _titulos_laterais[_titulo_i];
            draw_sprite(_titulo_sprite, 0, 0, 0);
        }

        var _painel_perks = _layout_perks.painel_perks;
        if (_tempo_entrada >= _entrada_duracao) {
            var _hover_perk = point_in_rectangle(_mx, _my, _painel_perks.x1, _painel_perks.y1,
                _painel_perks.x2, _painel_perks.y2);
            if ((_hover_perk || global.ui_state.perk_selecionada >= 0)
                && sprite_exists(sprite_slots_selecao)) {
                draw_sprite(sprite_slots_selecao, 0, 0, 0);
            }
        }

        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text_transformed(_layout_perks.nivel_x, _layout_perks.nivel_y,
            string(global.personagem_status.nivel), 1.6, 1.6, 0);
    }

    if (_revelacao_em_surface) {
        surface_reset_target();

        var _dissolve_duracao = _entrada_duracao - _cartela_duracao;
        var _dissolve_progresso = clamp(
            (_tempo_entrada - _cartela_duracao) / _dissolve_duracao,
            0, 1
        );

        // A cartela permanece atras dos pixels ocultos e desaparece com o dissolve.
        var _cartela_alpha = 1 - _dissolve_progresso;
        draw_set_alpha(_cartela_alpha);
        draw_set_color(c_black);
        draw_rectangle(0, 0, 1920, 1080, false);
        draw_set_color(make_color_rgb(178, 22, 39));
        draw_rectangle(0, 138, 1920, 942, false);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text_transformed(960, 540, "INVENTARIO", 2.4, 2.4, 0);

        draw_set_alpha(1);
        draw_set_color(c_white);
        shader_set(shd_inventario_noise_dissolve);
        shader_set_uniform_f(inventario_dissolve_progresso, _dissolve_progresso);
        shader_set_uniform_f(inventario_dissolve_ruido, 0.12);
        draw_surface(inventario_perks_surface, 0, 0);
        shader_reset();
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

if (estado_ui == UI_STATE.NONE && global.ui_state.menu_tab_aberto
    && global.ui_state.inventario_tela != "perks") {
    var _categoria_aberta = global.ui_state.inventario_aberto && global.ui_state.categoria_selecionada != "";

    if (!_categoria_aberta
        && (!global.ui_state.obstaculo_menu_aberto || global.ui_state.obstaculo_selecao_item_ativa)) {
        for (var i = 0; i < array_length(global.botoes_hud); i++) {
            var _btn = global.botoes_hud[i];
            var _hover = point_in_rectangle(_mx, _my, _btn.x1, _btn.y1, _btn.x2, _btn.y2);
            var _selecionado = (global.ui_state.categoria_selecionada == _btn.categoria);

            if (_hover || _selecionado) {
                draw_sprite(_btn.spr_ativo, 0, 0, 0);
            } else {
                draw_sprite(_btn.spr_apagado, 0, 0, 0);
            }
        }
    }

    if (_categoria_aberta) {
        var _panel_x = global.ui_config.inv_panel_x;
        var _panel_y = global.ui_config.inv_panel_y;
        var _panel_w = global.ui_config.inv_panel_w;
        var _panel_h = global.ui_config.inv_panel_h;
        var _cat_nome = global.ui_state.categoria_selecionada;
        var _array_alvo = scr_inventario_get_categoria(_cat_nome);
        var _titulo = scr_get_inventory_category_title(_cat_nome);
        var _modo_selecao_obstaculo = global.ui_state.obstaculo_menu_aberto && global.ui_state.obstaculo_selecao_item_ativa;
        if (_modo_selecao_obstaculo) {
            _titulo = "Escolher Item";
        }

        draw_set_alpha(0.96);
        draw_set_color(c_black);
        draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, false);
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(218, 218, 218));
        draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true);
        draw_set_color(make_color_rgb(90, 90, 90));
        draw_rectangle(_panel_x + 4, _panel_y + 4, _panel_x + _panel_w - 4, _panel_y + _panel_h - 4, true);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_white);
        draw_text_transformed(_panel_x + 20, _panel_y + 20, _titulo, 1.45, 1.45, 0);

        if (_modo_selecao_obstaculo) {
            draw_set_color(make_color_rgb(210, 210, 210));
            draw_text_ext(_panel_x + 20, _panel_y + 58,
                global.ui_state.obstaculo_menu_texto, 14, _panel_w - 120);
        }

        var _back_rect = scr_get_inventory_back_rect();
        var _hover_back = point_in_rectangle(_mx, _my, _back_rect.x1, _back_rect.y1, _back_rect.x2, _back_rect.y2);
        draw_set_color(_hover_back ? c_white : make_color_rgb(128, 128, 128));
        draw_rectangle(_back_rect.x1, _back_rect.y1, _back_rect.x2, _back_rect.y2, true);
        draw_text(_back_rect.x1 + 7, _back_rect.y1 + 4, "X");

        draw_set_color(make_color_rgb(128, 128, 128));
        draw_text(_panel_x + _panel_w - 96, _panel_y + 54,
            string(array_length(global.inventario.mochila)) + "/" + string(global.inventario.capacidade));

        var _slots_categoria = scr_get_inventory_slot_limit(_cat_nome);
        var _limite = min(array_length(_array_alvo), _slots_categoria);
        for (var i = 0; i < _slots_categoria; i++) {
            var _rect = scr_get_inventory_slot_rect(i);
            var _hover_item = point_in_rectangle(_mx, _my, _rect.x1, _rect.y1, _rect.x2, _rect.y2);

            draw_set_alpha(1);
            draw_set_color(c_black);
            draw_rectangle(_rect.x1, _rect.y1, _rect.x2, _rect.y2, false);
            draw_set_color(_hover_item ? c_white : make_color_rgb(92, 92, 92));
            draw_rectangle(_rect.x1, _rect.y1, _rect.x2, _rect.y2, true);

            if (i < _limite) {
                var _meu_item = _array_alvo[i];
                var _nome = scr_get_item_nome(_meu_item);

                if (scr_inventory_is_equipped(_meu_item)) {
                    draw_set_color(c_white);
                    draw_rectangle(_rect.x1 + 4, _rect.y1 + 4, _rect.x2 - 4, _rect.y2 - 4, true);
                    draw_text(_rect.x2 - 26, _rect.y1 + 6, "EQ");
                }

                if (variable_struct_exists(_meu_item, "sprite")
                    && _meu_item.sprite != noone && sprite_exists(_meu_item.sprite)) {
                    var _spr_w = sprite_get_width(_meu_item.sprite);
                    var _spr_h = sprite_get_height(_meu_item.sprite);
                    var _scale = min(1, 28 / max(_spr_w, _spr_h));
                    draw_sprite_ext(_meu_item.sprite, 0, _rect.x1 + 10, _rect.y1 + 10, _scale, _scale, 0, c_white, 1);
                } else {
                    draw_set_color(make_color_rgb(190, 190, 190));
                    draw_rectangle(_rect.x1 + 9, _rect.y1 + 9, _rect.x1 + 30, _rect.y1 + 30, true);
                    draw_text(_rect.x1 + 15, _rect.y1 + 12, string_copy(_nome, 1, 1));
                }

                draw_set_color(c_white);
                draw_text_ext(_rect.x1 + 7, _rect.y1 + 35, _nome, 10, global.ui_config.inv_slot_w - 10);

                if (variable_struct_exists(_meu_item, "quantidade") && _meu_item.quantidade > 1) {
                    draw_set_color(make_color_rgb(210, 210, 210));
                    draw_text(_rect.x2 - 24, _rect.y2 - 20, "x" + string(_meu_item.quantidade));
                }
            }
        }

        if (global.ui_state.item_menu_aberto && is_struct(global.ui_state.item_menu_item)) {
            var _menu_x = global.ui_state.item_menu_x;
            var _menu_y = global.ui_state.item_menu_y;
            var _menu_w = global.ui_config.inv_context_w;
            var _row_h = global.ui_config.inv_context_row_h;
            var _acoes = global.ui_state.item_menu_acoes;
            var _menu_h = array_length(_acoes) * _row_h;

            draw_set_alpha(0.92);
            draw_set_color(c_black);
            draw_rectangle(_menu_x, _menu_y, _menu_x + _menu_w, _menu_y + _menu_h, false);
            draw_set_alpha(1);
            draw_set_color(c_white);
            draw_rectangle(_menu_x, _menu_y, _menu_x + _menu_w, _menu_y + _menu_h, true);

            for (var a = 0; a < array_length(_acoes); a++) {
                var _row_y = _menu_y + (a * _row_h);
                var _hover_action = point_in_rectangle(_mx, _my, _menu_x, _row_y, _menu_x + _menu_w, _row_y + _row_h);

                if (_hover_action) {
                    draw_set_color(c_dkgray);
                    draw_rectangle(_menu_x + 1, _row_y + 1, _menu_x + _menu_w - 1, _row_y + _row_h - 1, false);
                }

                draw_set_color(c_white);
                draw_text(_menu_x + 12, _row_y + 8, scr_inventory_action_label(_acoes[a]));
            }
        }
    }
}

// =========================================================================
// 5. SISTEMA DE LOOT
// =========================================================================
if (estado_ui != UI_STATE.NONE && global.ui_state.container_atual != noone) {
    var _modelo_nome = variable_struct_exists(global.ui_state.container_atual, "modelo")
        ? global.ui_state.container_atual.modelo : "barril";
    var _modelo = scr_get_container_template(_modelo_nome);
    if (_modelo == noone) exit;

    var _loot_icon = scr_get_loot_icon_rect(_modelo);
    var _hover_loot_icon = point_in_rectangle(_mx, _my, _loot_icon.x1, _loot_icon.y1, _loot_icon.x2, _loot_icon.y2);
    var _container_nome = variable_struct_exists(global.ui_state.container_atual, "nome")
        ? global.ui_state.container_atual.nome : "Barril";

        var _loot_bg_x = global.ui_config.loot_panel_bg_x;
        var _loot_bg_y = global.ui_config.loot_panel_bg_y;
        var _loot_bg_w = global.ui_config.loot_panel_bg_w;
        var _loot_bg_h = global.ui_config.loot_panel_bg_h;

        draw_set_alpha(0.98);
        draw_set_color(c_black);
        draw_rectangle(_loot_bg_x, _loot_bg_y, _loot_bg_x + _loot_bg_w, _loot_bg_y + _loot_bg_h, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_rectangle(_loot_bg_x, _loot_bg_y, _loot_bg_x + _loot_bg_w, _loot_bg_y + _loot_bg_h, true);
        draw_set_color(make_color_rgb(72, 72, 72));
        draw_rectangle(_loot_bg_x + 4, _loot_bg_y + 4, _loot_bg_x + _loot_bg_w - 4, _loot_bg_y + _loot_bg_h - 4, true);

        if (variable_struct_exists(_modelo, "sprite_ui") && sprite_exists(_modelo.sprite_ui)) {
            draw_sprite(_modelo.sprite_ui, 0, global.ui_config.loot_panel_x, global.ui_config.loot_panel_y);
        } else {
            draw_set_alpha(0.96);
            draw_set_color(c_black);
            draw_rectangle(_loot_icon.x1, _loot_icon.y1, _loot_icon.x2, _loot_icon.y2, false);
            draw_set_alpha(1);
            draw_set_color(_hover_loot_icon ? c_white : make_color_rgb(92, 92, 92));
            draw_rectangle(_loot_icon.x1, _loot_icon.y1, _loot_icon.x2, _loot_icon.y2, true);
            draw_set_color(make_color_rgb(54, 54, 54));
            draw_rectangle(_loot_icon.x1 + 4, _loot_icon.y1 + 4, _loot_icon.x2 - 4, _loot_icon.y2 - 4, true);

            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(c_white);
            draw_text_ext((_loot_icon.x1 + _loot_icon.x2) * 0.5, (_loot_icon.y1 + _loot_icon.y2) * 0.5 - 2,
                _container_nome, 14, global.ui_config.loot_icon_w - 28);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
    }

    switch (estado_ui) {
        case UI_STATE.CONTAINER_SELECT:
        case UI_STATE.HOLD_SEARCH:
            break;

        case UI_STATE.LOOT_OPEN:
            var _sub_aba_x = global.ui_config.loot_sub_aba_x;
            var _sub_aba_y = global.ui_config.loot_sub_aba_y;
            var _loot_panel = scr_get_loot_panel_rect(_modelo);

            draw_set_alpha(0.96);
            draw_set_color(c_black);
            draw_rectangle(_loot_panel.x1, _loot_panel.y1, _loot_panel.x2, _loot_panel.y2, false);
            draw_set_alpha(1);
            draw_set_color(c_white);
            draw_rectangle(_loot_panel.x1, _loot_panel.y1, _loot_panel.x2, _loot_panel.y2, true);
            draw_set_color(make_color_rgb(72, 72, 72));
            draw_rectangle(_loot_panel.x1 + 4, _loot_panel.y1 + 4, _loot_panel.x2 - 4, _loot_panel.y2 - 4, true);

            var _rows = variable_struct_exists(_modelo, "linhas")
                ? _modelo.linhas
                : ceil(global.ui_config.loot_max_slots / max(1, _modelo.colunas));
            var _slots_total = min(global.ui_config.loot_max_slots, _modelo.colunas * _rows);
            var _lista_loot = global.ui_state.container_atual.itens_dentro;

            for (var s = 0; s < _slots_total; s++) {
                var _slot = scr_get_loot_slot_rect(_modelo, s, _sub_aba_x, _sub_aba_y);
                var _hover_slot = point_in_rectangle(_mx, _my, _slot.x1, _slot.y1, _slot.x2, _slot.y2);

                draw_set_color(c_black);
                draw_rectangle(_slot.x1, _slot.y1, _slot.x2, _slot.y2, false);
                draw_set_color(_hover_slot ? c_white : make_color_rgb(92, 92, 92));
                draw_rectangle(_slot.x1, _slot.y1, _slot.x2, _slot.y2, true);
            }

            for (var i = 0; i < array_length(_lista_loot); i++) {
                var _item_loot = _lista_loot[i];
                var _slot_item = scr_get_loot_slot_rect(_modelo, i, _sub_aba_x, _sub_aba_y);

                if (variable_struct_exists(_item_loot, "sprite")
                    && _item_loot.sprite != noone && sprite_exists(_item_loot.sprite)) {
                    var _spr_w = sprite_get_width(_item_loot.sprite);
                    var _spr_h = sprite_get_height(_item_loot.sprite);
                    var _spr_xoff = sprite_get_xoffset(_item_loot.sprite);
                    var _spr_yoff = sprite_get_yoffset(_item_loot.sprite);
                    var _scale = min(1, 46 / max(_spr_w, _spr_h));
                    var _draw_left = (_slot_item.x1 + _slot_item.x2 - (_spr_w * _scale)) * 0.5;
                    var _draw_top = (_slot_item.y1 + _slot_item.y2 - (_spr_h * _scale)) * 0.5;
                    draw_sprite_ext(_item_loot.sprite, 0,
                        _draw_left + (_spr_xoff * _scale),
                        _draw_top + (_spr_yoff * _scale),
                        _scale, _scale, 0, c_white, 1);
                }
            }
            break;
    }
}

var mostrar_hitbox_clique = false;
if (mostrar_hitbox_clique && is_struct(global.current_room)
    && variable_struct_exists(global.current_room, "itens")
    && !(variable_struct_exists(global.current_room, "contexto_auto_abrir") && global.current_room.contexto_auto_abrir)) {

    var _itens_hitbox = global.current_room.itens;

    for (var h = 0; h < array_length(_itens_hitbox); h++) {
        var _item_hitbox = _itens_hitbox[h];
        var _removido_hitbox = variable_struct_exists(_item_hitbox, "removido") && _item_hitbox.removido;

        if (!_item_hitbox.coletado && !_removido_hitbox) {
            var _hb = scr_get_item_hitbox(_item_hitbox);
            var _hitbox_manual = variable_struct_exists(_hb, "manual") && _hb.manual;
            var _tipo_hitbox = variable_struct_exists(_item_hitbox, "tipo") ? _item_hitbox.tipo : "";

            if (_hitbox_manual && (_tipo_hitbox == "cadaver" || _tipo_hitbox == "obstaculo" || _tipo_hitbox == "contexto")) {
                var _cor_hitbox = c_red;
                if (_tipo_hitbox == "obstaculo") _cor_hitbox = c_lime;
                if (_tipo_hitbox == "contexto") _cor_hitbox = c_yellow;

                draw_set_alpha(0.28);
                draw_set_color(_cor_hitbox);
                draw_rectangle(_hb.x1, _hb.y1, _hb.x2, _hb.y2, false);

                draw_set_alpha(1);
                draw_set_color(_cor_hitbox);
                draw_rectangle(_hb.x1, _hb.y1, _hb.x2, _hb.y2, true);

                draw_set_color(c_white);
                draw_text(_hb.x1 + 8, _hb.y1 + 8, _item_hitbox.nome);
            }
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

if (global.ui_state.obstaculo_menu_aberto
    && !global.ui_state.obstaculo_selecao_item_ativa) {
    var _panel_obstaculo = scr_get_obstaculo_menu_panel_rect();
    var _botao_obstaculo = scr_get_obstaculo_menu_botao_rect();
    var _hover_botao_obstaculo = point_in_rectangle(_mx, _my,
        _botao_obstaculo.x1, _botao_obstaculo.y1,
        _botao_obstaculo.x2, _botao_obstaculo.y2);
    var _selecionando_obstaculo = global.ui_state.obstaculo_selecao_item_ativa;
    var _dados_obstaculo = global.ui_state.obstaculo_menu_dados;
    var _nome_obstaculo = "Obstaculo";
    if (is_struct(_dados_obstaculo) && variable_struct_exists(_dados_obstaculo, "nome")) {
        _nome_obstaculo = _dados_obstaculo.nome;
    }

    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_rectangle(_panel_obstaculo.x1, _panel_obstaculo.y1, _panel_obstaculo.x2, _panel_obstaculo.y2, false);
    draw_set_color(make_color_rgb(126, 126, 126));
    draw_rectangle(_panel_obstaculo.x1, _panel_obstaculo.y1, _panel_obstaculo.x2, _panel_obstaculo.y2, true);
    draw_set_color(make_color_rgb(12, 12, 12));
    draw_rectangle(_panel_obstaculo.x1 + 4, _panel_obstaculo.y1 + 4, _panel_obstaculo.x2 - 4, _panel_obstaculo.y2 - 4, false);
    draw_set_color(make_color_rgb(72, 72, 72));
    draw_rectangle(_panel_obstaculo.x1 + 4, _panel_obstaculo.y1 + 4, _panel_obstaculo.x2 - 4, _panel_obstaculo.y2 - 4, true);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_text_transformed(_panel_obstaculo.x1 + 20, _panel_obstaculo.y1 + 20, "OBSTACULO", 1.35, 1.35, 0);

    draw_set_color(make_color_rgb(210, 210, 210));
    draw_text_ext(_panel_obstaculo.x1 + 20,
        _panel_obstaculo.y1 + 62,
        _nome_obstaculo,
        14,
        (_panel_obstaculo.x2 - _panel_obstaculo.x1) - 40);

    draw_set_color(c_white);
    draw_text_ext(_panel_obstaculo.x1 + 20,
        _panel_obstaculo.y1 + 130,
        global.ui_state.obstaculo_menu_texto,
        18,
        (_panel_obstaculo.x2 - _panel_obstaculo.x1) - 40);

    draw_set_alpha(_selecionando_obstaculo ? 0.55 : 1);
    draw_set_color(c_black);
    draw_rectangle(_botao_obstaculo.x1, _botao_obstaculo.y1, _botao_obstaculo.x2, _botao_obstaculo.y2, false);
    draw_set_color((_hover_botao_obstaculo && !_selecionando_obstaculo) ? c_white : make_color_rgb(92, 92, 92));
    draw_rectangle(_botao_obstaculo.x1, _botao_obstaculo.y1, _botao_obstaculo.x2, _botao_obstaculo.y2, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text((_botao_obstaculo.x1 + _botao_obstaculo.x2) * 0.5,
        (_botao_obstaculo.y1 + _botao_obstaculo.y2) * 0.5,
        _selecionando_obstaculo ? "Inventario aberto" : "Escolher item");
    draw_set_alpha(1);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

if (global.ui_state.mensagem_timer > 0 && global.ui_state.mensagem_contexto != "") {
    var _msg_x = 420;
    var _msg_y = 930;
    var _msg_w = 1080;
    var _msg_h = 86;

    draw_set_alpha(0.9);
    draw_set_color(c_black);
    draw_rectangle(_msg_x, _msg_y, _msg_x + _msg_w, _msg_y + _msg_h, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(126, 126, 126));
    draw_rectangle(_msg_x, _msg_y, _msg_x + _msg_w, _msg_y + _msg_h, true);
    draw_set_color(c_white);
    draw_text_ext(_msg_x + 22, _msg_y + 18, global.ui_state.mensagem_contexto, 18, _msg_w - 44);
}

// =========================================================================
// 6. FADE FINAL
// =========================================================================
if (fade_alpha > 0) {
    scr_draw_dither_fade(fade_alpha);
}
