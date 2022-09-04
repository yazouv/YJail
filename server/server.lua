ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local TempsJail = {}
local JoueurEstMort = {}

RegisterNetEvent('YJail:tempsjail')
AddEventHandler('YJail:tempsjail', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM yjail WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            TempsJail[xPlayer.source] = {}
            TempsJail[xPlayer.source].time = result[1].time
            TempsJail[xPlayer.source].reason = result[1].raison
            TempsJail[xPlayer.source].staffname = result[1].staffname
            TriggerClientEvent('YJail:encoredutemps', xPlayer.source, TempsJail[xPlayer.source].time)
            for k, v in pairs(Config.Position["entrée"]) do
                SetEntityCoords(GetPlayerPed(xPlayer.source), v.x, v.y, v.z)
            end
            TriggerClientEvent('esx:showNotification', xPlayer.source,
                "~r~Vous vous êtes déconnecté en étant en jail")
            TriggerClientEvent('YJail:openmenu', xPlayer.source, nil, TempsJail[xPlayer.source].reason,
                TempsJail[xPlayer.source].staffname)
        else
            TempsJail[xPlayer.source] = {}
            TempsJail[xPlayer.source].time = 0
        end
    end)
end)

RegisterNetEvent('YJail:updatetemps')
AddEventHandler('YJail:updatetemps', function(NewTempsJail)
    local xPlayer = ESX.GetPlayerFromId(source)
    TempsJail[xPlayer.source].time = NewTempsJail
    if tonumber(TempsJail[xPlayer.source].time) == 0 then
        TempsJail[xPlayer.source].time = 0
        TriggerClientEvent("esx:showNotification", source, "Votre jail est maintenant ~g~terminé")
        TriggerClientEvent('YJail:finjail', source)
        MySQL.Async.execute('DELETE FROM yjail WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        })
        for k, v in pairs(Config.Position["sortie"]) do
            SetEntityCoords(GetPlayerPed(xPlayer.source), v.x, v.y, v.z)
        end
    else
        MySQL.Async.execute('UPDATE yjail SET time = @time WHERE identifier = @identifier', {
            ['@time'] = TempsJail[xPlayer.source].time,
            ['@identifier'] = xPlayer.identifier
        })
    end
end)

RegisterCommand('jail', function(source, args)
    if source == 0 then
        print("Vous ne pouvez pas jail dans la console")
        return
    end
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= 'user' then
        local JoueurTarget = ESX.GetPlayerFromId(args[1])
        if JoueurTarget then
            Wait(100)
            if tonumber(TempsJail[JoueurTarget.source].time) >= 1 then
                TriggerClientEvent('esx:showNotification', source,
                    "Le joueur est déjà en jail pendant: ~b~" .. TempsJail[JoueurTarget.source].time .. " ~s~minutes")
            else
                local reason = table.concat(args, ' ', 3)
                TempsJail[JoueurTarget.source].time = args[2]
                TempsJail[JoueurTarget.source].reason = reason
                TempsJail[JoueurTarget.source].staffname = xPlayer.getName()
                MySQL.Async.execute('INSERT INTO yjail (identifier, time, raison, staffname) VALUES (@identifier, @time, @raison, @staffname)'
                    , {
                        ['@identifier'] = JoueurTarget.identifier,
                        ['@time'] = args[2],
                        ["@raison"] = reason,
                        ["@staffname"] = xPlayer.getName()
                    }, function()
                end)
                TriggerClientEvent('YJail:encoredutemps', JoueurTarget.source, TempsJail[JoueurTarget.source].time)
                for k, v in pairs(Config.Position["entrée"]) do
                    SetEntityCoords(GetPlayerPed(JoueurTarget.source), v.x, v.y, v.z)
                end
                sendToDiscord(Config.Webhook.Jail, "**Nouveau Jail**", GetPlayerName(source), reason,
                    args[2])
                if args[2] == tostring("1") then
                    TriggerClientEvent('esx:showNotification', source,
                        "Vous avez jail ~b~" ..
                        GetPlayerName(JoueurTarget.source) .. " ~s~pendant ~b~" .. args[2] .. " ~s~minute")
                    TriggerClientEvent('esx:showNotification', JoueurTarget.source,
                        "Vous avez été mit en jail pendant ~b~" .. args[2] .. " ~s~minute")
                else
                    TriggerClientEvent('esx:showNotification', source,
                        "Vous avez jail ~b~" ..
                        GetPlayerName(JoueurTarget.source) .. " ~s~pendant ~b~" .. args[2] .. " ~s~minutes")
                    TriggerClientEvent('esx:showNotification', JoueurTarget.source,
                        "Vous avez été mis en jail pendant ~b~" .. args[2] .. " ~s~minutes")
                end
                TriggerClientEvent('YJail:openmenu', JoueurTarget.source, nil, TempsJail[JoueurTarget.source].reason,
                    TempsJail[JoueurTarget.source].staffname)
            end
        else
            TriggerClientEvent('esx:showNotification', source, "Aucun joueur trouvé avec l'ID que vous avez entré")
        end
    end
end)

RegisterCommand('jailoffline', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    local reason = table.concat(args, " ", 3)
    if xPlayer.getGroup() ~= 'user' then
        MySQL.Async.execute("INSERT INTO yjail (identifier, time, raison, staffname) VALUES (@identifier, @time, @raison, @staffname)"
            , {
            ["@identifier"] = args[1],
            ["@time"] = args[2],
            ["@raison"] = reason,
            ["@staffname"] = xPlayer.getName()
        })
        sendToDiscord(Config.Webhook.JailOffline, "**Nouveau JailOffline**", GetPlayerName(source), reason,
            args[2])
    end
end)

RegisterCommand('unjail', function(source, args)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() ~= 'user' then
        local JoueurTarget = ESX.GetPlayerFromId(args[1])
        if JoueurTarget then
            Wait(100)
            sendToDiscord(Config.Webhook.UnJail, "**Nouveau UnJail**", GetPlayerName(source), "Aucune",
                "Aucune")
            if tonumber(TempsJail[JoueurTarget.source].time) >= 0 then
                TempsJail[JoueurTarget.source].time = 0
                TriggerClientEvent('esx:showNotification', source,
                    "Le joueur ~b~" .. GetPlayerName(xPlayer.source) .. " ~s~a été unjail")
                TriggerClientEvent('YJail:encoredutemps', JoueurTarget.source, 0)
                for k, v in pairs(Config.Position["sortie"]) do
                    SetEntityCoords(GetPlayerPed(JoueurTarget.source), v.x, v.y, v.z)
                end
                MySQL.Async.execute('DELETE FROM yjail WHERE `identifier` = @identifier', {
                    ['@identifier'] = JoueurTarget.identifier
                })
            else
                TriggerClientEvent('esx:showNotification', source,
                    "Le joueur ~b~" .. GetPlayerName(JoueurTarget.source) .. " ~s~n'est pas en jail")
            end
        else
            TriggerClientEvent('esx:showNotification', source, "Aucun joueur trouvé avec l'ID que vous avez entré")
        end
    end
end)

AddEventHandler('playerDropped', function(reason)
    local xPlayer = ESX.GetPlayerFromId(source)
    if tonumber(TempsJail[xPlayer.source].time) > 0 then
        raisondujail = TempsJail[xPlayer.source].reason
        nomdustaff = TempsJail[xPlayer.source].staffname
    end
    if (xPlayer) then
        if TempsJail[xPlayer.source] then
            local TimeJail = tonumber(TempsJail[xPlayer.source].time)
            if tonumber(TimeJail) >= 1 then
                MySQL.Async.fetchAll('SELECT * FROM `yjail` WHERE `identifier` = @identifier', {
                    ['@identifier'] = xPlayer.identifier
                }, function(result)
                    if result[1] then
                        MySQL.Async.execute('UPDATE yjail SET time = @time WHERE identifier = @identifier', {
                            ['@identifier'] = xPlayer.identifier,
                            ['@time'] = TimeJail,
                        })
                    else
                        MySQL.Async.execute('INSERT INTO yjail (identifier, time, raison, staffname) VALUES (@identifier, @time, @raison, @staffname)'
                            , {
                                ['@identifier'] = xPlayer.identifier,
                                ['@time'] = TimeJail,
                                ["@raison"] = raisondujail,
                                ["@staffname"] = nomdustaff
                            }, function()
                        end)
                    end
                end)
                TempsJail[xPlayer.source] = nil
            end
        end
        if JoueurEstMort[source] then
            MySQL.Async.execute('INSERT INTO yjail (identifier, time, raison, staffname) VALUES (@identifier, @time, @raison, @staffname)'
                , {
                ['@identifier'] = xPlayer.identifier,
                ['@time'] = 10,
                ["@raison"] = "Déco Mort",
                ["@staffname"] = "Anti Déco Mort"
            })
        end
    end
end)

function sendToDiscord(embed_url, embed_description, embed_staffname, embed_reason, embed_time)
    if Config.Webhook.Jail == "" or Config.Webhook.JailOffline == "" or Config.Webhook.UnJail == "" then
        return
    end
    if (embed_time == "Aucune") then
        embed_time = "Aucune"
    else
        embed_time = embed_time .. " minute(s)"
    end
    local embed = {
        {
            ["description"] = embed_description,
            ["fields"] = {
                {
                    ["name"] = "Staff",
                    ["value"] = embed_staffname,
                    ["inline"] = true
                },
                {
                    ["name"] = "Raison",
                    ["value"] = embed_reason,
                    ["inline"] = true
                },
                {
                    ["name"] = "Durée",
                    ["value"] = embed_time,
                    ["inline"] = true
                },
            },
            ["footer"] = {
                ["text"] = "Made by Yazouv#0455",
            },
        }
    }

    PerformHttpRequest(embed_url, function(err, text, headers) end, 'POST',
        json.encode({ username = Config.ServerName, embeds = embed }), { ['Content-Type'] = 'application/json' })
end
