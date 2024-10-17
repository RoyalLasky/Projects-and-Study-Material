local onTimeCrack = {}
lib.callback.register('bayview_drugs:crack:getitem', function(source, type)
    local src = source
    if type == "CrackProcess" then
        local number = 0
        for _, v in pairs(Config.Crack.Process.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.Crack.Process.RequiredItems then
            return true
        else
            return false
        end
    end
end)

RegisterServerEvent("bayview_drugs:crack:giveitems")
AddEventHandler("bayview_drugs:crack:giveitems", function(type)
    local src = source
    if onTimeCrack[src] and onTimeCrack[src] > GetGameTimer() then
        Logs(src, "Drugs (Crack, Time): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (Crack, Time): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
        return
    end
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    if type == "CrackProcess" then
        local dist = #(Config.Crack.Process.coords - srcCoords)
        if dist <= 100 then
            local number = 0
            for _, v in pairs(Config.Crack.Process.RequiredItems) do
                if GetItem(v.item, v.count, src) then
                    number = number + 1
                end
            end
            if number == #Config.Crack.Process.RequiredItems then
                for _, v in pairs(Config.Crack.Process.RequiredItems) do
                    if v.remove then
                        RemoveItem(v.item, v.count, src)
                    end
                end
                for _, v in pairs(Config.Crack.Process.AddItems) do
                    AddItem(v.item, v.count, src)
                end
                onTimeCrack[src] = GetGameTimer() + (2 * 1000)
                Logs(src, Config.Crack.Process.Log)
            end
        else
            Logs(src, "Drugs (Crack, coords): Player Tried to exploit Event")
            BanPlayer(src, "Drugs (Crack Coords): Player Tried to exploit Event")
            if Config.DropPlayer then
                DropPlayer(src, "Drugs: Player Tried to exploit Event")
            end
        end
    end
end)
