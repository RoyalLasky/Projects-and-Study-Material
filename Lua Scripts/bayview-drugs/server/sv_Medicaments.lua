local onTimerMedicaments = {}
lib.callback.register('bayview_drugs:medicaments:getitem', function(source, price, amount)
    local src = source
    if GetMoney(price * amount, src) then
        return true
    else
        return false
    end
end)

RegisterServerEvent("bayview_drugs:medicaments:giveitems")
AddEventHandler("bayview_drugs:medicaments:giveitems", function(item, price, amount)
    local src = source
    if onTimerMedicaments[src] and onTimerMedicaments[src] > GetGameTimer() then
        Logs(src, "Drugs (Medicaments, Timer): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (Medicaments, Timer): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
        return
    end
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    for _, v in pairs(Config.MedicamentsShop.Ped) do
        ShopCoords = v.coords
    end
    local dist = #(vec3(ShopCoords) - srcCoords)
    if dist <= 20 then
        for _, v in pairs(Config.MedicamentsShop.Items) do
            if item == v.item and price == v.price and amount >= v.MinAmount and amount <= v.MaxAmount then
                if GetMoney(price * amount, src) then
                    onTimerMedicaments[src] = GetGameTimer() + (2 * 1000)
                    RemoveMoney(price * amount, src)
                    if item == "lsd" then
                        local random = math.random(1, 5)
                        item = "lsd" .. random
                    elseif item == "ecstasy" then
                        local random = math.random(1, 5)
                        item = "ecstasy" .. random
                    end
                    Logs(src, locale("HasBought", amount, item, price * amount))
                    AddItem(item, amount, src)
                end
            end
        end
    else
        Logs(src, "Drugs (Medicaments, Coords): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (Medicaments, Coords): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
    end
end)
