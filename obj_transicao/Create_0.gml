// Variáveis padrão (serão mudadas no editor de salas)
destino = noone; 
tecla_ativacao = ord("W");

// Define os pontos de parada (âncoras)
pos_esquerda = 0;
pos_centro = 1280;
pos_direita = 2560;

// Alvo inicial (o jogo começa olhando para o centro)
target_x = pos_centro;

// Suavidade (0.1 é bem cinematográfico, 0.2 é mais responsivo)
smooth_speed = 0.1;

// Controle lateral menos sensivel.
// A camera so muda de alvo se o mouse permanecer na borda por alguns frames.
pan_edge_margin = 260;
pan_hold_delay = 8;
pan_request = 0;
pan_region = 0;
pan_hold_time = 0;

// Trava a câmera no centro no frame 1
camera_set_view_pos(view_camera[0], target_x, 0);
