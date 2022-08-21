Config = {
    EnableSafeZone = true, --Defaut : true
    Position = {
        ["entrée"] = {
            { x = 1642.56, y = 2569.01, z = 45.55 }, --Position de l'endroit de jail
        },
        ["sortie"] = {
            { x = 218.6331, y = -810.1385, z = 30.6779 }, --Postion de sortie du jail
        },
    },
    Webhook = {
        Jail = "", --Webhook pour le jail
        UnJail = "", --Webhook pour le unjail
        JailOffline = "", --Webhook pour le jail offline
    },
    Tenue = {
        male = { --Tenue jail homme
            ['tshirt_1'] = 15, ['tshirt_2'] = 0,
            ['torso_1'] = 146, ['torso_2'] = 0,
            ['decals_1'] = 0, ['decals_2'] = 0,
            ['arms'] = 0, ['pants_1'] = 3,
            ['pants_2'] = 7, ['shoes_1'] = 12,
            ['shoes_2'] = 12, ['chain_1'] = 50,
        },
        female = { --Tenue jail femme
            ['tshirt_1'] = 3, ['tshirt_2'] = 0,
            ['torso_1'] = 38, ['torso_2'] = 3,
            ['decals_1'] = 0, ['decals_2'] = 0,
            ['arms'] = 2, ['pants_1'] = 3,
            ['pants_2'] = 15, ['shoes_1'] = 66,
            ['shoes_2'] = 5, ['chain_1'] = 0,
        },
    },
}

Config.ServerName = "YJail"
