LAPTOPS = {}
SHIPMENT = {}

QBCore = exports['qb-core']:GetCoreObject()
PlayerData = nil

-- AddEventHandler('playerSpawned', function ()
--     if not next(LAPTOPS) then   
--         CreateShipmentCallingPoints()
--     end 

--     if not next(SHIPMENT) then
--         TriggerServerEvent('qb-shipments:server:syncActiveShipments')
--     end
-- end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    if not next(LAPTOPS) then   
        CreateShipmentCallingPoints()
    end 

    if not next(SHIPMENT) then
        TriggerServerEvent('qb-shipments:server:syncActiveShipments')
    end
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

RegisterNetEvent('qb-shipments:client:createShipment', function (shipment)
    SHIPMENT = lib.points.new({
        coords = vector3(shipment.dropPoint.x, shipment.dropPoint.y, shipment.dropPoint.z),
        heading = shipment.dropPoint.w,
        distance = 300,
        name = shipment.name,
        model = Config.shipment.packagelist[shipment.name].model,
        handle = 0,
        blip = 0
    })

    if QBCore.Functions.GetPlayerData().citizenid == shipment.callerId then         
        SHIPMENT.blip = GetBlipForShipment(vector3(SHIPMENT.coords.x+shipment.blipOffset.x, SHIPMENT.coords.y+shipment.blipOffset.y,  SHIPMENT.coords.z))
    end
     
    function SHIPMENT:onEnter()
        --print('entered range of point', self.id, self.name)
        lib.requestModel(self.model, 1000)
        self.handle = CreateObject(GetHashKey(self.model), self.coords, false)
        SetEntityHeading(self.handle, self.heading)
        PlaceObjectOnGroundProperly(self.handle)
        Wait(500)
        FreezeEntityPosition(self.handle, true)
        self.ptfxHandle = StartPtfx("core", "exp_grd_flare", self.coords, 1.0)
        exports.ox_target:addLocalEntity(self.handle, {
            name = "shipment_target",
            label = "Open Shipment",
            distance = 3.0,
            icon = "fa-solid fa-lock-open",
            onSelect = function (data)
                local success = lib.skillCheck('easy',{'w','a','s','d'})
                if success then
                    TriggerServerEvent('qb-shipments:server:openShipment')
                else
                    lib.notify({
                        title="Failed!",
                        description="Failed to open the shipments",
                        type="error"
                    })
                end
            end
        })
    end
     
    function SHIPMENT:onExit()
        --print('left range of point', self.id)
        StopPtfx(self.ptfxHandle)
        exports.ox_target:removeLocalEntity(self.handle, "shipment_target")
        FreezeEntityPosition(self.handle, false)
        DeleteObject(self.handle)
    end

    exports['qb-radialmenu']:AddRadialItem({
        id = 'shipment_location',
        title = 'Shipment',
        icon = 'location-dot',
        type = 'client',
        event = 'qb-shipments:client:shareLocation',
        shouldClose = true,
    })

end)

AddEventHandler('qb-shipments:client:shareLocation', function ()
    local input = lib.inputDialog('Shipment Locator', {
        {type = 'number', label = 'Player ID', description = 'Enter Player ID', icon = 'fa-user-large', required = true},
    })
    
    if input then
        TriggerServerEvent('qb-shipments:server:sendLocation', input[1])
    end
end)

RegisterNetEvent('qb-shipments:client:createShipmentBlip', function (blipOffset)
    SHIPMENT.blip = GetBlipForShipment(vector3(SHIPMENT.coords.x+blipOffset.x, SHIPMENT.coords.y+blipOffset.y,  SHIPMENT.coords.z))
end)


RegisterNetEvent('qb-shipments:client:deleteShipment', function ()
    if next(SHIPMENT) then
        exports.ox_target:removeLocalEntity(SHIPMENT.handle, "shipment_target")
        exports['qb-radialmenu']:RemoveRadialItem('shipment_location')
        RemoveBlip(SHIPMENT.blip)
        if SHIPMENT.handle and DoesEntityExist(SHIPMENT.handle) then
            StopPtfx(SHIPMENT.ptfxHandle)
            DeleteObject(SHIPMENT.handle)
        end
        SHIPMENT:remove()
        SHIPMENT = {}
    end
end)

AddEventHandler('onResourceStop', function (resourceName)
    if GetCurrentResourceName() == resourceName then
        for _,laptop in pairs(LAPTOPS) do
            FreezeEntityPosition(laptop.handle, false)
            DeleteObject(laptop.handle)
            laptop:remove()
        end

        if next(SHIPMENT) then
            exports.ox_target:removeLocalEntity(SHIPMENT.handle, "shipment_target")
            exports['qb-radialmenu']:RemoveRadialItem('shipment_location')
            RemoveBlip(SHIPMENT.blip)
            if SHIPMENT.handle and DoesEntityExist(SHIPMENT.handle) then
                StopPtfx(SHIPMENT.ptfxHandle)
                DeleteObject(SHIPMENT.handle)
                --print("SHIPMENT deleted..")
            end
            SHIPMENT:remove()
        end
    end
end)

AddEventHandler('onResourceStart', function (resourceName)
    if GetCurrentResourceName() == resourceName then
        PlayerData = QBCore.Functions.GetPlayerData()
        CreateShipmentCallingPoints()
    end
end)






function CreateShipmentCallingPoints()
    for k,v in pairs(Config.shipment.callingPoints) do
        local laptop = lib.points.new({
            coords = vector3(v.coords.x, v.coords.y, v.coords.z),
            heading = v.coords.w,
            distance = 15,
            model = v.model,
            handle = 0,
        })

        function laptop:onEnter()
            lib.requestModel(self.model, 1000)
            self.handle = CreateObject(GetHashKey(self.model), self.coords, false)
            SetEntityHeading(self.handle, self.heading)
            FreezeEntityPosition(self.handle, true)
            exports.ox_target:addLocalEntity(self.handle, {
                name = "shipment_laptop",
                label = "Call for Shipments",
                distance = 1.5,
                icon = "fa-brands fa-internet-explorer",
                event = "qb-shipment:client:openShipmentMenu",
                id = k,
                authorized = v.authorized
            })
        end

        function laptop:onExit()
            exports.ox_target:removeLocalEntity(self.handle, "shipment_laptop")
            FreezeEntityPosition(self.handle, false)
            DeleteObject(self.handle)
        end

        table.insert(LAPTOPS, laptop)
    end
end

function GetBlipForShipment(coord)
    local blip = AddBlipForRadius(coord,200.0)
    --local blip = AddBlipForCoord(coord)
    --SetBlipSprite(blip, 501)
    --SetBlipScale(blip, 1.0)
    SetBlipColour(blip,26)
    SetBlipAlpha(blip, 150)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString("Shipment")
    EndTextCommandSetBlipName(blip)
    return blip
end

function StartPtfx(dict, particleName, coords, scale)
	-- Request the particle dictionary.
	RequestNamedPtfxAsset(dict)
	-- Wait for the particle dictionary to load.
	while not HasNamedPtfxAssetLoaded(dict) do
		Citizen.Wait(0)
	end
	-- Tell the game that we want to use a specific dictionary for the next particle native.
	UseParticleFxAsset(dict)

	local particleHandle = StartParticleFxLoopedAtCoord(particleName, coords, 0.0, 0.0, 0.0, scale, false, false, false)
	SetParticleFxLoopedColour(particleHandle, 0, 255, 0 ,0)
    --print("Ptfx started..")
	return particleHandle
end

function StopPtfx(handle)
    StopParticleFxLooped(handle, false)
    --print("Ptfx stopped..")
end