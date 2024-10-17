local QBCore = exports['qb-core']:GetCoreObject()

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0.0, 0.0, 0.0, 175)
    ClearDrawOrigin()
end


RegisterNetEvent("lasky-dice:client:rollanimation", function()
    TriggerEvent('animations:client:EmoteCommandStart', {"diceroll"})
    --loadAnimDict(Config.Drugs[k].animDictionary)
    --TaskPlayAnim(playerPed, Config.Drugs[k].animDictionary, Config.Drugs[k].animation, 8.0, 1.0, -1, 49, 0, 0, 0, 0)
    --Wait(Config.Drugs[k].anidur*1000)
    --StopAnimTask(playerPed, Config.Drugs[k].animDictionary, Config.Drugs[k].animation, 1.0)
end)

RegisterNetEvent("lasky-dice:client:roll", function(enterednumber)
    local newnumber = math.random(0, enterednumber)

    TriggerServerEvent('lasky-dice:server:roll2', GetEntityCoords(PlayerPedId()), newnumber, enterednumber)
end)

RegisterNetEvent("lasky-dice:client:roll2", function(coords, roll, enterednumber)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local dist = #(playerCoords - coords)
    if dist < 10 then
        local looptimer = 0
        Wait(1500)
        while looptimer ~= 400 do
            local playerPed = PlayerPedId()
            local pos = GetEntityCoords(playerPed)
            DrawText3D(pos.x, pos.y, pos.z+1.0, "You rolled a ~y~"..roll.." ~w~out of ~r~".. enterednumber.."~w~.")
            looptimer = looptimer + 1
            Wait(1)
        end
    end
end)