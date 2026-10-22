// =============================================================================
// obj_game - DRAW EVENT
// =============================================================================
// Mundo: fundo da sala e itens do cenario.
// Interface fica no Draw GUI.
// =============================================================================

if (!scr_globals_ui_prontos()) exit;
if (room == rm_autopsia) exit;
if (room == rm_combate_teste) exit;

if (is_struct(global.current_room)) {
    scr_luminancia_respirar_iniciar();

    if (variable_struct_exists(global.current_room, "navegacao_corredores")
        && navegacao_corredor_ativo) {
        var _hub_draw = global.current_room.navegacao_corredores;
        var _opcoes_draw = _hub_draw.opcoes;
        var _cenario_atual = _opcoes_draw[navegacao_corredor_indice].cenario;
        var _cenario_anterior = _opcoes_draw[navegacao_corredor_anterior].cenario;
        var _progresso_cenario = navegacao_corredor_alpha;

        if (navegacao_corredor_anterior != navegacao_corredor_indice && _progresso_cenario < 1) {
            draw_sprite_ext(_cenario_anterior, 0, 0, 0,
                1920 / sprite_get_width(_cenario_anterior),
                1080 / sprite_get_height(_cenario_anterior),
                0, c_white, alpha_cenario);
        }

        scr_draw_dither_sprite_stretched(_cenario_atual, _progresso_cenario,
            alpha_cenario);
    }
    else if (variable_struct_exists(global.current_room, "background")) {

        var _bg = global.current_room.background;
        var _bg_x = sprite_get_xoffset(_bg);
        var _bg_y = sprite_get_yoffset(_bg);
        var _bg_escala_x = variable_struct_exists(global.current_room, "background_escala_x") ? global.current_room.background_escala_x : 1;
        var _bg_escala_y = variable_struct_exists(global.current_room, "background_escala_y") ? global.current_room.background_escala_y : 1;

        if (variable_struct_exists(global.current_room, "layout_cenario")) {
            var _layout_cenario = global.current_room.layout_cenario;
            draw_sprite_ext(_bg, 0, _layout_cenario.x, _layout_cenario.y,
                _layout_cenario.largura / sprite_get_width(_bg),
                _layout_cenario.altura / sprite_get_height(_bg),
                0, c_white, alpha_cenario);
        } else if (variable_struct_exists(global.current_room, "background_ajustar_tela")
            && global.current_room.background_ajustar_tela) {
            draw_sprite_stretched(_bg, 0, 0, 0, 1920, 1080);
        } else {
            draw_sprite_ext(
                _bg,
                0,
                _bg_x,
                _bg_y,
                _bg_escala_x,
                _bg_escala_y,
                0,
                c_white,
                alpha_cenario
            );
        }
    }

    // Camadas animadas do cenario, alinhadas a arte-base.
    if (variable_struct_exists(global.current_room, "camadas_animadas")) {
        var _camadas_animadas = global.current_room.camadas_animadas;
        for (var _animada_i = 0; _animada_i < array_length(_camadas_animadas); _animada_i++) {
            var _camada_animada = _camadas_animadas[_animada_i];
            if (_camada_animada.sprite == noone || !sprite_exists(_camada_animada.sprite)) continue;

            if (_camada_animada.tipo == "fade_cenario") {
                var _duracao_fade = max(0.001, _camada_animada.duracao);
                var _tempo_fade = global.luminancia_tempo
                    - floor(global.luminancia_tempo / _duracao_fade) * _duracao_fade;
                var _ciclo_fade = _tempo_fade / _duracao_fade;
                var _alpha_fade = 1;

                // Entrada e saida possuem a mesma duracao para o ciclo parecer respirado.
                if (_ciclo_fade < 0.16) {
                    _alpha_fade = _ciclo_fade / 0.16;
                } else if (_ciclo_fade > 0.84) {
                    _alpha_fade = 1 - ((_ciclo_fade - 0.84) / 0.16);
                }

                draw_sprite_ext(_camada_animada.sprite, 0,
                    _camada_animada.x, _camada_animada.y,
                    _camada_animada.largura / sprite_get_width(_camada_animada.sprite),
                    _camada_animada.altura / sprite_get_height(_camada_animada.sprite),
                    0, c_white,
                    _camada_animada.alpha * _alpha_fade * alpha_cenario);
            }
        }
    }

    // Camadas fixas acima do fundo e abaixo dos itens interativos.
    if (variable_struct_exists(global.current_room, "camadas_cenario")) {
        var _camadas_cenario = global.current_room.camadas_cenario;
        for (var _camada_i = 0; _camada_i < array_length(_camadas_cenario); _camada_i++) {
            var _camada = _camadas_cenario[_camada_i];
            if (_camada.sprite != noone && sprite_exists(_camada.sprite)) {
                draw_sprite_ext(_camada.sprite, 0, _camada.x, _camada.y,
                    _camada.largura / sprite_get_width(_camada.sprite),
                    _camada.altura / sprite_get_height(_camada.sprite),
                    0, c_white, alpha_cenario);
            }
        }
    }

    scr_luminancia_respirar_terminar();

    if (room != rm_transicao
        && variable_struct_exists(global.current_room, "itens")) {

        var _itens = global.current_room.itens;

        for (var i = 0; i < array_length(_itens); i++) {

            var _item = _itens[i];

            if (_item.coletado) continue;
            if (variable_struct_exists(_item, "removido") && _item.removido) continue;

            var _hb = scr_get_item_hitbox(_item);

            if (_hb.sprite == noone) continue;

            draw_sprite_ext(
                _hb.sprite,
                0,
                _item.x,
                _item.y,
                1,
                1,
                0,
                c_white,
                alpha_cenario
            );
        }
    }


    // =========================================================
    // PAINEL E LEGENDA DA INTERAÇÃO
    // =========================================================

    if (scr_contexto_ativo()) {

        var _ctx_item = noone;

        // Procura no banco o item correspondente
        // ao elemento atualmente selecionado.
        if (variable_struct_exists(global.current_room, "itens")) {

            var _itens_ctx = global.current_room.itens;

            for (var j = 0; j < array_length(_itens_ctx); j++) {

                var _item_ctx = _itens_ctx[j];

                if (variable_struct_exists(_item_ctx, "elemento_inicial")
                    && variable_struct_exists(global.contexto_interacao, "elemento_atual")) {

                    if (_item_ctx.elemento_inicial
                        == global.contexto_interacao.elemento_atual) {

                        _ctx_item = _item_ctx;
                        break;
                    }
                }
            }
        }


        // -----------------------------------------------------
        // PAINEL
        // -----------------------------------------------------

        if (_ctx_item != noone
            && variable_struct_exists(_ctx_item, "painel_sprite")
            && _ctx_item.painel_sprite != noone) {

            draw_sprite(
                _ctx_item.painel_sprite,
                0,
                0,
                0
            );
        }


        // -----------------------------------------------------
        // LEGENDA
        // -----------------------------------------------------

        if (_ctx_item != noone
            && variable_struct_exists(_ctx_item, "legenda_sprite")
            && _ctx_item.legenda_sprite != noone) {

            draw_sprite(
                _ctx_item.legenda_sprite,
                0,
                0,
                0
            );
        }
    }
}

draw_set_alpha(1);
