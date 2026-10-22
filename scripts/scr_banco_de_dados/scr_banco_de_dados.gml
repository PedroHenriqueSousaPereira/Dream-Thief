// =============================================================================
// DREAM THIEF â€” BANCO DE DADOS CENTRAL (FONTE ÃšNICA DA VERDADE)
// =============================================================================
// REGRA: O banco NÃƒO executa gameplay. Ele DEFINE dados e estrutura.
//        Draw lÃª. Step processa. Banco configura.
// =============================================================================

function scr_configurar_resolucao(_w, _h, _window_scale, _modo) {
    if (argument_count < 3) _window_scale = -1;
    if (argument_count < 4) _modo = "fullscreen";

    surface_resize(application_surface, _w, _h);
    display_set_gui_size(_w, _h);

    if (_modo == "fullscreen") {
        window_set_fullscreen(true);
        return;
    }

    window_set_fullscreen(false);

    if (_modo == "ajustar") {
        var _margem_topo = 48;
        var _margem_base = 96;
        var _safe_w = display_get_width();
        var _safe_h = display_get_height() - _margem_topo - _margem_base;
        var _scale_fit = min(_safe_w / _w, _safe_h / _h);
        _scale_fit = min(1, _scale_fit);

        var _janela_w = round(_w * _scale_fit);
        var _janela_h = round(_h * _scale_fit);
        window_set_size(_janela_w, _janela_h);
        window_set_position(max(0, (_safe_w - _janela_w) * 0.5), _margem_topo);
        return;
    }

    if (_window_scale > 0) {
        window_set_size(_w * _window_scale, _h * _window_scale);
        window_set_position(max(0, (display_get_width() - window_get_width()) * 0.5), 0);
    }
}

function scr_globals_ui_prontos() {
    return variable_global_exists("ui_config")
        && variable_global_exists("ui_state")
        && variable_global_exists("botoes_hud")
        && variable_global_exists("inventario")
        && variable_global_exists("inventarios")
        && variable_global_exists("db_itens")
        && variable_global_exists("container_templates")
        && variable_global_exists("current_room");
}

function scr_get_container_template(_modelo_nome) {
    if (!variable_global_exists("container_templates")) {
        show_debug_message("ERRO: global.container_templates nao foi inicializado.");
        return noone;
    }

    if (is_string(_modelo_nome) && variable_struct_exists(global.container_templates, _modelo_nome)) {
        return global.container_templates[$ _modelo_nome];
    }

    if (variable_struct_exists(global.container_templates, "barril")) {
        show_debug_message("Aviso: template de container inexistente: " + string(_modelo_nome) + ". Usando barril.");
        return global.container_templates.barril;
    }

    return noone;
}

function scr_get_inventory_slot_limit(_categoria) {
    if (!variable_global_exists("botoes_hud")) return 999999;

    for (var i = 0; i < array_length(global.botoes_hud); i++) {
        var _btn = global.botoes_hud[i];
        if (_btn.categoria == _categoria) {
            return variable_struct_exists(_btn, "max_slots") ? _btn.max_slots : 999999;
        }
    }

    return 999999;
}

