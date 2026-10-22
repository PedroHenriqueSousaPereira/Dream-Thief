if (!variable_global_exists("combat") || !is_struct(global.combat)) exit;

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

draw_set_alpha(1);
draw_set_color(c_black);
draw_rectangle(0, 0, 1920, 1080, false);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_text_transformed(40, 30, "COMBATE TESTE", 1.8, 1.8, 0);

var _enemy = global.combat.inimigo;

// Painel principal do inimigo.
draw_set_color(make_color_rgb(28, 28, 28));
draw_rectangle(70, 95, 1440, 1015, false);
draw_set_color(make_color_rgb(84, 84, 84));
draw_rectangle(70, 95, 1440, 1015, true);

draw_set_color(c_white);
draw_text_transformed(100, 125, _enemy.nome, 1.45, 1.45, 0);

var _hp_w = 520;
var _hp_rate = _enemy.hp / max(1, _enemy.hp_max);
draw_set_color(make_color_rgb(70, 16, 16));
draw_rectangle(100, 180, 100 + _hp_w, 208, false);
draw_set_color(make_color_rgb(190, 38, 38));
draw_rectangle(100, 180, 100 + (_hp_w * _hp_rate), 208, false);
draw_set_color(c_white);
draw_rectangle(100, 180, 100 + _hp_w, 208, true);
draw_text(635, 184, "HP " + string(_enemy.hp) + "/" + string(_enemy.hp_max));

var _vigor_rate = _enemy.vigor / max(1, _enemy.vigor_max);
draw_set_color(make_color_rgb(62, 50, 12));
draw_rectangle(100, 222, 100 + _hp_w, 250, false);
draw_set_color(make_color_rgb(218, 172, 28));
draw_rectangle(100, 222, 100 + (_hp_w * _vigor_rate), 250, false);
draw_set_color(c_white);
draw_rectangle(100, 222, 100 + _hp_w, 250, true);
draw_text(635, 226, "VIGOR " + string(_enemy.vigor) + "/" + string(_enemy.vigor_max));

// Corpo clicavel por partes.
var _partes = _enemy.partes;
for (var p = 0; p < array_length(_partes); p++) {
    var _part = _partes[p];
    var _hover = point_in_rectangle(_mx, _my, _part.x1, _part.y1, _part.x2, _part.y2);
    var _selected = global.combat.selected_part_id == _part.id;
    var _destroyed = _part.estado == "destruida";

    if (_destroyed) {
        draw_set_color(make_color_rgb(58, 20, 20));
    } else if (_selected) {
        draw_set_color(make_color_rgb(120, 95, 20));
    } else if (_hover) {
        draw_set_color(make_color_rgb(74, 74, 74));
    } else {
        draw_set_color(make_color_rgb(42, 42, 42));
    }
    draw_rectangle(_part.x1, _part.y1, _part.x2, _part.y2, false);

    draw_set_color(_selected ? c_white : make_color_rgb(128, 128, 128));
    draw_rectangle(_part.x1, _part.y1, _part.x2, _part.y2, true);

    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text((_part.x1 + _part.x2) * 0.5, (_part.y1 + _part.y2) * 0.5 - 12, _part.nome);
    draw_text((_part.x1 + _part.x2) * 0.5, (_part.y1 + _part.y2) * 0.5 + 12, "HP " + string(_part.hp) + "/" + string(_part.hp_max));
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Defesa ativa.
if (global.combat.estado == "defense_check") {
    var _bar_x = 315;
    var _bar_y = 765;
    var _bar_w = 880;
    var _bar_h = 44;
    var _marker_x = _bar_x + (_bar_w * clamp(global.combat.defense_marker, 0, 1));

    draw_set_color(make_color_rgb(18, 18, 18));
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
    draw_set_color(make_color_rgb(120, 120, 120));
    draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, true);

    draw_set_color(make_color_rgb(70, 70, 70));
    draw_rectangle(_bar_x + (_bar_w * 0.36), _bar_y + 4, _bar_x + (_bar_w * 0.64), _bar_y + _bar_h - 4, false);
    draw_set_color(make_color_rgb(210, 210, 210));
    draw_rectangle(_bar_x + (_bar_w * 0.46), _bar_y + 4, _bar_x + (_bar_w * 0.54), _bar_y + _bar_h - 4, false);

    draw_set_color(c_white);
    draw_rectangle(_marker_x - 3, _bar_y - 8, _marker_x + 3, _bar_y + _bar_h + 8, false);
    draw_text(_bar_x, _bar_y - 34, "DEFESA ATIVA");
}

