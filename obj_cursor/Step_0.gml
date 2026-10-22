// 1. Seguir o mouse na interface (GUI)
x = device_mouse_x_to_gui(0);
y = device_mouse_y_to_gui(0);

var _move_dist = point_distance(x, y, trail_last_x, trail_last_y);
if (_move_dist >= trail_min_distance) {
    array_insert(trail_positions, 0, {
        x : trail_last_x,
        y : trail_last_y,
        life : 1
    });

    while (array_length(trail_positions) > trail_length) {
        array_delete(trail_positions, array_length(trail_positions) - 1, 1);
    }

    trail_last_x = x;
    trail_last_y = y;
} else {
    for (var t = array_length(trail_positions) - 1; t >= 0; t--) {
        var _trail = trail_positions[t];
        _trail.life -= trail_idle_fade;

        if (_trail.life <= 0) {
            array_delete(trail_positions, t, 1);
        } else {
            trail_positions[t] = _trail;
        }
    }
}

// 2. Lógica de feedback visual (Hover inteligente)
var _hovering = false;

if (instance_exists(obj_game) && scr_globals_ui_prontos()) {
    var _game = obj_game;
    
    // a. Verifica hover no botão NAV
    var _mouse_no_nav = point_in_rectangle(x, y,
        global.ui_config.nav_x1, global.ui_config.nav_y1,
        global.ui_config.nav_x2, global.ui_config.nav_y2);
        
    if (_mouse_no_nav && _game.estado_ui == UI_STATE.NONE && !global.ui_state.menu_tab_aberto
        && !global.ui_state.obstaculo_menu_aberto && !scr_contexto_ativo()) {
        _hovering = true;
    }
    
    // b. Verifica hover em botões do inventário
    var _categoria_aberta = global.ui_state.inventario_aberto && global.ui_state.categoria_selecionada != "";

    if (!_hovering && _game.estado_ui == UI_STATE.NONE && global.ui_state.menu_tab_aberto && !_categoria_aberta) {
        for (var i = 0; i < array_length(global.botoes_hud); i++) {
            var _btn = global.botoes_hud[i];
            if (point_in_rectangle(x, y, _btn.x1, _btn.y1, _btn.x2, _btn.y2)) {
                _hovering = true;
                break;
            }
        }
    }
    
    if (!_hovering && _game.estado_ui == UI_STATE.NONE && global.ui_state.menu_tab_aberto
        && _categoria_aberta) {

        var _back_rect = scr_get_inventory_back_rect();
        if (point_in_rectangle(x, y, _back_rect.x1, _back_rect.y1, _back_rect.x2, _back_rect.y2)) {

            _hovering = true;
        }

        if (!_hovering && global.ui_state.item_menu_aberto) {
            var _menu_x = global.ui_state.item_menu_x;
            var _menu_y = global.ui_state.item_menu_y;
            var _menu_w = global.ui_config.inv_context_w;
            var _menu_h = array_length(global.ui_state.item_menu_acoes) * global.ui_config.inv_context_row_h;

            if (point_in_rectangle(x, y, _menu_x, _menu_y, _menu_x + _menu_w, _menu_y + _menu_h)) {
                _hovering = true;
            }
        }

        if (!_hovering) {
            var _array_alvo = scr_inventario_get_categoria(global.ui_state.categoria_selecionada);
            var _limite = min(array_length(_array_alvo), scr_get_inventory_slot_limit(global.ui_state.categoria_selecionada));
            for (var s = 0; s < _limite; s++) {
                var _slot_rect = scr_get_inventory_slot_rect(s);
                if (point_in_rectangle(x, y, _slot_rect.x1, _slot_rect.y1, _slot_rect.x2, _slot_rect.y2)) {
                    _hovering = true;
                    break;
                }
            }
        }
    }

    // c. Verifica hover em itens interativos do cenário
    if (!_hovering && global.ui_state.obstaculo_menu_aberto
        && !global.ui_state.obstaculo_selecao_item_ativa) {
        var _botao_obstaculo = scr_get_obstaculo_menu_botao_rect();
        if (point_in_rectangle(x, y,
            _botao_obstaculo.x1, _botao_obstaculo.y1,
            _botao_obstaculo.x2, _botao_obstaculo.y2)) {
            _hovering = true;
        }
    }

    if (!_hovering && scr_contexto_ativo() && !scr_contexto_aguardando_item()) {
        var _back_contexto = scr_get_contexto_back_rect();
        if (point_in_rectangle(x, y,
            _back_contexto.x1, _back_contexto.y1,
            _back_contexto.x2, _back_contexto.y2)) {
            _hovering = true;
        }

        var _contexto_dados = global.contexto_interacao.dados;
        if (!_hovering && is_struct(_contexto_dados) && variable_struct_exists(_contexto_dados, "elementos")) {
            var _contexto_elemento_index = 0;
            for (var ce = 0; ce < array_length(_contexto_dados.elementos); ce++) {
                var _elemento = _contexto_dados.elementos[ce];
                if (variable_struct_exists(_elemento, "id") && _elemento.id == "voltar") {
                    continue;
                }

                var _elemento_rect = scr_get_contexto_elemento_rect(_contexto_elemento_index);
                _contexto_elemento_index += 1;
                if (point_in_rectangle(x, y,
                    _elemento_rect.x1, _elemento_rect.y1,
                    _elemento_rect.x2, _elemento_rect.y2)) {
                    _hovering = true;
                    break;
                }
            }
        }

        if (!_hovering) {
            var _elemento_atual = scr_contexto_get_elemento_atual();
            var _acoes_contexto = scr_contexto_get_acoes_elemento(_elemento_atual);
            for (var ca = 0; ca < array_length(_acoes_contexto); ca++) {
                var _acao_rect = scr_get_contexto_action_rect(ca);
                if (point_in_rectangle(x, y,
                    _acao_rect.x1, _acao_rect.y1,
                    _acao_rect.x2, _acao_rect.y2)) {
                    _hovering = true;
                    break;
                }
            }
        }
    }

    if (room != rm_autopsia && !_hovering && !_mouse_no_nav && !_game.magi_ativo && !global.ui_state.inventario_aberto
        && !global.ui_state.menu_tab_aberto && !global.ui_state.obstaculo_menu_aberto
        && !scr_contexto_ativo() && _game.fade_estado == "parado" && _game.estado_ui == UI_STATE.NONE) {
        if (is_struct(global.current_room) && variable_struct_exists(global.current_room, "itens")) {
            var _itens = global.current_room.itens;
            for (var i = 0; i < array_length(_itens); i++) {
                var _item = _itens[i];
                var _removido = variable_struct_exists(_item, "removido") && _item.removido;
                if (!_item.coletado && !_removido) {
                    var _hb = scr_get_item_hitbox(_item);
                    var _hitbox_manual = variable_struct_exists(_hb, "manual") && _hb.manual;
                    if ((_hb.sprite != noone || _hitbox_manual) && point_in_rectangle(x, y, _hb.x1, _hb.y1, _hb.x2, _hb.y2)) {
                        _hovering = true;
                        break;
                    }
                }
            }
        }
    }
    
    // d. Verifica hover no container aberto (mini-barril)
    if (!_hovering && _game.estado_ui != UI_STATE.NONE && global.ui_state.container_atual != noone) {
        var _modelo_nome = variable_struct_exists(global.ui_state.container_atual, "modelo")
            ? global.ui_state.container_atual.modelo : "barril";
        var _modelo = scr_get_container_template(_modelo_nome);
        if (_modelo == noone) {
            image_index = 0;
            exit;
        }
        
        var _icon_hb = scr_get_loot_icon_rect(_modelo);
        if (point_in_rectangle(x, y, _icon_hb.x1, _icon_hb.y1, _icon_hb.x2, _icon_hb.y2)) {
            _hovering = true;
        }
        
        // e. Verifica hover nos itens de dentro do container
        if (!_hovering && _game.estado_ui == UI_STATE.LOOT_OPEN) {
            var _sub_aba_x = global.ui_config.loot_sub_aba_x;
            var _sub_aba_y = global.ui_config.loot_sub_aba_y;
            var _lista_loot = global.ui_state.container_atual.itens_dentro;
            
            for (var i = 0; i < array_length(_lista_loot); i++) {
                var _item_loot = _lista_loot[i];
                var _item_hb = scr_get_loot_slot_rect(_modelo, i, _sub_aba_x, _sub_aba_y);
                
                if (point_in_rectangle(x, y, _item_hb.x1, _item_hb.y1, _item_hb.x2, _item_hb.y2)) {
                    _hovering = true;
                    break;
                }
            }
        }
    }
}

// 3. Atualiza o frame do cursor (0 = normal, 1 = interativo)
image_index = _hovering ? 1 : 0;
