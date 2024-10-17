local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add('roll', "Roll Dice", {{ name = 'number', help = 'Number to Roll' }}, false, function(source, args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local enterednumber = tonumber(args[1])
    if enterednumber == nil then 
        TriggerClientEvent('QBCore:Notify', src, "You need to pick a number", 'error')
    elseif enterednumber < 1 then 
        TriggerClientEvent('QBCore:Notify', src, "Pick a number greater than 0.", 'error')
    elseif enterednumber > config.maxnumber then
        TriggerClientEvent('QBCore:Notify', src, "Number needs to be under "..config.maxnumber..".", 'error')
    else
        TriggerClientEvent("lasky-dice:client:rollanimation", src)
        TriggerClientEvent('lasky-dice:client:roll', src, enterednumber)
    end
end)

RegisterNetEvent('lasky-dice:server:roll2', function(coords, roll, enterednumber)
    TriggerClientEvent('lasky-dice:client:roll2', -1, coords, roll, enterednumber)
end)