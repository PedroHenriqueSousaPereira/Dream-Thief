// =============================================================================
// obj_autopsia_controller - STEP EVENT
// =============================================================================

if (!is_struct(autopsia_data)) {
    exit;
}

if (sair_solicitado) {
    if (instance_exists(obj_game) && obj_game.fade_estado == "parado") {
        obj_game.fade_alvo_sala = global.autopsia_retorno_sala_logica;
        if (obj_game.fade_alvo_sala == noone) {
            obj_game.fade_alvo_sala = rm_game;
        }
        obj_game.fade_estado = "escurecendo";
    }
    else if (!instance_exists(obj_game)) {
        room_goto(rm_game);
    }
    exit;
}

if (instance_exists(obj_game) && obj_game.fade_estado != "parado") {
    hover_parte = "";
    hover_voltar = false;
    exit;
}

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

var _painel_x1 = global.ui_config.nav_table_x;
var _painel_y1 = global.ui_config.nav_table_y;
var _painel_x2 = _painel_x1 + global.ui_config.nav_table_w;
var _painel_y2 = _painel_y1 + global.ui_config.nav_table_h;
var _mouse_no_painel = point_in_rectangle(_mx, _my, _painel_x1, _painel_y1, _painel_x2, _painel_y2);

var _imagem_w = 1920;
var _imagem_h = 1080;
if (variable_struct_exists(autopsia_data, "background") && sprite_exists(autopsia_data.background)) {
    _imagem_w = sprite_get_width(autopsia_data.background);
    _imagem_h = sprite_get_height(autopsia_data.background);
}

if (autopsia_liberada && !_mouse_no_painel) {
    var _zoom_antigo = autopsia_zoom_alvo;
    var _zoom_novo = autopsia_zoom_alvo;

    if (mouse_wheel_up()) {
        _zoom_novo = min(2.5, autopsia_zoom_alvo + 0.25);
    }
    if (mouse_wheel_down()) {
        _zoom_novo = max(1, autopsia_zoom_alvo - 0.25);
    }

    if (_zoom_novo != _zoom_antigo) {
        var _mundo_mouse_x = (_mx - autopsia_pan_x) / max(0.01, _zoom_antigo);
        var _mundo_mouse_y = (_my - autopsia_pan_y) / max(0.01, _zoom_antigo);

        autopsia_zoom_alvo = _zoom_novo;
        autopsia_pan_x = _mx - (_mundo_mouse_x * autopsia_zoom_alvo);
        autopsia_pan_y = _my - (_mundo_mouse_y * autopsia_zoom_alvo);
    }
}

autopsia_zoom = autopsia_zoom_alvo;

var _area_visivel_w = global.ui_config.nav_table_x;
var _area_visivel_h = 1080;
var _pan_min_x = min(0, _area_visivel_w - (_imagem_w * autopsia_zoom));
var _pan_min_y = min(0, _area_visivel_h - (_imagem_h * autopsia_zoom));
autopsia_pan_x = clamp(autopsia_pan_x, _pan_min_x, 0);
autopsia_pan_y = clamp(autopsia_pan_y, _pan_min_y, 0);

if (autopsia_liberada && !_mouse_no_painel && mouse_check_button_pressed(mb_left)) {
    autopsia_arrastando = true;
    autopsia_arrastou = false;
    autopsia_drag_inicio_x = _mx;
    autopsia_drag_inicio_y = _my;
    autopsia_drag_ultimo_x = _mx;
    autopsia_drag_ultimo_y = _my;
}

if (autopsia_arrastando) {
    if (mouse_check_button(mb_left)) {
        var _drag_dx = _mx - autopsia_drag_ultimo_x;
        var _drag_dy = _my - autopsia_drag_ultimo_y;
        var _dist_drag = point_distance(_mx, _my, autopsia_drag_inicio_x, autopsia_drag_inicio_y);

        if (_dist_drag > 4) {
            autopsia_arrastou = true;
        }

        if (autopsia_arrastou) {
            autopsia_pan_x += _drag_dx;
            autopsia_pan_y += _drag_dy;
            autopsia_pan_x = clamp(autopsia_pan_x, _pan_min_x, 0);
            autopsia_pan_y = clamp(autopsia_pan_y, _pan_min_y, 0);
        }

        autopsia_drag_ultimo_x = _mx;
        autopsia_drag_ultimo_y = _my;
    } else {
        autopsia_arrastando = false;
    }
}

