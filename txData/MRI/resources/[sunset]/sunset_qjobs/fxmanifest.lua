fx_version 'cerulean'
game 'gta5'

author 'Sunset Valley Roleplay'
description 'Sistema de Empregos - Sunset Valley'
version '1.0.0'

ui_page 'nui/ui.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}

files {
    'nui/ui.html',
    'nui/ui.css',
    'nui/ui.js',
}
