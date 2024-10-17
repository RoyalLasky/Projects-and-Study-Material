local onTimerComicShop = {}
lib.callback.register('bayview_drugs:comicshop:getitem', function(source, price, amount)
    local src = source
    if GetMoney(price * amount, src) then
        return true
    else
        return false
    end
end)

RegisterServerEvent("bayview_drugs:comicshop:giveitems")
AddEventHandler("bayview_drugs:comicshop:giveitems", function(item, price, amount)
    local src = source
    if onTimerComicShop[src] and onTimerComicShop[src] > GetGameTimer() then
        Logs(src, "Drugs (ComicShop, Time): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (ComicShop, Time): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
        return
    end
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    for _, v in pairs(Config.ComicShop.Ped) do
        ShopCoords = v.coords
    end
    local dist = #(vec3(ShopCoords) - srcCoords)
    if dist <= 20 then
        for _, v in pairs(Config.ComicShop.Items) do
            if item == v.item and price == v.price and amount >= v.MinAmount and amount <= v.MaxAmount then
                if GetMoney(price * amount, src) then
                    RemoveMoney(price * amount, src)
                    AddItem(item, amount, src)
                    Logs(src, locale("HasBought", amount, item, price * amount))
                    onTimerComicShop[src] = GetGameTimer() + (2 * 1000)
                end
            end
        end
    else
        Logs(src, "Drugs (ComicShop, Coords): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (ComicShop, Coords): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
    end
end)