function scr_inicializar_mapa(){

    // =========================================================================
    // 1. CONFIGURAÃ‡ÃƒO GLOBAL DA UI (global.ui_config)
    // =========================================================================
    // TODAS as posiÃ§Ãµes, margens, grids e tamanhos ficam aqui.
    // Draw e Step LEEM daqui. NinguÃ©m mais define coordenadas.
    // =========================================================================
    global.ui_config = {

        // --- NAV (BotÃ£o de navegaÃ§Ã£o) ---
        nav_x1 : 1550,
        nav_y1 : 960,
        nav_x2 : 1900,
        nav_y2 : 1073,
        nav_table_x : 1510,
        nav_table_y : 7,
        nav_table_w : 405,
        nav_table_h : 1070,
        nav_portrait_x : 1530,
        nav_portrait_y : 88,
        nav_portrait_w : 365,
        nav_portrait_h : 148,
        nav_loadout_x : 1530,
        nav_loadout_y : 270,
        nav_loadout_w : 365,
        nav_loadout_h : 270,
        nav_loadout_slot_w : 90,
        nav_loadout_slot_h : 135,
        nav_loadout_gap_x  : 150,
        nav_loadout_gap_y  : 130,
        nav_loadout_mag_offset_x  : 0,
        nav_loadout_mag_offset_y  : -27,
        nav_loadout_def_offset_x  : -110,
        nav_loadout_def_offset_y  : 110,
        nav_loadout_atq_offset_x  : 110,
        nav_loadout_atq_offset_y  : 110,
        nav_loadout_cura_offset_x : 0,
        nav_loadout_cura_offset_y : 249,
		//lugar do quadrado
        nav_action_x : 1550,
		//onde o quadrado fica 
        nav_action_y : 960,
		// altura do quadrado 
        nav_action_w : 349,
		// aba da direita
        nav_action_h : 113,
		//parte debaixo

        // --- PAINEL DE LOOT (O Ãcone do Mini-Barril) ---
        loot_panel_x        : 2360,
        loot_panel_y        : 550,
        loot_panel_bg_x     : 1513,
        loot_panel_bg_y     : 5,
        loot_panel_bg_w     : 400,
        loot_panel_bg_h     : 1070,
        loot_icon_x         : 1510,
        loot_icon_y         : 425,
        loot_icon_w         : 250,
        loot_icon_h         : 84,

        // --- GRADE DE ITENS (A Sub-Aba Preta de 15 slots) ---
        loot_sub_aba_x      : 1565, 
        loot_sub_aba_y      : 400,
        loot_slot_w         : 70,
        loot_slot_h         : 70,
        loot_max_slots      : 15,

        // --- GRADE DO INVENTÃRIO ---
        inv_grid_x        : 865,
        inv_grid_y        : 700,
        inv_slot_distance : 94,
        inv_max_display   : 20,
        inv_panel_x       : 1510,
        inv_panel_y       : 425,
        inv_panel_w       : 390,
        inv_panel_h       : 648,
        inv_items_x       : 1532,
        inv_items_y       : 515,
        inv_slot_w        : 70,
        inv_slot_h        : 70,
        inv_slot_gap_x    : 10,
        inv_slot_gap_y    : 10,
        inv_slot_cols     : 4,
        inv_context_w     : 190,
        inv_context_row_h : 32,
        inventario_perks : {
            // Todas as camadas usam o canvas virtual de 1920x1080.
            fundo_sprite : sprite_fundo_azul,
            painel_personagem_sprite : sprite_painel_branco,
            camadas_fixas : [
                sprite_fundo,
                sprite_slots,
                sprite_preto,
                sprite_explicacao_perk,
                sprite_nivel,
                sprite_vermelho_nivel
            ],
            titulos_laterais : [sprite_font_arma, sprite_font_armaduras, sprite_font_acessorios],
            titulos_laterais_pretos : [
                sprite_font_arma_preto,
                sprite_font_armaduras_preto,
                sprite_font_acessorios_preto
            ],
            titulos_laterais_hitboxes : [
                { x1 : 0, y1 : 400, x2 : 390, y2 : 570, preto_x : 0, preto_y : 0 },
                { x1 : 0, y1 : 35, x2 : 470, y2 : 190, preto_x : 0, preto_y : 0 },
                { x1 : 0, y1 : 855, x2 : 440, y2 : 1080, preto_x : 0, preto_y : 0 }
            ],
            painel_perks : { x1 : 496, y1 : 432, x2 : 998, y2 : 1012 },
            controle_nivel : { x1 : 1322, y1 : 448, x2 : 1454, y2 : 899 },
            nivel_x : 1690,
            nivel_y : 930
        },
        autopsia_voltar_x : 40,
        autopsia_voltar_y : 40,
        autopsia_voltar_w : 150,
        autopsia_voltar_h : 48,
        obstaculo_menu_x : 1510,
        obstaculo_menu_y : 7,
        obstaculo_menu_w : 405,
        obstaculo_menu_h : 1070,
        obstaculo_opcao_w : 92,
        obstaculo_opcao_h : 92,
        obstaculo_opcao_gap : 26,
        obstaculo_botao_w : 300,
        obstaculo_botao_h : 56,
        encounter_panel_x : 470,
        encounter_panel_y : 230,
        encounter_panel_w : 980,
        encounter_panel_h : 560,
        encounter_button_w : 260,
        encounter_button_h : 58,
        encounter_button_gap : 42,
        contexto_panel_x : 0,
        contexto_panel_y : 0,
        contexto_panel_w : 1920,
        contexto_panel_h : 1080,
        contexto_rail_x : 14,
        contexto_rail_y : 858,
        contexto_rail_slot_w : 76,
        contexto_rail_slot_h : 82,
        contexto_rail_gap : 8,
        contexto_back_x : 18,
        contexto_back_y : 624,
        contexto_back_w : 176,
        contexto_back_h : 42,
        contexto_action_x : 18,
        contexto_action_y : 685,
        contexto_action_w : 394,
        contexto_action_h : 50,
        contexto_action_gap : 12
    };

    // =========================================================================
    // 2. ESTADO GLOBAL DA UI (global.ui_state)
    // =========================================================================
    // Separado da configuraÃ§Ã£o. Aqui ficam estados MUTÃVEIS da interface.
    // =========================================================================
    global.ui_state = {
        inventario_aberto    : false,
        menu_tab_aberto      : false,
        inventario_tela      : "",
        perk_selecionada     : -1,
        categoria_selecionada : "",
        container_atual      : noone,
        item_menu_aberto     : false,
        item_menu_item       : noone,
        item_menu_categoria  : "",
        item_menu_indice     : -1,
        item_menu_x          : 0,
        item_menu_y          : 0,
        item_menu_acoes      : [],
        mensagem_contexto    : "",
        mensagem_timer       : 0,
        obstaculo_menu_aberto : false,
        obstaculo_menu_obstaculo : noone,
        obstaculo_menu_dados : noone,
        obstaculo_menu_opcoes : [],
        obstaculo_menu_texto : "",
        obstaculo_selecao_item_ativa : false
    };

    global.autopsia_retorno_room_real = noone;
    global.autopsia_retorno_sala_logica = noone;
    global.autopsia_cadaver_atual = noone;
    global.autopsia_id_atual = "";
    global.pode_cortar_teias = false;
    global.game_state = "exploracao";
    // Estado que pertence a esta tentativa de jogo. A sala de memorias usa
    // estes dados como ponto central sem depender de uma room fisica extra.
    global.run_atual = {
        etapa : "inicio",
        sala_hub : "sala_memorias",
        escolhas_memoria : [],
        fragmentos_descobertos : [],
        nos_memoria_desbloqueados : {},
        pontos_memoria : 0
    };
    global.personagem_status = {
        nivel : 1,
        pontos_de_status : 0,
        pontos_memoria : 0
    };
    // Base do RPG. Os IDs permanecem estaveis para que eventos, pensamentos e
    // equipamentos possam consultar os mesmos atributos sem acoplamento visual.
    global.db_rpg = {
        atributos : {
            corpo      : { nome : "Corpo", descricao : "Forca fisica, resistencia e confronto direto." },
            mente      : { nome : "Mente", descricao : "Raciocinio, memoria e investigacao." },
            percepcao  : { nome : "Percepcao", descricao : "Leitura do ambiente e dos detalhes ocultos." },
            tecnica    : { nome : "Tecnica", descricao : "Operacao, reparo e conhecimento pratico." },
            vontade    : { nome : "Vontade", descricao : "Controle emocional e persistencia." },
            instinto   : { nome : "Instinto", descricao : "Reacao, intuicao e sobrevivencia." }
        },
        habilidades : {
            forca        : { nome : "Forca", atributo : "corpo" },
            resistencia  : { nome : "Resistencia", atributo : "corpo" },
            combate      : { nome : "Combate", atributo : "corpo" },
            investigacao : { nome : "Investigacao", atributo : "mente" },
            conhecimento : { nome : "Conhecimento", atributo : "mente" },
            memoria      : { nome : "Memoria", atributo : "mente" },
            observacao   : { nome : "Observacao", atributo : "percepcao" },
            audicao      : { nome : "Audicao", atributo : "percepcao" },
            intuicao     : { nome : "Intuicao", atributo : "percepcao" },
            engenharia   : { nome : "Engenharia", atributo : "tecnica" },
            medicina     : { nome : "Medicina", atributo : "tecnica" },
            eletronica   : { nome : "Eletronica", atributo : "tecnica" }
        },
        status : {
            conviccao    : { nome : "Conviccao", descricao : "Firmeza para sustentar decisoes em situacoes adversas." },
            perseveranca : { nome : "Perseveranca", descricao : "Capacidade de continuar mesmo quando a rota se fecha." },
            fragmentos   : { nome : "Fragmentos", descricao : "Memorias recuperadas que alimentam a arvore de lembrancas." }
        },
        arvore_memorias : {
            nome : "Memorias",
            descricao : "Escolhas recuperadas na area das memorias alteram esta arvore ao longo da run.",
            nos : [
                {
                    id : "fragmento_01",
                    nome : "Eco Inicial",
                    descricao : "O primeiro fragmento recuperado torna a memoria mais nitida.",
                    custo : 1,
                    requer : [],
                    efeitos : [ { grupo : "habilidades", id : "memoria", valor : 1 } ]
                },
                {
                    id : "olhar_atento",
                    nome : "Olhar Atento",
                    descricao : "Recordacoes incompletas ajudam a perceber detalhes esquecidos.",
                    custo : 1,
                    requer : [ "fragmento_01" ],
                    efeitos : [ { grupo : "habilidades", id : "observacao", valor : 1 } ]
                },
                {
                    id : "vontade_continua",
                    nome : "Vontade Continua",
                    descricao : "O passado nao define sozinho o proximo passo.",
                    custo : 1,
                    requer : [ "fragmento_01" ],
                    efeitos : [ { grupo : "status", id : "perseveranca", valor : 1 } ]
                }
            ]
        }
    };
    global.personagem_rpg = {
        atributos : {
            corpo : 1, mente : 1, percepcao : 2,
            tecnica : 1, vontade : 1, instinto : 2
        },
        habilidades : {
            forca : 0, resistencia : 0, combate : 0,
            investigacao : 1, conhecimento : 0, memoria : 0,
            observacao : 1, audicao : 0, intuicao : 1,
            engenharia : 0, medicina : 1, eletronica : 0
        },
        recursos : {
            sanidade : 100,
            sanidade_max : 100
        },
        status : {
            conviccao : 0,
            perseveranca : 0,
            fragmentos : 0
        },
        memorias : {
            pontos_disponiveis : 0,
            fragmentos : [],
            nos_desbloqueados : {},
            escolhas : []
        },
        pensamentos : [],
        condicoes   : {},
        parceiros   : [],
        relacoes    : {}
    };
    global.rpg_ultimo_teste = noone;
    global.rpg_historico_testes = [];
    global.contexto_interacao = {
        ativo          : false,
        contexto_id    : "",
        dados          : noone,
        elemento_atual : "",
        mensagem       : "",
        aguardando_item: false,
        item_alvo      : ""
    };
    global.evento_runtime = {
        ativo          : false,
        evento_id      : "",
        interacao_id   : "",
        contexto_id    : "",
        no_atual       : "",
        estado         : "",
        escolhas       : [],
        escolha_selecionada : -1,
        mensagem       : "",
        resultado      : "",
        historico      : [],
        ultimo_teste   : noone,
        apresentacao   : {
            cenario_id       : "",
            legenda_id       : "",
            acao_id          : "",
            icones_liberados : false
        },
        transicao_painel : {
            ativa      : false,
            fase       : "",
            proximo_no : "",
            alpha      : 1,
            velocidade : 0.12,
            troca_cenario : false,
            troca_legenda : false,
            troca_acao    : false
        }
    };
    global.encounter = {
        ativo        : false,
        id           : "",
        dados        : noone,
        enemy_id     : "",
        tipo         : "",
        transition   : "",
        texto        : "",
        estado       : "inativo",
        timer        : 0,
        alpha        : 0,
        auto_start   : false,
        auto_delay   : 60,
        origem_item  : noone,
        resultado    : ""
    };

    // =========================================================================
    // 3. INVENTÃRIO UNIFICADO (global.inventarios)
    // =========================================================================
    // UMA struct com sub-arrays por categoria.
    // Elimina os 10 arrays separados (inv_weapon, inv_cura, etc.)
    // =========================================================================
    global.inventario = {
        capacidade : 18,
        mochila    : [],
        equipados  : {
            weapon : noone,
            helmet : noone,
            armor  : noone,
            legs   : noone,
            boots  : noone,
            ring   : noone
        }
    };

    global.inventarios = {
        weapon      : [],
        cura        : [],
        helmet      : [],
        armor       : [],
        legs        : [],
        boots       : [],
        ring        : [],
        mapa        : [],
        consumiveis : [],
        geral       : []
    };

    // =========================================================================
    // 4. BANCO MESTRE DE ITENS (global.db_itens)
    // =========================================================================
    // Cada item Ã© definido UMA VEZ. Salas e containers referenciam por ID.
    // Template = O QUE o item Ã©. InstÃ¢ncia = O ESTADO do item.
    // =========================================================================
    global.db_itens = {

        erva_verde : {
            nome          : "Erva Verde",
            sprite_cenario : erva_verde,
            sprite_inv    : erva_icone,
            categoria     : "cura",
            tipo          : "consumivel",
            slot          : "",
            acao          : "recuperar_vida",
            valor         : 25,
            dano          : 0,
            defesa        : 0,
            stack         : 5,
            acoes_combate : ["usar_erva_verde"],
            descricao     : "Uma erva simples usada para recuperar vida."
        },

        facao_enferrujado : {
            nome          : "Facao Enferrujado",
            sprite_cenario : Sprite14,
            sprite_inv    : Sprite14,
            categoria     : "weapon",
            tipo          : "equipamento",
            slot          : "weapon",
            acao          : "equipar",
            valor         : 0,
            dano          : 6,
            defesa        : 0,
            stack         : 1,
            tipo_dano     : "corte",
            dano_vigor    : 3,
            custo_acao    : 2,
            acoes_combate : ["ataque_corte_basico"],
            descricao     : "Uma lamina gasta, mas ainda util em combate."
        },

        cadaver_escavador : {
            nome          : "Cadaver do Escavador",
            sprite_cenario : Sprite14,
            sprite_inv    : noone,
            categoria     : "geral",
            tipo          : "cadaver",
            slot          : "",
            acao          : "nenhuma",
            valor         : 0,
            dano          : 0,
            defesa        : 0,
            stack         : 1,
            interacoes    : ["inspecionar_corpo", "voltar"],
            descricao     : "Um corpo abandonado. A autopsia precisa ser feita em uma tela dedicada."
        },

        faca_gasta : {
            nome          : "Faca Gasta",
            sprite_cenario : noone,
            sprite_inv    : noone,
            categoria     : "weapon",
            tipo          : "item",
            slot          : "",
            acao          : "cortar_teias",
            valor         : 0,
            dano          : 4,
            defesa        : 0,
            stack         : 1,
            tipo_dano     : "corte",
            dano_vigor    : 2,
            custo_acao    : 2,
            acoes_combate : ["ataque_corte_basico"],
            descricao     : "Uma faca desgastada. Filamentos semelhantes a teias aderem a lamina."
        },

        elmo_velho : {
            nome          : "Elmo Velho",
            sprite_cenario : Sprite14,
            sprite_inv    : Sprite14,
            categoria     : "helmet",
            tipo          : "equipamento",
            slot          : "helmet",
            acao          : "equipar",
            valor         : 0,
            dano          : 0,
            defesa        : 2,
            stack         : 1,
            descricao     : "Um elmo velho com protecao basica."
        },

        colete_lona_toxica : {
            nome          : "Colete de Lona Toxica",
            sprite_cenario : Sprite14,
            sprite_inv    : Sprite14,
            categoria     : "armor",
            tipo          : "equipamento",
            slot          : "armor",
            acao          : "equipar",
            valor         : 0,
            dano          : 0,
            defesa        : 3,
            stack         : 1,
            descricao     : "Uma armadura improvisada de lona grossa."
        },

        anel_helion_frio : {
            nome          : "Anel de Helion Frio",
            sprite_cenario : Sprite14,
            sprite_inv    : Sprite14,
            categoria     : "ring",
            tipo          : "equipamento",
            slot          : "ring",
            acao          : "equipar",
            valor         : 0,
            dano          : 1,
            defesa        : 1,
            stack         : 1,
            descricao     : "Um anel frio que melhora levemente ataque e defesa."
        }

        // PARA ADICIONAR ITENS NOVOS: basta cadastrar aqui.
        // Nenhuma alteraÃ§Ã£o em Draw, Step, ou loot necessÃ¡ria.
        //
        // municao_pistola : {
        //      nome          : "MuniÃ§Ã£o 9mm",
        //      sprite_cenario : spr_municao,
        //      sprite_inv    : spr_municao_icone,
        //      categoria     : "consumiveis",
        //      acao          : "nenhuma",
        //      valor         : 0,
        //      stack         : 30
        // }
    };

    // =========================================================================
    // 5. SISTEMA DE HUD â€” BOTÃ•ES DO INVENTÃRIO (DATA-DRIVEN)
    // =========================================================================
    global.botoes_hud = [
        { categoria: "armor",       x1: 1520, y1: 540, x2: 1920, y2: 625, spr_ativo: armor_ativo,       spr_apagado: armor_apagado,       sprite_painel: inventario_grid_peitoral,      colunas: 5, espacamento_x: 92, espacamento_y: 92, margem_x: 963, margem_y: 354, max_slots: 4 },
        { categoria: "helmet",      x1: 1720, y1: 445, x2: 1920, y2: 530, spr_ativo: helmet_ativo,      spr_apagado: helmet_apagado,      sprite_painel: inventario_grid_helmet,      colunas: 5, espacamento_x: 92, espacamento_y: 92, margem_x: 963, margem_y: 354, max_slots: 4 },
        { categoria: "legs",        x1: 1515, y1: 635, x2: 1715, y2: 720, spr_ativo: legs_ativo,        spr_apagado: legs_apagado,        sprite_painel: inventario_grid_legs,      colunas: 5, espacamento_x: 92, espacamento_y: 92, margem_x: 963, margem_y: 354, max_slots: 4 },
        { categoria: "boots",       x1: 1725, y1: 635, x2: 1920, y2: 720, spr_ativo: boots_ativo,       spr_apagado: boots_apagado,       sprite_painel: inventario_grid_botas,      colunas: 5, espacamento_x: 92, espacamento_y: 92, margem_x: 963, margem_y: 354, max_slots: 4 },
        { categoria: "weapon",      x1: 1515, y1: 445, x2: 1715, y2: 530, spr_ativo: weapon_ativo,      spr_apagado: weapon_apagado,      sprite_painel: inventario_grid_armas,      colunas: 5, espacamento_x: 92, espacamento_y: 92, margem_x: 963, margem_y: 354, max_slots: 6 },
        { categoria: "ring",        x1: 1515, y1: 730, x2: 1715, y2: 780, spr_ativo: ring_ativo,        spr_apagado: ring_apagado,        sprite_painel: inventario_grid_ring,       colunas: 5, espacamento_x: 92, espacamento_y: 92, margem_x: 963, margem_y: 354, max_slots: 4 },
        { categoria: "cura",        x1: 1725, y1: 730, x2: 1920, y2: 780, spr_ativo: cura_ativo,        spr_apagado: cura_apagado,        sprite_painel: inventario_grid_cura,       colunas: 5, espacamento_x: 92, espacamento_y: 92, margem_x: 963, margem_y: 354, max_slots: 6 },
        { categoria: "mapa",        x1: 1515, y1: 790, x2: 1715, y2: 910, spr_ativo: mapa_ativo,        spr_apagado: mapa_apagado,        sprite_painel: inventario_grid_mapa,       colunas: 5, espacamento_x: 92, espacamento_y: 92, margem_x: 963, margem_y: 354, max_slots: 1 },
        { categoria: "consumiveis", x1: 1725, y1: 790, x2: 1920, y2: 910, spr_ativo: consumiveis_ativo, spr_apagado: consumiveis_apagado, sprite_painel: inventario_grid_consumiveis, colunas: 5, espacamento_x: 92, espacamento_y: 92, margem_x: 963, margem_y: 354, max_slots: 28 }
    ];

    // =========================================================================
    // 6. TEMPLATES DE CONTAINERS (GENÃ‰RICOS)
    // =========================================================================
    // Qualquer container novo = apenas definir template aqui.
    // Draw e Step usam a mesma lÃ³gica para TODOS os containers.
    // =========================================================================
    global.container_templates = {
        barril: {
            sprite_ui      : spr_fundo_loot,
            colunas        : 3,
            linhas         : 5,
            espacamento_x  : 90,
            espacamento_y  : 90,
            margem_x       : 20,
            margem_y       : 26
        }

        // NOVOS CONTAINERS: basta adicionar aqui.
        //
        // armario: {
        //      colunas        : 4,
        //      linhas         : 5,
        //      espacamento_x  : 48,
        //      espacamento_y  : 48,
        //      margem_x       : 30,
        //      margem_y       : 30
        // }
    };

    // =========================================================================
    // 7. DEFINIÃ‡ÃƒO DAS SALAS (DATA-DRIVEN)
    // =========================================================================
    // Itens agora referenciam o banco via "base" (ID do db_itens).
    // Dados posicionais (x, y, padding) ficam na sala (sÃ£o do CENÃRIO, nÃ£o do item).
    // =========================================================================

    global.db_autopsias = {
        escavador_01 : {
            id          : "escavador_01",
            nome        : "Cadaver do Escavador",
            background  : spr_dungeon_autopsia,
            sprite_base : main_autopsia,
            draw_x      : 0,
            draw_y      : 0,
            draw_scale  : 1,
            texto_inicial : "O corpo esta apoiado contra a parede. A capa esconde quase tudo.",

            overlays : {
                capa : spr_capa_escavador,
                mao  : spr_mao_escavador
            },

            partes : [
                {
                    id      : "capa",
                    nome    : "Capa",
                    x1      : 560,
                    y1      : 150,
                    x2      : 1360,
                    y2      : 850,
                    overlay : "capa",
                    texto   : "A capa se abre com resistencia. Por baixo dela ha marcas de campo e contaminacao seca."
                },
                {
                    id      : "mao",
                    nome    : "Mao esquerda",
                    x1      : 1020,
                    y1      : 590,
                    x2      : 1540,
                    y2      : 1010,
                    overlay : "mao",
                    requer_parte : "capa",
                    texto   : "A mao aparece sob a capa. A faca esta presa entre os dedos.",
                    recompensa : "faca_gasta",
                    coleta_habilitada : true
                }
            ]
        }
    };

    // --- SUB ABA: OBSTACULOS E ITENS ACEITOS ---
    // Cada obstaculo cataloga quais itens podem resolver o puzzle.
    global.db_obstaculos = {
        parede_teias_01 : {
            nome            : "Parede de Teias",
            texto_bloqueado : "O caminho esta bloqueado por uma massa espessa de teias.",
            texto_pergunta  : "Como voce quer cortar as teias?",
            item_necessario : "faca_gasta",
            itens_aceitos   : [
                {
                    base          : "faca_gasta",
                    nome          : "Faca Gasta",
                    uso           : "cortar",
                    texto_sucesso : "Voce corta as teias e abre passagem.",
                    texto_falha   : "Voce ainda nao tem a faca gasta."
                }
            ],
            consome_item    : false,
            texto_sucesso   : "Voce corta as teias e abre passagem.",
            texto_falha     : "Voce nao possui nada capaz de cortar isso.",
            ao_resolver     : "aguardar_porta",
            dados_extra     : {
                direcao    : "norte",
                destino_id : "sala_gerador"
            },
            encontro_apos_resolver : "emboscada_teias_01"
        }
    };

    // =========================================================================
    // SUB ABA: COMBATE DE TESTE
    // =========================================================================
    // Banco isolado para prototipar combate sem afetar exploracao, autopsia e loot.
    global.db_combate = {
        action_max : 10,
        jogador_hp_max : 40
    };

    global.db_acoes_combate = {
        ataque_corte_basico : {
            id          : "ataque_corte_basico",
            nome        : "Cortar",
            tipo        : "ataque",
            categoria   : "arma",
            custo       : 2,
            dano_hp     : 6,
            dano_vigor  : 3,
            tipo_dano   : "corte",
            requer_item : "",
            requer_alvo : true,
            texto       : "Voce corta a parte marcada."
        },

        ataque_corte_pesado : {
            id          : "ataque_corte_pesado",
            nome        : "Corte Pesado",
            tipo        : "ataque",
            categoria   : "arma",
            custo       : 4,
            dano_hp     : 10,
            dano_vigor  : 5,
            tipo_dano   : "corte",
            requer_item : "",
            requer_alvo : true,
            texto       : "Voce prepara um golpe pesado contra a parte marcada."
        },

        defender : {
            id          : "defender",
            nome        : "Defender",
            tipo        : "defesa",
            categoria   : "defesa",
            custo       : 2,
            dano_hp     : 0,
            dano_vigor  : 0,
            tipo_dano   : "defesa",
            requer_item : "",
            requer_alvo : false,
            texto       : "Voce reserva postura para se defender."
        },

        usar_erva_verde : {
            id          : "usar_erva_verde",
            nome        : "Usar Erva",
            tipo        : "cura",
            categoria   : "cura",
            custo       : 3,
            cura        : 25,
            requer_item : "erva_verde",
            requer_alvo : false,
            consome_item : true,
            texto       : "Voce usa uma erva verde."
        },

        magia_teste : {
            id          : "magia_teste",
            nome        : "Magia Teste",
            tipo        : "magia",
            categoria   : "magia",
            custo       : 3,
            dano_hp     : 5,
            dano_vigor  : 7,
            tipo_dano   : "magia",
            requer_item : "",
            requer_alvo : true,
            texto       : "Voce canaliza uma magia instavel."
        },

        executar : {
            id          : "executar",
            nome        : "Executar",
            tipo        : "execucao",
            categoria   : "arma",
            custo       : 0,
            dano_hp     : 18,
            dano_vigor  : 0,
            tipo_dano   : "execucao",
            requer_item : "",
            requer_alvo : false,
            texto       : "Voce usa a abertura e executa um golpe pesado."
        }
    };

    global.db_inimigos_combate = {
        criatura_teste_01 : {
            id        : "criatura_teste_01",
            nome      : "Criatura de Teste",
            hp_max    : 36,
            vigor_max : 20,
            ataque    : {
                nome       : "Investida",
                dano       : 8,
                dano_vigor : 2
            },
            partes : [
                {
                    id          : "cabeca",
                    nome        : "Cabeca",
                    hp_max      : 10,
                    fraquezas   : ["atordoamento"],
                    resistencias: [],
                    mod_hp      : 0.8,
                    mod_vigor   : 1.6,
                    x1          : 820,
                    y1          : 180,
                    x2          : 1100,
                    y2          : 340,
                    estado      : "intacta"
                },
                {
                    id          : "torso",
                    nome        : "Torso",
                    hp_max      : 18,
                    fraquezas   : [],
                    resistencias: ["corte"],
                    mod_hp      : 1.0,
                    mod_vigor   : 0.7,
                    x1          : 760,
                    y1          : 350,
                    x2          : 1160,
                    y2          : 660,
                    estado      : "intacta"
                },
                {
                    id          : "braco",
                    nome        : "Braco",
                    hp_max      : 12,
                    fraquezas   : ["corte"],
                    resistencias: [],
                    mod_hp      : 1.0,
                    mod_vigor   : 1.0,
                    x1          : 520,
                    y1          : 360,
                    x2          : 740,
                    y2          : 640,
                    estado      : "intacta",
                    ataques_afetados : ["Investida"]
                }
            ]
        }
    };

    // =========================================================================
    // SUB ABA: ENCONTROS
    // =========================================================================
    // Camada entre exploracao e combate. A sala dispara o encontro; o encontro
    // apresenta o evento e entrega o enemy_id para o modulo de combate.
    global.db_encontros = {
        encontro_teste_01 : {
            id              : "encontro_teste_01",
            nome            : "Algo atras da parede",
            tipo            : "encontro_especial",
            enemy_id        : "criatura_teste_01",
            texto           : "Algo se arrasta atras da parede.",
            texto_resultado : "O ruido cessa por alguns instantes.",
            transition_type : "escurecer_cenario",
            escolhas        : ["enfrentar", "recuar"],
            one_shot        : true
        },

        emboscada_teias_01 : {
            id              : "emboscada_teias_01",
            nome            : "ALGUMA COISA ESTA NESTA SALA.",
            tipo            : "emboscada",
            enemy_id        : "criatura_teste_01",
            texto           : "Algo se desprende das teias e avanca.",
            transition_type : "blackout",
            escolhas        : [],
            auto_start      : true,
            auto_delay      : 80,
            one_shot        : false
        }
    };

    // =========================================================================
    // SUB ABA: INTERACOES CONTEXTUAIS
    // =========================================================================
    // Cenas especiais de investigacao. A sala continua em exploracao, mas o Draw
    // GUI apresenta um painel dedicado com elementos locais e acoes.
    global.db_contextos_interacao = {
        contexto_teias_faca_01 : {
            id             : "contexto_teias_faca_01",
            nome           : "Porta Bloqueada",
            titulo         : "CadÃ¡ver do Escavador",
            sprite_menu    : spr_legenda_cadaver,
            sprite_menu_w  : 450,
            sprite_menu_h  : 1080,
            sprite_escavador      : spr_painel_cadaver,
            sprite_escavador_x    : 430,
            sprite_escavador_y    : 0,
            sprite_escavador_w    : 1490,
            sprite_escavador_h    : 1080,
            sprite_escavador_zoom : 1.12,
            estado_inicial : "bloqueada",
            obstaculo_id   : "parede_teias_01",
            autopsia_id    : "escavador_01",
            elementos      : [
                {
                    id     : "porta",
                    nome   : "Porta",
                    icone  : "P",
                    textos : {
                        bloqueada       : "VocÃª entra na sala e a primeira coisa que vÃª Ã© o cadÃ¡ver de um escavador encostado contra uma parede de concreto sem detalhes.                  sangue escorre de seu capacete metÃ¡lico,acumulando-se no chÃ£o.",
                        teias_removidas : "Com as teias removidas, a porta ainda resiste, mas agora voce consegue alcancar a trava.",
                        porta_aberta    : "A passagem esta aberta. O caminho adiante pode ser seguido pelo NAV."
                    },
                    acoes  : {
                        bloqueada       : [
                            { id : "tentar_abrir_porta", nome : "Iniciar Evento" }
                        ],
                        teias_removidas : [
                            { id : "abrir_porta", nome : "Iniciar Evento" }
                        ],
                        porta_aberta    : [
                            { id : "seguir_porta", nome : "Iniciar Evento" }
                        ]
                    }
                },
                {
                    id     : "teias",
                    nome   : "Teias",
                    icone  : "T",
                    textos : {
                        bloqueada       : "Uma parede de teias grossas cobre a lateral da passagem. Parece possivel corta-las com uma lamina.",
                        teias_removidas : "As teias foram cortadas. Fios rompidos ainda tremem junto da parede.",
                        porta_aberta    : "Restos das teias ficam presos nas bordas da abertura."
                    },
                    acoes  : {
                        bloqueada       : [
                            { id : "usar_item_teias", nome : "Iniciar Evento" }
                        ],
                        teias_removidas : [
                            { id : "examinar_teias", nome : "Iniciar Evento" }
                        ],
                        porta_aberta    : [
                            { id : "examinar_teias", nome : "Iniciar Evento" }
                        ]
                    }
                },
                {
                    id     : "cadaver",
                    nome   : "Cadaver",
                    icone  : "C",
                    textos : {
                        bloqueada       : "O cadaver do escavador esta proximo da porta. Talvez haja algo util preso ao corpo.",
                        teias_removidas : "O corpo continua no mesmo lugar, mas a passagem agora respira ar frio.",
                        porta_aberta    : "O cadaver permanece abandonado junto da entrada."
                    },
                    acoes  : {
                        bloqueada       : [
                            { id : "olhar_cadaver", nome : "Iniciar Evento" }
                        ],
                        teias_removidas : [
                            { id : "olhar_cadaver", nome : "Iniciar Evento" }
                        ],
                        porta_aberta    : [
                            { id : "olhar_cadaver", nome : "Iniciar Evento" }
                        ]
                    }
                },
                {
                    id     : "voltar",
                    nome   : "Voltar",
                    icone  : "V",
                    textos : {
                        bloqueada       : "Voce se afasta da porta por enquanto.",
                        teias_removidas : "Voce se afasta da passagem aberta nas teias.",
                        porta_aberta    : "Voce volta para a sala."
                    },
                    acoes  : {
                        bloqueada       : [
                            { id : "sair_contexto", nome : "Voltar" }
                        ],
                        teias_removidas : [
                            { id : "sair_contexto", nome : "Voltar" }
                        ],
                        porta_aberta    : [
                            { id : "sair_contexto", nome : "Voltar" }
                        ]
                    }
                }
            ]
        }
    };

    // =========================================================================
    // SUB ABA: INTERACOES E EVENTOS (FASE 1)
    // =========================================================================
    // Interacoes catalogam pontos clicaveis. Eventos catalogam o fluxo narrativo.
    // O runtime acompanha o contexto atual sem substituir o sistema legado.
    global.db_interacoes = {
        porta_principal : {
            id          : "porta_principal",
            tipo        : "ponto_interacao",
            contexto_id : "contexto_teias_faca_01",
            elemento_id : "porta",
            evento_id   : "evento_cadaver_escavador",
            evento_auto_abrir : false,
            hitbox      : { x1 : 690, y1 : 210, x2 : 1180, y2 : 930 },
            condicao    : "sempre"
        },
        parede_teias : {
            id          : "parede_teias",
            tipo        : "ponto_interacao",
            contexto_id : "contexto_teias_faca_01",
            elemento_id : "teias",
            evento_id   : "evento_cadaver_escavador",
            evento_auto_abrir : false,
            hitbox      : { x1 : 200, y1 : 180, x2 : 650, y2 : 930 },
            condicao    : "sempre"
        },
        cadaver_escavador : {
            id          : "cadaver_escavador",
            tipo        : "ponto_interacao",
            contexto_id : "contexto_teias_faca_01",
            elemento_id : "cadaver",
            evento_id   : "evento_cadaver_escavador",
            evento_auto_abrir : true,
            hitbox      : { x1 : 1100, y1 : 550, x2 : 1600, y2 : 1000 },
            condicao    : "sempre"
        }
    };

    global.db_eventos = {
evento_cadaver_escavador : {
    id             : "evento_cadaver_escavador",
    tipo           : "investigacao",
    contexto_id    : "contexto_teias_faca_01",
    estado_inicial : "entrada",
    no_inicial     : "inicio",

    // =========================================================
    // CENARIO
    // =========================================================

    cenario : {
        sprite   : spr_dungeon_autopsia,
        pos_x    : 0,
        pos_y    : 0,
        escala_x : 1,
        escala_y : 1,
        efeito   : "nenhum"
    },

    // =========================================================
    // PAINEL
    // =========================================================

    painel : {
        sprite  : spr_painel_cadaver,

        pos_x : 0,
        pos_y : 0,

        largura : 520,
        altura  : 1080,

        escolha_x          : 8,
        escolha_inicio_y   : 696,
        escolha_largura    : 452,
        escolha_altura     : 58,
        escolha_espaco     : 12
    },

    // Camadas visuais independentes do fluxo logico do evento.
    apresentacao : {
        base : {
            sprite : spr_painel_cadaver
        },

        cenarios : {
            cadaver : { sprite : spr_dungeon_autopsia, x : 0, y : 0, escala_x : 1, escala_y : 1 },
            porta   : { sprite : spr_evento_porta_cenario, x : 0, y : 0, escala_x : 1.1483, escala_y : 1.1477 }
        },

        legendas : {
            cadaver : { sprite : spr_legenda_cadaver, x : 0, y : 0, escala_x : 1, escala_y : 1 },
            partes  : { sprite : spr_painel_cadaver_escolhas, recorte : { x : 0, y : 0, largura : 520, altura : 686 }, x : 0, y : 0 },
            // A legenda e um canvas completo de 1920x1080, como o cenario.
            porta   : { sprite : spr_evento_porta_legenda, x : 0, y : 0, escala_x : 1, escala_y : 1 }
        },

        acoes : {
            iniciar : { sprite : spr_painel_cadaver, recorte : { x : 0, y : 694, largura : 520, altura : 60 }, x : 0, y : 694 },
            confirmar : { sprite : spr_painel_cadaver_escolhas, recorte : { x : 0, y : 686, largura : 520, altura : 70 }, x : 0, y : 686 }
        },

        icones : [
            { id : "porta", x1 : 0, y1 : 770, x2 : 112, y2 : 880, proximo : "porta_confirmar" },
            { id : "cadaver", x1 : 126, y1 : 770, x2 : 244, y2 : 880, proximo : "cadaver_confirmar" },
            { id : "saida", x1 : 258, y1 : 770, x2 : 376, y2 : 880, proximo : "" }
        ]
    },

    // =========================================================
    // TEXTO
    // =========================================================

    texto : {
        fonte       : -1,
        alinhamento : fa_left,
        espacamento : 4
    },

    // =========================================================
    // NOS DO EVENTO
    // =========================================================

    nos : {

        // =====================================================
        // INICIO
        // =====================================================

        inicio : {
            id : "inicio",

            apresentacao : { cenario : "cadaver", legenda : "cadaver", acao : "iniciar", libera_icones : false },

            titulo : "CADAVER DO ESCAVADOR",

            legenda_sprite : spr_legenda_cadaver,
            texto_embutido : true,

            mensagem :
                "Voce entra na sala e encontra um cadaver encostado contra uma parede de concreto. Deseja investigar esta situacao?",

            escolhas : [
                {
                    id       : "iniciar_evento",
                    texto    : "INICIAR EVENTO",
                    proximo : "cadaver_confirmar",

                    x       : 0,
                    y       : 690,
                    largura : 523,
                    altura  : 68,
                    sprite  : spr_painel_iniciar_evento,
                    desenhada_na_sprite : true,
                    transicao_painel : "fade"
                }
            ]
        },

        cadaver_confirmar : {
            id : "cadaver_confirmar",

            apresentacao : { cenario : "cadaver", legenda : "cadaver", acao : "confirmar", libera_icones : true },

            escolhas : [
                { id : "voltar_cadaver", texto : "VOLTAR", proximo : "inicio", x : 20, y : 685, largura : 214, altura : 73, sprite : spr_painel_voltar, desenhada_na_sprite : true, transicao_painel : "fade" },
                { id : "confirmar_cadaver", texto : "CONFIRMAR", proximo : "selecionar_parte", x : 289, y : 685, largura : 214, altura : 73, sprite : spr_painel_confirmar, desenhada_na_sprite : true, transicao_painel : "fade" }
            ]
        },


        // =====================================================
        // SELECIONAR PARTE
        // =====================================================

        selecionar_parte : {
            id : "selecionar_parte",

            apresentacao : { cenario : "cadaver", legenda : "partes", acao : "confirmar", libera_icones : true },

            titulo : "CADAVER DO ESCAVADOR",
            painel_sprite : spr_painel_cadaver_escolhas,
            texto_embutido : true,

            mensagem :
                "Qual parte do corpo voce quer vasculhar? Selecione uma parte e confirme.",

            mensagem_alinhamento : fa_center,
            mensagem_x           : 260,
            mensagem_y           : 115,
            mensagem_largura     : 464,

            escolhas : [

                // -------------------------------------------------
                // CABECA
                // -------------------------------------------------

                {
                    id          : "parte_cabeca",
                    texto       : "CABECA",
                    selecionavel : true,
                    proximo      : "cabeca",

                    // Sprite que sera mostrada quando
                    // o mouse estiver sobre esta opcao.
                    sprite : spr_parte_cabeca,
                    estilo : "lista",

                    // Hitbox da opcao.
                    x       : 28,
                    y       : 260,
                    largura : 464
                },


                // -------------------------------------------------
                // TORSO
                // -------------------------------------------------

                {
                    id          : "parte_torso",
                    texto       : "TORSO",
                    selecionavel : true,
                    proximo      : "torso",

                    // Sprite do torso.
                    sprite : spr_parte_torso,
                    estilo : "lista",

                    // Hitbox da opcao.
                    x       : 28,
                    y       : 360,
                    largura : 464
                },


                // -------------------------------------------------
                // MAOS
                // -------------------------------------------------

                {
                    id          : "parte_maos",
                    texto       : "MAOS",
                    selecionavel : true,
                    proximo      : "maos",

                    // Sprite das maos.
                    sprite : spr_parte_maos,
                    estilo : "lista",

                    // Hitbox da opcao.
                    x       : 28,
                    y       : 460,
                    largura : 464
                },


                // -------------------------------------------------
                // PERNAS
                // -------------------------------------------------

                {
                    id          : "parte_pernas",
                    texto       : "PERNAS",
                    selecionavel : true,
                    proximo      : "pernas",

                    // Sprite das pernas.
                    sprite : spr_parte_pernas,
                    estilo : "lista",

                    // Hitbox da opcao.
                    x       : 28,
                    y       : 560,
                    largura : 464
                },


                // -------------------------------------------------
                // VOLTAR
                // -------------------------------------------------

                {
                    id       : "voltar_inicio",
                    texto    : "VOLTAR",
                    proximo  : "inicio",

                    x       : 20,
                    y       : 685,
                    largura : 214,
                    altura  : 73,
                    sprite : spr_painel_voltar,
                    desenhada_na_sprite : true
                },


                // -------------------------------------------------
                // CONFIRMAR
                // -------------------------------------------------

                {
                    id       : "confirmar_parte",
                    texto    : "CONFIRMAR",
                    acao     : "confirmar_escolha",

                    x       : 289,
                    y       : 685,
                    largura : 214,
                    altura  : 73,
                    sprite : spr_painel_confirmar,
                    desenhada_na_sprite : true
                }
            ]
        },

        porta_iniciar : {
            id : "porta_iniciar",

            apresentacao : { cenario : "porta", legenda : "porta", acao : "iniciar", libera_icones : true },

            escolhas : [
                { id : "iniciar_porta", texto : "INICIAR EVENTO", proximo : "porta_confirmar", x : 8, y : 696, largura : 508, transicao_painel : "fade" }
            ]
        },

        porta_confirmar : {
            id : "porta_confirmar",

            apresentacao : { cenario : "porta", legenda : "porta", acao : "confirmar", libera_icones : true },

            escolhas : [
                { id : "voltar_porta", texto : "VOLTAR", proximo : "porta_iniciar", x : 20, y : 685, largura : 214, altura : 73, sprite : spr_painel_voltar, desenhada_na_sprite : true, transicao_painel : "fade" },
                { id : "confirmar_porta", texto : "CONFIRMAR", acao : "tentar_abrir_porta", x : 289, y : 685, largura : 214, altura : 73, sprite : spr_painel_confirmar, desenhada_na_sprite : true }
            ]
        },


        // =====================================================
        // CABECA
        // =====================================================

        cabeca : {
            id : "cabeca",

            titulo : "CABECA",
            painel_sprite : spr_painel_cabeca,
            texto_embutido : true,

            mensagem :
                "A lente do capacete esta quebrada. Ha marcas escuras ao redor do rosto.",

            escolhas : [
                {
                    id       : "examinar_cabeca",
                    texto    : "EXAMINAR",
                    proximo : "cabeca_examinada",
                    x : 0, y : 250, largura : 523, altura : 66,
                    sprite : spr_painel_examinar_branco,
                    desenhada_na_sprite : true
                },

                {
                    id       : "voltar_partes_cabeca",
                    texto    : "VOLTAR",
                    proximo : "selecionar_parte",
                    x : 0, y : 316, largura : 523, altura : 73,
                    sprite : spr_painel_voltar_preto,
                    desenhada_na_sprite : true
                },

                {
                    id       : "investigacao_rapida_cabeca",
                    texto    : "INVESTIGACAO RAPIDA",
                    acao     : "rpg_investigacao_rapida",
                    proximo  : "cabeca_investigacao_rapida",
                    x : 27, y : 393, largura : 472, altura : 94,
                    sprite_base : spr_painel_investigacao,
                    sprite : spr_painel_investigacao_branco,
                    desenhada_na_sprite : true
                },

                {
                    id       : "teste_percepcao_cabeca",
                    texto    : "TESTE DE PERCEPCAO",
                    x : 28, y : 511, largura : 472, altura : 94,
                    sprite_base : spr_painel_percepcao,
                    sprite : spr_painel_percepcao_branco,
                    desenhada_na_sprite : true,
                    teste : {
                        atributo : "percepcao",
                        habilidade : "investigacao",
                        dificuldade : 11,
                        modificadores : 0,
                        proximo_falha_critica : "cabeca_falha_critica",
                        proximo_falha : "cabeca_falha",
                        proximo_sucesso_parcial : "cabeca_sucesso_parcial",
                        proximo_sucesso : "cabeca_sucesso",
                        proximo_sucesso_critico : "cabeca_sucesso_critico"
                    }
                }
            ]
        },


        // =====================================================
        // TORSO
        // =====================================================

        torso : {
            id : "torso",

            titulo : "TORSO",

            mensagem :
                "O traje esta rasgado e coberto por sangue seco. Algo parece preso sob o tecido.",

            escolhas : [
                {
                    id       : "examinar_torso",
                    texto    : "EXAMINAR",
                    proximo : "torso_examinado"
                },

                {
                    id       : "voltar_partes_torso",
                    texto    : "VOLTAR",
                    proximo : "selecionar_parte"
                }
            ]
        },


        // =====================================================
        // MAOS
        // =====================================================

        maos : {
            id : "maos",

            titulo : "MAOS",

            mensagem :
                "Uma das maos esta presa sob a capa. Os dedos seguram algo metalico.",

            escolhas : [
                {
                    id       : "examinar_maos",
                    texto    : "EXAMINAR",
                    proximo : "maos_examinadas"
                },

                {
                    id       : "voltar_partes_maos",
                    texto    : "VOLTAR",
                    proximo : "selecionar_parte"
                }
            ]
        },


        // =====================================================
        // PERNAS
        // =====================================================

        pernas : {
            id : "pernas",

            titulo : "PERNAS",

            mensagem :
                "As pernas estao presas entre os escombros. Nao ha nada evidente para recolher.",

            escolhas : [
                {
                    id       : "examinar_pernas",
                    texto    : "EXAMINAR",
                    proximo : "pernas_examinadas"
                },

                {
                    id       : "voltar_partes_pernas",
                    texto    : "VOLTAR",
                    proximo : "selecionar_parte"
                }
            ]
        },


        // =====================================================
        // CABECA EXAMINADA
        // =====================================================

        cabeca_falha_critica : {
            id : "cabeca_falha_critica",
            titulo : "CABECA",
            mensagem : "Ao tocar a lente, ela se desfaz. O estalo ecoa pela sala e voce perde o unico detalhe que restava visivel.",
            escolhas : [{ id : "retornar_cabeca_falha_critica", texto : "VOLTAR", proximo : "selecionar_parte" }]
        },

        cabeca_examinada : {
            id : "cabeca_examinada",
            titulo : "CABECA",
            mensagem : "A lente quebrada e as marcas antigas nao revelam nada alem de uma morte violenta.",
            escolhas : [{ id : "retornar_cabeca_examinada", texto : "VOLTAR", proximo : "cabeca" }]
        },

        cabeca_investigacao_rapida : {
            id : "cabeca_investigacao_rapida",
            titulo : "CABECA",
            mensagem : "Voce força a observacao dos detalhes. A cena deixa uma lembranca ruim e sua sanidade diminui em 3.",
            escolhas : [{ id : "retornar_cabeca_rapida", texto : "VOLTAR", proximo : "cabeca" }]
        },

        cabeca_falha : {
            id : "cabeca_falha",
            titulo : "CABECA",
            mensagem : "As marcas ao redor do rosto sao antigas demais para dizer algo com certeza. A lente quebrada nao ajuda.",
            escolhas : [{ id : "retornar_cabeca_falha", texto : "VOLTAR", proximo : "selecionar_parte" }]
        },

        cabeca_sucesso_parcial : {
            id : "cabeca_sucesso_parcial",
            titulo : "CABECA",
            mensagem : "Voce reconhece residuos de um sedativo no vedante do capacete. A causa da morte continua incerta.",
            escolhas : [{ id : "retornar_cabeca_parcial", texto : "VOLTAR", proximo : "selecionar_parte" }]
        },

        cabeca_sucesso : {
            id : "cabeca_sucesso",
            titulo : "CABECA",
            mensagem : "Sob a lente, ha marcas de agulha e residuos de sedativo. O escavador foi contido antes de morrer.",
            escolhas : [{ id : "retornar_cabeca_sucesso", texto : "VOLTAR", proximo : "selecionar_parte" }]
        },

        cabeca_sucesso_critico : {
            id : "cabeca_sucesso_critico",
            titulo : "CABECA",
            mensagem : "Entre os fragmentos da lente, voce encontra o codigo de lote do sedativo. Ele pertence ao mesmo fornecedor marcado na parede.",
            escolhas : [{ id : "retornar_cabeca_critico", texto : "VOLTAR", proximo : "selecionar_parte" }]
        },


        // =====================================================
        // TORSO EXAMINADO
        // =====================================================

        torso_examinado : {
            id : "torso_examinado",

            titulo : "TORSO",

            mensagem :
                "O rasgo revela um bolso vazio. O restante do traje esta colado ao corpo.",

            escolhas : [
                {
                    id       : "retornar_torso",
                    texto    : "VOLTAR",
                    proximo : "selecionar_parte"
                }
            ]
        },


        // =====================================================
        // MAOS EXAMINADAS
        // =====================================================

        maos_examinadas : {
            id : "maos_examinadas",

            titulo : "MAOS",

            mensagem :
                "A mao segura uma pequena lamina gasta. O item podera ser coletado em uma etapa posterior.",

            escolhas : [
                {
                    id       : "retornar_maos",
                    texto    : "VOLTAR",
                    proximo : "selecionar_parte"
                }
            ]
        },


        // =====================================================
        // PERNAS EXAMINADAS
        // =====================================================

            pernas_examinadas : {
                id : "pernas_examinadas",
                titulo : "PERNAS",
                mensagem : "Nao ha nada util entre os escombros desta parte do corpo.",
                escolhas : [
                    {
                        id      : "retornar_pernas",
                        texto   : "VOLTAR",
                        proximo : "selecionar_parte"
                    }
                ]
            }
        }
    }
    }
};

