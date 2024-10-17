local onTimerShrooms = {}
lib.callback.register('bayview_drugs:mushroom:getitem', function(source, type)
    local src = source
    if type == "MushroomPickup" then
        local number = 0
        for _, v in pairs(Config.MushroomsField.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.MushroomsField.RequiredItems then
            return true
        else
            return false
        end
    end
end)

RegisterServerEvent("bayview_drugs:mushroom:giveitems")
AddEventHandler("bayview_drugs:mushroom:giveitems", function(type)
    local src = source
    if onTimerShrooms[src] and onTimerShrooms[src] > GetGameTimer() then
        Logs(src, "Drugs (Mushrooms, Time): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (Mushrooms, Time): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
        return
    end
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    if type == "MushroomPickup" then
        local dist = #(Config.MushroomsField.coords - srcCoords)
        if dist <= 100 then
            local number = 0
            for _, v in pairs(Config.MushroomsField.RequiredItems) do
                if GetItem(v.item, v.count, src) then
                    number = number + 1
                end
            end
            if number == #Config.MushroomsField.RequiredItems then
                for _, v in pairs(Config.MushroomsField.RequiredItems) do
                    if v.remove then
                        RemoveItem(v.item, v.count, src)
                    end
                end
                for _, v in pairs(Config.MushroomsField.AddItems) do
                    AddItem(v.item, v.count, src)
                end
                onTimerShrooms[src] = GetGameTimer() + (2 * 1000)
                Logs(src, Config.MushroomsField.Log)
            end
        else
            Logs(src, "Drugs (Mushrooms, Coords): Player Tried to exploit Event")
            BanPlayer(src, "Drugs (Mushrooms, Coords): Player Tried to exploit Event")
            if Config.DropPlayer then
                DropPlayer(src, "Drugs: Player Tried to exploit Event")
            end
        end
    end
end)
