fx_version 'cerulean'
use_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

version '2.0.0'
author 'MRI'
credits 'Arius Scripts'
description 'Advanced ambulance job with intergrated death system'


shared_script '@ox_lib/init.lua'

ox_libs {
	'locale',
}

client_scripts {
	"modules/utils/client/utils.lua",
	"client.lua",
	"modules/compatibility/frameworks/**/client.lua",
	"modules/compatibility/target/*.lua",
	"modules/injuries/client.lua",
	"modules/death/client.lua",
	"modules/stretcher/client.lua",
	"modules/paramedic/client.lua",
	"modules/job/client/main.lua",
	"modules/job/client/garage.lua",
	"modules/job/client/medical_bag.lua",
	"modules/job/client/shops.lua",
	"modules/job/client/clothing.lua",
	"modules/job/client/bossmenu.lua",
	"modules/deathlog/client.lua",
    "modules/survival/client.lua",
	"modules/utils/client/coords_debug.lua",
    "modules/hospital_editor/client.lua",
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"modules/compatibility/frameworks/**/server.lua",
	"server.lua",
	"modules/commands/server.lua",
	"modules/compatibility/txadmin/server.lua",
	"modules/deathlog/server.lua",
    "modules/hospital_editor/server.lua",
}

files {
	'locales/*.json',
	"data/*.lua",
	'config.lua',
}
