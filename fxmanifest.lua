fx_version 'adamant'
game 'gta5'

author 'Yazouv#0455'
desription 'YJail - Systeme de jail pour FiveM'

client_scripts {
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
    "client/client.lua",
    "config.lua"
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "server/server.lua",
    "config.lua"
}

dependencies {
    'es_extended',
    'esx_skin'
}
