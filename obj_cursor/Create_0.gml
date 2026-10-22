// Guarda contra duplicações de instâncias persistentes
if (instance_number(obj_cursor) > 1) {
    instance_destroy();
    exit;
}

window_set_cursor(cr_none); // Esconde o mouse do Windows
image_speed = 0;           // Impede que o cursor fique animando sozinho
depth = -10000;            // Garante que ele fique por cima de tudo

trail_length = 5;
trail_min_distance = 4;
trail_alpha_start = 0.42;
trail_alpha_decay = 0.075;
trail_scale_start = 0.86;
trail_scale_decay = 0.085;
trail_idle_fade = 0.08;
trail_positions = [];
trail_last_x = x;
trail_last_y = y;
