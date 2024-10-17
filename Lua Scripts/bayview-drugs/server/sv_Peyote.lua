local onTimePeyote = {}
lib.callback.register('bayview_drugs:peyote:getitem', function(source, type)
    local src = source
    if type == "PeyotePickup" then
        local number = 0
        for _, v in pairs(Config.PeyoteField.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.PeyoteField.RequiredItems then
            return true
        else
            return false
        end
    end
end)

RegisterServerEvent("bayview_drugs:peyote:giveitems")
AddEventHandler("bayview_drugs:peyote:giveitems", function(type)
    local src = source
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    if onTimePeyote[src] and onTimePeyote[src] > GetGameTimer() then
        Logs(src, "Drugs (peyote, Time): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (peyote, Time): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
        return
    end
    if type == "PeyotePickup" then
        local dist = #(Config.PeyoteField.coords - srcCoords)
        if dist <= 100 then
            local number = 0
            for _, v in pairs(Config.PeyoteField.RequiredItems) do
                if GetItem(v.item, v.count, src) then
                    number = number + 1
                end
            end
            if number == #Config.PeyoteField.RequiredItems then
                for _, v in pairs(Config.PeyoteField.RequiredItems) do
                    if v.remove then
                        RemoveItem(v.item, v.count, src)
                    end
                end
                for _, v in pairs(Config.PeyoteField.AddItems) do
                    AddItem(v.item, v.count, src)
                end
                onTimePeyote[src] = GetGameTimer() + (2 * 1000)
                Logs(src, Config.PeyoteField.Log)
            end
        else
            Logs(src, "Drugs (peyote, coords): Player Tried to exploit Event")
            BanPlayer(src, "Drugs (peyote, Coords): Player Tried to exploit Event")
            if Config.DropPlayer then
                DropPlayer(src, "Drugs: Player Tried to exploit Event")
            end
        end
    end
end)
