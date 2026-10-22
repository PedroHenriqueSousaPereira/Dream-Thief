if (room == rm_transicao) exit;

camera_set_view_size(view, view_width, view_height);

var _spd = 10;
var _deadspace = 450;

var _mouse_gui_x = device_mouse_x_to_gui(0);
var _center_x = display_get_gui_width() / 2;

if (_mouse_gui_x < _center_x - _deadspace) {
    x = x - _spd;
} else if (_mouse_gui_x > _center_x + _deadspace) {
    x = x + _spd;
}

x = clamp(x, 0, max(0, room_width - view_width));
y = clamp(y, 0, max(0, room_height - view_height));

camera_set_view_pos(view, x, y);
