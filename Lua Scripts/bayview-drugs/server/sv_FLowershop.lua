lib.locale()

local onTimerFlowerShop = {}
lib.callback.register('bayview_drugs:flowershop:getitem', function(source, price, amount)
    local src = source
    if GetMoney(price * amount, src) then
        return true
    else
        return false
    end
end)

RegisterServerEvent("bayview_drugs:flowershop:giveitems")
AddEventHandler("bayview_drugs:flowershop:giveitems", function(item, price, amount)
    local src = source
    if onTimerFlowerShop[src] and onTimerFlowerShop[src] > GetGameTimer() then
        Logs(src, "Drugs (FlowerShop, Timer): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (FlowerShop, Timer): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
        return
    end
    local srcCoords = GetEntityCoords(GetPlayerPed(src))
    for _, v in pairs(Config.FlowerShop.Ped) do
        ShopCoords = v.coords
    end
    local dist = #(vec3(ShopCoords) - srcCoords)
    if dist <= 20 then
        for _, v in pairs(Config.FlowerShop.Items) do
            if item == v.item and price == v.price and amount >= v.MinAmount and amount <= v.MaxAmount then
                if GetMoney(price * amount, src) then
                    onTimerFlowerShop[src] = GetGameTimer() + (2 * 1000)
                    RemoveMoney(price * amount, src)
                    AddItem(item, amount, src)
                    Logs(src, locale("HasBought", amount, item, price * amount))
                end
            end
        end
    else
        Logs(src, "Drugs (FlowerShop, Coords): Player Tried to exploit Event")
        BanPlayer(src, "Drugs (FlowerShop, Coords): Player Tried to exploit Event")
        if Config.DropPlayer then
            DropPlayer(src, "Drugs: Player Tried to exploit Event")
        end
    end
end)
