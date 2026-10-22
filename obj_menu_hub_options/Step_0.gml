var _gui_w = display_get_gui_width();
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

var _total_w = (card_w * 2) + card_gap;
var _start_x = (_gui_w - _total_w) * 0.5;

hover_option = "";

for (var i = 0; i < array_length(option_cards); i++) {
    var _card = option_cards[i];
    var _x1 = _start_x + (i * (card_w + card_gap));
    var _y1 = card_y;
    var _x2 = _x1 + card_w;
    var _y2 = _y1 + card_h;

    if (point_in_rectangle(_mx, _my, _x1, _y1, _x2, _y2)) {
        hover_option = _card.id;

        if (mouse_check_button_pressed(mb_left)) {
            selected_action = _card.id;
            show_debug_message("menu_hub option: " + selected_action);
        }
    }
}
