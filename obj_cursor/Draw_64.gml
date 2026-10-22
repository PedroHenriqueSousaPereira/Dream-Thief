for (var i = array_length(trail_positions) - 1; i >= 0; i--) {
    var _trail = trail_positions[i];
    var _alpha = max(0, trail_alpha_start - (i * trail_alpha_decay)) * _trail.life;
    var _scale = max(0.35, trail_scale_start - (i * trail_scale_decay));

    if (_alpha > 0) {
        draw_sprite_ext(sprite_index, image_index, _trail.x, _trail.y,
            _scale, _scale, image_angle, c_white, _alpha);
    }
}

draw_sprite_ext(sprite_index, image_index, x, y,
    image_xscale, image_yscale, image_angle, image_blend, image_alpha);
