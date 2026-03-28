fx_version 'cerulean'
game 'gta5'

name        'garagex_tuning'
author      'GarageX'
description 'Sistema de Tuning NUI Drag-and-Drop - QBOX'
version     '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client/client.lua',
}

server_scripts {
    'server/server.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/car_top.png',
    'html/items/arm_s1.png',
    'html/items/arm_s2.png',
    'html/items/arm_s3.png',
    'html/items/arm_s4.png',
    'html/items/freio_s1.png',
    'html/items/freio_s2.png',
    'html/items/freio_s3.png',
    'html/items/freio_s4.png',
    'html/items/motor_s1.png',
    'html/items/motor_s2.png',
    'html/items/motor_s3.png',
    'html/items/motor_s4.png',
    'html/items/susp_s1.png',
    'html/items/susp_s2.png',
    'html/items/susp_s3.png',
    'html/items/susp_s4.png',
    'html/items/trans_s1.png',
    'html/items/trans_s2.png',
    'html/items/trans_s3.png',
    'html/items/trans_s4.png',
    'html/items/turbo_s1.png',
    'html/items/turbo_s2.png',
    'html/items/turbo_s3.png',
    'html/items/turbo_s4.png',
}

lua54 'yes'

dependencies {
    'ox_lib',
    'qbx_core',
}
