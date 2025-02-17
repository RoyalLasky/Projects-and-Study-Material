local onTimerMeth = {}
lib.callback.register('bayview_drugs:meth:getitem', function(source, type)
    local src = source
    if type == "MethBreak" then
        local number = 0
        for k, v in pairs(Config.Meth.Break.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.Meth.Break.RequiredItems then
            return true
        else
            return false
        end
    elseif type == "MethPour" then
        local number = 0
        for k, v in pairs(Config.Meth.Complete.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.Meth.Complete.RequiredItems then
            return true
        else
            return false
        end
    elseif type == "Complete" then
        local number = 0
        for k, v in pairs(Config.Meth.Complete.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.Meth.Complete.RequiredItems then
            return true
        else
            return false
        end
    elseif type == "MethPackage" then
        local number = 0
        for k, v in pairs(Config.Meth.Package.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.Meth.Package.RequiredItems then
            return true
        else
            return false
        end
    elseif type == "MethGet" then
        local number = 0
        for k, v in pairs(Config.Meth.GetSacid.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.Meth.GetSacid.RequiredItems then
            return true
        else
            return false
        end
    end
end)

RegisterServerEvent("bayview_drugs:meth:giveitems")
AddEventHandler("bayview_drugs:meth:giveitems", function(type)
    local src = source
    if onTimerMeth[src] and onTimerMeth[src] > GetGameTimer() then
        Logs(src, "Drugs (Meth, Timer): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (Meth, Timer): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
        return
    end
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    if type == "MethGet" then
        local dist = #(Config.Meth.GetSacid.coords - srcCoords)
        if dist <= 20 then
            local number = 0
            for k, v in pairs(Config.Meth.GetSacid.RequiredItems) do
                if GetItem(v.item, v.count, src) then
                    number = number + 1
                end
            end
            if number == #Config.Meth.GetSacid.RequiredItems then
                for k, v in pairs(Config.Meth.GetSacid.RequiredItems) do
                    if v.remove then
                        RemoveItem(v.item, v.count, src)
                    end
                end
                for k, v in pairs(Config.Meth.GetSacid.AddItems) do
                    AddItem(v.item, v.count, src)
                end
                onTimerMeth[src] = GetGameTimer() + (2 * 1000)
                Logs(src, Config.Meth.GetSacid.Log)
            end
        else
            Logs(src, "Drugs (Meth, coords): Player Tried to exploit Event")
            BanPlayer(src, "Drugs (Meth, Coords): Player Tried to exploit Event")
            if Config.DropPlayer then
                DropPlayer(src, "Drugs: Player Tried to exploit Event")
            end
        end
    elseif type == "Complete" then
        local dist = #(Config.Meth.Complete.coords - srcCoords)
        if dist <= 20 then
            local number = 0
            for k, v in pairs(Config.Meth.Complete.RequiredItems) do
                if GetItem(v.item, v.count, src) then
                    number = number + 1
                end
            end
            if number == #Config.Meth.Complete.RequiredItems then
                for k, v in pairs(Config.Meth.Complete.RequiredItems) do
                    if v.remove then
                        RemoveItem(v.item, v.count, src)
                    end
                end
                for k, v in pairs(Config.Meth.Complete.AddItems) do
                    AddItem(v.item, v.count, src)
                end
                onTimerMeth[src] = GetGameTimer() + (2 * 1000)
                Logs(src, Config.Meth.Complete.Log)
            end
        else
            Logs(src, "Drugs (Meth, Coords): Player Tried to exploit Event")
            BanPlayer(src, "Drugs (Meth, Coords): Player Tried to exploit Event")
            if Config.DropPlayer then
                DropPlayer(src, "Drugs: Player Tried to exploit Event")
            end
        end
    elseif type == "MethBreak" then
        local dist = #(Config.Meth.Break.coords - srcCoords)
        if dist <= 20 then
            local number = 0
            for k, v in pairs(Config.Meth.Break.RequiredItems) do
                if GetItem(v.item, v.count, src) then
                    number = number + 1
                end
            end
            if number == #Config.Meth.Break.RequiredItems then
                for k, v in pairs(Config.Meth.Break.RequiredItems) do
                    if v.remove then
                        RemoveItem(v.item, v.count, src)
                    end
                end
                for k, v in pairs(Config.Meth.Break.AddItems) do
                    AddItem(v.item, v.count, src)
                end
                onTimerMeth[src] = GetGameTimer() + (2 * 1000)
                Logs(src, Config.Meth.Break.Log)
            end
        else
            Logs(src, "Drugs (Meth, Coords): Player Tried to exploit Event")
            BanPlayer(src, "Drugs (Meth, Coords): Player Tried to exploit Event")
            if Config.DropPlayer then
                DropPlayer(src, "Drugs: Player Tried to exploit Event")
            end
        end
    elseif type == "MethPackage" then
        local dist = #(Config.Meth.Package.coords - srcCoords)
        if dist <= 20 then
            local number = 0
            for k, v in pairs(Config.Meth.Package.RequiredItems) do
                if GetItem(v.item, v.count, src) then
                    number = number + 1
                end
            end
            if number == #Config.Meth.Package.RequiredItems then
                for k, v in pairs(Config.Meth.Package.RequiredItems) do
                    if v.remove then
                        RemoveItem(v.item, v.count, src)
                    end
                end
                for k, v in pairs(Config.Meth.Package.AddItems) do
                    AddItem(v.item, v.count, src)
                end
                onTimerMeth[src] = GetGameTimer() + (2 * 1000)
                Logs(src, Config.Meth.Package.Log)
            end
        else
            Logs(src, "Drugs (Meth, Coords): Player Tried to exploit Event")
            BanPlayer(src, "Drugs (Meth, Coords): Player Tried to exploit Event")
            if Config.DropPlayer then
                DropPlayer(src, "Drugs: Player Tried to exploit Event")
            end
        end
    end
end)