// --- SALA INICIAL ---
global.antechamber_room = {
        background : spr_dungeon_1,
        topleft    : [500, 300],
        bottomright : [600, 400],
        itens      : [
            {
                nome         : "Ruido na Parede",
                sprite       : Sprite14,
                x            : 960,
                y            : 560,
                padding      : 80,
                tipo         : "encontro",
                encounter_id : "encontro_teste_01",
                debug_hitbox : false,
                coletado     : false
            }
        ]
    };

    // --- SALA DAS MEMORIAS ---
    // Hub logico fixo da run. Ele reutiliza rm_game e troca apenas os dados
    // exibidos, evitando uma room extra enquanto a estrutura ainda evolui.
    global.sala_memorias = {
        id : "sala_memorias",
        tipo : "hub_memorias",
        papel_na_run : "controle_central",
        background : spr_entrada_profunda_cenario,
        // Cenario e painel usam o mesmo canvas virtual para manter o encaixe.
        layout_cenario : { x : 0, y : 0, largura : 1920, altura : 1080 },
        // A iluminacao clara aparece e desaparece suavemente sem mover a arte.
        camadas_animadas : [
            {
                sprite : spr_entrada_profunda_sweep,
                x : 0, y : 0,
                largura : 1920, altura : 1080,
                tipo : "fade_cenario",
                alpha : 1.0,
                duracao : 18.0
            }
        ],
        // A cinematica de memoria e desenhada no Draw GUI sobre este cenario.
        camadas_cenario : [],
        topleft    : [700, 300],
        bottomright : [800, 400],
        navegacao_sequencia : {
            modo : "cinematica_memorias",
            escolha_andar_branco : andar_branco,
            escolha_andar_vermelho : andar_vermelho,
            escolha_voltar_branco : voltar_branco,
            escolha_voltar_vermelho : voltar_vermelho,
            cinematica : {
                menu_andar : { x1 : 1240, y1 : 695, x2 : 1490, y2 : 770 },
                menu_voltar : { x1 : 1240, y1 : 775, x2 : 1490, y2 : 845 },
                escolha_seguir : { x1 : 1180, y1 : 715, x2 : 1750, y2 : 790 },
                escolha_lembrar : { x1 : 1180, y1 : 810, x2 : 1750, y2 : 885 },
                relatorio_cards : [
                    { tipo : "sprite", sprite : spr_memoria_card_passo, duracao : 0.40 },
                    { tipo : "sprite", sprite : spr_memoria_card_espera, duracao : 0.40 },
                    { tipo : "sprite", sprite : spr_memoria_card_pergunta, duracao : 2.00 },
                    { tipo : "silhueta", duracao : 0.70 },
                    { tipo : "sprite", sprite : spr_memoria_card_duvida, duracao : 0.40 },
                    { tipo : "sprite", sprite : spr_memoria_card_memorias, duracao : 1.50 },
                    { tipo : "sprite", sprite : spr_memoria_card_sua_memoria, duracao : 1.40 }
                ],
                relatorio_fragmentos : [
                    { tipo : "sprite", sprite : spr_memoria_card_porque_esta, duracao : 0.50 },
                    { tipo : "sprite", sprite : spr_memoria_card_suas_memorias, duracao : 0.45 },
                    { tipo : "sprite", sprite : spr_memoria_card_voce_lembra, duracao : 0.35 },
                    {
                        tema : "vermelho",
                        titulo : "NAO.",
                        escala : 2.5,
                        duracao : 0.25
                    },
                    { tipo : "sprite", sprite : spr_memoria_card_lembre_1, duracao : 0.20 }
                ],
                relatorio_lembre : [
                    { tipo : "sprite", sprite : spr_memoria_card_lembre_2, duracao : 0.20 },
                    { tipo : "sprite", sprite : spr_memoria_card_lembre_3, duracao : 0.1667 },
                    { tipo : "sprite", sprite : spr_memoria_card_lembre_4, duracao : 0.1667 },
                    { tipo : "sprite", sprite : spr_memoria_card_lembre_5, duracao : 0.1333 },
                    { tipo : "sprite", sprite : spr_memoria_card_lembre_6, duracao : 0.1333 },
                    { tipo : "sprite", sprite : spr_memoria_card_lembre_7, duracao : 0.1167 },
                    { tipo : "sprite", sprite : spr_memoria_card_lembre_8, duracao : 0.1167 },
                    { tipo : "sprite", sprite : spr_memoria_card_lembre_9, duracao : 0.1167 },
                    { tipo : "sprite", sprite : spr_memoria_card_lembre_10, duracao : 0.1333 },
                    { tipo : "sprite", sprite : spr_memoria_card_lembre_11, duracao : 0.1667 }
                ],
                signalis_frames : [ signalis_1, signalis_2, signalis_3, signalis_4, signalis_5, signalis_6 ],
                silhueta : spr_memoria_guardiao,
                interrogacao : spr_memoria_card_interrogacao,
                duracao_preto : 0.40,
                duracao_interrogacao : 0.55,
                duracao_escurecer : 0.20,
                duracao_signalis_entrada : 0.65,
                fps_signalis : 10
            },
            destino_voltar : noone,
            destino_lembrar : noone,
            destino_seguir  : noone,
            decisao_memoria : ""
        },
        itens : []
    };

    // Compatibilidade temporaria com interacoes e objetos ja configurados.
    // Novos sistemas devem usar global.sala_memorias diretamente.
    global.cubicle_one = global.sala_memorias;

    // --- SALA CADAVER ESCAVADOR ---
// Sala logica isolada para a mecanica de autopsia e teias.
global.sala_cadaver_escavador = {
    background : spr_dungeon_autopsia,

    topleft     : [0, 0],
    bottomright : [0, 0],

    norte : noone,
    sul   : noone,
    leste : noone,
    oeste : noone,

    // ---------------------------------------------------------
    // CONTEXTO DO CENARIO
    // ---------------------------------------------------------
    contexto_id              : "contexto_teias_faca_01",
    contexto_estado          : "bloqueada",

    // A apresentacao do cadaver abre ao entrar na sala. Depois de fechada,
    // as hitboxes do cenario voltam a ficar disponiveis para exploracao.
    contexto_auto_abrir      : false,
    interacao_auto_abrir     : true,
    interacao_inicial        : "cadaver_escavador",
    interacao_no_inicial     : "inicio",
    interacao_inicial_aberta : false,

    contexto_elemento_inicial : "porta",
    contexto_sair_destino     : rm_transicao,

    // ---------------------------------------------------------
    // AREAS INTERATIVAS DO CENARIO
    // ---------------------------------------------------------
    itens : [

        // =====================================================
        // PORTA
        // =====================================================
        {
            nome             : "Porta Bloqueada",
            tipo             : "contexto",

            contexto_id      : "contexto_teias_faca_01",
            elemento_inicial : "porta",

            // HITBOX DA PORTA
            x1               : 690,
            y1               : 210,
            x2               : 1180,
            y2               : 930,

            coletado         : false
        },


        // =====================================================
        // CADAVER DO ESCAVADOR
        // =====================================================
        {
            nome             : "Cadaver do Escavador",
            tipo             : "cadaver",

            // O cadaver utiliza o mesmo contexto do cenario.
            contexto_id      : "contexto_teias_faca_01",

            // Quando clicar no cadaver, o painel abre
            // diretamente no elemento "cadaver".
            elemento_inicial : "cadaver",

            autopsia_id      : "escavador_01",

            // HITBOX DO CADAVER
            x1               : 1100,
            y1               : 550,
            x2               : 1600,
            y2               : 1000,

            coletado         : false
        },


        // =====================================================
        // PAREDE DE TEIAS
        // =====================================================
        {
            nome             : "Parede de Teias",
            tipo             : "obstaculo",

            obstaculo_id     : "parede_teias_01",

            // HITBOX DAS TEIAS
            x1               : 200,
            y1               : 180,
            x2               : 650,
            y2               : 930,

            removido         : false,
            coletado         : false,

            debug_hitboxes   : false
        },
		{
    nome             : "Cadaver do Escavador",
    tipo             : "cadaver",

    contexto_id      : "contexto_teias_faca_01",
    elemento_inicial : "cadaver",

    painel_sprite    : spr_painel_cadaver,
    legenda_sprite   : spr_legenda_cadaver,

    autopsia_id      : "escavador_01",

    x1               : 1100,
    y1               : 550,
    x2               : 1600,
    y2               : 1000,

    coletado         : false
}
    ]
};

    // --- SALA GERADOR ---
    global.sala_gerador = {
        background : spr_dungeon_3,
        topleft    : [900, 300],
        bottomright : [1000, 400],
        itens      : [
            {
                nome         : "Barril de Suprimentos",
                sprite       : spr_barril,
                x            : 1200,
                y            : 700,
                tipo         : "container",
                modelo       : "barril",
                aberto       : false,
                itens_dentro : [], // Inicializa vazio
                coletado     : false
            }
        ]
    };

    // --- HUB DOS TRES CORREDORES ---
    // Cada opcao guarda sua propria arte, texto e destino. Apenas a primeira
    // rota esta liberada neste momento; as demais podem receber salas depois.
    global.sala_escolha_corredores = {
        background : spr_corredor_escolha_1,
        background_ajustar_tela : true,
        topleft : [1050, 300],
        bottomright : [1150, 400],
        itens : [],
        navegacao_corredores : {
            painel_sprite : spr_painel_corredores,
            botao_sprite : spr_botao_corredor,
            opcoes : [
                {
                    cenario : spr_corredor_escolha_1,
                    fonte_sprite : spr_font_corredor_1,
                    titulo : "CORREDOR VAZIO",
                    legenda : "O arco aberto leva a uma sala onde algo espera na escuridao.",
                    disponivel : true,
                    destino : noone
                },
                {
                    cenario : spr_corredor_escolha_2,
                    fonte_sprite : spr_font_corredor_2,
                    titulo : "PASSAGEM FUNDA",
                    legenda : "Um segundo arco se esconde ao fundo. Este caminho ainda nao esta pronto.",
                    disponivel : false,
                    destino : noone
                },
                {
                    cenario : spr_corredor_escolha_3,
                    fonte_sprite : spr_font_corredor_3,
                    titulo : "CORREDOR DAS TEIAS",
                    legenda : "Fios azuis fecham a passagem. Ha movimento alem da barreira.",
                    disponivel : false,
                    destino : noone
                }
            ],
            botoes : [
                { x1 : 1410, y1 : 552, x2 : 1495, y2 : 630 },
                { x1 : 1498, y1 : 552, x2 : 1580, y2 : 630 },
                { x1 : 1583, y1 : 552, x2 : 1665, y2 : 630 }
            ],
            entrar : { x1 : 1263, y1 : 635, x2 : 1802, y2 : 687 }
        }
    };

    // --- CONEXÃ•ES ENTRE SALAS ---
    global.antechamber_room.norte = global.sala_memorias;
    global.sala_memorias.sul      = global.antechamber_room;
    global.sala_memorias.norte    = global.sala_gerador;
    global.sala_memorias.navegacao_sequencia.destino_voltar = global.antechamber_room;
    global.sala_gerador.sul       = global.sala_memorias;
    global.sala_gerador.norte     = global.sala_escolha_corredores;
    global.sala_escolha_corredores.sul = global.sala_gerador;
    global.sala_escolha_corredores.navegacao_corredores.opcoes[0].destino = global.sala_cadaver_escavador;
    // As duas escolhas mantem estados separados, mas levam ao mesmo hub ate a
    // rota narrativa de lembrar receber um destino proprio.
    global.sala_memorias.navegacao_sequencia.destino_lembrar = global.sala_escolha_corredores;
    global.sala_memorias.navegacao_sequencia.destino_seguir = global.sala_escolha_corredores;

    // Popula contÃªineres com seguranÃ§a apÃ³s banco de dados e salas estarem totalmente mapeados
    array_push(global.sala_gerador.itens[0].itens_dentro, scr_instanciar_item("erva_verde"));
    array_push(global.sala_gerador.itens[0].itens_dentro, scr_instanciar_item("facao_enferrujado"));
    array_push(global.sala_gerador.itens[0].itens_dentro, scr_instanciar_item("elmo_velho"));
    scr_inventario_adicionar(scr_instanciar_item("facao_enferrujado"));
    scr_inventario_adicionar(scr_instanciar_item("elmo_velho"));
    scr_inventario_adicionar(scr_instanciar_item("colete_lona_toxica"));
    scr_inventario_adicionar(scr_instanciar_item("anel_helion_frio"));


