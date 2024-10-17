local onTimerPharmacist = {}
lib.callback.register('bayview_drugs:pharmacist:getitem', function(source, price, amount)
    local src = source
    if GetMoney(price * amount, src) then
        return true
    else
        return false
    end
end)

RegisterServerEvent("bayview_drugs:pharmacist:giveitems")
AddEventHandler("bayview_drugs:pharmacist:giveitems", function(item, price, amount)
    local src = source
    if onTimerPharmacist[src] and onTimerPharmacist[src] > GetGameTimer() then
        Logs(src, "Drugs (Pharmacist, Time): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (Pharmacist, Time): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
        return
    end
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    for _, v in pairs(Config.Pharmacist.Ped) do
        ShopCoords = v.coords
    end
    local dist = #(vec3(ShopCoords) - srcCoords)
    if dist <= 20 then
        onTimerPharmacist[src] = GetGameTimer() + (2 * 1000)
        for _, v in pairs(Config.Pharmacist.Items) do
            if item == v.item and price == v.price and amount >= v.MinAmount and amount <= v.MaxAmount then
                if GetMoney(price * amount, src) then
                    RemoveMoney(price * amount, src)
                    AddItem(item,  amount, src)
                    Logs(src, locale("HasBought", amount, item, price * amount))
                end
            end
        end
    else
        Logs(src, "Drugs (Pharmacist, Coords): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (Pharmacist, Coords): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
    end
end)
