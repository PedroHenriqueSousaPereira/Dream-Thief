// =============================================================================
// obj_autopsia_controller - CREATE EVENT
// =============================================================================

if (!variable_global_exists("db_autopsias")) {
    scr_inicializar_mapa();
}

if (!variable_global_exists("autopsia_id_atual")) global.autopsia_id_atual = "";
if (!variable_global_exists("autopsia_cadaver_atual")) global.autopsia_cadaver_atual = noone;
if (!variable_global_exists("autopsia_retorno_sala_logica")) global.autopsia_retorno_sala_logica = noone;

autopsia_id = global.autopsia_id_atual;
if (autopsia_id == "") {
    autopsia_id = "escavador_01";
}

autopsia_data = scr_get_autopsia_data(autopsia_id);
cadaver_ref = global.autopsia_cadaver_atual;
autopsia_estado = {
    partes_examinadas : {},
    itens_coletados   : {}
};

if (is_struct(cadaver_ref)) {
    if (!variable_struct_exists(cadaver_ref, "estado_autopsia")
        || !is_struct(cadaver_ref.estado_autopsia)) {
        cadaver_ref.estado_autopsia = {
            partes_examinadas : {},
            itens_coletados   : {}
        };
    }

    autopsia_estado = cadaver_ref.estado_autopsia;

    if (!variable_struct_exists(autopsia_estado, "partes_examinadas")
        || !is_struct(autopsia_estado.partes_examinadas)) {
        autopsia_estado.partes_examinadas = {};
    }

    if (!variable_struct_exists(autopsia_estado, "itens_coletados")
        || !is_struct(autopsia_estado.itens_coletados)) {
        autopsia_estado.itens_coletados = {};
    }
}

partes_examinadas = autopsia_estado.partes_examinadas;
itens_coletados = autopsia_estado.itens_coletados;
hover_parte = "";
hover_voltar = false;
hover_acao = "";
texto_atual = "";
sair_solicitado = false;
autopsia_liberada = false;
autopsia_zoom = 1;
autopsia_zoom_alvo = 1;
autopsia_pan_x = 0;
autopsia_pan_y = 0;
autopsia_arrastando = false;
autopsia_arrastou = false;
autopsia_drag_inicio_x = 0;
autopsia_drag_inicio_y = 0;
autopsia_drag_ultimo_x = 0;
autopsia_drag_ultimo_y = 0;

if (is_struct(autopsia_data)) {
    texto_atual = autopsia_data.texto_inicial;

    for (var i = 0; i < array_length(autopsia_data.partes); i++) {
        var _parte = autopsia_data.partes[i];
        if (!variable_struct_exists(partes_examinadas, _parte.id)) {
            partes_examinadas[$ _parte.id] = false;
        }
    }
}
else {
    texto_atual = "Nao ha dados cadastrados para esta autopsia.";
}