// =============================================================================
// FUNÃ‡Ã•ES UTILITÃRIAS â€” LAYOUT E HITBOX
// =============================================================================
// Usadas pelo Step E pelo Draw. UMA fonte. ZERO duplicaÃ§Ã£o.
// =============================================================================

/// @function scr_get_slot_position(container_template, index, anchor_x, anchor_y)
/// @description Retorna {x, y} do slot na grid do container. Usado por Draw E Step.
function scr_get_slot_position(_template, _index, _anchor_x, _anchor_y) {
    var _col = _index % _template.colunas;
    var _lin = _index div _template.colunas;
    return {
        x : _anchor_x + _template.margem_x + (_col * _template.espacamento_x),
        y : _anchor_y + _template.margem_y + (_lin * _template.espacamento_y)
    };
}

function scr_get_loot_icon_rect(_template) {
    if (argument_count > 0 && is_struct(_template)
        && variable_struct_exists(_template, "sprite_ui") && sprite_exists(_template.sprite_ui)) {
        return scr_get_item_sprite_hitbox(_template.sprite_ui, global.ui_config.loot_panel_x, global.ui_config.loot_panel_y);
    }

    return {
        x1 : global.ui_config.loot_icon_x,
        y1 : global.ui_config.loot_icon_y,
        x2 : global.ui_config.loot_icon_x + global.ui_config.loot_icon_w,
        y2 : global.ui_config.loot_icon_y + global.ui_config.loot_icon_h
    };
}

function scr_get_loot_panel_rect(_template) {
    var _cols = _template.colunas;
    var _rows = variable_struct_exists(_template, "linhas")
        ? _template.linhas
        : ceil(global.ui_config.loot_max_slots / max(1, _cols));

    var _w = (_template.margem_x * 2)
        + global.ui_config.loot_slot_w
        + ((_cols - 1) * _template.espacamento_x);

    var _h = (_template.margem_y * 2)
        + global.ui_config.loot_slot_h
        + ((_rows - 1) * _template.espacamento_y);

    return {
        x1 : global.ui_config.loot_sub_aba_x,
        y1 : global.ui_config.loot_sub_aba_y,
        x2 : global.ui_config.loot_sub_aba_x + _w,
        y2 : global.ui_config.loot_sub_aba_y + _h
    };
}

function scr_get_loot_slot_rect(_template, _index, _anchor_x, _anchor_y) {
    var _pos = scr_get_slot_position(_template, _index, _anchor_x, _anchor_y);
    return {
        x1 : _pos.x,
        y1 : _pos.y,
        x2 : _pos.x + global.ui_config.loot_slot_w,
        y2 : _pos.y + global.ui_config.loot_slot_h
    };
}

/// @function scr_get_item_hitbox(item_struct)
/// @description Retorna {x1, y1, x2, y2} da hitbox de um item no cenÃ¡rio.
///              Resolve a referÃªncia ao banco mestre automaticamente.
function scr_get_item_hitbox(_item) {
    if (variable_struct_exists(_item, "x1")
        && variable_struct_exists(_item, "y1")
        && variable_struct_exists(_item, "x2")
        && variable_struct_exists(_item, "y2")) {
        return {
            x1     : _item.x1,
            y1     : _item.y1,
            x2     : _item.x2,
            y2     : _item.y2,
            sprite : noone,
            manual : true
        };
    }

    // Resolve o sprite do cenÃ¡rio (itens com "base" buscam no banco)
    var _sprite = noone;
    if (variable_struct_exists(_item, "sprite")) {
        _sprite = _item.sprite;
    } else if (variable_struct_exists(_item, "base")) {
        if (!variable_global_exists("db_itens") || !variable_struct_exists(global.db_itens, _item.base)) {
            show_debug_message("ERRO: base de item inexistente no banco: " + string(_item.base));
            return { x1: 0, y1: 0, x2: 0, y2: 0, sprite: noone };
        }

        var _db = global.db_itens[$ _item.base];
        _sprite = _db.sprite_cenario;
    }

    if (_sprite == noone || !sprite_exists(_sprite)) {
        return { x1: 0, y1: 0, x2: 0, y2: 0, sprite: noone };
    }

    var _w       = sprite_get_width(_sprite);
    var _h       = sprite_get_height(_sprite);
    var _xoff    = sprite_get_xoffset(_sprite);
    var _yoff    = sprite_get_yoffset(_sprite);
    var _pad     = variable_struct_exists(_item, "padding") ? _item.padding : 0;

    return {
        x1     : _item.x - _xoff - _pad,
        y1     : _item.y - _yoff - _pad,
        x2     : _item.x - _xoff + _w + _pad,
        y2     : _item.y - _yoff + _h + _pad,
        sprite : _sprite
    };
}

/// @function scr_get_item_sprite_hitbox(sprite, draw_x, draw_y)
/// @description Retorna {x1, y1, x2, y2} a partir de um sprite e posiÃ§Ã£o de draw.
///              Usado para hitbox de itens dentro de containers (loot).
function scr_get_item_sprite_hitbox(_sprite, _draw_x, _draw_y) {
    var _w    = sprite_get_width(_sprite);
    var _h    = sprite_get_height(_sprite);
    var _xoff = sprite_get_xoffset(_sprite);
    var _yoff = sprite_get_yoffset(_sprite);

    return {
        x1 : _draw_x - _xoff,
        y1 : _draw_y - _yoff,
        x2 : _draw_x - _xoff + _w,
        y2 : _draw_y - _yoff + _h
    };
}

// =============================================================================
// SISTEMA DE INSTANCIAÃ‡ÃƒO DE ITENS
// =============================================================================

/// @function scr_instanciar_item(base_id, [quantidade])
/// @description Cria uma INSTÃ‚NCIA de item a partir do banco mestre.
///              Template = O QUE o item Ã©. InstÃ¢ncia = O ESTADO do item.
function scr_instanciar_item(_base_id, _quantidade) {
    if (argument_count < 2) _quantidade = 1;

    if (!variable_global_exists("db_itens") || !variable_struct_exists(global.db_itens, _base_id)) {
        show_debug_message("ERRO: tentativa de instanciar item inexistente: " + string(_base_id));
        return noone;
    }

    var _template = global.db_itens[$ _base_id];

    return {
        base       : _base_id,
        nome       : _template.nome,
        sprite     : _template.sprite_inv,
        categoria  : _template.categoria,
        tipo       : variable_struct_exists(_template, "tipo") ? _template.tipo : "item",
        slot       : variable_struct_exists(_template, "slot") ? _template.slot : "",
        acao       : variable_struct_exists(_template, "acao") ? _template.acao : "nenhuma",
        valor      : variable_struct_exists(_template, "valor") ? _template.valor : 0,
        dano       : variable_struct_exists(_template, "dano") ? _template.dano : 0,
        defesa     : variable_struct_exists(_template, "defesa") ? _template.defesa : 0,
        tipo_dano  : variable_struct_exists(_template, "tipo_dano") ? _template.tipo_dano : "",
        dano_vigor : variable_struct_exists(_template, "dano_vigor") ? _template.dano_vigor : 0,
        custo_acao : variable_struct_exists(_template, "custo_acao") ? _template.custo_acao : 0,
        acoes_combate : variable_struct_exists(_template, "acoes_combate") ? _template.acoes_combate : [],
        stack      : variable_struct_exists(_template, "stack") ? _template.stack : 1,
        quantidade : _quantidade,
        descricao  : variable_struct_exists(_template, "descricao") ? _template.descricao : ""
    };
}

function scr_inventario_sync_categorias() {
    global.inventarios.weapon = [];
    global.inventarios.cura = [];
    global.inventarios.helmet = [];
    global.inventarios.armor = [];
    global.inventarios.legs = [];
    global.inventarios.boots = [];
    global.inventarios.ring = [];
    global.inventarios.mapa = [];
    global.inventarios.consumiveis = [];
    global.inventarios.geral = [];

    for (var i = 0; i < array_length(global.inventario.mochila); i++) {
        var _item = global.inventario.mochila[i];
        var _cat = variable_struct_exists(_item, "categoria") ? _item.categoria : "geral";

        if (variable_struct_exists(global.inventarios, _cat)) {
            array_push(global.inventarios[$ _cat], _item);
        } else {
            array_push(global.inventarios.geral, _item);
        }
    }
}

function scr_inventario_get_categoria(_cat) {
    var _resultado = [];

    if (_cat != "" && variable_struct_exists(global.inventario.equipados, _cat)) {
        var _equipado = global.inventario.equipados[$ _cat];
        if (_equipado != noone) {
            array_push(_resultado, _equipado);
        }
    }

    if (_cat != "" && variable_struct_exists(global.inventarios, _cat)) {
        var _itens = global.inventarios[$ _cat];
        for (var i = 0; i < array_length(_itens); i++) {
            array_push(_resultado, _itens[i]);
        }
        return _resultado;
    }

    return global.inventario.mochila;
}

function scr_inventario_tentar_empilhar(_item) {
    var _stack = variable_struct_exists(_item, "stack") ? _item.stack : 1;
    if (_stack <= 1 || !variable_struct_exists(_item, "base")) {
        return false;
    }

    for (var i = 0; i < array_length(global.inventario.mochila); i++) {
        var _alvo = global.inventario.mochila[i];

        if (variable_struct_exists(_alvo, "base") && _alvo.base == _item.base) {
            var _qtd = variable_struct_exists(_alvo, "quantidade") ? _alvo.quantidade : 1;

            if (_qtd < _stack) {
                _alvo.quantidade = min(_stack, _qtd + (variable_struct_exists(_item, "quantidade") ? _item.quantidade : 1));
                global.inventario.mochila[i] = _alvo;
                scr_inventario_sync_categorias();
                return true;
            }
        }
    }

    return false;
}

function scr_inventario_adicionar(_item) {
    if (_item == noone) return false;

    if (scr_inventario_tentar_empilhar(_item)) {
        return true;
    }

    if (array_length(global.inventario.mochila) >= global.inventario.capacidade) {
        show_debug_message("Inventario cheio: " + _item.nome);
        return false;
    }

    array_push(global.inventario.mochila, _item);
    scr_inventario_sync_categorias();
    return true;
}

function scr_remover_item_inventario(_item) {
    for (var i = 0; i < array_length(global.inventario.mochila); i++) {
        if (global.inventario.mochila[i] == _item) {
            if (variable_struct_exists(_item, "quantidade") && _item.quantidade > 1) {
                _item.quantidade -= 1;
                global.inventario.mochila[i] = _item;
            } else {
                array_delete(global.inventario.mochila, i, 1);
            }

            scr_inventario_sync_categorias();
            return true;
        }
    }

    return false;
}

function scr_equipar_item(_item) {
    if (!is_struct(_item) || !variable_struct_exists(_item, "slot") || _item.slot == "") {
        show_debug_message("Item nao possui slot de equipamento.");
        return false;
    }

    var _slot = _item.slot;
    if (!variable_struct_exists(global.inventario.equipados, _slot)) {
        show_debug_message("Slot de equipamento desconhecido: " + string(_slot));
        return false;
    }

    for (var i = 0; i < array_length(global.inventario.mochila); i++) {
        if (global.inventario.mochila[i] == _item) {
            array_delete(global.inventario.mochila, i, 1);
            break;
        }
    }

    var _antigo = global.inventario.equipados[$ _slot];
    if (_antigo != noone) {
        array_push(global.inventario.mochila, _antigo);
    }

    global.inventario.equipados[$ _slot] = _item;
    scr_inventario_sync_categorias();
    show_debug_message("Equipado: " + _item.nome);
    return true;
}

function scr_desequipar_item(_slot) {
    if (!variable_struct_exists(global.inventario.equipados, _slot)) {
        return false;
    }

    var _item = global.inventario.equipados[$ _slot];
    if (_item == noone) {
        return false;
    }

    if (array_length(global.inventario.mochila) >= global.inventario.capacidade) {
        show_debug_message("Mochila cheia. Nao foi possivel desequipar.");
        return false;
    }

    global.inventario.equipados[$ _slot] = noone;
    array_push(global.inventario.mochila, _item);
    scr_inventario_sync_categorias();
    show_debug_message("Desequipado: " + _item.nome);
    return true;
}

function scr_get_inventory_slot_rect(_index) {
    var _cols = global.ui_config.inv_slot_cols;
    var _col = _index % _cols;
    var _row = _index div _cols;
    var _x = global.ui_config.inv_items_x + (_col * (global.ui_config.inv_slot_w + global.ui_config.inv_slot_gap_x));
    var _y = global.ui_config.inv_items_y + (_row * (global.ui_config.inv_slot_h + global.ui_config.inv_slot_gap_y));

    return {
        x1 : _x,
        y1 : _y,
        x2 : _x + global.ui_config.inv_slot_w,
        y2 : _y + global.ui_config.inv_slot_h
    };
}

function scr_get_inventory_back_rect() {
    var _x2 = global.ui_config.inv_panel_x + global.ui_config.inv_panel_w - 16;
    var _y1 = global.ui_config.inv_panel_y + 16;

    return {
        x1 : _x2 - 24,
        y1 : _y1,
        x2 : _x2,
        y2 : _y1 + 24
    };
}

function scr_get_inventory_category_title(_cat) {
    switch (_cat) {
        case "weapon": return "Armas";
        case "cura": return "Medico";
        case "helmet": return "Elmos";
        case "armor": return "Armaduras";
        case "legs": return "Pernas";
        case "boots": return "Botas";
        case "ring": return "Aneis";
        case "mapa": return "Mapa";
        case "consumiveis": return "Recursos";
    }

    return "Itens";
}

function scr_get_item_nome(_item) {
    if (is_struct(_item) && variable_struct_exists(_item, "nome")) {
        return _item.nome;
    }

    return "Item";
}

function scr_get_item_descricao(_item) {
    if (is_struct(_item) && variable_struct_exists(_item, "descricao")) {
        return _item.descricao;
    }

    return scr_get_item_nome(_item);
}

function scr_mostrar_mensagem_contexto(_texto) {
    if (!variable_global_exists("ui_state")) return;

    global.ui_state.mensagem_contexto = string(_texto);
    global.ui_state.mensagem_timer = 180;
    show_debug_message(string(_texto));
}

function scr_get_autopsia_data(_id) {
    if (!variable_global_exists("db_autopsias")) return noone;
    if (!variable_struct_exists(global.db_autopsias, _id)) return noone;
    return global.db_autopsias[$ _id];
}

function scr_get_obstaculo_data(_id) {
    if (!variable_global_exists("db_obstaculos")) return noone;
    if (!variable_struct_exists(global.db_obstaculos, _id)) return noone;
    return global.db_obstaculos[$ _id];
}

function scr_inventario_possui_base(_base_id) {
    if (_base_id == "") return false;

    for (var i = 0; i < array_length(global.inventario.mochila); i++) {
        var _item = global.inventario.mochila[i];
        if (is_struct(_item) && variable_struct_exists(_item, "base") && _item.base == _base_id) {
            return true;
        }
    }

    var _slots = ["weapon", "helmet", "armor", "legs", "boots", "ring"];
    for (var s = 0; s < array_length(_slots); s++) {
        var _slot = _slots[s];
        var _equipado = global.inventario.equipados[$ _slot];
        if (is_struct(_equipado) && variable_struct_exists(_equipado, "base") && _equipado.base == _base_id) {
            return true;
        }
    }

    return false;
}

function scr_inventario_get_item_por_base(_base_id) {
    if (_base_id == "") return noone;

    for (var i = 0; i < array_length(global.inventario.mochila); i++) {
        var _item = global.inventario.mochila[i];
        if (is_struct(_item) && variable_struct_exists(_item, "base") && _item.base == _base_id) {
            return _item;
        }
    }

    var _slots = ["weapon", "helmet", "armor", "legs", "boots", "ring"];
    for (var s = 0; s < array_length(_slots); s++) {
        var _slot = _slots[s];
        var _equipado = global.inventario.equipados[$ _slot];
        if (is_struct(_equipado) && variable_struct_exists(_equipado, "base") && _equipado.base == _base_id) {
            return _equipado;
        }
    }

    return noone;
}

function scr_obstaculo_get_nome_item_catalogo(_base_id) {
    if (_base_id == "") return "";
    if (variable_global_exists("db_itens") && variable_struct_exists(global.db_itens, _base_id)) {
        return global.db_itens[$ _base_id].nome;
    }
    return string(_base_id);
}

function scr_obstaculo_normalizar_item_aceito(_entrada) {
    if (is_string(_entrada)) {
        return {
            base          : _entrada,
            nome          : scr_obstaculo_get_nome_item_catalogo(_entrada),
            uso           : "",
            texto_sucesso : "",
            texto_falha   : ""
        };
    }

    if (!is_struct(_entrada)) return noone;

    var _base = variable_struct_exists(_entrada, "base") ? _entrada.base : "";
    if (_base == "") return noone;

    var _nome = scr_obstaculo_get_nome_item_catalogo(_base);
    if (variable_struct_exists(_entrada, "nome")) {
        _nome = _entrada.nome;
    }
    var _uso = variable_struct_exists(_entrada, "uso") ? _entrada.uso : "";
    var _texto_sucesso = variable_struct_exists(_entrada, "texto_sucesso") ? _entrada.texto_sucesso : "";
    var _texto_falha = variable_struct_exists(_entrada, "texto_falha") ? _entrada.texto_falha : "";

    return {
        base          : _base,
        nome          : _nome,
        uso           : _uso,
        texto_sucesso : _texto_sucesso,
        texto_falha   : _texto_falha
    };
}

function scr_obstaculo_get_itens_aceitos(_dados) {
    var _resultado = [];
    if (!is_struct(_dados)) return _resultado;

    var _catalogo = [];
    if (variable_struct_exists(_dados, "itens_aceitos") && is_array(_dados.itens_aceitos)) {
        _catalogo = _dados.itens_aceitos;
    }
    else if (variable_struct_exists(_dados, "opcoes") && is_array(_dados.opcoes)) {
        _catalogo = _dados.opcoes;
    }

    for (var i = 0; i < array_length(_catalogo); i++) {
        var _opcao = scr_obstaculo_normalizar_item_aceito(_catalogo[i]);
        if (_opcao != noone) {
            array_push(_resultado, _opcao);
        }
    }

    if (array_length(_resultado) <= 0
        && variable_struct_exists(_dados, "item_necessario")
        && _dados.item_necessario != "") {
        array_push(_resultado, scr_obstaculo_normalizar_item_aceito(_dados.item_necessario));
    }

    return _resultado;
}

function scr_obstaculo_get_opcoes(_dados) {
    return scr_obstaculo_get_itens_aceitos(_dados);
}

function scr_fechar_menu_obstaculo() {
    if (!variable_global_exists("ui_state")) return;

    global.ui_state.obstaculo_menu_aberto = false;
    global.ui_state.obstaculo_menu_obstaculo = noone;
    global.ui_state.obstaculo_menu_dados = noone;
    global.ui_state.obstaculo_menu_opcoes = [];
    global.ui_state.obstaculo_menu_texto = "";
    global.ui_state.obstaculo_selecao_item_ativa = false;
    global.ui_state.menu_tab_aberto = false;
    global.ui_state.inventario_aberto = false;
    global.ui_state.inventario_tela = "";
    global.ui_state.categoria_selecionada = "";
}

function scr_resetar_texto_menu_obstaculo() {
    if (!variable_global_exists("ui_state")) return;
    if (!global.ui_state.obstaculo_menu_aberto) return;

    var _dados = global.ui_state.obstaculo_menu_dados;
    if (!is_struct(_dados)) {
        global.ui_state.obstaculo_menu_texto = "";
        return;
    }

    if (variable_struct_exists(_dados, "texto_pergunta")) {
        global.ui_state.obstaculo_menu_texto = _dados.texto_pergunta;
    } else if (variable_struct_exists(_dados, "texto_bloqueado")) {
        global.ui_state.obstaculo_menu_texto = _dados.texto_bloqueado;
    }
}

function scr_get_obstaculo_menu_panel_rect() {
    return {
        x1 : global.ui_config.obstaculo_menu_x,
        y1 : global.ui_config.obstaculo_menu_y,
        x2 : global.ui_config.obstaculo_menu_x + global.ui_config.obstaculo_menu_w,
        y2 : global.ui_config.obstaculo_menu_y + global.ui_config.obstaculo_menu_h
    };
}

function scr_get_obstaculo_menu_opcao_rect(_index, _total) {
    var _panel = scr_get_obstaculo_menu_panel_rect();
    var _slot_w = global.ui_config.obstaculo_opcao_w;
    var _slot_h = global.ui_config.obstaculo_opcao_h;
    var _gap = global.ui_config.obstaculo_opcao_gap;
    var _total_w = (_total * _slot_w) + (max(0, _total - 1) * _gap);
    var _x1 = _panel.x1 + (((_panel.x2 - _panel.x1) - _total_w) * 0.5) + (_index * (_slot_w + _gap));
    var _y1 = _panel.y1 + 92;

    return {
        x1 : _x1,
        y1 : _y1,
        x2 : _x1 + _slot_w,
        y2 : _y1 + _slot_h
    };
}

function scr_get_obstaculo_menu_botao_rect() {
    var _panel = scr_get_obstaculo_menu_panel_rect();
    var _botao_w = global.ui_config.obstaculo_botao_w;
    var _botao_h = global.ui_config.obstaculo_botao_h;
    var _x1 = _panel.x1 + (((_panel.x2 - _panel.x1) - _botao_w) * 0.5);
    var _y1 = _panel.y2 - 110;

    return {
        x1 : _x1,
        y1 : _y1,
        x2 : _x1 + _botao_w,
        y2 : _y1 + _botao_h
    };
}

