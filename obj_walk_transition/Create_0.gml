// Destinos por teclado.
// Podem ser sobrescritos pelas variaveis do objeto na room.
if (!variable_instance_exists(id, "destino_w")) destino_w = noone;
if (!variable_instance_exists(id, "destino_s")) destino_s = noone;

// Destinos por clique nas tres areas da room de transicao.
// Troque estes valores quando criar salas novas para cada caminho.
if (!variable_instance_exists(id, "destino_area_esquerda")) {
    destino_area_esquerda = variable_global_exists("sala_memorias") ? global.sala_memorias : noone;
}

if (!variable_instance_exists(id, "destino_area_centro")) {
    destino_area_centro = variable_global_exists("sala_cadaver_escavador") ? global.sala_cadaver_escavador : noone;
}

if (!variable_instance_exists(id, "destino_area_direita")) {
    destino_area_direita = variable_global_exists("antechamber_room") ? global.antechamber_room : noone;
}

// Hitboxes em coordenadas da room, nao do GUI.
// A room tem 3840px de largura, dividida em esquerda / centro / direita.
transition_click_areas = [
    { nome: "esquerda", x1: 180,  y1: 140, x2: 1180, y2: 640, destino: destino_area_esquerda },
    { nome: "centro",   x1: 1460, y1: 120, x2: 2380, y2: 650, destino: destino_area_centro },
    { nome: "direita",  x1: 2660, y1: 140, x2: 3660, y2: 640, destino: destino_area_direita }
];