var _input_mx = (_mx - autopsia_pan_x) / max(0.01, autopsia_zoom);
var _input_my = (_my - autopsia_pan_y) / max(0.01, autopsia_zoom);

hover_voltar = false;
hover_acao = "";
var _acao_x1 = _painel_x1 + 24;
var _acao_x2 = _painel_x2 - 24;
var _acao_h = 58;
var _acao_voltar_y1 = _painel_y2 - 280;
var _acao_olhar_y1 = _painel_y2 - 206;
var _acao_check_y1 = _painel_y2 - 132;

if (point_in_rectangle(_mx, _my, _acao_x1, _acao_voltar_y1, _acao_x2, _acao_voltar_y1 + _acao_h)) {
    hover_acao = "voltar";
}
else if (point_in_rectangle(_mx, _my, _acao_x1, _acao_olhar_y1, _acao_x2, _acao_olhar_y1 + _acao_h)) {
    hover_acao = "olhar";
}
else if (point_in_rectangle(_mx, _my, _acao_x1, _acao_check_y1, _acao_x2, _acao_check_y1 + _acao_h)) {
    hover_acao = "checagem";
}

hover_parte = "";

if (autopsia_liberada && !_mouse_no_painel) {
    for (var i = 0; i < array_length(autopsia_data.partes); i++) {
        var _parte = autopsia_data.partes[i];
        var _bloqueada = variable_struct_exists(_parte, "requer_parte")
            && (!variable_struct_exists(partes_examinadas, _parte.requer_parte)
                || !partes_examinadas[$ _parte.requer_parte]);

        if (_bloqueada) {
            continue;
        }

        if (point_in_rectangle(_input_mx, _input_my, _parte.x1, _parte.y1, _parte.x2, _parte.y2)) {
            hover_parte = _parte.id;
            break;
        }
    }
}

if (keyboard_check_pressed(vk_escape)) {
    sair_solicitado = true;
    exit;
}

if (mouse_check_button_pressed(mb_left)) {
    if (hover_acao == "voltar") {
        sair_solicitado = true;
        exit;
    }

    if (hover_acao == "olhar") {
        if (!autopsia_liberada) {
            autopsia_liberada = true;
            texto_atual = "Voce se aproxima do corpo. Agora pode examinar partes e usar o zoom.";
        } else {
            texto_atual = "Voce ja esta examinando o corpo.";
        }
        exit;
    }

    if (hover_acao == "checagem") {
        exit;
    }

}

if (mouse_check_button_released(mb_left)) {
    if (autopsia_liberada && !_mouse_no_painel && !autopsia_arrastou && hover_parte != "") {
        for (var j = 0; j < array_length(autopsia_data.partes); j++) {
            var _parte_clicada = autopsia_data.partes[j];

            if (_parte_clicada.id == hover_parte) {
                texto_atual = _parte_clicada.texto;
                partes_examinadas[$ _parte_clicada.id] = true;

                if (variable_struct_exists(_parte_clicada, "recompensa")) {
                    var _ja_coletou = variable_struct_exists(itens_coletados, _parte_clicada.id)
                        && itens_coletados[$ _parte_clicada.id];
                    var _coleta_habilitada = variable_struct_exists(_parte_clicada, "coleta_habilitada")
                        && _parte_clicada.coleta_habilitada;

                    if (!_ja_coletou && _coleta_habilitada) {
                        var _coletou = scr_coletar_item({
                            base : _parte_clicada.recompensa
                        });

                        if (_coletou) {
                            itens_coletados[$ _parte_clicada.id] = true;

                            if (_parte_clicada.recompensa == "faca_gasta") {
                                global.pode_cortar_teias = true;
                            }
                        }
                    }
                }

                break;
            }
        }
    }
}
