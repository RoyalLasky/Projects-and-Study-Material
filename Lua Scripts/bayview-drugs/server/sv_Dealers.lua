local onTimerDealers = {}
lib.callback.register('bayview_drugs:dealersshop:getitem', function(source, price, amount)
    local src = source
    if GetMoney(price * amount, src) then
        return true
    else
        return false
    end
end)

RegisterServerEvent("bayview_drugs:dealersshop:giveitems")
AddEventHandler("bayview_drugs:dealersshop:giveitems", function(item, price, amount)
    local src = source
    if onTimerDealers[src] and onTimerDealers[src] > GetGameTimer() then
        Logs(src, "Drugs (Dealer, Time): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (Dealer, Time): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
        return
    end
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    for _, v in pairs(Config.Dealer.Ped) do
        ShopCoords = v.coords
    end
    local dist = #(vec3(ShopCoords) - srcCoords)
    if dist <= 20 then
        for _, v in pairs(Config.Dealer.Items) do
            if item == v.item and price == v.price and amount >= v.MinAmount and amount <= v.MaxAmount then
                if GetMoney(price * amount, src) then
                    onTimerDealers[src] = GetGameTimer() + (2 * 1000)
                    RemoveMoney(price * amount, src)
                    AddItem(item, amount, src)
                    Logs(src, locale("HasBought", amount, item, price * amount))
                end
            end
        end
    else
        Logs(src, "Drugs (Dealer, Coords): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (Dealer, Coords): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
    end
end)

lib.callback.register('bayview_drugs:dealers:getitem', function(source, type)
    local src = source
    if type == "GeraldShop" then
        local number = 0
        for k, v in pairs(Config.Gerald.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.Gerald.RequiredItems then
            return true
        else
            return false
        end
    elseif type == "LocateDealer1" then
        local number = 0
        for k, v in pairs(Config.LocateDealer.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.LocateDealer.RequiredItems then
            for k, v in pairs(Config.LocateDealer.RequiredItems) do
                if v.remove then
                    RemoveItem(v.item, v.count, src)
                end
            end
            return true
        else
            return false
        end
    elseif type == "MadrazoTrade" then
        local number = 0
        for k, v in pairs(Config.Madrazo.RequiredItems) do
            if GetItem(v.item, v.count, src) then
                number = number + 1
            end
        end
        if number == #Config.Madrazo.RequiredItems then
            return true
        else
            return false
        end
    end
end)

RegisterServerEvent("bayview_drugs:dealers:giveitems")
AddEventHandler("bayview_drugs:dealers:giveitems", function(type)
    local src = source
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    if onTimerDealers[src] and onTimerDealers[src] > GetGameTimer() then
        Logs(src, "Drugs (Madrazo or Gerald, Time): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (Madrazo or Gerald, Time): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
        return
    end
    if type == "GeraldShop" then
        local dist = #(Config.Gerald.Location.Coords - srcCoords)
        if dist <= 50 then
            local number = 0
            for k, v in pairs(Config.Gerald.RequiredItems) do
                if GetItem(v.item, v.count, src) then
                    number = number + 1
                end
            end
            if number == #Config.Gerald.RequiredItems then
                for k, v in pairs(Config.Gerald.RequiredItems) do
                    if v.remove then
                        RemoveItem(v.item, v.count, src)
                    end
                end
                for k, v in pairs(Config.Gerald.AddItems) do
                    AddItem(v.item, v.count, src)
                end
                onTimerDealers[src] = GetGameTimer() + (2 * 1000)
                Logs(src, Config.Gerald.Log)
            end
        else
            Logs(src, "Drugs (Gerald, Coords): Player Tried to exploit Event")
            BanPlayer(src, "Drugs (Gerald Coords): Player Tried to exploit Event")
            if Config.DropPlayer then
                DropPlayer(src, "Drugs: Player Tried to exploit Event")
            end
        end
    elseif type == "MadrazoTrade" then
        local dist = #(Config.Madrazo.Location.Coords - srcCoords)
        if dist <= 50 then
            local number = 0
            for k, v in pairs(Config.Madrazo.RequiredItems) do
                if GetItem(v.item, v.count, src) then
                    number = number + 1
                end
            end
            if number == #Config.Madrazo.RequiredItems then
                for k, v in pairs(Config.Madrazo.RequiredItems) do
                    if v.remove then
                        RemoveItem(v.item, v.count, src)
                    end
                end
                for k, v in pairs(Config.Madrazo.AddItems) do
                    AddItem(v.item, v.count, src)
                end
                onTimerDealers[src] = GetGameTimer() + (2 * 1000)
                Logs(src, Config.Madrazo.Log)
            end
        else
            Logs(src, "Drugs (Madrazo, Coords): Player Tried to exploit Event")
            BanPlayer(src, "Drugs (Madrazo, Coords): Player Tried to exploit Event")
            if Config.DropPlayer then
                DropPlayer(src, "Drugs: Player Tried to exploit Event")
            end
        end
    end
end)
