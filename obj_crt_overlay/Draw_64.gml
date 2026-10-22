var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// 1. Se a surface não existir, criamos do tamanho da tela inteira
if (!surface_exists(surf_scanline)) {
    surf_scanline = surface_create(_gui_w, _gui_h); 
    
    // Trava o desenho na surface
    surface_set_target(surf_scanline);
    draw_clear_alpha(c_black, 0); 
    
    draw_set_color(c_black);
    
    // Faz um loop que desenha linhas horizontais de fora a fora
    // O "_y += 4" é o espaçamento das linhas. Mude para 3 ou 5 se quiser mais juntas/separadas.
    for (var _y = 0; _y < _gui_h; _y += 4) {
        draw_line(0, _y, _gui_w, _y);
        
        // Se quiser a linha um pouco mais grossa, descomente a linha abaixo:
        // draw_line(0, _y + 1, _gui_w, _y + 1);
    }
    
    // Libera a surface
    surface_reset_target(); 
}

// 2. Desenha a surface inteira na tela uma única vez por frame!
draw_surface_ext(surf_scanline, 0, 0, 1, 1, 0, c_white, forca_scanline);