// Mensagem.
draw_set_color(make_color_rgb(12, 12, 12));
draw_rectangle(100, 870, 1410, 980, false);
draw_set_color(make_color_rgb(90, 90, 90));
draw_rectangle(100, 870, 1410, 980, true);
draw_set_color(c_white);
draw_text_ext(125, 900, global.combat.mensagem, 18, 1220);

// Painel direito.
draw_set_color(c_black);
draw_rectangle(combat_panel_x, combat_panel_y, combat_panel_x + combat_panel_w, combat_panel_y + combat_panel_h, false);
draw_set_color(make_color_rgb(84, 84, 84));
draw_rectangle(combat_panel_x, combat_panel_y, combat_panel_x + combat_panel_w, combat_panel_y + combat_panel_h, true);

draw_set_color(c_white);
draw_text_transformed(combat_panel_x + 30, combat_panel_y + 34, "TURNO " + string(global.combat.turno), 1.35, 1.35, 0);
draw_text(combat_panel_x + 30, combat_panel_y + 92, "Estado: " + global.combat.estado);
draw_text(combat_panel_x + 30, combat_panel_y + 128, "AP: " + string(global.combat.action_points) + "/" + string(global.combat.action_max));
draw_text(combat_panel_x + 30, combat_panel_y + 164, "HP Jogador: " + string(global.combat.jogador_hp) + "/" + string(global.combat.jogador_hp_max));

var _selected_part = scr_combat_get_part(global.combat.selected_part_id);
var _selected_part_name = _selected_part == noone ? "Nenhum" : _selected_part.nome;
draw_text(combat_panel_x + 30, combat_panel_y + 200, "Alvo: " + _selected_part_name);

if (global.combat.pending_action_id != "") {
    var _pending = scr_combat_get_action(global.combat.pending_action_id);
    if (_pending != noone) {
        draw_set_color(make_color_rgb(210, 210, 210));
        draw_text(combat_panel_x + 30, combat_panel_y + 232, "Escolha alvo para: " + _pending.nome);
    }
}

// Quatro categorias do personagem.
var _cats = [
    { id: "arma", label: "ARMA" },
    { id: "defesa", label: "DEF" },
    { id: "cura", label: "CURA" },
    { id: "magia", label: "MAG" }
];

