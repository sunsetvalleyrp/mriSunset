fx_version 'cerulean'
game 'gta5'

author 'Sunset Valley Roleplay'
description 'Sistema de Lojas - Sunset Valley'
version '1.0.0'

ui_page 'nui/ui.html'


shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    'server.lua'
}

client_scripts {
    'client.lua'
}

files {
    'nui/ui.html',
    'nui/ui.css',
    'nui/ui.js',
    'nui/inventario/*.png'
}