function scr_abrir_selecao_item_obstaculo() {
    if (!variable_global_exists("ui_state")) return false;
    if (!global.ui_state.obstaculo_menu_aberto) return false;

    global.ui_state.obstaculo_selecao_item_ativa = true;
    global.ui_state.menu_tab_aberto = true;
    global.ui_state.inventario_aberto = false;
    global.ui_state.inventario_tela = "itens";
    global.ui_state.categoria_selecionada = "";
    global.ui_state.item_menu_aberto = false;
    global.ui_state.item_menu_item = noone;
    global.ui_state.item_menu_acoes = [];
    global.ui_state.container_atual = noone;
    global.ui_state.obstaculo_menu_texto = "Escolha uma categoria e selecione qualquer item.";
    return true;
}

function scr_abrir_menu_obstaculo(_obstaculo) {
    if (!variable_global_exists("ui_state")) return false;
    if (!is_struct(_obstaculo) || !variable_struct_exists(_obstaculo, "obstaculo_id")) {
        return false;
    }

    var _dados = scr_get_obstaculo_data(_obstaculo.obstaculo_id);
    if (!is_struct(_dados)) return false;

    global.ui_state.obstaculo_menu_aberto = true;
    global.ui_state.obstaculo_menu_obstaculo = _obstaculo;
    global.ui_state.obstaculo_menu_dados = _dados;
    global.ui_state.obstaculo_menu_opcoes = scr_obstaculo_get_opcoes(_dados);
    global.ui_state.obstaculo_selecao_item_ativa = false;
    global.ui_state.menu_tab_aberto = true;
    global.ui_state.inventario_aberto = false;
    global.ui_state.inventario_tela = "obstaculo";
    global.ui_state.categoria_selecionada = "";
    global.ui_state.item_menu_aberto = false;
    global.ui_state.item_menu_item = noone;
    global.ui_state.item_menu_acoes = [];
    if (variable_struct_exists(_dados, "texto_pergunta")) {
        global.ui_state.obstaculo_menu_texto = _dados.texto_pergunta;
    } else {
        global.ui_state.obstaculo_menu_texto = _dados.texto_bloqueado;
    }
    global.ui_state.mensagem_contexto = "";
    global.ui_state.mensagem_timer = 0;
    return true;
}

function scr_resolver_sala_por_id(_id) {
    if (_id == "") return noone;
    if (variable_global_exists(_id)) return variable_global_get(_id);
    return noone;
}

function scr_aplicar_resolucao_obstaculo(_obstaculo, _dados) {
    if (!is_struct(_obstaculo) || !is_struct(_dados)
        || !variable_struct_exists(_dados, "ao_resolver")) {
        return;
    }

    switch (_dados.ao_resolver) {
        case "abrir_passagem":
            if (!variable_struct_exists(_dados, "dados_extra")
                || !is_struct(_dados.dados_extra)) {
                break;
            }

            var _extra = _dados.dados_extra;
            var _direcao = variable_struct_exists(_extra, "direcao") ? _extra.direcao : "";
            var _destino_id = variable_struct_exists(_extra, "destino_id") ? _extra.destino_id : "";
            var _destino = scr_resolver_sala_por_id(_destino_id);

            if (_direcao != "" && _destino != noone && is_struct(global.current_room)) {
                global.current_room[$ _direcao] = _destino;
            }
            break;
    }
}

function scr_resolver_obstaculo_cenario(_obstaculo, _item) {
    if (!is_struct(_obstaculo) || !variable_struct_exists(_obstaculo, "obstaculo_id")) {
        return false;
    }

    var _dados = scr_get_obstaculo_data(_obstaculo.obstaculo_id);
    if (!is_struct(_dados)) return false;

    var _base_necessaria = variable_struct_exists(_dados, "item_necessario") ? _dados.item_necessario : "";
    var _item_base = "";
    var _item_encontrado = noone;

    if (argument_count >= 2) {
        if (is_struct(_item) && variable_struct_exists(_item, "base")) {
            _item_base = _item.base;
            _item_encontrado = _item;
        }
        else if (is_string(_item)) {
            _item_base = _item;
            _item_encontrado = scr_inventario_get_item_por_base(_item_base);
        }
    }

    if (_item_base != "" && _item_encontrado == noone) {
        _item_encontrado = scr_inventario_get_item_por_base(_item_base);
    }

    var _opcoes = scr_obstaculo_get_itens_aceitos(_dados);
    var _item_aceito = (_base_necessaria == "" && array_length(_opcoes) <= 0);
    var _opcao_encontrada = noone;

    for (var i = 0; i < array_length(_opcoes); i++) {
        var _opcao = _opcoes[i];
        var _base_opcao = variable_struct_exists(_opcao, "base") ? _opcao.base : "";
        if (_base_opcao != "" && _item_base == _base_opcao) {
            _item_aceito = true;
            _opcao_encontrada = _opcao;
            break;
        }
    }

    if (!_item_aceito && _base_necessaria != "" && _item_base == _base_necessaria) {
        _item_aceito = true;
    }

    var _exige_item = (_base_necessaria != "" || _item_base != "");

    if (_item_aceito && (!_exige_item || _item_encontrado != noone)) {
        _obstaculo.removido = true;
        global.pode_cortar_teias = true;
        if (variable_struct_exists(_dados, "consome_item") && _dados.consome_item) {
            scr_remover_item_inventario(_item_encontrado);
        }
        scr_aplicar_resolucao_obstaculo(_obstaculo, _dados);
        var _texto_sucesso = variable_struct_exists(_dados, "texto_sucesso") ? _dados.texto_sucesso : "Caminho liberado.";
        if (is_struct(_opcao_encontrada)
            && variable_struct_exists(_opcao_encontrada, "texto_sucesso")
            && _opcao_encontrada.texto_sucesso != "") {
            _texto_sucesso = _opcao_encontrada.texto_sucesso;
        }
        scr_mostrar_mensagem_contexto(_texto_sucesso);
        if (variable_struct_exists(_dados, "encontro_apos_resolver") && _dados.encontro_apos_resolver != "") {
            scr_iniciar_encontro(_dados.encontro_apos_resolver, _obstaculo);
        }
        return true;
    }

    var _texto_falha = variable_struct_exists(_dados, "texto_falha") ? _dados.texto_falha : "Nada acontece.";
    if (variable_global_exists("ui_state") && global.ui_state.obstaculo_menu_aberto) {
        global.ui_state.obstaculo_menu_texto = _texto_falha;
        show_debug_message(_texto_falha);
    } else {
        scr_mostrar_mensagem_contexto(_texto_falha);
    }
    return false;
}

// =============================================================================
// =============================================================================
// SISTEMA DE EVENTOS E INTERACOES - FASE 1
// =============================================================================

function scr_get_interacao_data(_interacao_id) {
    if (!variable_global_exists("db_interacoes")
        || !variable_struct_exists(global.db_interacoes, _interacao_id)) return noone;
    return global.db_interacoes[$ _interacao_id];
}

function scr_get_evento_data(_evento_id) {
    if (!variable_global_exists("db_eventos")
        || !variable_struct_exists(global.db_eventos, _evento_id)) {
        show_debug_message("ERRO: evento inexistente no banco: " + string(_evento_id));
        return noone;
    }
    return global.db_eventos[$ _evento_id];
}

/// @description Abre o evento associado a uma interacao sem usar o contexto legado.
function scr_interacao_abrir(_interacao_id, _no_inicial) {
    var _interacao = scr_get_interacao_data(_interacao_id);
    if (!is_struct(_interacao) || !variable_struct_exists(_interacao, "evento_id")) return false;

    var _evento_id = _interacao.evento_id;
    if (_evento_id == "") return false;

    global.game_state = "interacao";
    return scr_evento_abrir(_evento_id, _interacao_id, _no_inicial);
}

function scr_evento_runtime_sincronizar() {
    if (!variable_global_exists("evento_runtime")
        || !is_struct(global.evento_runtime)
        || !global.evento_runtime.ativo) return;

    if (scr_contexto_ativo()) {
        global.evento_runtime.mensagem = global.contexto_interacao.mensagem;
    }
}

function scr_evento_abrir(_evento_id, _interacao_id, _no_inicial) {
    var _evento = scr_get_evento_data(_evento_id);
    if (!is_struct(_evento)) return false;

    var _no = _no_inicial;
    if (_no == "" && variable_struct_exists(_evento, "no_inicial")) _no = _evento.no_inicial;
    if (!variable_struct_exists(_evento, "nos") || !variable_struct_exists(_evento.nos, _no)) {
        show_debug_message("ERRO: no inicial inexistente no evento: " + string(_evento_id) + "/" + string(_no));
        return false;
    }

    global.evento_runtime.ativo        = true;
    global.evento_runtime.evento_id    = _evento_id;
    global.evento_runtime.interacao_id = _interacao_id;
    global.evento_runtime.contexto_id  = variable_struct_exists(_evento, "contexto_id") ? _evento.contexto_id : "";
    global.evento_runtime.no_atual     = _no;
    global.evento_runtime.estado       = _no;
    global.evento_runtime.escolha_selecionada = -1;
    global.evento_runtime.escolhas     = [];
    global.evento_runtime.mensagem     = "";
    global.evento_runtime.resultado    = "";
    global.evento_runtime.historico    = [];
    global.evento_runtime.ultimo_teste = noone;
    global.evento_runtime.apresentacao = {
        cenario_id       : "",
        legenda_id       : "",
        acao_id          : "",
        icones_liberados : false
    };
    global.evento_runtime.transicao_painel = {
        ativa      : false,
        fase       : "",
        proximo_no : "",
        alpha      : 1,
        velocidade : 0.12,
        troca_cenario : false,
        troca_legenda : false,
        troca_acao    : false
    };

    var _no_data = _evento.nos[$ _no];
    if (variable_struct_exists(_no_data, "escolhas")) {
        global.evento_runtime.escolhas = _no_data.escolhas;
    }
    scr_evento_apresentacao_aplicar(_no);
    return true;
}

function scr_evento_set_no(_no_id) {
    if (!variable_global_exists("evento_runtime") || !global.evento_runtime.ativo) return false;
    var _evento = scr_get_evento_data(global.evento_runtime.evento_id);
    if (!is_struct(_evento) || !variable_struct_exists(_evento, "nos")
        || !variable_struct_exists(_evento.nos, _no_id)) {
        show_debug_message("ERRO: no inexistente no evento: " + string(global.evento_runtime.evento_id) + "/" + string(_no_id));
        return false;
    }

    var _no_anterior = global.evento_runtime.no_atual;
    if (_no_id != _no_anterior && scr_contexto_ativo()) {
        global.contexto_interacao.mensagem = "";
    }
    global.evento_runtime.no_atual = _no_id;
    global.evento_runtime.estado = _no_id;
    global.evento_runtime.escolha_selecionada = -1;
    var _no_data = _evento.nos[$ _no_id];
    if (variable_struct_exists(_no_data, "escolhas")) {
        global.evento_runtime.escolhas = _no_data.escolhas;
    } else {
        global.evento_runtime.escolhas = [];
    }
    scr_evento_runtime_sincronizar();
    scr_evento_apresentacao_aplicar(_no_id);
    return true;
}

function scr_evento_apresentacao_obter_no(_no_id) {
    if (!scr_evento_ui_ativo()) return noone;
    var _evento = scr_get_evento_data(global.evento_runtime.evento_id);
    if (!is_struct(_evento) || !variable_struct_exists(_evento, "nos")
        || !variable_struct_exists(_evento.nos, _no_id)) return noone;
    var _no = _evento.nos[$ _no_id];
    return variable_struct_exists(_no, "apresentacao") ? _no.apresentacao : noone;
}

function scr_evento_apresentacao_aplicar(_no_id) {
    var _config = scr_evento_apresentacao_obter_no(_no_id);
    if (!is_struct(_config)) return;
    if (!variable_struct_exists(global.evento_runtime, "apresentacao")) {
        global.evento_runtime.apresentacao = {
            cenario_id : "", legenda_id : "", acao_id : "", icones_liberados : false
        };
    }

    if (variable_struct_exists(_config, "cenario")) global.evento_runtime.apresentacao.cenario_id = _config.cenario;
    if (variable_struct_exists(_config, "legenda")) global.evento_runtime.apresentacao.legenda_id = _config.legenda;
    if (variable_struct_exists(_config, "acao")) global.evento_runtime.apresentacao.acao_id = _config.acao;
    if (variable_struct_exists(_config, "libera_icones")) global.evento_runtime.apresentacao.icones_liberados = _config.libera_icones;
}

function scr_evento_apresentacao_alpha(_camada) {
    if (!scr_evento_transicao_painel_ativa()) return 1;
    var _transicao = global.evento_runtime.transicao_painel;
    var _campo = "troca_" + _camada;
    if (!variable_struct_exists(_transicao, _campo) || !variable_struct_get(_transicao, _campo)) return 1;
    return _transicao.alpha;
}

function scr_evento_get_icone(_id) {
    if (!scr_evento_ui_ativo()) return noone;
    var _evento = scr_get_evento_data(global.evento_runtime.evento_id);
    if (!is_struct(_evento) || !variable_struct_exists(_evento, "apresentacao")
        || !variable_struct_exists(_evento.apresentacao, "icones")) return noone;
    var _icones = _evento.apresentacao.icones;
    for (var i = 0; i < array_length(_icones); i++) {
        if (_icones[i].id == _id) return _icones[i];
    }
    return noone;
}

function scr_evento_executar_icone(_id) {
    if (!scr_evento_ui_ativo() || !global.evento_runtime.apresentacao.icones_liberados) return false;
    var _icone = scr_evento_get_icone(_id);
    if (!is_struct(_icone) || !variable_struct_exists(_icone, "proximo") || _icone.proximo == "") return false;
    return scr_evento_iniciar_transicao_painel(_icone.proximo);
}

function scr_evento_transicao_painel_ativa() {
    return scr_evento_ui_ativo()
        && variable_struct_exists(global.evento_runtime, "transicao_painel")
        && global.evento_runtime.transicao_painel.ativa;
}

function scr_evento_iniciar_transicao_painel(_proximo_no) {
    if (!scr_evento_ui_ativo()) return false;

    var _evento = scr_get_evento_data(global.evento_runtime.evento_id);
    if (!is_struct(_evento) || !variable_struct_exists(_evento, "nos")
        || !variable_struct_exists(_evento.nos, _proximo_no)) return false;

    var _alvo = scr_evento_apresentacao_obter_no(_proximo_no);
    if (!is_struct(_alvo)) return scr_evento_set_no(_proximo_no);

    var _atual = global.evento_runtime.apresentacao;
    global.evento_runtime.transicao_painel = {
        ativa      : true,
        fase       : "saida",
        proximo_no : _proximo_no,
        alpha      : 1,
        velocidade : 0.12,
        troca_cenario : !variable_struct_exists(_alvo, "cenario") || _alvo.cenario != _atual.cenario_id,
        troca_legenda : !variable_struct_exists(_alvo, "legenda") || _alvo.legenda != _atual.legenda_id,
        troca_acao    : !variable_struct_exists(_alvo, "acao") || _alvo.acao != _atual.acao_id
    };
    return true;
}

function scr_evento_atualizar_transicao_painel() {
    if (!scr_evento_transicao_painel_ativa()) return;

    var _transicao = global.evento_runtime.transicao_painel;
    if (_transicao.fase == "saida") {
        _transicao.alpha = max(0, _transicao.alpha - _transicao.velocidade);
        if (_transicao.alpha <= 0) {
            if (scr_evento_set_no(_transicao.proximo_no)) {
                _transicao.fase = "entrada";
            } else {
                _transicao.ativa = false;
                _transicao.alpha = 1;
            }
        }
    } else {
        _transicao.alpha = min(1, _transicao.alpha + _transicao.velocidade);
        if (_transicao.alpha >= 1) {
            _transicao.ativa = false;
            _transicao.fase = "";
            _transicao.proximo_no = "";
        }
    }
}

function scr_evento_registrar_escolha(_escolha_id) {
    if (!variable_global_exists("evento_runtime") || !global.evento_runtime.ativo) return false;
    array_push(global.evento_runtime.historico, {
        no      : global.evento_runtime.no_atual,
        escolha : _escolha_id,
        estado  : global.evento_runtime.estado
    });
    global.evento_runtime.resultado = _escolha_id;
    return true;
}

function scr_evento_fechar() {
    if (!variable_global_exists("evento_runtime") || !is_struct(global.evento_runtime)) return;
    global.evento_runtime.ativo = false;
    global.evento_runtime.escolha_selecionada = -1;
    global.evento_runtime.escolhas = [];
    global.evento_runtime.mensagem = "";
    if (variable_struct_exists(global.evento_runtime, "transicao_painel")) {
        global.evento_runtime.transicao_painel.ativa = false;
        global.evento_runtime.transicao_painel.alpha = 1;
    }
    if (!scr_contexto_ativo()) global.game_state = "exploracao";
}

// SISTEMA DE INTERACAO CONTEXTUAL
// =============================================================================

// =============================================================================
// SISTEMA DE EVENTOS EM PAINEL - PILOTO FASE 2
// =============================================================================

function scr_evento_ui_ativo() {
    if (!variable_global_exists("evento_runtime") || !global.evento_runtime.ativo) return false;
    if (!variable_global_exists("db_eventos") || global.evento_runtime.evento_id == "") return false;
    var _evento = scr_get_evento_data(global.evento_runtime.evento_id);
    return is_struct(_evento) && variable_struct_exists(_evento, "nos");
}

function scr_evento_get_no_atual() {
    if (!scr_evento_ui_ativo()) return noone;
    var _evento = scr_get_evento_data(global.evento_runtime.evento_id);
    if (!is_struct(_evento) || !variable_struct_exists(_evento, "nos")) return noone;
    var _no_id = global.evento_runtime.no_atual;
    if (!variable_struct_exists(_evento.nos, _no_id)) return noone;
    return _evento.nos[$ _no_id];
}

function scr_evento_get_escolhas() {
    var _no = scr_evento_get_no_atual();
    if (!is_struct(_no) || !variable_struct_exists(_no, "escolhas")) return [];
    return _no.escolhas;
}

function scr_evento_get_escolha(_id) {
    var _escolhas = scr_evento_get_escolhas();
    for (var i = 0; i < array_length(_escolhas); i++) {
        if (variable_struct_exists(_escolhas[i], "id") && _escolhas[i].id == _id) return _escolhas[i];
    }
    return noone;
}

function scr_evento_get_painel_rect() {
    var _evento = scr_get_evento_data(global.evento_runtime.evento_id);
    var _painel = _evento.painel;
    return { x1 : _painel.pos_x, y1 : _painel.pos_y, x2 : _painel.pos_x + _painel.largura, y2 : _painel.pos_y + _painel.altura };
}

function scr_evento_get_escolha_rect(_index) {
    var _evento = scr_get_evento_data(global.evento_runtime.evento_id);
    var _painel = _evento.painel;
    var _escolhas = scr_evento_get_escolhas();
    if (_index < 0 || _index >= array_length(_escolhas)) return { x1 : 0, y1 : 0, x2 : 0, y2 : 0 };

    var _escolha = _escolhas[_index];
    if (variable_struct_exists(_escolha, "x") && variable_struct_exists(_escolha, "y")) {
        var _largura = variable_struct_exists(_escolha, "largura") ? _escolha.largura : _painel.escolha_largura;
        var _altura = variable_struct_exists(_escolha, "altura") ? _escolha.altura : _painel.escolha_altura;
        return { x1 : _painel.pos_x + _escolha.x, y1 : _painel.pos_y + _escolha.y, x2 : _painel.pos_x + _escolha.x + _largura, y2 : _painel.pos_y + _escolha.y + _altura };
    }

    var _inicio_y = variable_struct_exists(_painel, "escolha_inicio_y") ? _painel.escolha_inicio_y : (_painel.pos_y + _painel.altura - 260);
    var _y = _inicio_y + (_index * (_painel.escolha_altura + _painel.escolha_espaco));
    return { x1 : _painel.pos_x + _painel.escolha_x, y1 : _y, x2 : _painel.pos_x + _painel.escolha_x + _painel.escolha_largura, y2 : _y + _painel.escolha_altura };
}

function scr_rpg_obter_valor(_grupo, _id) {
    if (!variable_global_exists("personagem_rpg") || !is_struct(global.personagem_rpg)) return 0;
    if (!variable_struct_exists(global.personagem_rpg, _grupo)) return 0;

    var _valores = global.personagem_rpg[$ _grupo];
    if (!is_struct(_valores) || !variable_struct_exists(_valores, _id)) return 0;
    return _valores[$ _id];
}

function scr_rpg_registrar_memoria(_fragmento_id, _escolha_id, _pontos) {
    if (!variable_global_exists("personagem_rpg") || !is_struct(global.personagem_rpg)) return false;

    if (!variable_global_exists("personagem_status") || !is_struct(global.personagem_status)) {
        global.personagem_status = { nivel : 1, pontos_de_status : 0, pontos_memoria : 0 };
    }
    else if (!variable_struct_exists(global.personagem_status, "pontos_memoria")) {
        global.personagem_status.pontos_memoria = 0;
    }

    if (!variable_struct_exists(global.personagem_rpg, "memorias") || !is_struct(global.personagem_rpg.memorias)) {
        global.personagem_rpg.memorias = {
            pontos_disponiveis : 0,
            fragmentos : [],
            nos_desbloqueados : {},
            escolhas : []
        };
    }

    if (!variable_struct_exists(global.personagem_rpg, "status") || !is_struct(global.personagem_rpg.status)) {
        global.personagem_rpg.status = { conviccao : 0, perseveranca : 0, fragmentos : 0 };
    }

    var _ja_descoberto = false;
    for (var i = 0; i < array_length(global.personagem_rpg.memorias.fragmentos); i++) {
        if (global.personagem_rpg.memorias.fragmentos[i] == _fragmento_id) {
            _ja_descoberto = true;
            break;
        }
    }
    if (!_ja_descoberto) {
        array_push(global.personagem_rpg.memorias.fragmentos, _fragmento_id);
        global.personagem_rpg.status.fragmentos += 1;
    }

    var _registro = { fragmento_id : _fragmento_id, escolha_id : _escolha_id };
    array_push(global.personagem_rpg.memorias.escolhas, _registro);

    // Repetir a mesma memoria registra a decisao, mas nao gera pontos extras.
    if (!_ja_descoberto) {
        var _ganho = max(0, _pontos);
        global.personagem_rpg.memorias.pontos_disponiveis += _ganho;
        global.personagem_status.pontos_memoria += _ganho;

        if (variable_global_exists("run_atual") && is_struct(global.run_atual)) {
            global.run_atual.pontos_memoria += _ganho;
            array_push(global.run_atual.fragmentos_descobertos, _fragmento_id);
            array_push(global.run_atual.escolhas_memoria, _registro);
        }
    }

    return !_ja_descoberto;
}

