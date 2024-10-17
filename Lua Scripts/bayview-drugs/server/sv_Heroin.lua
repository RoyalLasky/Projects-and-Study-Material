local onTimerHeroin = {}
lib.callback.register('bayview_drugs:heroin:getitem', function(source, type)
    local src = source
    if type == "heroinPickup" then
        local number = 0
        for _, v in pairs(Config.Heroin.Field.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.Heroin.Field.RequiredItems then
            return true
        else
            return false
        end
    elseif type == "HeroinProcess" then
        local number = 0
        for _, v in pairs(Config.Heroin.Process.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.Heroin.Process.RequiredItems then
            return true
        else
            return false
        end
    end
end)

RegisterServerEvent("bayview_drugs:heroin:giveitems")
AddEventHandler("bayview_drugs:heroin:giveitems", function(type)
    local src = source
    if onTimerHeroin[src] and onTimerHeroin[src] > GetGameTimer() then
        Logs(src, "Drugs (Heroin, Timer): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (Heroin, Time): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
        return
    end
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    if type == "heroinPickup" then
        local dist = #(Config.Heroin.Field.coords - srcCoords)
        if dist <= 100 then
            local number = 0
            for _, v in pairs(Config.Heroin.Field.RequiredItems) do
                if GetItem(v.item, v.count, src) then
                    number = number + 1
                end
            end
            if number == #Config.Heroin.Field.RequiredItems then
                for _, v in pairs(Config.Heroin.Field.RequiredItems) do
                    if v.remove then
                        RemoveItem(v.item, v.count, src)
                    end
                end
                for _, v in pairs(Config.Heroin.Field.AddItems) do
                    AddItem(v.item, v.count, src)
                end
                onTimerHeroin[src] = GetGameTimer() + (2 * 1000)
                Logs(src, Config.Heroin.Field.Log)
            end
        else
            Logs(src, "Drugs (Heroin, coords): Player Tried to exploit Event")
            BanPlayer(src, "Drugs (Heroin, Coords): Player Tried to exploit Event")
            if Config.DropPlayer then
                DropPlayer(src, "Drugs: Player Tried to exploit Event")
            end
        end
    elseif type == "HeroinProcess" then
        local dist = #(Config.Heroin.Process.coords - srcCoords)
        if dist <= 100 then
            local number = 0
            for _, v in pairs(Config.Heroin.Process.RequiredItems) do
                if GetItem(v.item, v.count, src) then
                    number = number + 1
                end
            end
            if number == #Config.Heroin.Process.RequiredItems then
                for _, v in pairs(Config.Heroin.Process.RequiredItems) do
                    if v.remove then
                        RemoveItem(v.item, v.count, src)
                    end
                end
                for _, v in pairs(Config.Heroin.Process.AddItems) do
                    AddItem(v.item, v.count, src)
                end
                onTimerHeroin[src] = GetGameTimer() + (2 * 1000)
                Logs(src, Config.Heroin.Process.Log)
            end
        else
            Logs(src, "Drugs (Heroin, coords): Player Tried to exploit Event")
            BanPlayer(src, "Drugs (Heroin, Coords): Player Tried to exploit Event")
            if Config.DropPlayer then
                DropPlayer(src, "Drugs: Player Tried to exploit Event")
            end
        end
    end
end)
