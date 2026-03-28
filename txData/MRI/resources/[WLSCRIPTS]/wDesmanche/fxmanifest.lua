fx_version 'cerulean'
game 'gta5'

author 'WLScripts'
description 'Sistema de Desmanche de Veículos'
version '1.0.0'

dependencies {
    'qbx_core',
    'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

lua54 'yes'