for (var c = 0; c < array_length(_cats); c++) {
    var _cat = _cats[c];
    var _cx = combat_cat_x + (c * (combat_cat_w + combat_cat_gap));
    var _hover_cat = point_in_rectangle(_mx, _my, _cx, combat_cat_y, _cx + combat_cat_w, combat_cat_y + combat_cat_h);
    var _active_cat = global.combat.categoria_aberta == _cat.id;

    draw_set_color(_active_cat ? make_color_rgb(86, 86, 86) : make_color_rgb(24, 24, 24));
    draw_rectangle(_cx, combat_cat_y, _cx + combat_cat_w, combat_cat_y + combat_cat_h, false);
    draw_set_color(_hover_cat || _active_cat ? c_white : make_color_rgb(116, 116, 116));
    draw_rectangle(_cx, combat_cat_y, _cx + combat_cat_w, combat_cat_y + combat_cat_h, true);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(_cx + (combat_cat_w * 0.5), combat_cat_y + (combat_cat_h * 0.5), _cat.label);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Acoes da categoria aberta.
draw_set_color(c_white);
draw_text_transformed(combat_panel_x + 30, combat_panel_y + 350, string_upper(global.combat.categoria_aberta), 1.1, 1.1, 0);

if (global.combat.estado == "player_planning" || global.combat.estado == "posture_break") {
    var _acoes = scr_combat_get_acoes_categoria(global.combat.categoria_aberta);

    if (array_length(_acoes) <= 0) {
        draw_set_color(make_color_rgb(150, 150, 150));
        draw_text(combat_action_x, combat_action_y + 12, "Nada disponivel");
    }

    for (var a = 0; a < array_length(_acoes); a++) {
        var _acao = scr_combat_get_action(_acoes[a].action_id);
        if (_acao == noone) continue;

        var _row_y = combat_action_y + (a * (combat_action_h + combat_action_gap));
        var _hover_action = point_in_rectangle(_mx, _my,
            combat_action_x, _row_y,
            combat_action_x + combat_action_w, _row_y + combat_action_h);

        draw_set_color(_hover_action ? make_color_rgb(72, 72, 72) : make_color_rgb(24, 24, 24));
        draw_rectangle(combat_action_x, _row_y, combat_action_x + combat_action_w, _row_y + combat_action_h, false);
        draw_set_color(c_white);
        draw_rectangle(combat_action_x, _row_y, combat_action_x + combat_action_w, _row_y + combat_action_h, true);
        draw_text(combat_action_x + 18, _row_y + 12, _acao.nome);
        draw_text(combat_action_x + 245, _row_y + 12, "AP " + string(_acao.custo));
    }
} else {
    draw_set_color(make_color_rgb(150, 150, 150));
    draw_text(combat_action_x, combat_action_y + 12, "Acoes bloqueadas nesta fase");
}

// Fila planejada.
draw_set_color(c_white);
draw_text(combat_panel_x + 30, 650, "PLANEJADO");
var _planos = global.combat.acoes_planejadas;
for (var q = 0; q < min(5, array_length(_planos)); q++) {
    var _plano = _planos[q];
    var _acao_plano = scr_combat_get_action(_plano.action_id);
    var _part_plano = scr_combat_get_part(_plano.part_id);
    var _nome_acao = _acao_plano == noone ? _plano.action_id : _acao_plano.nome;
    var _nome_parte = _part_plano == noone ? "" : " > " + _part_plano.nome;
    draw_text(combat_panel_x + 30, 682 + (q * 26), string(q + 1) + ". " + _nome_acao + _nome_parte);
}

var _hover_end = point_in_rectangle(_mx, _my,
    combat_end_turn_x, combat_end_turn_y,
    combat_end_turn_x + combat_end_turn_w, combat_end_turn_y + combat_end_turn_h);
var _button_label = "Executar planejamento";
if (global.combat.estado == "enemy_phase") _button_label = "Fase inimiga";
if (global.combat.estado == "defense_check") _button_label = "Clique na defesa";

draw_set_color(_hover_end ? make_color_rgb(72, 72, 72) : make_color_rgb(24, 24, 24));
draw_rectangle(combat_end_turn_x, combat_end_turn_y, combat_end_turn_x + combat_end_turn_w, combat_end_turn_y + combat_end_turn_h, false);
draw_set_color(c_white);
draw_rectangle(combat_end_turn_x, combat_end_turn_y, combat_end_turn_x + combat_end_turn_w, combat_end_turn_y + combat_end_turn_h, true);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(combat_end_turn_x + (combat_end_turn_w * 0.5), combat_end_turn_y + (combat_end_turn_h * 0.5), _button_label);

var _hover_back = point_in_rectangle(_mx, _my,
    combat_back_x, combat_back_y,
    combat_back_x + combat_back_w, combat_back_y + combat_back_h);
draw_set_color(_hover_back ? make_color_rgb(72, 72, 72) : make_color_rgb(24, 24, 24));
draw_rectangle(combat_back_x, combat_back_y, combat_back_x + combat_back_w, combat_back_y + combat_back_h, false);
draw_set_color(c_white);
draw_rectangle(combat_back_x, combat_back_y, combat_back_x + combat_back_w, combat_back_y + combat_back_h, true);
draw_text(combat_back_x + (combat_back_w * 0.5), combat_back_y + (combat_back_h * 0.5), "Voltar");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