function scr_rpg_somar_modificadores(_modificadores) {
    if (is_real(_modificadores)) return _modificadores;
    if (!is_array(_modificadores)) return 0;

    var _total = 0;
    for (var i = 0; i < array_length(_modificadores); i++) {
        var _modificador = _modificadores[i];
        if (is_real(_modificador)) {
            _total += _modificador;
        } else if (is_struct(_modificador) && variable_struct_exists(_modificador, "valor")) {
            _total += _modificador.valor;
        }
    }
    return _total;
}

function scr_rpg_aplicar_investigacao_rapida(_custo_sanidade) {
    if (!variable_global_exists("personagem_rpg") || !is_struct(global.personagem_rpg)) return false;
    if (!variable_struct_exists(global.personagem_rpg, "recursos") || !is_struct(global.personagem_rpg.recursos)) {
        global.personagem_rpg.recursos = { sanidade : 100, sanidade_max : 100 };
    }

    var _sanidade_atual = variable_struct_exists(global.personagem_rpg.recursos, "sanidade")
        ? global.personagem_rpg.recursos.sanidade : 100;
    global.personagem_rpg.recursos.sanidade = max(0, _sanidade_atual - max(0, _custo_sanidade));
    return true;
}

function scr_rpg_testar(_atributo_id, _habilidade_id, _dificuldade, _modificadores) {
    var _dado_1 = irandom_range(1, 6);
    var _dado_2 = irandom_range(1, 6);
    var _atributo = scr_rpg_obter_valor("atributos", _atributo_id);
    var _habilidade = scr_rpg_obter_valor("habilidades", _habilidade_id);
    var _bonus = scr_rpg_somar_modificadores(_modificadores);
    var _total = _dado_1 + _dado_2 + _atributo + _habilidade + _bonus;
    var _resultado = "sucesso";

    if (_total <= _dificuldade - 5) {
        _resultado = "falha_critica";
    } else if (_total < _dificuldade) {
        _resultado = "falha";
    } else if (_total == _dificuldade) {
        _resultado = "sucesso_parcial";
    } else if (_total >= _dificuldade + 6) {
        _resultado = "sucesso_critico";
    }

    var _teste = {
        atributo : _atributo_id,
        habilidade : _habilidade_id,
        dificuldade : _dificuldade,
        dado_1 : _dado_1,
        dado_2 : _dado_2,
        atributo_valor : _atributo,
        habilidade_valor : _habilidade,
        modificadores : _bonus,
        total : _total,
        resultado : _resultado
    };
    global.rpg_ultimo_teste = _teste;
    array_push(global.rpg_historico_testes, _teste);
    return _teste;
}

function scr_evento_resolver_proximo(_escolha) {
    if (!is_struct(_escolha)) return "";
    var _proximo = variable_struct_exists(_escolha, "proximo") ? _escolha.proximo : "";
    if (!variable_struct_exists(_escolha, "teste") || !is_struct(_escolha.teste)) return _proximo;

    var _config = _escolha.teste;
    var _atributo = variable_struct_exists(_config, "atributo") ? _config.atributo : "";
    var _habilidade = variable_struct_exists(_config, "habilidade") ? _config.habilidade : "";
    var _dificuldade = variable_struct_exists(_config, "dificuldade") ? _config.dificuldade : 11;
    var _modificadores = variable_struct_exists(_config, "modificadores") ? _config.modificadores : 0;
    var _teste = scr_rpg_testar(_atributo, _habilidade, _dificuldade, _modificadores);
    global.evento_runtime.ultimo_teste = _teste;

    var _campo_resultado = "proximo_" + _teste.resultado;
    if (variable_struct_exists(_config, _campo_resultado)) {
        _proximo = _config[$ _campo_resultado];
    }
    return _proximo;
}

function scr_evento_executar_escolha(_id) {
    if (!scr_evento_ui_ativo()) return "";
    var _escolhas = scr_evento_get_escolhas();
    var _escolha = noone;
    var _indice = -1;
    for (var i = 0; i < array_length(_escolhas); i++) {
        if (variable_struct_exists(_escolhas[i], "id") && _escolhas[i].id == _id) {
            _escolha = _escolhas[i];
            _indice = i;
            break;
        }
    }
    if (!is_struct(_escolha)) return "";

    // Opcoes selecionaveis apenas marcam a escolha. A transicao ocorre no confirmar.
    if (variable_struct_exists(_escolha, "selecionavel") && _escolha.selecionavel) {
        global.evento_runtime.escolha_selecionada = _indice;
        global.evento_runtime.resultado = _id;
        return "";
    }

    scr_evento_registrar_escolha(_id);

    if (variable_struct_exists(_escolha, "acao") && _escolha.acao == "confirmar_escolha") {
        var _indice_selecionado = global.evento_runtime.escolha_selecionada;
        if (_indice_selecionado < 0 || _indice_selecionado >= array_length(_escolhas)) return "";
        var _escolha_confirmada = _escolhas[_indice_selecionado];
        if (!variable_struct_exists(_escolha_confirmada, "selecionavel") || !_escolha_confirmada.selecionavel) return "";
        global.evento_runtime.resultado = _escolha_confirmada.id;
        var _proximo_confirmado = scr_evento_resolver_proximo(_escolha_confirmada);
        if (_proximo_confirmado != "") {
            scr_evento_set_no(_proximo_confirmado);
        }
        return "";
    }

    if (variable_struct_exists(_escolha, "acao") && _escolha.acao == "sair_contexto") {
        if (scr_contexto_ativo()) scr_contexto_fechar();
        else scr_evento_fechar();
        return "fechou";
    }

    var _resultado = "";
    var _acao_escolha = variable_struct_exists(_escolha, "acao") ? _escolha.acao : "";
    if (_acao_escolha == "rpg_investigacao_rapida") {
        scr_rpg_aplicar_investigacao_rapida(3);
    } else if (_acao_escolha != "") {
        _resultado = scr_contexto_executar_acao(_escolha.acao);
    }
    if (_resultado != "") return _resultado;
    var _proximo = scr_evento_resolver_proximo(_escolha);
    if (_proximo != "") {
        if (variable_struct_exists(_escolha, "transicao_painel")
            && _escolha.transicao_painel == "fade") {
            scr_evento_iniciar_transicao_painel(_proximo);
        } else {
            scr_evento_set_no(_proximo);
        }
    }
    return "";
}

function scr_contexto_ativo() {
    return variable_global_exists("contexto_interacao")
        && is_struct(global.contexto_interacao)
        && global.contexto_interacao.ativo;
}

function scr_contexto_aguardando_item() {
    return scr_contexto_ativo()
        && variable_struct_exists(global.contexto_interacao, "aguardando_item")
        && global.contexto_interacao.aguardando_item;
}

function scr_get_contexto_data(_contexto_id) {
    if (!variable_global_exists("db_contextos_interacao")
        || !variable_struct_exists(global.db_contextos_interacao, _contexto_id)) {
        show_debug_message("ERRO: contexto inexistente no banco: " + string(_contexto_id));
        return noone;
    }

    return global.db_contextos_interacao[$ _contexto_id];
}

function scr_contexto_get_estado() {
    if (is_struct(global.current_room) && variable_struct_exists(global.current_room, "contexto_estado")) {
        return global.current_room.contexto_estado;
    }

    if (scr_contexto_ativo()
        && is_struct(global.contexto_interacao.dados)
        && variable_struct_exists(global.contexto_interacao.dados, "estado_inicial")) {
        return global.contexto_interacao.dados.estado_inicial;
    }

    return "bloqueada";
}

function scr_contexto_set_estado(_estado) {
    if (is_struct(global.current_room)) {
        global.current_room.contexto_estado = _estado;
    }
    if (variable_global_exists("evento_runtime") && is_struct(global.evento_runtime)
        && global.evento_runtime.ativo) {
    }
}

function scr_contexto_get_sair_destino() {
    if (is_struct(global.current_room)
        && variable_struct_exists(global.current_room, "contexto_sair_destino")) {
        return global.current_room.contexto_sair_destino;
    }

    return noone;
}

function scr_contexto_get_passagem_destino() {
    if (!scr_contexto_ativo()) return noone;

    var _dados_contexto = global.contexto_interacao.dados;
    if (!is_struct(_dados_contexto)
        || !variable_struct_exists(_dados_contexto, "obstaculo_id")) {
        return noone;
    }

    var _dados_obstaculo = scr_get_obstaculo_data(_dados_contexto.obstaculo_id);
    if (!is_struct(_dados_obstaculo)
        || !variable_struct_exists(_dados_obstaculo, "dados_extra")
        || !is_struct(_dados_obstaculo.dados_extra)) {
        return noone;
    }

    var _destino_id = variable_struct_exists(_dados_obstaculo.dados_extra, "destino_id")
        ? _dados_obstaculo.dados_extra.destino_id
        : "";
    return scr_resolver_sala_por_id(_destino_id);
}

function scr_contexto_get_item_por_tipo(_tipo) {
    if (!is_struct(global.current_room) || !variable_struct_exists(global.current_room, "itens")) {
        return noone;
    }

    var _itens = global.current_room.itens;
    for (var i = 0; i < array_length(_itens); i++) {
        var _item = _itens[i];
        var _item_tipo = variable_struct_exists(_item, "tipo") ? _item.tipo : "";
        if (_item_tipo == _tipo) {
            return _item;
        }
    }

    return noone;
}

function scr_contexto_get_obstaculo(_obstaculo_id) {
    if (!is_struct(global.current_room) || !variable_struct_exists(global.current_room, "itens")) {
        return noone;
    }

    var _itens = global.current_room.itens;
    for (var i = 0; i < array_length(_itens); i++) {
        var _item = _itens[i];
        if (variable_struct_exists(_item, "obstaculo_id") && _item.obstaculo_id == _obstaculo_id) {
            return _item;
        }
    }

    return noone;
}

function scr_contexto_sincronizar_estado() {
    if (!scr_contexto_ativo()) return;

    var _dados = global.contexto_interacao.dados;
    if (!is_struct(_dados) || !variable_struct_exists(_dados, "obstaculo_id")) return;

    var _obstaculo = scr_contexto_get_obstaculo(_dados.obstaculo_id);
    if (is_struct(_obstaculo)
        && variable_struct_exists(_obstaculo, "removido")
        && _obstaculo.removido
        && scr_contexto_get_estado() == "bloqueada") {
        scr_contexto_set_estado("teias_removidas");
    }
}

function scr_contexto_get_elemento(_elemento_id) {
    if (!scr_contexto_ativo()) return noone;

    var _dados = global.contexto_interacao.dados;
    if (!is_struct(_dados) || !variable_struct_exists(_dados, "elementos")) {
        return noone;
    }

    for (var i = 0; i < array_length(_dados.elementos); i++) {
        var _elemento = _dados.elementos[i];
        if (variable_struct_exists(_elemento, "id") && _elemento.id == _elemento_id) {
            return _elemento;
        }
    }

    return noone;
}

function scr_contexto_get_elemento_atual() {
    if (!scr_contexto_ativo()) return noone;
    return scr_contexto_get_elemento(global.contexto_interacao.elemento_atual);
}

function scr_contexto_get_texto_elemento(_elemento) {
    if (!is_struct(_elemento) || !variable_struct_exists(_elemento, "textos")) {
        return "";
    }

    var _estado = scr_contexto_get_estado();
    if (variable_struct_exists(_elemento.textos, _estado)) {
        return _elemento.textos[$ _estado];
    }

    if (variable_struct_exists(_elemento.textos, "bloqueada")) {
        return _elemento.textos.bloqueada;
    }

    return "";
}

function scr_contexto_get_acoes_elemento(_elemento) {
    if (!is_struct(_elemento) || !variable_struct_exists(_elemento, "acoes")) {
        return [];
    }

    var _estado = scr_contexto_get_estado();
    if (variable_struct_exists(_elemento.acoes, _estado)) {
        return _elemento.acoes[$ _estado];
    }

    if (variable_struct_exists(_elemento.acoes, "bloqueada")) {
        return _elemento.acoes.bloqueada;
    }

    return [];
}

function scr_contexto_fechar() {
    if (!variable_global_exists("contexto_interacao")) return;

    global.contexto_interacao.ativo = false;
    global.contexto_interacao.contexto_id = "";
    global.contexto_interacao.dados = noone;
    global.contexto_interacao.elemento_atual = "";
    global.contexto_interacao.mensagem = "";
    global.contexto_interacao.aguardando_item = false;
    global.contexto_interacao.item_alvo = "";
    scr_evento_fechar();

    if (variable_global_exists("ui_state")) {
        global.ui_state.menu_tab_aberto = false;
        global.ui_state.inventario_aberto = false;
        global.ui_state.inventario_tela = "";
        global.ui_state.categoria_selecionada = "";
        scr_inventory_reset_item_menu();
    }

    if (variable_global_exists("game_state") && global.game_state == "contexto") {
        global.game_state = "exploracao";
    }
}

function scr_contexto_abrir(_contexto_id, _elemento_inicial) {
    var _dados = scr_get_contexto_data(_contexto_id);
    if (!is_struct(_dados)) return false;

    if (argument_count < 2 || _elemento_inicial == "") {
        _elemento_inicial = "inicio";
    }

    if (is_struct(global.current_room)
        && !variable_struct_exists(global.current_room, "contexto_estado")
        && variable_struct_exists(_dados, "estado_inicial")) {
        global.current_room.contexto_estado = _dados.estado_inicial;
    }

    global.contexto_interacao = {
        ativo          : true,
        contexto_id    : _contexto_id,
        dados          : _dados,
        elemento_atual : _elemento_inicial,
        mensagem       : "",
        aguardando_item: false,
        item_alvo      : ""
    };

    global.game_state = "contexto";

    if (variable_global_exists("ui_state")) {
        global.ui_state.obstaculo_menu_aberto = false;
        global.ui_state.obstaculo_selecao_item_ativa = false;
        global.ui_state.menu_tab_aberto = false;
        global.ui_state.inventario_aberto = false;
        global.ui_state.inventario_tela = "";
        global.ui_state.categoria_selecionada = "";
        global.ui_state.container_atual = noone;
        scr_inventory_reset_item_menu();
    }

    scr_contexto_sincronizar_estado();
    var _evento_id = "evento_cadaver_escavador";
    var _interacao_id = "";
    var _evento_auto_abrir = false;
    if (variable_global_exists("db_interacoes") && is_struct(global.db_interacoes)) {
        var _interacoes = variable_struct_get_names(global.db_interacoes);
        for (var ii = 0; ii < array_length(_interacoes); ii++) {
            var _interacao = global.db_interacoes[$ _interacoes[ii]];
            if (variable_struct_exists(_interacao, "contexto_id")
                && _interacao.contexto_id == _contexto_id
                && variable_struct_exists(_interacao, "elemento_id")
                && _interacao.elemento_id == _elemento_inicial) {
                _interacao_id = _interacao.id;
                if (variable_struct_exists(_interacao, "evento_id")) _evento_id = _interacao.evento_id;
                _evento_auto_abrir = variable_struct_exists(_interacao, "evento_auto_abrir")
                    && _interacao.evento_auto_abrir;
                break;
            }
        }
    }
    if (_evento_auto_abrir) {
        if (_interacao_id == "") _interacao_id = _contexto_id + "_" + _elemento_inicial;
        var _evento_no_inicial = "";
        scr_evento_abrir(_evento_id, _interacao_id, _evento_no_inicial);
        scr_evento_runtime_sincronizar();
    }
    return true;
}

function scr_contexto_selecionar_elemento(_elemento_id) {
    if (!scr_contexto_ativo()) return false;
    if (scr_contexto_get_elemento(_elemento_id) == noone) return false;

    global.contexto_interacao.elemento_atual = _elemento_id;
    global.contexto_interacao.mensagem = "";
    scr_evento_set_no(_elemento_id);

    if (_elemento_id == "voltar") {
        scr_contexto_fechar();
    }

    return true;
}

function scr_get_contexto_elemento_rect(_index) {
    var _x1 = global.ui_config.contexto_rail_x
        + (_index * (global.ui_config.contexto_rail_slot_w + global.ui_config.contexto_rail_gap));
    var _y1 = global.ui_config.contexto_rail_y;

    return {
        x1 : _x1,
        y1 : _y1,
        x2 : _x1 + global.ui_config.contexto_rail_slot_w,
        y2 : _y1 + global.ui_config.contexto_rail_slot_h
    };
}

function scr_get_contexto_back_rect() {
    return {
        x1 : global.ui_config.contexto_back_x,
        y1 : global.ui_config.contexto_back_y,
        x2 : global.ui_config.contexto_back_x + global.ui_config.contexto_back_w,
        y2 : global.ui_config.contexto_back_y + global.ui_config.contexto_back_h
    };
}

function scr_get_contexto_action_rect(_index) {
    var _x1 = global.ui_config.contexto_action_x;
    var _y1 = global.ui_config.contexto_action_y
        + (_index * (global.ui_config.contexto_action_h + global.ui_config.contexto_action_gap));

    return {
        x1 : _x1,
        y1 : _y1,
        x2 : _x1 + global.ui_config.contexto_action_w,
        y2 : _y1 + global.ui_config.contexto_action_h
    };
}

function scr_contexto_abrir_selecao_item(_item_alvo) {
    if (!scr_contexto_ativo()) return false;

    global.contexto_interacao.aguardando_item = true;
    global.contexto_interacao.item_alvo = _item_alvo;
    global.contexto_interacao.mensagem = "Escolha qualquer item do inventario.";

    global.ui_state.menu_tab_aberto = true;
    global.ui_state.inventario_aberto = false;
    global.ui_state.inventario_tela = "itens";
    global.ui_state.categoria_selecionada = "";
    global.ui_state.item_menu_aberto = false;
    global.ui_state.item_menu_item = noone;
    global.ui_state.item_menu_acoes = [];
    global.ui_state.container_atual = noone;
    return true;
}

function scr_contexto_cancelar_selecao_item() {
    if (!scr_contexto_ativo()) return false;

    global.contexto_interacao.aguardando_item = false;
    global.contexto_interacao.item_alvo = "";
    global.contexto_interacao.mensagem = "";
    global.ui_state.menu_tab_aberto = false;
    global.ui_state.inventario_aberto = false;
    global.ui_state.inventario_tela = "";
    global.ui_state.categoria_selecionada = "";
    scr_inventory_reset_item_menu();
    return true;
}

function scr_contexto_usar_item(_item) {
    if (!scr_contexto_ativo()) return false;

    var _dados = global.contexto_interacao.dados;
    if (!is_struct(_dados) || !variable_struct_exists(_dados, "obstaculo_id")) {
        scr_contexto_cancelar_selecao_item();
        return false;
    }

    var _obstaculo = scr_contexto_get_obstaculo(_dados.obstaculo_id);
    global.contexto_interacao.aguardando_item = false;
    global.contexto_interacao.item_alvo = "";
    global.ui_state.menu_tab_aberto = false;
    global.ui_state.inventario_aberto = false;
    global.ui_state.inventario_tela = "";
    global.ui_state.categoria_selecionada = "";
    scr_inventory_reset_item_menu();

    if (!is_struct(_obstaculo)) {
        global.contexto_interacao.mensagem = "Nada nesta cena reage ao item.";
        return false;
    }

    var _resolvido = scr_resolver_obstaculo_cenario(_obstaculo, _item);
    if (_resolvido) {
        scr_contexto_set_estado("teias_removidas");
        global.contexto_interacao.ativo = false;
        global.contexto_interacao.aguardando_item = false;
        return true;
    }

    global.contexto_interacao.mensagem = "Esse item nao resolve as teias.";
    return false;
}

function scr_contexto_preparar_autopsia() {
    var _cadaver = scr_contexto_get_item_por_tipo("cadaver");
    if (!is_struct(_cadaver)) {
        if (scr_contexto_ativo()) {
            global.contexto_interacao.mensagem = "Nao ha cadaver acessivel aqui.";
        }
        return false;
    }

    global.autopsia_retorno_room_real = room;
    global.autopsia_retorno_sala_logica = global.current_room;
    global.autopsia_cadaver_atual = _cadaver;
    global.autopsia_id_atual = variable_struct_exists(_cadaver, "autopsia_id") ? _cadaver.autopsia_id : "escavador_01";
    scr_contexto_fechar();
    return true;
}

