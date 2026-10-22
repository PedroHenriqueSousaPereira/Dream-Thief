// Guarda contra duplicações de instâncias persistentes
if (instance_number(obj_camera) > 1) {
    instance_destroy();
    exit;
}

#macro view view_camera[0]

view_width = 1920;
view_height = 1080;
