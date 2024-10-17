--- Reducer function for custom stringification of the table items 
---@param t table 
---@param cb function
---@return string
local function reducer (t, cb)
    local str = "" 
    for _, v in pairs (t) do 
      str = str..cb(v) 
    end
    return str
end

local cancelBtn = lib.addKeybind({
    name = 'Cancel',
    description = 'Cancel on going progress bar',
    defaultKey = 'Escape',
    onPressed = function(self)
        lib.cancelProgress()
    end,
})
cancelBtn:disable(true)

function InitShipmentMenu(id)
    local shipment_menu_options = {}
    for package,data in pairs(Config.shipment.packagelist) do
        if lib.table.contains(data.laptops, id) and (lib.table.contains(data.authorized, 'everyone') or lib.table.contains(data.authorized, PlayerData.job.name) or lib.table.contains(data.authorized, PlayerData.gang.name)) then
            local option = {}
            option.title = package
            option.description = reducer(data.requiredItems, function (item)
                return "📋"..item.name.." x"..item.count.."\n"
            end)
            option.icon = "fa-box-open"
            option.iconColor = "#f5cb42"
            option.image = "nui://"..GetCurrentResourceName().."/client/img/"..data.img
            option.metadata = {}
            for _,item in ipairs(data.items) do
                table.insert(option.metadata, {label="🔹"..exports.ox_inventory:Items(item.name).label, value=" "..item.count})
            end
            option.onSelect = function (data)
                lib.callback('qb-shipments:server:isShipmentCallable', false, function(callable)
                    if callable then
                        CallShipment(data)
                    end
                end, data)
            end
            option.args = { package = package }
            table.insert(shipment_menu_options, option)
        end
    end
    
    lib.registerContext({
        id = "shipment_menu",
        title = "Shipment Menu",
        options = shipment_menu_options
    })
end

function CallShipment(data)
    cancelBtn:disable(false)
    if lib.progressBar({
        duration = 1500,
        label = "Calling Shipment",
        canCancel = true,
        disable = {
            move = true,
            mouse = true
        }
    }) then
        TriggerServerEvent("qb-shipments:server:createShipment", data)
    end

    cancelBtn:disable(true)
end


AddEventHandler('qb-shipment:client:openShipmentMenu', function (data)

    if lib.table.contains(data.authorized, 'everyone') then
        InitShipmentMenu(data.id)
        lib.showContext("shipment_menu") 
    elseif lib.table.contains(data.authorized, PlayerData.job.name) then        --check for job
        if PlayerData.job.isboss then
            InitShipmentMenu(data.id)
            lib.showContext("shipment_menu")
        else
            lib.notify({
                title="Login Failed!",
                description="You don't have password",
                type="error"
            })
        end
    elseif lib.table.contains(data.authorized, PlayerData.gang.name) then   --check for gang
        if PlayerData.gang.isboss then
            InitShipmentMenu(data.id)
            lib.showContext("shipment_menu")
        else
            lib.notify({
                title="Login Failed!",
                description="You don't have password",
                type="error"
            })
        end
    else
        lib.notify({
            title="Unauthorized!",
            description="You are not authorized for this action",
            type="error"
        })
    end  
end)