function scr_contexto_executar_acao(_acao_id) {
    if (!scr_contexto_ativo()) return "";

    scr_contexto_sincronizar_estado();
    scr_evento_registrar_escolha(_acao_id);


    // Ponte temporaria: o contexto abre o evento, mas o evento controla os nos.
    if (!scr_evento_ui_ativo()) {
        var _no_evento_acao = "";
        switch (_acao_id) {
            case "tentar_abrir_porta": _no_evento_acao = "porta"; break;
            case "usar_item_teias": _no_evento_acao = "teias"; break;
            case "olhar_cadaver": _no_evento_acao = "cadaver"; break;
        }
        if (_no_evento_acao != "") {
            var _evento_piloto = scr_get_evento_data("evento_cadaver_escavador");
            if (is_struct(_evento_piloto) && variable_struct_exists(_evento_piloto, "nos")
                && variable_struct_exists(_evento_piloto.nos, _no_evento_acao)
                && scr_evento_abrir("evento_cadaver_escavador", _acao_id, _no_evento_acao)) {
                return "abrir_evento";
            }
        }
    }
    switch (_acao_id) {
        case "sair_contexto":
            scr_contexto_fechar();
            return "fechou";

        case "examinar_porta":
            if (scr_contexto_get_estado() == "bloqueada") {
                global.contexto_interacao.mensagem = "A trava parece presa por dentro. As teias escondem onde mexer.";
            } else if (scr_contexto_get_estado() == "teias_removidas") {
                global.contexto_interacao.mensagem = "Agora voce consegue tocar a trava da porta.";
            } else {
                global.contexto_interacao.mensagem = "A porta esta aberta.";
            }
            break;

        case "tentar_abrir_porta":
            global.contexto_interacao.mensagem = "A porta nao cede enquanto as teias segurarem o mecanismo.";
            break;

        case "abrir_porta":
            if (scr_contexto_get_estado() == "teias_removidas") {
                var _dados_contexto = global.contexto_interacao.dados;
                if (is_struct(_dados_contexto)
                    && variable_struct_exists(_dados_contexto, "obstaculo_id")) {
                    var _dados_obstaculo = scr_get_obstaculo_data(_dados_contexto.obstaculo_id);
                    if (is_struct(_dados_obstaculo)
                        && variable_struct_exists(_dados_obstaculo, "dados_extra")
                        && is_struct(_dados_obstaculo.dados_extra)) {
                        var _extra = _dados_obstaculo.dados_extra;
                        var _direcao = variable_struct_exists(_extra, "direcao") ? _extra.direcao : "";
                        var _destino_id = variable_struct_exists(_extra, "destino_id") ? _extra.destino_id : "";
                        var _destino = scr_resolver_sala_por_id(_destino_id);
                        if (_direcao != "" && _destino != noone && is_struct(global.current_room)) {
                            global.current_room[$ _direcao] = _destino;
                        }
                    }
                }
                scr_contexto_set_estado("porta_aberta");
                global.contexto_interacao.mensagem = "A porta destrava. A passagem pode ser atravessada.";
            } else {
                global.contexto_interacao.mensagem = "Ainda ha algo bloqueando a porta.";
            }
            break;

        case "seguir_porta":
            if (scr_contexto_get_estado() == "porta_aberta") {
                return "seguir_destino";
            }
            global.contexto_interacao.mensagem = "A porta ainda nao esta aberta.";
            break;

        case "examinar_teias":
            if (scr_contexto_get_estado() == "bloqueada") {
                global.contexto_interacao.mensagem = "Os fios sao densos demais para serem arrancados com a mao.";
            } else {
                global.contexto_interacao.mensagem = "As teias cortadas abriram a passagem.";
            }
            break;

        case "usar_item_teias":
            scr_contexto_abrir_selecao_item("teias");
            return "inventario";

        case "examinar_cadaver":
            global.contexto_interacao.mensagem = "O corpo tem marcas de escavacao e uma das maos esta presa sob a capa.";
            break;

        case "olhar_cadaver":
            if (scr_contexto_preparar_autopsia()) {
                return "abrir_autopsia";
            }
            break;
    }

    scr_evento_runtime_sincronizar();
    return "";
}

// =============================================================================
// SISTEMA DE COLETA UNIFICADO
// =============================================================================

/// @function scr_coletar_item(item_struct)
/// @description Coleta um item e coloca na categoria correta do inventÃ¡rio.
///              Substitui os 2 switches duplicados de 9 cases.
function scr_coletar_item(_item) {
    // Se o item tem "base", instanciar a partir do banco
    var _struct_final;
    if (variable_struct_exists(_item, "base") && !variable_struct_exists(_item, "nome")) {
        _struct_final = scr_instanciar_item(_item.base);
    } else {
        // Item jÃ¡ Ã© uma struct completa (vindo de container, por exemplo)
        _struct_final = _item;
    }

    if (_struct_final == noone) return false;

    var _cat = variable_struct_exists(_struct_final, "categoria") ? _struct_final.categoria : "geral";
    var _ok = scr_inventario_adicionar(_struct_final);

    if (_ok) {
        show_debug_message("Item coletado: " + _struct_final.nome + " -> categoria: " + _cat);
    }

    return _ok;

    var _array_alvo = global.inventarios.geral;

    // Auto-triagem: joga no sub-array correto automaticamente
    if (variable_struct_exists(global.inventarios, _cat)) {
        _array_alvo = global.inventarios[$ _cat];
    }

    var _base = variable_struct_exists(_struct_final, "base") ? _struct_final.base : "";
    var _qtd = variable_struct_exists(_struct_final, "quantidade") ? _struct_final.quantidade : 1;
    var _stack = variable_struct_exists(_struct_final, "stack") ? max(1, _struct_final.stack) : 1;

    if (_base != "" && _stack > 1) {
        for (var i = 0; i < array_length(_array_alvo); i++) {
            var _existente = _array_alvo[i];
            if (variable_struct_exists(_existente, "base") && _existente.base == _base) {
                var _existente_qtd = variable_struct_exists(_existente, "quantidade") ? _existente.quantidade : 1;
                if (_existente_qtd < _stack) {
                    _existente.quantidade = min(_stack, _existente_qtd + _qtd);
                    show_debug_message("Item empilhado: " + _struct_final.nome + " x" + string(_existente.quantidade));
                    return true;
                }
            }
        }
    }

    var _limite = scr_get_inventory_slot_limit(_cat);
    if (array_length(_array_alvo) >= _limite) {
        show_debug_message("Inventario cheio para categoria: " + _cat);
        return false;
    }

    if (variable_struct_exists(global.inventarios, _cat)) {
        array_push(global.inventarios[$ _cat], _struct_final);
    } else {
        array_push(global.inventarios.geral, _struct_final);
    }

    show_debug_message("Item coletado: " + _struct_final.nome + " â†’ categoria: " + _cat);
    return true;
}

// =============================================================================
// SISTEMA DE INTERAÃ‡ÃƒO DATA-DRIVEN (usar_item)
// =============================================================================
function scr_inventory_reset_item_menu() {
    if (!variable_global_exists("ui_state")) return;

    global.ui_state.item_menu_aberto = false;
    global.ui_state.item_menu_item = noone;
    global.ui_state.item_menu_categoria = "";
    global.ui_state.item_menu_indice = -1;
    global.ui_state.item_menu_x = 0;
    global.ui_state.item_menu_y = 0;
    global.ui_state.item_menu_acoes = [];
}

function scr_inventory_is_equipment(_item) {
    if (!is_struct(_item)) return false;
    if (variable_struct_exists(_item, "tipo") && _item.tipo == "equipamento") return true;
    if (!variable_struct_exists(_item, "slot")) return false;
    return variable_struct_exists(global.inventario.equipados, _item.slot);
}

function scr_inventory_is_equipped(_item) {
    if (!scr_inventory_is_equipment(_item)) return false;
    var _slot = _item.slot;
    return global.inventario.equipados[$ _slot] == _item;
}

function scr_inventory_get_actions(_item) {
    if (scr_inventory_is_equipment(_item)) {
        if (scr_inventory_is_equipped(_item)) {
            return ["desequipar", "inspecionar"];
        }

        return ["equipar", "inspecionar"];
    }

    if (variable_struct_exists(_item, "acao") && _item.acao != "nenhuma") {
        return ["usar", "inspecionar"];
    }

    return ["inspecionar"];
}

function scr_inventory_action_label(_action) {
    switch (_action) {
        case "equipar": return "Equipar";
        case "desequipar": return "Desequipar";
        case "usar": return "Usar";
        case "inspecionar": return "Inspecionar";
    }

    return string(_action);
}

function scr_inventory_open_item_menu(_item, _categoria, _indice, _x, _y) {
    global.ui_state.item_menu_aberto = true;
    global.ui_state.item_menu_item = _item;
    global.ui_state.item_menu_categoria = _categoria;
    global.ui_state.item_menu_indice = _indice;
    global.ui_state.item_menu_x = clamp(_x, global.ui_config.inv_panel_x, global.ui_config.inv_panel_x + global.ui_config.inv_panel_w - global.ui_config.inv_context_w);
    global.ui_state.item_menu_y = clamp(_y, global.ui_config.inv_panel_y + 48, global.ui_config.inv_panel_y + global.ui_config.inv_panel_h - 120);
    global.ui_state.item_menu_acoes = scr_inventory_get_actions(_item);
}

function scr_inventory_equip_item(_item) {
    return scr_equipar_item(_item);
}

function scr_inventory_unequip_item(_item) {
    if (!scr_inventory_is_equipment(_item)) return false;
    return scr_desequipar_item(_item.slot);
}

function scr_inventory_remove_selected_item() {
    var _cat = global.ui_state.item_menu_categoria;
    var _idx = global.ui_state.item_menu_indice;

    if (!variable_struct_exists(global.inventarios, _cat)) return false;

    var _lista = global.inventarios[$ _cat];
    if (_idx < 0 || _idx >= array_length(_lista)) return false;

    var _item = _lista[_idx];
    var _qtd = variable_struct_exists(_item, "quantidade") ? _item.quantidade : 1;

    if (_qtd > 1) {
        _item.quantidade = _qtd - 1;
    } else {
        array_delete(global.inventarios[$ _cat], _idx, 1);
    }

    return true;
}

function scr_inventory_apply_action(_action) {
    var _item = global.ui_state.item_menu_item;
    if (!is_struct(_item)) {
        scr_inventory_reset_item_menu();
        return false;
    }

    switch (_action) {
        case "equipar":
            scr_inventory_equip_item(_item);
            break;

        case "desequipar":
            scr_inventory_unequip_item(_item);
            break;

        case "usar":
            usar_item(_item);
            break;

        case "inspecionar":
            show_debug_message("Item: " + _item.nome);
            break;
    }

    scr_inventory_reset_item_menu();
    return true;
}

function usar_item(_item) {
    if (!variable_struct_exists(_item, "acao")) {
        show_debug_message("Este item nÃ£o possui uma aÃ§Ã£o definida.");
        return false;
    }

    switch (_item.acao) {
        case "recuperar_vida":
            var _cura = variable_struct_exists(_item, "valor") ? _item.valor : 0;
            scr_remover_item_inventario(_item);
            // global.vida += _cura; // Descomente quando implementar vida
            show_debug_message("VocÃª usou " + _item.nome + " e recuperou " + string(_cura) + " de vida!");
            return true;

        case "abrir_porta":
            show_debug_message("VocÃª usou " + _item.nome + " para destrancar algo!");
            return true;

        case "cortar_teias":
            global.pode_cortar_teias = true;
            scr_mostrar_mensagem_contexto("A faca pode cortar teias.");
            return true;

        default:
            show_debug_message("AÃ§Ã£o do item desconhecida: " + _item.acao);
            return false;
    }
}

// =============================================================================
// FUNCOES DE ENCONTRO
// =============================================================================
// Camada intermediaria entre exploracao e combate. O encontro nao resolve combate;
// ele apresenta o evento e chama o modulo de combate com o enemy_id correto.
// =============================================================================

function scr_get_encontro_data(_encounter_id) {
    if (!variable_global_exists("db_encontros") || !variable_struct_exists(global.db_encontros, _encounter_id)) {
        show_debug_message("ERRO: encontro inexistente no banco: " + string(_encounter_id));
        return noone;
    }

    return global.db_encontros[$ _encounter_id];
}

function scr_encounter_ativo() {
    return variable_global_exists("encounter") && is_struct(global.encounter) && global.encounter.ativo;
}

function scr_encounter_fechar() {
    if (!variable_global_exists("encounter") || !is_struct(global.encounter)) return;

    global.encounter.ativo = false;
    global.encounter.id = "";
    global.encounter.dados = noone;
    global.encounter.enemy_id = "";
    global.encounter.tipo = "";
    global.encounter.transition = "";
    global.encounter.texto = "";
    global.encounter.estado = "inativo";
    global.encounter.timer = 0;
    global.encounter.alpha = 0;
    global.encounter.auto_start = false;
    global.encounter.auto_delay = 60;
    global.encounter.origem_item = noone;
    global.encounter.resultado = "";
}

function scr_iniciar_encontro(_encounter_id, _origem_item) {
    var _dados = scr_get_encontro_data(_encounter_id);
    if (_dados == noone) return false;

    if (argument_count < 2) _origem_item = noone;

    global.encounter = {
        ativo        : true,
        id           : _encounter_id,
        dados        : _dados,
        enemy_id     : _dados.enemy_id,
        tipo         : variable_struct_exists(_dados, "tipo") ? _dados.tipo : "encontro_comum",
        transition   : variable_struct_exists(_dados, "transition_type") ? _dados.transition_type : "escurecer_cenario",
        texto        : variable_struct_exists(_dados, "texto") ? _dados.texto : "...",
        estado       : "apresentacao",
        timer        : 0,
        alpha        : 0,
        auto_start   : variable_struct_exists(_dados, "auto_start") ? _dados.auto_start : false,
        auto_delay   : variable_struct_exists(_dados, "auto_delay") ? _dados.auto_delay : 60,
        origem_item  : _origem_item,
        resultado    : ""
    };
    global.game_state = "encontro";

    if (variable_global_exists("ui_state")) {
        global.ui_state.inventario_aberto = false;
        global.ui_state.menu_tab_aberto = false;
        global.ui_state.categoria_selecionada = "";
        global.ui_state.container_atual = noone;
        global.ui_state.obstaculo_menu_aberto = false;
        global.ui_state.obstaculo_selecao_item_ativa = false;
        scr_inventory_reset_item_menu();
    }

    return true;
}

function scr_encounter_update() {
    if (!scr_encounter_ativo()) return;

    global.encounter.timer += 1;
    global.encounter.alpha = min(1, global.encounter.alpha + 0.06);

    if (global.encounter.estado == "apresentacao" && global.encounter.timer >= 18) {
        if (global.encounter.auto_start) {
            if (global.encounter.timer >= global.encounter.auto_delay) {
                scr_encounter_enfrentar();
            }
        } else {
            global.encounter.estado = "escolha";
        }
    }
}

function scr_get_encounter_button_rect(_index) {
    var _panel_x = global.ui_config.encounter_panel_x;
    var _panel_y = global.ui_config.encounter_panel_y;
    var _panel_w = global.ui_config.encounter_panel_w;
    var _button_w = global.ui_config.encounter_button_w;
    var _button_h = global.ui_config.encounter_button_h;
    var _gap = global.ui_config.encounter_button_gap;
    var _total_w = (_button_w * 2) + _gap;
    var _x = _panel_x + ((_panel_w - _total_w) * 0.5) + (_index * (_button_w + _gap));
    var _y = _panel_y + global.ui_config.encounter_panel_h - 105;

    return {
        x1 : _x,
        y1 : _y,
        x2 : _x + _button_w,
        y2 : _y + _button_h
    };
}

function scr_encounter_enfrentar() {
    if (!scr_encounter_ativo()) return false;

    global.encounter.estado = "indo_combate";
    global.encounter.resultado = "";

    if (scr_iniciar_combate(global.encounter.enemy_id, rm_game)) {
        global.game_state = "combate";
        room_goto(rm_combate_teste);
        return true;
    }

    global.encounter.estado = "escolha";
    return false;
}

function scr_encounter_recuar() {
    if (!scr_encounter_ativo()) return false;

    global.encounter.resultado = "recuou";
    scr_encounter_fechar();
    global.game_state = "exploracao";
    return true;
}

function scr_encounter_finalizar_resultado(_resultado) {
    if (!scr_encounter_ativo()) return;

    var _dados = global.encounter.dados;
    var _origem = global.encounter.origem_item;

    if (_resultado == "vitoria") {
        if (_origem != noone && is_struct(_origem)) {
            if (variable_struct_exists(_dados, "one_shot") && _dados.one_shot) {
                _origem.coletado = true;
            }
            _origem.resolvido = true;
        }
    }

    global.encounter.resultado = _resultado;
    scr_encounter_fechar();
    global.game_state = "exploracao";
}

// =============================================================================
// FUNCOES DE COMBATE DE TESTE
// =============================================================================
// Prototipo isolado. O combate le o inventario atual, mas nao possui inventario
// proprio. Conteudo fica no banco, estado fica em global.combat.
// =============================================================================

function scr_combat_array_contains(_array, _value) {
    for (var i = 0; i < array_length(_array); i++) {
        if (_array[i] == _value) return true;
    }

    return false;
}

function scr_combat_clone_part(_part) {
    return {
        id          : _part.id,
        nome        : _part.nome,
        hp          : _part.hp_max,
        hp_max      : _part.hp_max,
        fraquezas   : variable_struct_exists(_part, "fraquezas") ? _part.fraquezas : [],
        resistencias: variable_struct_exists(_part, "resistencias") ? _part.resistencias : [],
        mod_hp      : variable_struct_exists(_part, "mod_hp") ? _part.mod_hp : 1,
        mod_vigor   : variable_struct_exists(_part, "mod_vigor") ? _part.mod_vigor : 1,
        x1          : _part.x1,
        y1          : _part.y1,
        x2          : _part.x2,
        y2          : _part.y2,
        estado      : variable_struct_exists(_part, "estado") ? _part.estado : "intacta",
        ataques_afetados : variable_struct_exists(_part, "ataques_afetados") ? _part.ataques_afetados : []
    };
}

function scr_combat_instanciar_inimigo(_enemy_id) {
    if (!variable_global_exists("db_inimigos_combate") || !variable_struct_exists(global.db_inimigos_combate, _enemy_id)) {
        show_debug_message("ERRO: inimigo de combate inexistente: " + string(_enemy_id));
        return noone;
    }

    var _base = global.db_inimigos_combate[$ _enemy_id];
    var _partes = [];

    for (var i = 0; i < array_length(_base.partes); i++) {
        array_push(_partes, scr_combat_clone_part(_base.partes[i]));
    }

    return {
        id        : _base.id,
        nome      : _base.nome,
        hp        : _base.hp_max,
        hp_max    : _base.hp_max,
        vigor     : _base.vigor_max,
        vigor_max : _base.vigor_max,
        ataque    : _base.ataque,
        partes    : _partes
    };
}

function scr_combat_get_action(_action_id) {
    if (!variable_global_exists("db_acoes_combate") || !variable_struct_exists(global.db_acoes_combate, _action_id)) {
        return noone;
    }

    return global.db_acoes_combate[$ _action_id];
}

function scr_combat_get_part_index(_part_id) {
    if (!variable_global_exists("combat") || !is_struct(global.combat)) return -1;
    if (!is_struct(global.combat.inimigo)) return -1;

    var _partes = global.combat.inimigo.partes;
    for (var i = 0; i < array_length(_partes); i++) {
        if (_partes[i].id == _part_id) return i;
    }

    return -1;
}

function scr_combat_get_part(_part_id) {
    var _idx = scr_combat_get_part_index(_part_id);
    if (_idx < 0) return noone;
    return global.combat.inimigo.partes[_idx];
}

function scr_combat_get_weapon_item() {
    if (!variable_global_exists("inventario")) return noone;
    if (global.inventario.equipados.weapon != noone) return global.inventario.equipados.weapon;

    if (variable_global_exists("inventarios") && array_length(global.inventarios.weapon) > 0) {
        return global.inventarios.weapon[0];
    }

    return noone;
}

function scr_combat_get_acoes_disponiveis() {
    var _acoes = [];
    var _weapon = scr_combat_get_weapon_item();

    if (_weapon != noone && variable_struct_exists(_weapon, "acoes_combate")) {
        for (var i = 0; i < array_length(_weapon.acoes_combate); i++) {
            array_push(_acoes, {
                action_id : _weapon.acoes_combate[i],
                item      : _weapon
            });
        }
        array_push(_acoes, { action_id : "ataque_corte_pesado", item : _weapon });
    }

    array_push(_acoes, { action_id : "defender", item : noone });

    if (scr_inventario_possui_base("erva_verde")) {
        array_push(_acoes, { action_id : "usar_erva_verde", item : scr_inventario_get_item_por_base("erva_verde") });
    }

    if (variable_global_exists("combat") && is_struct(global.combat) && global.combat.execution_available) {
        array_push(_acoes, { action_id : "executar", item : noone });
    }

    return _acoes;
}

function scr_combat_get_acoes_categoria(_categoria) {
    var _acoes = [];

    switch (_categoria) {
        case "arma": {
            var _weapon = scr_combat_get_weapon_item();
            if (_weapon != noone && variable_struct_exists(_weapon, "acoes_combate")) {
                for (var i = 0; i < array_length(_weapon.acoes_combate); i++) {
                    array_push(_acoes, { action_id : _weapon.acoes_combate[i], item : _weapon });
                }
                array_push(_acoes, { action_id : "ataque_corte_pesado", item : _weapon });
            }

            if (variable_global_exists("combat") && is_struct(global.combat) && global.combat.execution_available) {
                array_push(_acoes, { action_id : "executar", item : noone });
            }
            break;
        }

        case "defesa":
            array_push(_acoes, { action_id : "defender", item : noone });
            break;

        case "cura":
            if (scr_inventario_possui_base("erva_verde")) {
                array_push(_acoes, { action_id : "usar_erva_verde", item : scr_inventario_get_item_por_base("erva_verde") });
            }
            break;

        case "magia":
            array_push(_acoes, { action_id : "magia_teste", item : noone });
            break;
    }

    return _acoes;
}

function scr_combat_atualizar_acoes() {
    if (!variable_global_exists("combat") || !is_struct(global.combat)) return;
    global.combat.acoes_disponiveis = scr_combat_get_acoes_disponiveis();
}

function scr_iniciar_combate(_enemy_id, _return_room) {
    var _enemy = scr_combat_instanciar_inimigo(_enemy_id);
    if (_enemy == noone) return false;

    var _action_max = variable_global_exists("db_combate") ? global.db_combate.action_max : 10;
    var _hp_max = variable_global_exists("db_combate") ? global.db_combate.jogador_hp_max : 40;

    global.combat = {
        ativo               : true,
        estado              : "player_planning",
        turno               : 1,
        action_points       : _action_max,
        action_max          : _action_max,
        jogador_hp          : _hp_max,
        jogador_hp_max      : _hp_max,
        inimigo             : _enemy,
        selected_part_id    : "torso",
        categoria_aberta    : "arma",
        pending_action_id   : "",
        acoes_planejadas    : [],
        defesa_reservada    : false,
        defense_marker      : 0,
        defense_speed       : 0.018,
        execution_available : false,
        mensagem            : "Escolha uma parte e uma acao.",
        retorno_room        : _return_room,
        acoes_disponiveis   : []
    };
    global.game_state = "combate";

    scr_combat_atualizar_acoes();
    return true;
}

function scr_iniciar_combate_teste() {
    if (scr_iniciar_combate("criatura_teste_01", rm_game)) {
        room_goto(rm_combate_teste);
        return true;
    }

    return false;
}

