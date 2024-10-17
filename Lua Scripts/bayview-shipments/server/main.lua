IS_SHIPMENT_ACTIVE = false
SHIPMENT = {}

local eventID = nil

function InitCooldownTimestamps(savedData)
    local ts = {}
    for k,v in pairs(Config.shipment.packagelist) do
        ts[k] = savedData[k] or 0
    end
    return ts
end

local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('qb-shipments:server:syncActiveShipments', function ()
    local src = source
    if IS_SHIPMENT_ACTIVE then
        TriggerClientEvent('qb-shipments:client:createShipment', src, SHIPMENT)
    end
end)

lib.callback.register('qb-shipments:server:isShipmentCallable', function(src, args)
    if IS_SHIPMENT_ACTIVE then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Shipment Not Available!',
            description = 'Shipment delivery not available',
            icon = "fa-solid fa-box-open",
            type = 'error'
        })
        return false
    elseif os.time() < cooldownTimestamps[args.package] then
        local sec = cooldownTimestamps[args.package] - os.time()
        local min = math.floor(sec/60)
        local hrs = 0
        if min >= 60 then
            hrs = math.floor(min/60)
            min = math.floor(min%60)
        end

        local msg = string.format("Shipment delivery will be available after %s hour : %s min", hrs, min)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Shipment Not Available!',
            description = msg,
            icon = "fa-solid fa-box-open",
            type = 'error'
        })
        return false
    end


    local requiredItems = Config.shipment.packagelist[args.package].requiredItems
    local insufficient = false
    for _, requiredItem in pairs(requiredItems) do
        local count = exports.ox_inventory:Search(src, 'count', {requiredItem.name})
        if count < requiredItem.count then
            insufficient = true
            local needed = requiredItem.count - count
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Shipment Failed!',
                description = 'You need '..needed.." more "..requiredItem.name,
                icon = "fa-solid fa-box-open",
                type = 'error',
                duration = 10000
            })
        end
    end
    if insufficient then
        return false
    end

    return true
end)

RegisterNetEvent('qb-shipments:server:createShipment', function (args)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    math.randomseed (os.time ())
    local index = math.random(1,#Config.shipment.packagelist[args.package].dropPoints)
    IS_SHIPMENT_ACTIVE = true
    SHIPMENT.name = args.package
    SHIPMENT.dropPoint = Config.shipment.packagelist[SHIPMENT.name].dropPoints[index]
    SHIPMENT.blipOffset = {
        x = math.random(1,140)*(math.random(0,1)==0 and -1 or 1),    -- random offest between -140 to 140
        y = math.random(1,140)*(math.random(0,1)==0 and -1 or 1)
    }
    SHIPMENT.callerId = Player.PlayerData.citizenid
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Shipment Ready',
        description = 'Check Shipment location on the GPS',
        icon = "fa-solid fa-box-open",
        type = 'success'
    })
    TriggerClientEvent('qb-shipments:client:createShipment', -1, SHIPMENT)
    local requiredItems = Config.shipment.packagelist[args.package].requiredItems
    for _,requiredItem in pairs(requiredItems) do
        exports.ox_inventory:RemoveItem(src, requiredItem.name, requiredItem.count)
    end

    SetTimeout(Config.shipment.autodeleteThreshold*60*1000, function ()     --Activate auto delete timer for created shipment
        if IS_SHIPMENT_ACTIVE then
            RemoveShipment()
        end
    end)
end)

RegisterNetEvent('qb-shipments:server:openShipment', function ()
    local src = source
    if not SHIPMENT.inv then
        local shipmentItems = Config.shipment.packagelist[SHIPMENT.name].items
        local items = {}
        local weight = 0
        for _,data in pairs(shipmentItems) do
            local item = exports.ox_inventory:Items(data.name)
            weight = weight + item.weight*data.count
            if not item.stack then
                for i = 1, data.count, 1 do
                    table.insert(items, {data.name, 1})
                end
            else
                table.insert(items, {data.name, data.count})
            end
        end 

        SHIPMENT.inv = exports.ox_inventory:CreateTemporaryStash({
            label = 'Shipment',
            maxWeight = weight,
            slots = #items,
            items = items
        })

        eventID = AddEventHandler('ox_inventory:closedInventory', function(playerId, inventoryId)
            if inventoryId == SHIPMENT?.inv then
                local inv = exports.ox_inventory:GetInventory(SHIPMENT.inv)
                if not next(inv?.items) then
                    RemoveShipment()
                end
            end
        end)
    end
    TriggerClientEvent('ox_inventory:openInventory', src, 'stash', SHIPMENT.inv)
end)


function RemoveShipment()
    TriggerClientEvent('qb-shipments:client:deleteShipment', -1)
    cooldownTimestamps[SHIPMENT.name] = os.time()+(Config.shipment.packagelist[SHIPMENT.name].cooldownPeriod*60)
    SaveResourceFile(GetCurrentResourceName(), './DB/cooldown.json', json.encode(cooldownTimestamps), -1)
    SHIPMENT = {}
    IS_SHIPMENT_ACTIVE = false
    RemoveEventHandler(eventID)
end

RegisterNetEvent('qb-shipments:server:sendLocation', function (playerId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        TriggerClientEvent('qb-shipments:client:createShipmentBlip', playerId, SHIPMENT.blipOffset)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Location Sent',
            description = 'Shipment location sent successfully',
            icon = "fa-solid fa-box-open",
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Player Offline!',
            description = 'Player is not available or offline',
            icon = "fa-solid fa-box-open",
            type = 'error'
        })
    end
end)