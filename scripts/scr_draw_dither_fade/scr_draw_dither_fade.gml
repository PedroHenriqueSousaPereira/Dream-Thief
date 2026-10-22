// Dithered fade reutilizavel para as transicoes de sala e telas de interface.
// A matriz Bayer preserva o aspecto de pixels ordenados sem depender de shader.
function scr_draw_dither_fade(_alpha) {
    var _fade = clamp(_alpha, 0, 1);
    if (_fade <= 0) exit;

    draw_set_alpha(1);
    draw_set_color(c_black);

    if (_fade >= 1) {
        draw_rectangle(0, 0, 1920, 1080, false);
    }
    else {
        var _bloco = 12;
        var _passos = floor(_fade * 16);
        var _bayer = [
            [0, 8, 2, 10],
            [12, 4, 14, 6],
            [3, 11, 1, 9],
            [15, 7, 13, 5]
        ];

        for (var _y = 0; _y < 1080; _y += _bloco) {
            var _linha = (_y div _bloco) mod 4;
            for (var _x = 0; _x < 1920; _x += _bloco) {
                var _coluna = (_x div _bloco) mod 4;
                if (_bayer[_linha][_coluna] < _passos) {
                    draw_rectangle(_x, _y, _x + _bloco, _y + _bloco, false);
                }
            }
        }
    }

    draw_set_alpha(1);
    draw_set_color(c_white);
}

// Revela uma sprite em blocos Bayer, mantendo o cenario anterior visivel abaixo.
function scr_draw_dither_sprite_stretched(_sprite, _alpha, _overall_alpha) {
    var _fade = clamp(_alpha, 0, 1);
    if (_fade <= 0 || _sprite == noone || !sprite_exists(_sprite)) exit;

    var _sprite_w = sprite_get_width(_sprite);
    var _sprite_h = sprite_get_height(_sprite);

    if (_fade >= 1) {
        draw_sprite_ext(_sprite, 0, 0, 0, 1920 / _sprite_w, 1080 / _sprite_h,
            0, c_white, _overall_alpha);
        exit;
    }

    var _bloco = 12;
    var _passos = floor(_fade * 16);
    var _bayer = [
        [0, 8, 2, 10],
        [12, 4, 14, 6],
        [3, 11, 1, 9],
        [15, 7, 13, 5]
    ];
    var _escala_x = 1920 / _sprite_w;
    var _escala_y = 1080 / _sprite_h;

    for (var _y = 0; _y < 1080; _y += _bloco) {
        var _linha = floor(_y / _bloco) mod 4;
        for (var _x = 0; _x < 1920; _x += _bloco) {
            var _coluna = floor(_x / _bloco) mod 4;
            if (_bayer[_linha][_coluna] < _passos) {
                draw_sprite_part_ext(_sprite, 0,
                    _x / _escala_x, _y / _escala_y,
                    _bloco / _escala_x, _bloco / _escala_y,
                    _x, _y, _escala_x, _escala_y, c_white, _overall_alpha);
            }
        }
    }
}

// Aplica a oscilacao de iluminacao somente ao desenho do cenario.
function scr_luminancia_respirar_iniciar() {
    shader_set(shd_luminancia_respirar);
    shader_set_uniform_f(global.luminancia_uniform_brilho, global.luminancia_brilho);
    shader_set_uniform_f(global.luminancia_uniform_contraste, global.luminancia_contraste);
}

function scr_luminancia_respirar_terminar() {
    shader_reset();
}