function scr_combat_set_mensagem(_texto) {
    if (!variable_global_exists("combat") || !is_struct(global.combat)) return;
    global.combat.mensagem = _texto;
}

function scr_combat_acao_requer_alvo(_acao) {
    if (_acao == noone) return false;
    return variable_struct_exists(_acao, "requer_alvo") && _acao.requer_alvo;
}

function scr_combat_planejar_acao(_action_id, _part_id) {
    if (!variable_global_exists("combat") || !is_struct(global.combat)) return false;
    if (global.combat.estado != "player_planning" && global.combat.estado != "posture_break") return false;

    var _acao = scr_combat_get_action(_action_id);
    if (_acao == noone) {
        scr_combat_set_mensagem("Acao de combate inexistente.");
        return false;
    }

    if (global.combat.action_points < _acao.custo) {
        scr_combat_set_mensagem("Pontos de acao insuficientes.");
        return false;
    }

    if (variable_struct_exists(_acao, "requer_item") && _acao.requer_item != "") {
        if (!scr_inventario_possui_base(_acao.requer_item)) {
            scr_combat_set_mensagem("Item necessario ausente: " + _acao.requer_item);
            return false;
        }
    }

    if (scr_combat_acao_requer_alvo(_acao) && scr_combat_get_part(_part_id) == noone) {
        global.combat.pending_action_id = _action_id;
        scr_combat_set_mensagem("Escolha uma parte do inimigo para " + _acao.nome + ".");
        return false;
    }

    global.combat.action_points -= _acao.custo;
    array_push(global.combat.acoes_planejadas, {
        action_id : _action_id,
        part_id   : _part_id,
        custo     : _acao.custo
    });

    global.combat.pending_action_id = "";
    global.combat.mensagem = "Planejado: " + _acao.nome + ".";
    return true;
}

function scr_combat_aplicar_acao_planejada(_plano) {
    var _acao = scr_combat_get_action(_plano.action_id);
    if (_acao == noone) return false;

    switch (_acao.tipo) {
        case "ataque":
        case "magia": {
            var _part = scr_combat_get_part(_plano.part_id);
            if (_part == noone) return false;

            var _weapon = scr_combat_get_weapon_item();
            var _dano_hp = _acao.dano_hp;
            var _dano_vigor = _acao.dano_vigor;
            var _tipo_dano = _acao.tipo_dano;

            if (_acao.tipo == "ataque" && _weapon != noone) {
                if (variable_struct_exists(_weapon, "dano")) _dano_hp = max(_dano_hp, _weapon.dano);
                if (variable_struct_exists(_weapon, "dano_vigor")) _dano_vigor = max(_dano_vigor, _weapon.dano_vigor);
                if (variable_struct_exists(_weapon, "tipo_dano") && _weapon.tipo_dano != "") _tipo_dano = _weapon.tipo_dano;
            }

            var _mult_hp = _part.mod_hp;
            var _mult_vigor = _part.mod_vigor;

            if (scr_combat_array_contains(_part.fraquezas, _tipo_dano)) {
                _mult_hp *= 1.25;
                _mult_vigor *= 1.5;
            }

            if (scr_combat_array_contains(_part.resistencias, _tipo_dano)) {
                _mult_hp *= 0.5;
                _mult_vigor *= 0.75;
            }

            _dano_hp = max(1, round(_dano_hp * _mult_hp));
            _dano_vigor = max(0, round(_dano_vigor * _mult_vigor));

            _part.hp = max(0, _part.hp - _dano_hp);
            if (_part.hp <= 0) _part.estado = "destruida";

            global.combat.inimigo.hp = max(0, global.combat.inimigo.hp - _dano_hp);
            global.combat.inimigo.vigor = max(0, global.combat.inimigo.vigor - _dano_vigor);

            var _idx = scr_combat_get_part_index(_plano.part_id);
            if (_idx >= 0) global.combat.inimigo.partes[_idx] = _part;

            global.combat.mensagem = _acao.nome + " em " + _part.nome + ": HP -" + string(_dano_hp) + ", Vigor -" + string(_dano_vigor) + ".";
            break;
        }

        case "defesa":
            global.combat.defesa_reservada = true;
            global.combat.mensagem = "Defesa reservada para a fase inimiga.";
            break;

        case "cura": {
            var _cura = variable_struct_exists(_acao, "cura") ? _acao.cura : 0;
            global.combat.jogador_hp = min(global.combat.jogador_hp_max, global.combat.jogador_hp + _cura);

            if (variable_struct_exists(_acao, "consome_item") && _acao.consome_item) {
                var _item = scr_inventario_get_item_por_base(_acao.requer_item);
                if (_item != noone) scr_remover_item_inventario(_item);
            }

            global.combat.mensagem = _acao.nome + ": HP +" + string(_cura) + ".";
            break;
        }

        case "execucao":
            if (!global.combat.execution_available) return false;
            global.combat.inimigo.hp = max(0, global.combat.inimigo.hp - _acao.dano_hp);
            global.combat.execution_available = false;
            global.combat.inimigo.vigor = global.combat.inimigo.vigor_max;
            global.combat.mensagem = "Execucao: HP -" + string(_acao.dano_hp) + ".";
            break;
    }

    return true;
}

function scr_combat_resolver_planejamento() {
    if (!variable_global_exists("combat") || !is_struct(global.combat)) return false;
    if (array_length(global.combat.acoes_planejadas) <= 0) {
        scr_combat_set_mensagem("Nenhuma acao foi planejada.");
        return false;
    }

    var _planos = global.combat.acoes_planejadas;
    for (var i = 0; i < array_length(_planos); i++) {
        scr_combat_aplicar_acao_planejada(_planos[i]);
        if (scr_combat_check_fim()) break;
        if (global.combat.inimigo.vigor <= 0) {
            global.combat.execution_available = true;
            global.combat.estado = "posture_break";
            global.combat.mensagem = "Postura quebrada. Execucao disponivel na proxima decisao.";
            break;
        }
    }

    global.combat.acoes_planejadas = [];
    global.combat.pending_action_id = "";
    scr_combat_atualizar_acoes();

    if (global.combat.estado != "victory" && global.combat.estado != "defeat"
        && !(global.combat.estado == "posture_break" && global.combat.execution_available)) {
        global.combat.estado = "enemy_phase";
    }

    return true;
}

function scr_combat_check_fim() {
    if (!variable_global_exists("combat") || !is_struct(global.combat)) return false;

    if (global.combat.inimigo.hp <= 0) {
        global.combat.inimigo.hp = 0;
        global.combat.estado = "victory";
        global.combat.mensagem = "Vitoria. Pressione Voltar para sair.";
        if (scr_encounter_ativo()) {
            global.encounter.resultado = "vitoria";
        }
        return true;
    }

    if (global.combat.jogador_hp <= 0) {
        global.combat.jogador_hp = 0;
        global.combat.estado = "defeat";
        global.combat.mensagem = "Derrota no prototipo. Pressione Voltar para sair.";
        if (scr_encounter_ativo()) {
            global.encounter.resultado = "derrota";
        }
        return true;
    }

    return false;
}

function scr_combat_resolver_acao(_action_id, _part_id) {
    if (!variable_global_exists("combat") || !is_struct(global.combat)) return false;
    if (global.combat.estado != "player_planning" && global.combat.estado != "posture_break") return false;

    var _acao = scr_combat_get_action(_action_id);
    if (_acao == noone) {
        scr_combat_set_mensagem("Acao de combate inexistente.");
        return false;
    }

    if (global.combat.action_points < _acao.custo) {
        scr_combat_set_mensagem("Pontos de acao insuficientes.");
        return false;
    }

    if (variable_struct_exists(_acao, "requer_item") && _acao.requer_item != "") {
        if (!scr_inventario_possui_base(_acao.requer_item)) {
            scr_combat_set_mensagem("Item necessario ausente: " + _acao.requer_item);
            return false;
        }
    }

    global.combat.action_points -= _acao.custo;

    switch (_acao.tipo) {
        case "ataque": {
            var _part = scr_combat_get_part(_part_id);
            if (_part == noone) {
                scr_combat_set_mensagem("Escolha uma parte valida.");
                global.combat.action_points += _acao.custo;
                return false;
            }

            var _weapon = scr_combat_get_weapon_item();
            var _dano_hp = _acao.dano_hp;
            var _dano_vigor = _acao.dano_vigor;
            var _tipo_dano = _acao.tipo_dano;

            if (_weapon != noone) {
                if (variable_struct_exists(_weapon, "dano")) _dano_hp = max(_dano_hp, _weapon.dano);
                if (variable_struct_exists(_weapon, "dano_vigor")) _dano_vigor = max(_dano_vigor, _weapon.dano_vigor);
                if (variable_struct_exists(_weapon, "tipo_dano") && _weapon.tipo_dano != "") _tipo_dano = _weapon.tipo_dano;
            }

            var _mult_hp = _part.mod_hp;
            var _mult_vigor = _part.mod_vigor;

            if (scr_combat_array_contains(_part.fraquezas, _tipo_dano)) {
                _mult_hp *= 1.25;
                _mult_vigor *= 1.5;
            }

            if (scr_combat_array_contains(_part.resistencias, _tipo_dano)) {
                _mult_hp *= 0.5;
                _mult_vigor *= 0.75;
            }

            _dano_hp = max(1, round(_dano_hp * _mult_hp));
            _dano_vigor = max(0, round(_dano_vigor * _mult_vigor));

            _part.hp = max(0, _part.hp - _dano_hp);
            if (_part.hp <= 0) _part.estado = "destruida";

            global.combat.inimigo.hp = max(0, global.combat.inimigo.hp - _dano_hp);
            global.combat.inimigo.vigor = max(0, global.combat.inimigo.vigor - _dano_vigor);

            var _idx = scr_combat_get_part_index(_part_id);
            if (_idx >= 0) global.combat.inimigo.partes[_idx] = _part;

            global.combat.mensagem = _acao.nome + " em " + _part.nome + ": HP -" + string(_dano_hp) + ", Vigor -" + string(_dano_vigor) + ".";

            if (!scr_combat_check_fim() && global.combat.inimigo.vigor <= 0) {
                global.combat.execution_available = true;
                global.combat.estado = "posture_break";
                global.combat.mensagem = "Postura quebrada. Execucao disponivel.";
            }
            break;
        }

        case "defesa":
            global.combat.defesa_reservada = true;
            global.combat.mensagem = "Defesa reservada para a fase inimiga.";
            break;

        case "cura": {
            var _cura = variable_struct_exists(_acao, "cura") ? _acao.cura : 0;
            global.combat.jogador_hp = min(global.combat.jogador_hp_max, global.combat.jogador_hp + _cura);

            if (variable_struct_exists(_acao, "consome_item") && _acao.consome_item) {
                var _item = scr_inventario_get_item_por_base(_acao.requer_item);
                if (_item != noone) scr_remover_item_inventario(_item);
            }

            global.combat.mensagem = _acao.nome + ": HP +" + string(_cura) + ".";
            break;
        }

        case "execucao":
            if (!global.combat.execution_available) {
                scr_combat_set_mensagem("Nao existe abertura para execucao.");
                global.combat.action_points += _acao.custo;
                return false;
            }

            global.combat.inimigo.hp = max(0, global.combat.inimigo.hp - _acao.dano_hp);
            global.combat.execution_available = false;
            global.combat.inimigo.vigor = global.combat.inimigo.vigor_max;
            global.combat.estado = "player_planning";
            global.combat.mensagem = "Execucao: HP -" + string(_acao.dano_hp) + ".";
            scr_combat_check_fim();
            break;
    }

    scr_combat_atualizar_acoes();
    return true;
}

function scr_combat_enemy_turn() {
    if (!variable_global_exists("combat") || !is_struct(global.combat)) return;
    if (global.combat.estado == "victory" || global.combat.estado == "defeat") return;

    if (global.combat.defesa_reservada) {
        global.combat.estado = "defense_check";
        global.combat.defense_marker = 0;
        global.combat.mensagem = "Defesa ativa: clique quando o marcador estiver na zona central.";
        return;
    }

    scr_combat_resolver_ataque_inimigo("falha");
}

function scr_combat_resolver_ataque_inimigo(_defesa_resultado) {
    if (!variable_global_exists("combat") || !is_struct(global.combat)) return;

    var _atk = global.combat.inimigo.ataque;
    var _dano = _atk.dano;
    var _texto = _atk.nome + ": ";

    switch (_defesa_resultado) {
        case "perfeito":
            _dano = 0;
            global.combat.inimigo.vigor = max(0, global.combat.inimigo.vigor - (_atk.dano_vigor * 4));
            _texto += "parry perfeito. Dano anulado e grande dano de Vigor.";
            break;

        case "bom":
            _dano = max(1, floor(_dano * 0.35));
            global.combat.inimigo.vigor = max(0, global.combat.inimigo.vigor - (_atk.dano_vigor * 2));
            _texto += "defesa boa. Dano reduzido e Vigor pressionado.";
            break;

        case "ruim":
            _dano = max(1, floor(_dano * 0.7));
            global.combat.inimigo.vigor = max(0, global.combat.inimigo.vigor - _atk.dano_vigor);
            _texto += "defesa parcial. Voce ainda recebe parte do dano.";
            break;

        default:
            _texto += "voce recebe " + string(_dano) + " de dano.";
            break;
    }

    global.combat.jogador_hp = max(0, global.combat.jogador_hp - _dano);
    global.combat.defesa_reservada = false;
    global.combat.turno += 1;
    global.combat.action_points = global.combat.action_max;
    global.combat.pending_action_id = "";
    global.combat.acoes_planejadas = [];

    if (!scr_combat_check_fim()) {
        if (global.combat.inimigo.vigor <= 0) {
            global.combat.execution_available = true;
            global.combat.estado = "posture_break";
            global.combat.mensagem = _texto + " Postura quebrada.";
        } else {
            global.combat.estado = "player_planning";
            global.combat.mensagem = _texto;
        }
    }

    scr_combat_atualizar_acoes();
}

function scr_combat_sair() {
    if (!variable_global_exists("combat") || !is_struct(global.combat)) {
        room_goto(rm_game);
        return;
    }

    var _retorno = variable_struct_exists(global.combat, "retorno_room") ? global.combat.retorno_room : rm_game;
    var _resultado_combate = "fuga";
    if (global.combat.estado == "victory") {
        _resultado_combate = "vitoria";
    } else if (global.combat.estado == "defeat") {
        _resultado_combate = "derrota";
    }
    global.combat.ativo = false;

    if (scr_encounter_ativo()) {
        var _resultado_encontro = global.encounter.resultado != "" ? global.encounter.resultado : _resultado_combate;
        scr_encounter_finalizar_resultado(_resultado_encontro);
    } else {
        global.game_state = "exploracao";
    }

    if (room_exists(_retorno)) {
        room_goto(_retorno);
    } else {
        room_goto(rm_game);
    }
}

// =============================================================================
// INTERTITULOS NARRATIVOS
// =============================================================================
// Cards declarativos, conduzidos pelo obj_game persistente. O banco somente
// descreve conteudo; Step atualiza o estado e Draw GUI apresenta a camada.

function scr_narrativa_ativa() {
    return variable_global_exists("narrativa_transicao")
        && is_struct(global.narrativa_transicao)
        && global.narrativa_transicao.ativa;
}

function scr_narrativa_criar_card(_id, _scene_number, _titulo, _subtitulo,
    _rodape, _tema, _modo, _duracao) {
    var _bg = make_color_rgb(11, 11, 13);
    var _texto = make_color_rgb(244, 241, 236);
    var _acento = make_color_rgb(201, 0, 54);

    switch (_tema) {
        case "vermelho":
            _bg = make_color_rgb(204, 0, 54);
            _texto = c_white;
            _acento = make_color_rgb(255, 236, 238);
        break;

        case "off_white":
            _bg = make_color_rgb(241, 239, 234);
            _texto = make_color_rgb(145, 18, 35);
            _acento = make_color_rgb(176, 22, 42);
        break;
    }

    return {
        id : _id,
        scene_number : _scene_number,
        titulo : _titulo,
        subtitulo : _subtitulo,
        rodape : _rodape,
        bg_color : _bg,
        text_color : _texto,
        accent_color : _acento,
        modo : _modo,
        hold_seconds : _duracao,
        fade_in_seconds : 0.10,
        fade_out_seconds : 0.10
    };
}

function scr_narrativa_obter_sequencia(_id) {
    switch (_id) {
        case "entrada_corredor":
            return [
                scr_narrativa_criar_card(
                    "card_corredor_01", 2,
                    "A ENTRADA PROFUNDA",
                    "O ar muda antes da luz.",
                    "",
                    "vermelho", "auto", 0.60
                )
            ];

        case "lembrar_passado":
            return [
                scr_narrativa_criar_card(
                    "mem_espera", 3,
                    "ESPERA.",
                    "",
                    "",
                    "vermelho", "auto", 0.40
                ),
                scr_narrativa_criar_card(
                    "mem_pergunta", 4,
                    "POR QUE VOCE ESTA AQUI?",
                    "VOCE SE LEMBRA?",
                    "As memorias estao embacadas.",
                    "preto", "auto_ou_confirmar", 1.00
                ),
                scr_narrativa_criar_card(
                    "mem_fragmentos", 5,
                    "MEMORIAS.",
                    "DEVO LEMBRAR?",
                    "Fragmentos retornam",
                    "off_white", "confirmar", 0
                )
            ];
    }

    return [];
}

function scr_narrativa_iniciar(_sequencia_id, _acao_final) {
    if (scr_narrativa_ativa()) return false;

    var _cards = scr_narrativa_obter_sequencia(_sequencia_id);
    if (array_length(_cards) <= 0) return false;

    global.narrativa_transicao.cards = _cards;
    global.narrativa_transicao.indice = 0;
    global.narrativa_transicao.atual = _cards[0];
    global.narrativa_transicao.fase = "enter";
    global.narrativa_transicao.tempo = 0;
    global.narrativa_transicao.alpha = 0;
    global.narrativa_transicao.bloquear_ate_soltar = mouse_check_button(mb_left);
    global.narrativa_transicao.acao_final = _acao_final;
    global.narrativa_transicao.ativa = true;
    return true;
}

function scr_narrativa_proximo() {
    global.narrativa_transicao.indice += 1;

    if (global.narrativa_transicao.indice < array_length(global.narrativa_transicao.cards)) {
        global.narrativa_transicao.atual = global.narrativa_transicao.cards[global.narrativa_transicao.indice];
        global.narrativa_transicao.fase = "enter";
        global.narrativa_transicao.tempo = 0;
        global.narrativa_transicao.alpha = 0;
        return noone;
    }

    var _acao = global.narrativa_transicao.acao_final;
    global.narrativa_transicao.ativa = false;
    global.narrativa_transicao.cards = [];
    global.narrativa_transicao.indice = -1;
    global.narrativa_transicao.atual = noone;
    global.narrativa_transicao.fase = "idle";
    global.narrativa_transicao.tempo = 0;
    global.narrativa_transicao.alpha = 0;
    global.narrativa_transicao.bloquear_ate_soltar = true;
    global.narrativa_transicao.acao_final = noone;
    return _acao;
}

function scr_narrativa_atualizar(_delta_seconds) {
    if (!scr_narrativa_ativa() || !is_struct(global.narrativa_transicao.atual)) return noone;

    var _estado = global.narrativa_transicao;
    var _card = _estado.atual;
    var _dt = max(0, _delta_seconds);
    var _aceitar_confirmacao = false;

    if (_estado.bloquear_ate_soltar && !mouse_check_button(mb_left)) {
        _estado.bloquear_ate_soltar = false;
    }

    if (!_estado.bloquear_ate_soltar) {
        _aceitar_confirmacao = mouse_check_button_pressed(mb_left)
            || keyboard_check_pressed(vk_enter)
            || keyboard_check_pressed(vk_space);
    }

    switch (_estado.fase) {
        case "enter":
            _estado.tempo += _dt;
            _estado.alpha = min(1, _estado.tempo / max(0.001, _card.fade_in_seconds));
            if (_estado.alpha >= 1) {
                _estado.fase = "hold";
                _estado.tempo = 0;
            }
        break;

        case "hold":
            _estado.tempo += _dt;
            var _avancar = false;

            if (_card.modo == "confirmar") {
                _avancar = _aceitar_confirmacao;
            }
            else if (_card.modo == "auto_ou_confirmar") {
                _avancar = _aceitar_confirmacao || _estado.tempo >= _card.hold_seconds;
            }
            else {
                _avancar = _estado.tempo >= _card.hold_seconds;
            }

            if (_avancar) {
                _estado.fase = "exit";
                _estado.tempo = 0;
            }
        break;

        case "exit":
            _estado.tempo += _dt;
            _estado.alpha = max(0, 1 - (_estado.tempo / max(0.001, _card.fade_out_seconds)));
            if (_estado.alpha <= 0) {
                return scr_narrativa_proximo();
            }
        break;
    }

    return noone;
}

function scr_narrativa_desenhar() {
    if (!scr_narrativa_ativa() || !is_struct(global.narrativa_transicao.atual)) return;

    var _card = global.narrativa_transicao.atual;
    var _alpha = global.narrativa_transicao.alpha;
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _centro_x = _gw * 0.5;

    // A cartela e opaca desde o primeiro frame. O fade pertence ao texto para
    // nunca expor HUD, inventario ou cenario entre um card e outro.
    draw_set_alpha(1);
    draw_set_color(_card.bg_color);
    draw_rectangle(0, 0, _gw, _gh, false);

    draw_set_alpha(_alpha);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_card.text_color);
    draw_text_transformed(_centro_x, _gh * 0.34,
        "SCENE NUMBER " + string_format(_card.scene_number, 2, 0),
        1.15, 1.15, 0);
    draw_text_transformed(_centro_x, _gh * 0.50, _card.titulo, 2.2, 2.2, 0);

    if (_card.subtitulo != "") {
        draw_set_color(_card.accent_color);
        draw_text_transformed(_centro_x, _gh * 0.60, _card.subtitulo, 1.35, 1.35, 0);
    }

    if (_card.rodape != "") {
        draw_set_color(_card.text_color);
        draw_text_transformed(_centro_x, _gh * 0.78, _card.rodape, 1.05, 1.05, 0);
    }

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

