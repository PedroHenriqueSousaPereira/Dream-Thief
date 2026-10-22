// Guarda contra duplicações de instâncias persistentes
surf_scanline = -1;

if (instance_number(obj_crt_overlay) > 1) {
    instance_destroy();
    exit;
}

// Inicializa a variável da surface para evitar erros
surf_scanline = -1;

// Define a força do serrilhado (0.0 a 1.0)
forca_scanline = 0.35;
