// =============================================================================
// obj_autopsia_controller - DRAW GUI EVENT
// =============================================================================

draw_set_alpha(1);
draw_set_color(c_black);
draw_rectangle(0, 0, 1920, 1080, false);

if (!is_struct(autopsia_data)) {
    draw_set_color(c_white);
    draw_text(80, 80, texto_atual);
    exit;
}

var _draw_x = autopsia_data.draw_x;
var _draw_y = autopsia_data.draw_y;
var _zoom = autopsia_zoom;
var _pan_x = autopsia_pan_x;
var _pan_y = autopsia_pan_y;
var _draw_zoom_x = _pan_x + (_draw_x * _zoom);
var _draw_zoom_y = _pan_y + (_draw_y * _zoom);
var _scale = autopsia_data.draw_scale * _zoom;

scr_luminancia_respirar_iniciar();

if (variable_struct_exists(autopsia_data, "background")
    && sprite_exists(autopsia_data.background)) {
    draw_sprite_ext(autopsia_data.background, 0, _pan_x, _pan_y, _zoom, _zoom, 0, c_white, 1);
}

if (sprite_exists(autopsia_data.sprite_base)) {
    draw_sprite_ext(autopsia_data.sprite_base, 0, _draw_zoom_x, _draw_zoom_y, _scale, _scale, 0, c_white, 1);
}

for (var i = 0; i < array_length(autopsia_data.partes); i++) {
    var _parte = autopsia_data.partes[i];

    if (partes_examinadas[$ _parte.id]
        && variable_struct_exists(_parte, "overlay")
        && _parte.overlay != ""
        && variable_struct_exists(autopsia_data.overlays, _parte.overlay)) {

        var _overlay_sprite = autopsia_data.overlays[$ _parte.overlay];
        if (sprite_exists(_overlay_sprite)) {
            draw_sprite_ext(_overlay_sprite, 0, _draw_zoom_x, _draw_zoom_y, _scale, _scale, 0, c_white, 1);
        }
    }
}

scr_luminancia_respirar_terminar();

if (hover_parte != "") {
    for (var h = 0; h < array_length(autopsia_data.partes); h++) {
        var _hover = autopsia_data.partes[h];

        if (_hover.id == hover_parte) {
            var _hx1 = _pan_x + (_hover.x1 * _zoom);
            var _hy1 = _pan_y + (_hover.y1 * _zoom);
            var _hx2 = _pan_x + (_hover.x2 * _zoom);
            var _hy2 = _pan_y + (_hover.y2 * _zoom);

            draw_set_alpha(0.18);
            draw_set_color(make_color_rgb(175, 218, 158));
            draw_rectangle(_hx1, _hy1, _hx2, _hy2, false);
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(190, 235, 176));
            draw_rectangle(_hx1, _hy1, _hx2, _hy2, true);
            break;
        }
    }
}

var _panel_x = global.ui_config.nav_table_x;
var _panel_y = global.ui_config.nav_table_y;
var _panel_w = global.ui_config.nav_table_w;
var _panel_h = global.ui_config.nav_table_h;

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_black);
draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, false);
draw_set_color(make_color_rgb(126, 126, 126));
draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true);
draw_set_color(make_color_rgb(12, 12, 12));
draw_rectangle(_panel_x + 4, _panel_y + 4, _panel_x + _panel_w - 4, _panel_y + _panel_h - 4, false);
draw_set_color(make_color_rgb(72, 72, 72));
draw_rectangle(_panel_x + 4, _panel_y + 4, _panel_x + _panel_w - 4, _panel_y + _panel_h - 4, true);

draw_set_color(c_white);
draw_text_transformed(_panel_x + 20, _panel_y + 22, "AUTOPSIA", 1.35, 1.35, 0);
draw_set_color(make_color_rgb(210, 210, 210));
draw_text_ext(_panel_x + 20, _panel_y + 64, autopsia_data.nome, 14, _panel_w - 40);

draw_set_color(c_white);
draw_text_ext(_panel_x + 20, _panel_y + 132, texto_atual, 18, _panel_w - 40);

draw_set_color(make_color_rgb(150, 150, 150));
if (autopsia_liberada) {
    draw_text(_panel_x + 20, _panel_y + 655, "Zoom " + string(round(autopsia_zoom_alvo * 100)) + "%");
} else {
    draw_text(_panel_x + 20, _panel_y + 655, "Exame bloqueado");
}

var _acao_x1 = _panel_x + 24;
var _acao_x2 = _panel_x + _panel_w - 24;
var _acao_h = 58;
var _acao_voltar_y1 = _panel_y + _panel_h - 280;
var _acao_olhar_y1 = _panel_y + _panel_h - 206;
var _acao_check_y1 = _panel_y + _panel_h - 132;

var _acoes = [
    { id : "voltar",   label : "Voltar",          y1 : _acao_voltar_y1 },
    { id : "olhar",    label : "Olhar o corpo",  y1 : _acao_olhar_y1 },
    { id : "checagem", label : "Checagem rapida", y1 : _acao_check_y1 }
];

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
for (var a = 0; a < array_length(_acoes); a++) {
    var _acao = _acoes[a];
    var _hover_acao = (hover_acao == _acao.id);
    var _acao_desativada = (_acao.id == "checagem");

    draw_set_color(c_black);
    draw_rectangle(_acao_x1, _acao.y1, _acao_x2, _acao.y1 + _acao_h, false);
    if (_acao_desativada) {
        draw_set_color(make_color_rgb(46, 46, 46));
    } else {
        draw_set_color(_hover_acao ? c_white : make_color_rgb(92, 92, 92));
    }
    draw_rectangle(_acao_x1, _acao.y1, _acao_x2, _acao.y1 + _acao_h, true);
    draw_set_color(_acao_desativada ? make_color_rgb(118, 118, 118) : c_white);
    draw_text((_acao_x1 + _acao_x2) * 0.5, _acao.y1 + (_acao_h * 0.5), _acao.label);
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

if (instance_exists(obj_game) && obj_game.fade_alpha > 0) {
    scr_draw_dither_fade(obj_game.fade_alpha);
}
