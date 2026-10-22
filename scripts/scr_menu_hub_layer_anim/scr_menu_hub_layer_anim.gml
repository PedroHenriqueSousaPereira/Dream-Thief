gml_pragma("MarkTagAsUsed", "menu_hub");

function scr_menu_hub_layer_anim_create(_sprite_name, _animated, _hold_time, _fade_time, _alpha) {
    hub_sprite_name = _sprite_name;
    hub_sprite = asset_get_index(hub_sprite_name);
    hub_animated = _animated;

    if (hub_sprite == -1) {
        sprite_index = -1;
        visible = false;
        exit;
    }

    sprite_index = hub_sprite;
    visible = true;
    image_speed = 0;
    image_index = 0;
    image_alpha = _alpha;

    hub_frame = 0;
    hub_next_frame = 0;
    hub_dir = 1;
    hub_timer = 0;
    hub_hold_time = _hold_time;
    hub_fade_time = _fade_time;
    hub_fade_alpha = 0;
    hub_transitioning = false;
}

function scr_menu_hub_layer_anim_step() {
    if (!visible || sprite_index == -1 || !hub_animated || image_number <= 1) {
        image_index = 0;
        exit;
    }

    var _dt = delta_time / 1000000;

    if (hub_transitioning) {
        hub_timer += _dt;
        hub_fade_alpha = clamp(hub_timer / hub_fade_time, 0, 1);

        if (hub_timer >= hub_fade_time) {
            hub_frame = hub_next_frame;
            image_index = hub_frame;
            hub_timer = 0;
            hub_fade_alpha = 0;
            hub_transitioning = false;

            if (hub_frame >= image_number - 1) {
                hub_dir = -1;
            } else if (hub_frame <= 0) {
                hub_dir = 1;
            }
        }

        exit;
    }

    hub_timer += _dt;

    if (hub_timer >= hub_hold_time) {
        hub_timer = 0;

        if (hub_frame >= image_number - 1) {
            hub_dir = -1;
        } else if (hub_frame <= 0) {
            hub_dir = 1;
        }

        hub_next_frame = clamp(hub_frame + hub_dir, 0, image_number - 1);
        hub_transitioning = true;
    }
}

function scr_menu_hub_layer_anim_draw() {
    if (!visible || sprite_index == -1) {
        exit;
    }

    if (!hub_animated || image_number <= 1) {
        draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
        exit;
    }

    var _from_frame = clamp(hub_frame, 0, image_number - 1);
    var _to_frame = clamp(hub_next_frame, 0, image_number - 1);
    var _fade = clamp(hub_fade_alpha, 0, 1);

    draw_sprite_ext(sprite_index, _from_frame, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha);

    if (_fade > 0) {
        draw_sprite_ext(sprite_index, _to_frame, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha * _fade);
    }
}
