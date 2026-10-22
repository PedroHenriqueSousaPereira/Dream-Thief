if (!variable_global_exists("db_combate")) {
    scr_configurar_resolucao(1920, 1080, -1, "ajustar");
    scr_inicializar_mapa();
}

if (!variable_global_exists("combat") || !is_struct(global.combat) || !global.combat.ativo) {
    scr_iniciar_combate("criatura_teste_01", rm_game);
}

combat_panel_x = 1510;
combat_panel_y = 7;
combat_panel_w = 405;
combat_panel_h = 1070;

combat_cat_x = 1540;
combat_cat_y = 270;
combat_cat_w = 75;
combat_cat_h = 58;
combat_cat_gap = 15;

combat_action_x = 1540;
combat_action_y = 390;
combat_action_w = 345;
combat_action_h = 58;
combat_action_gap = 14;

combat_end_turn_x = 1540;
combat_end_turn_y = 900;
combat_end_turn_w = 345;
combat_end_turn_h = 58;

combat_back_x = 1540;
combat_back_y = 1000;
combat_back_w = 345;
combat_back_h = 48;
