Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
    end
end)

local ServerName = "YJail"
local mainMenu = RageUI.CreateMenu(ServerName, "Vous êtes en Jail")
local TempsJail = 0
local open = false

mainMenu.Closable = false
mainMenu.Closed = function() open = false end

--ON PLAYER JOIN
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    TriggerServerEvent("YJail:tempsjail")
end)

RegisterNetEvent('YJail:openmenu')
AddEventHandler('YJail:openmenu', function(time, raison, staffname)
    if not open then open = true
        RageUI.Visible(mainMenu, true)
        Citizen.CreateThread(function()
            TriggerEvent('skinchanger:getSkin', function(skin)
                if skin.sex == 0 then
                    TriggerEvent('skinchanger:loadClothes', skin, Config.Tenue.male)
                else
                    TriggerEvent('skinchanger:loadClothes', skin, Config.Tenue.female)
                end
            end)
            while open do
                RageUI.IsVisible(mainMenu, function()
                    if TempsJail == tostring("1") then
                        RageUI.Button("Temps restant: ~b~" .. ESX.Math.Round(TempsJail) .. " minute", nil, {}, true, {})
                    else
                        RageUI.Button("Temps restant: ~b~" .. ESX.Math.Round(TempsJail) .. " minutes", nil, {}, true, {})
                    end
                    if raison ~= nil or raison ~= "" or raison ~= " " then
                        RageUI.Button("Raison: ~o~" .. raison .. "", nil, {}, true, {})
                    else
                        RageUI.Button("Raison: ~o~Indéfinie", nil, {}, true, {})
                    end
                    if staffname ~= nil then
                        RageUI.Button("Staff: ~g~" .. staffname, nil, {}, true, {})
                    else
                        RageUI.Button("Staff: Console", nil, {}, true, {})
                    end
                end)
                Wait(0)
            end
        end)
    end
end)

Citizen.CreateThread(function()
    Wait(2500)
    TriggerServerEvent('YJail:tempsjail')
    while true do
        if tonumber(TempsJail) >= 1 then
            Wait(60000)
            TempsJail = TempsJail - 1
            TriggerServerEvent('YJail:updatetemps', TempsJail)
        end
        if tonumber(TempsJail) == 0 then
            RageUI.CloseAll()
            open = false
        end
        Wait(2500)
    end
end)

Citizen.CreateThread(function()
    local InSafeZone = false
    local OutSafeZone = false
    while true do
        if tonumber(TempsJail) >= 1 then
            for k, v in pairs(Config.Position["entrée"]) do
                if #(GetEntityCoords(GetPlayerPed(-1)) - vector3(v.x, v.y, v.z)) > 35 then
                    SetEntityCoords(GetPlayerPed(-1), v.x, v.y, v.z)
                    ESX.ShowNotification("~r~Vous ne pouvez pas vous échapper !")
                    if not OutSafeZone then
                        NetworkSetFriendlyFireOption(true)
                        TriggerEvent("esx:showNotification", "~r~Vous n'êtes plus dans une safe zone !")
                        OutSafeZone = true
                        InSafeZone = false
                    end
                else
                    if (Config.EnableSafeZone == true) then
                        if not InSafeZone then
                            NetworkSetFriendlyFireOption(false)
                            ClearPlayerWantedLevel(PlayerId())
                            SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
                            TriggerEvent("esx:showNotification", "~g~Vous êtes dans une safe zone !")
                            InSafeZone = true
                            OutSafeZone = false
                        end
                    end
                end
            end
            if (Config.EnableSafeZone == true) then
                if InSafeZone then
                    DisableControlAction(2, 37, true)
                    DisablePlayerFiring(player, true)
                    DisableControlAction(0, 106, true)
                    if IsDisabledControlJustPressed(2, 37) then
                        SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
                        TriggerEvent("esx:showNotification", "~r~Vous ne pouvez pas utiliser d'armes en safe zone !")
                    end
                    if IsDisabledControlJustPressed(0, 106) then
                        SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true)
                        TriggerEvent("esx:showNotification", "~r~Vous ne pouvez pas faire ceci en safe zone !")
                    end
                end
            end
            Wait(0)
        else
            Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/jail', 'id, temps, raison')
    TriggerEvent('chat:addSuggestion', '/jailoffline', 'license, temps, raison')
    TriggerEvent('chat:addSuggestion', '/unjail', 'id')
end)

RegisterNetEvent('YJail:encoredutemps')
AddEventHandler('YJail:encoredutemps', function(result)
    TempsJail = result
    if TempsJail == 0 then
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
            TriggerEvent('skinchanger:loadSkin', skin)
        end)
        for k, v in pairs(Config.Position["sortie"]) do
            SetEntityCoords(GetPlayerPed(-1), v.x, v.y, v.z)
        end
        if (Config.EnableSafeZone == true) then
            TriggerEvent("esx:showNotification", "~r~Vous n'êtes plus dans une safe zone !")
        end
        RageUI.CloseAll()
        open = false
    end
end)

RegisterNetEvent('YJail:finjail')
AddEventHandler('YJail:finjail', function()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end)
    for k, v in pairs(Config.Position["sortie"]) do
        SetEntityCoords(GetPlayerPed(-1), v.x, v.y, v.z)
    end
    if (Config.EnableSafeZone == true) then
        TriggerEvent("esx:showNotification", "~r~Vous n'êtes plus dans une safe zone !")
    end
end)
