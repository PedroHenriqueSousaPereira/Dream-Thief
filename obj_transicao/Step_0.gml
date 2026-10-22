// 1. LOGICA DE MOVIMENTO (deslize)
var _current_x = camera_get_view_x(view_camera[0]);
var _new_x = lerp(_current_x, target_x, smooth_speed);
camera_set_view_pos(view_camera[0], _new_x, 0);

// 2. LOGICA DE MOUSE COM ZONA MORTA
// O mouse precisa ficar alguns frames na borda antes de trocar a direcao da camera.
var _gui_w = display_get_gui_width();
var _mouse_gui_x = device_mouse_x_to_gui(0);
var _next_request = pan_region;
var _center_left = _gui_w * 0.34;
var _center_right = _gui_w * 0.66;

if (_mouse_gui_x >= _center_left && _mouse_gui_x <= _center_right) {
    _next_request = 0;
}
else if (_mouse_gui_x <= pan_edge_margin) {
    _next_request = -1;
}
else if (_mouse_gui_x >= _gui_w - pan_edge_margin) {
    _next_request = 1;
}

if (_next_request != pan_request) {
    pan_request = _next_request;
    pan_hold_time = 0;
}
else if (pan_hold_time < pan_hold_delay) {
    pan_hold_time += 1;
}

if (pan_hold_time >= pan_hold_delay) {
    pan_region = pan_request;
}

if (pan_region < 0) {
    target_x = pos_esquerda;
}
else if (pan_region > 0) {
    target_x = pos_direita;
}
else {
    target_x = pos_centro;
}
