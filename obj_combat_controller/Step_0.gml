if (!variable_global_exists("combat") || !is_struct(global.combat)) {
    scr_iniciar_combate("criatura_teste_01", rm_game);
}

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _click = mouse_check_button_pressed(mb_left);

if (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right)) {
    scr_combat_sair();
    exit;
}

if (global.combat.estado == "defense_check") {
    global.combat.defense_marker += global.combat.defense_speed;

    if (keyboard_check_pressed(vk_space)) {
		var _m = global.combat.defense_marker;
			var _resultado = "falha";

        if (_m >= 0.46 && _m <= 0.54) {
            _resultado = "perfeito";
        } else if (_m >= 0.36 && _m <= 0.64) {
            _resultado = "bom";
        } else if (_m >= 0.20 && _m <= 0.80) {
            _resultado = "ruim";
        }

        scr_combat_resolver_ataque_inimigo(_resultado);
        exit;
    }

    if (global.combat.defense_marker >= 1) {
        scr_combat_resolver_ataque_inimigo("falha");
        exit;
    }
}

if (!_click) exit;

if (point_in_rectangle(_mx, _my,
    combat_back_x, combat_back_y,
    combat_back_x + combat_back_w, combat_back_y + combat_back_h)) {
    scr_combat_sair();
    exit;
}

if (global.combat.estado == "victory" || global.combat.estado == "defeat") exit;

var _cats = ["arma", "defesa", "cura", "magia"];
for (var c = 0; c < array_length(_cats); c++) {
    var _cx = combat_cat_x + (c * (combat_cat_w + combat_cat_gap));
    if (point_in_rectangle(_mx, _my, _cx, combat_cat_y, _cx + combat_cat_w, combat_cat_y + combat_cat_h)) {
        global.combat.categoria_aberta = _cats[c];
        global.combat.pending_action_id = "";
        global.combat.mensagem = "Categoria: " + string_upper(_cats[c]) + ".";
        exit;
    }
}

if (global.combat.estado == "player_planning" || global.combat.estado == "posture_break") {
    var _partes = global.combat.inimigo.partes;
    for (var p = 0; p < array_length(_partes); p++) {
        var _part = _partes[p];
        if (point_in_rectangle(_mx, _my, _part.x1, _part.y1, _part.x2, _part.y2)) {
            global.combat.selected_part_id = _part.id;

            if (global.combat.pending_action_id != "") {
                scr_combat_planejar_acao(global.combat.pending_action_id, _part.id);
            } else {
                global.combat.mensagem = "Alvo selecionado: " + _part.nome + ".";
            }
            exit;
        }
    }

    var _acoes = scr_combat_get_acoes_categoria(global.combat.categoria_aberta);
    for (var a = 0; a < array_length(_acoes); a++) {
        var _row_y = combat_action_y + (a * (combat_action_h + combat_action_gap));
        if (point_in_rectangle(_mx, _my,
            combat_action_x, _row_y,
            combat_action_x + combat_action_w, _row_y + combat_action_h)) {

            var _action_id = _acoes[a].action_id;
            var _acao = scr_combat_get_action(_action_id);

            if (scr_combat_acao_requer_alvo(_acao)) {
                global.combat.pending_action_id = _action_id;
                global.combat.mensagem = "Escolha a parte para " + _acao.nome + ".";
            } else {
                scr_combat_planejar_acao(_action_id, global.combat.selected_part_id);
            }
            exit;
        }
    }
}

if (point_in_rectangle(_mx, _my,
    combat_end_turn_x, combat_end_turn_y,
    combat_end_turn_x + combat_end_turn_w, combat_end_turn_y + combat_end_turn_h)) {

    if (global.combat.estado == "enemy_phase") {
        scr_combat_enemy_turn();
    } else {
        scr_combat_resolver_planejamento();
    }
    exit;
}
