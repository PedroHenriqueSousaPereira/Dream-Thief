var _gui_w = display_get_gui_width();
var _total_w = (card_w * 2) + card_gap;
var _start_x = (_gui_w - _total_w) * 0.5;

draw_set_halign(fa_center);
draw_set_valign(fa_middle);

for (var i = 0; i < array_length(option_cards); i++) {
    var _card = option_cards[i];
    var _x1 = _start_x + (i * (card_w + card_gap));
    var _y1 = card_y;
    var _x2 = _x1 + card_w;
    var _y2 = _y1 + card_h;
    var _hover = hover_option == _card.id;

    draw_set_alpha(0.88);
    draw_set_color(c_black);
    draw_rectangle(_x1, _y1, _x2, _y2, false);

    draw_set_alpha(1);
    draw_set_color(_hover ? make_color_rgb(235, 202, 138) : make_color_rgb(92, 92, 92));
    draw_rectangle(_x1, _y1, _x2, _y2, true);

    draw_set_color(make_color_rgb(34, 31, 28));
    draw_rectangle(_x1 + 4, _y1 + 4, _x2 - 4, _y2 - 4, true);

    if (_hover) {
        draw_set_alpha(0.22);
        draw_set_color(make_color_rgb(235, 171, 77));
        draw_rectangle(_x1 + 6, _y1 + 6, _x2 - 6, _y2 - 6, false);
        draw_set_alpha(1);
    }

    draw_set_color(_hover ? c_white : make_color_rgb(214, 214, 214));
    draw_text_transformed((_x1 + _x2) * 0.5, _y1 + 29, _card.title, 1.05, 1.05, 0);

    draw_set_color(_hover ? make_color_rgb(224, 190, 124) : make_color_rgb(142, 142, 142));
    draw_text_transformed((_x1 + _x2) * 0.5, _y1 + 58, _card.subtitle, 0.78, 0.78, 0);
}

draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
