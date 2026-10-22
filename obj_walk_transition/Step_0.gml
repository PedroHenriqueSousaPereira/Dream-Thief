if (!instance_exists(obj_game) || !scr_globals_ui_prontos()) exit;

var _game = obj_game;

// So permite navegacao se o fade estiver parado e nenhuma interface estiver aberta.
if (_game.fade_estado == "parado" && !_game.magi_ativo && !global.ui_state.inventario_aberto) {

    // Clique nas areas da room de transicao.
    if (room == rm_transicao && mouse_check_button_pressed(mb_left)) {
        var _cam = view_camera[0];
        var _gui_w = display_get_gui_width();
        var _gui_h = display_get_gui_height();
        var _mx_gui = device_mouse_x_to_gui(0);
        var _my_gui = device_mouse_y_to_gui(0);
        var _mx_room = camera_get_view_x(_cam) + ((_mx_gui / _gui_w) * camera_get_view_width(_cam));
        var _my_room = camera_get_view_y(_cam) + ((_my_gui / _gui_h) * camera_get_view_height(_cam));

        for (var i = 0; i < array_length(transition_click_areas); i++) {
            var _area = transition_click_areas[i];
            if (point_in_rectangle(_mx_room, _my_room, _area.x1, _area.y1, _area.x2, _area.y2)) {
                var _destino_click = _area.destino;
                var _destino_valido = (_destino_click != noone) && (is_struct(_destino_click) || room_exists(_destino_click));

                if (_destino_valido) {
                    _game.fade_alvo_sala = _destino_click;
                    _game.fade_estado = "escurecendo";
                }
                else {
                    show_debug_message("ERRO: destino invalido na area de transicao: " + _area.nome);
                }

                break;
            }
        }
    }

    // Tenta ir para frente (W).
    if (keyboard_check_pressed(ord("W"))) {
        if (variable_instance_exists(id, "destino_w") && destino_w != noone && is_struct(destino_w)) {
            _game.fade_alvo_sala = destino_w;
            _game.fade_estado = "escurecendo";
        } else {
            show_debug_message("ERRO: destino_w nao e uma Struct valida no obj_walk_transition!");
        }
    }

    // Tenta voltar (S).
    if (keyboard_check_pressed(ord("S"))) {
        if (variable_instance_exists(id, "destino_s") && destino_s != noone && is_struct(destino_s)) {
            _game.fade_alvo_sala = destino_s;
            _game.fade_estado = "escurecendo";
        } else {
            show_debug_message("ERRO: destino_s nao e uma Struct valida para voltar!");
        }
    }
}
