-- Variables

local QBCore = exports['qb-core']:GetCoreObject()
local fuelSynced = false
local inBlacklisted = false
local inGasStation = false
local isFueling = false
local Stations = {}
local props = {
	'prop_gas_pump_1d',
	'prop_gas_pump_1a',
	'prop_gas_pump_1b',
	'prop_gas_pump_1c',
	'prop_vintage_pump',
	'prop_gas_pump_old2',
	'prop_gas_pump_old3',
}
local CurrentWeaponData = {}

-- Functions

local function isHoldingWeapon(weaponHash)
	return GetSelectedPedWeapon(PlayerPedId()) == weaponHash
end

local function ManageFuelUsage(vehicle)
	if not DecorExistOn(vehicle, Config.FuelDecor) then
		SetFuel(vehicle, math.random(200, 800) / 10)
	elseif not fuelSynced then
		SetFuel(vehicle, GetFuel(vehicle))
		fuelSynced = true
	end
	if IsVehicleEngineOn(vehicle) then
		SetFuel(vehicle, GetVehicleFuelLevel(vehicle) - Config.FuelUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Config.Classes[GetVehicleClass(vehicle)] or 1.0) / 10)
		SetVehicleEngineOn(veh, true, true, true)
	else
		SetVehicleEngineOn(veh, true, true, true)
	end
end

-- Threads

CreateThread(function()
	local bones = {
		"petroltank",
		"petroltank_l",
		"petroltank_r",
		"wheel_rf",
		"wheel_rr",
		"petrolcap ",
		"seat_dside_r",
		"engine",
	}
	exports['qb-target']:AddTargetBone(bones, {
		options = {
			{
				type = "client",
				event = "ps-fuel:client:SendMenuToServer",
				icon = "fas fa-gas-pump",
				label = "Refuel Vehicle",
				canInteract = function()
					return inGasStation or HasPedGotWeapon(PlayerPedId(), 883325847)
				end
			}
		},
		distance = 1.5,
	})
end)

if Config.LeaveEngineRunning then
	CreateThread(function()
		while true do
			Wait(100)
			local ped = GetPlayerPed(-1)
			if DoesEntityExist(ped) and IsPedInAnyVehicle(ped, false) and IsControlPressed(2, 75) and not IsEntityDead(ped) and not IsPauseMenuActive() then
				local engineWasRunning = GetIsVehicleEngineRunning(GetVehiclePedIsIn(ped, true))
				Wait(1000)
				if DoesEntityExist(ped) and not IsPedInAnyVehicle(ped, false) and not IsEntityDead(ped) and not IsPauseMenuActive() then
					local veh = GetVehiclePedIsIn(ped, true)
					if engineWasRunning then
						SetVehicleEngineOn(veh, true, true, true)
					end
				end
			end
		end
	end)
end

if Config.ShowNearestGasStationOnly then
	CreateThread(function()
		local currentGasBlip = 0
		while true do
			local coords = GetEntityCoords(PlayerPedId())
			local closest = 1000
			local closestCoords
			
			for _, gasStationCoords in pairs(Config.GasStationsBlips) do
				local dstcheck = #(coords - gasStationCoords)
				if dstcheck < closest then
					closest = dstcheck
					closestCoords = gasStationCoords
				end
			end
			if DoesBlipExist(currentGasBlip) then
				RemoveBlip(currentGasBlip)
			end
			currentGasBlip = CreateBlip(closestCoords)
			Wait(10000)
		end
	end)
	
else
	CreateThread(function()
		for _, gasStationCoords in pairs(Config.GasStationsBlips) do
			CreateBlip(gasStationCoords)
		end
	end)
end

CreateThread(function()
	for k=1, #Config.GasStations do
		Stations[k] = PolyZone:Create(Config.GasStations[k].zones, {
			name="GasStation"..k,
			minZ = 	Config.GasStations[k].minz,
			maxZ = Config.GasStations[k].maxz,
			debugPoly = false
		})
		Stations[k]:onPlayerInOut(function(isPointInside)
			if isPointInside then
				inGasStation = true
			else
				inGasStation = false
			end
		end)
	end
end)

CreateThread(function()
	DecorRegister(Config.FuelDecor, 1)
	for index = 1, #Config.Blacklist do
		if type(Config.Blacklist[index]) == 'string' then
			Config.Blacklist[GetHashKey(Config.Blacklist[index])] = true
		else
			Config.Blacklist[Config.Blacklist[index]] = true
		end
	end
	for index = #Config.Blacklist, 1, -1 do
		Config.Blacklist[index] = nil
	end
	while true do
		Wait(1000)
		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped) then
			local vehicle = GetVehiclePedIsIn(ped)
			if Config.Blacklist[GetEntityModel(vehicle)] then
				inBlacklisted = true
			else
				inBlacklisted = false
			end
			if not inBlacklisted and GetPedInVehicleSeat(vehicle, -1) == ped then
				ManageFuelUsage(vehicle)
			end
		else
			if fuelSynced then
				fuelSynced = false
			end
			if inBlacklisted then
				inBlacklisted = false
			end
		end
	end
end)

-- Client Events

RegisterNetEvent('ps-fuel:client:buyCanMenu', function()
	exports['qb-menu']:openMenu({
		{
			header = "Gas Station",
			txt = 'The total cost is going to be: $'..Config.canCost..' including taxes.',
			params = {
				event = "ps-fuel:client:buyCan",
			}
		},
	})
end)

RegisterNetEvent('ps-fuel:client:buyCan', function()
	local ped = PlayerPedId()
	--if not HasPedGotWeapon(ped, 883325847) then
		--QBCore.Functions.TriggerCallback('ps-fuel:server:fuelCanPurchase', function(hasMoney)
		--	if hasMoney then
		--		local pumpLocation = nil
		--		for k,v in pairs(Config.GasStationOwner) do
		--			if GetDistanceBetweenCoords(vector3(v[1],v[2],v[3]),GetEntityCoords(ped)) <= v[4] then
		--				pumpLocation = k
		--			end
		--		end
		--		QBCore.Functions.TriggerCallback('ps-fuel:server:PayForFuelGasStation', function(result)
		--			--lol this does nothing WOOO
		--		end, pumpLocation, Config.canCost, 0, true)
		--	end
		--end)
		local pumpLocation = nil
		for k,v in pairs(Config.GasStationOwner) do
			if GetDistanceBetweenCoords(vector3(v[1],v[2],v[3]),GetEntityCoords(ped)) <= v[4] then
				pumpLocation = k
			end
		end
		QBCore.Functions.TriggerCallback('ps-fuel:server:PayForFuelGasStation', function(result)
			--lol this does nothing WOOO
		end, pumpLocation, Config.canCost, 0, true)
	--end
end)
--[[
RegisterNetEvent('ps-fuel:client:refuelCanMenu', function()
	local ped = PlayerPedId()
	local price = 0
	local weapon = GetSelectedPedWeapon(PlayerPedId())
	local ammo = GetAmmoInPedWeapon(PlayerPedId(), weapon)
	local ammotoAdd = 4500 - ammo
	
	local fuelToAdd = tonumber(ammotoAdd/45)
	if fuelToAdd ~= 0 then
		price = math.floor(fuelToAdd * Config.fuelPrice)
		exports['qb-menu']:openMenu({
			{
				header = "Gas Station",
				txt = "The total cost of refueling the Gas can will be "..Config.refuelCost.."$",
				params = {
					event = "ps-fuel:client:refuelCan",
				}
			},
		})
	else
		QBCore.Functions.Notify(Lang:t("already_full"), "error")
	end
end)

RegisterNetEvent('ps-fuel:client:refuelCan', function()
	local vehicle = QBCore.Functions.GetClosestVehicle()
	local ped = PlayerPedId()
	local CurFuel = GetVehicleFuelLevel(vehicle)
	if HasPedGotWeapon(ped, 883325847) then
		if GetAmmoInPedWeapon(ped, 883325847) <= 99 then
			RequestAnimDict("weapon@w_sp_jerrycan")
			while not HasAnimDictLoaded('weapon@w_sp_jerrycan') do Wait(100) end
			TaskPlayAnim(ped, "weapon@w_sp_jerrycan", "fire", 8.0, 1.0, -1, 1, 0, 0, 0, 0 )
			QBCore.Functions.Progressbar("refuel-car", "Refueling", 10000, false, true, {
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			}, {}, {}, {}, function() -- Done
				TriggerServerEvent('ps-fuel:server:PayForFuel', Config.refuelCost, GetPlayerServerId(PlayerId()))
				TriggerServerEvent("weapons:server:UpdateWeaponAmmo", CurrentWeaponData, tonumber(4500))
				PlaySound(-1, "5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
				StopAnimTask(ped, "weapon@w_sp_jerrycan", "fire", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
			end, function() -- Cancel
				QBCore.Functions.Notify(Lang:t("notify.refuel_cancel"), "error")
				StopAnimTask(ped, "weapon@w_sp_jerrycan", "fire", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
			end)
		else
			QBCore.Functions.Notify(Lang:t("notify.jerrycan_full"), "error")
		end
	end
end)
]]

RegisterNetEvent('ps-fuel:client:SendMenuToServer', function()
	local vehicle = QBCore.Functions.GetClosestVehicle()
	local ped = PlayerPedId()
	local CurFuel = GetVehicleFuelLevel(vehicle)
	if HasPedGotWeapon(ped, 883325847) then
		if GetAmmoInPedWeapon(ped, 883325847) ~= 0 then
			if CurFuel < 95 then
				TriggerServerEvent('ps-fuel:server:OpenMenu', 0, inGasStatio, true)
			else
				QBCore.Functions.Notify(Lang:t("notify.vehicle_full"), "error")
			end
		else
			QBCore.Functions.Notify(Lang:t("notify.jerrycan_empty"), "error")
		end
	else
		if CurFuel < 95 then
			local pumpLocation = nil
			for k,v in pairs(Config.GasStationOwner) do
				if GetDistanceBetweenCoords(vector3(v[1],v[2],v[3]),GetEntityCoords(ped)) <= v[4] then
					pumpLocation = k
				end
			end
			TriggerServerEvent('ps-fuel:server:OpenMenu', CurFuel, inGasStation, false, pumpLocation)
		else
			QBCore.Functions.Notify(Lang:t("notify.vehicle_full"), "error")
		end
	end
end)

AddEventHandler('weapons:client:SetCurrentWeapon', function(data, bool)
	if bool ~= false then
		CurrentWeaponData = data
	else
		CurrentWeaponData = {}
	end
	CanShoot = bool
end)

RegisterNetEvent('ps-fuel:client:RefuelVehicle', function(data)
	local src = source
	local gasProp = 0
	local gasNozzle = "prop_cs_fuel_nozle"
	local ped = PlayerPedId()
	local vehicle = QBCore.Functions.GetClosestVehicle()
	local ped = PlayerPedId()
	local CurFuel = GetFuel(vehicle)
	local time = (100 - CurFuel) * 400
	local vehicleCoords = GetEntityCoords(vehicle)
	if inGasStation == false and not HasPedGotWeapon(ped, 883325847) then
	elseif inGasStation == false and GetAmmoInPedWeapon(ped, 883325847) == 0 then
		return
	end
	if HasPedGotWeapon(ped, 883325847) then
		local fuelToAdd = tonumber((100 - CurFuel) * 45)
		local weapon = GetSelectedPedWeapon(PlayerPedId())
		local currentWeapon = exports.ox_inventory:getCurrentWeapon()
		local ammo = currentWeapon.metadata.ammo
		if fuelToAdd == 0 then
			QBCore.Functions.Notify("Vehicle already full", "error")
			return
		end
		if ammo <= 0 then
			QBCore.Functions.Notify("You have no fuel in the gas can", "error")
		else
			RequestAnimDict("weapon@w_sp_jerrycan")
			while not HasAnimDictLoaded('weapon@w_sp_jerrycan') do
				Wait(100)
			end
			TaskPlayAnim(ped, "weapon@w_sp_jerrycan", "fire", 8.0, 1.0, -1, 1, 0, 0, 0, 0 )
			if GetIsVehicleEngineRunning(vehicle) and Config.VehicleBlowUp then
				local Chance = math.random(1, 100)
				if Chance <= Config.BlowUpChance then
					AddExplosion(vehicleCoords, 5, 50.0, true, false, true)
					return
				end
			end
			TriggerEvent("ps-fuel:client:fuelTick", vehicle)
			QBCore.Functions.Progressbar("refuel-car", "Refueling", time, false, true, {
			
				disableMovement = true,
				disableCarMovement = true,
				disableMouse = false,
				disableCombat = true,
			}, {}, {}, {}, function() -- Done

				local currentWeapon = exports.ox_inventory:getCurrentWeapon()
				local ammo = currentWeapon.metadata.ammo
				local carfuel = math.floor(CurFuel * 1) / 1 -- sets carfuel to a full number.
				local howmuchdoineedtofillup = 100 - carfuel -- how much do i need to fill up
				local howmuchifilledup = 100 - carfuel -- how much "ammo" did I use

				if ammo >= howmuchdoineedtofillup then
				    SetFuel(vehicle, 100)
				    TriggerServerEvent('ps-fuel:Server:setJerryDurability', ammo - howmuchifilledup)
				else
				    SetFuel(vehicle, carfuel + ammo)
				    TriggerServerEvent('ps-fuel:Server:setJerryDurability', 0)
					TriggerEvent('ox_inventory:disarm', ped, true)
					--TriggerServerEvent('ps-fuel:server:RemoveCan', src)
				end

				PlaySound(-1, "5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
				StopAnimTask(ped, "weapon@w_sp_jerrycan", "fire", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
				isFueling = false
			end, function() -- Cancel
				QBCore.Functions.Notify(Lang:t("notify.refuel_cancel"), "error")
				StopAnimTask(ped, "weapon@w_sp_jerrycan", "fire", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
			end)
		end
	else
		if inGasStation then
			if isCloseVeh() then
				if QBCore.Functions.GetPlayerData().money['cash'] <= data.pricePaid then
					QBCore.Functions.Notify(Lang:t("notify.no_money"), "error")
				else
					RequestAnimDict("amb@world_human_security_shine_torch@male@base")
					while not HasAnimDictLoaded('amb@world_human_security_shine_torch@male@base') do Wait(100) end
					TaskPlayAnim(ped, "amb@world_human_security_shine_torch@male@base", "base", 8.0, 1.0, -1, 1, 0, 0, 0, 0 )
					
					gasProp = CreateObject(gasNozzle, 1.0, 1.0, 1.0, 1, 1, 0)
					local bone = GetPedBoneIndex(PlayerPedId(), 60309)
					AttachEntityToEntity(gasProp, PlayerPedId(), bone, 0.0, 0.0, 0.05, 350.0, 350.0, 250.0, 1, 1, 0, 0, 2, 1)
					
					if GetIsVehicleEngineRunning(vehicle) and Config.VehicleBlowUp then
						local Chance = math.random(1, 100)
						if Chance <= Config.BlowUpChance then
							AddExplosion(vehicleCoords, 5, 50.0, true, false, true)
							return
						end
					end
					QBCore.Functions.Progressbar("refuel-car", "Refueling", time, false, true, {
						disableMovement = true,
						disableCarMovement = true,
						disableMouse = false,
						disableCombat = true,
					}, {}, {}, {}, function() -- Done
						local pumpLocation = nil
						for k,v in pairs(Config.GasStationOwner) do
							if GetDistanceBetweenCoords(vector3(v[1],v[2],v[3]),GetEntityCoords(ped)) <= v[4] then
								pumpLocation = k
							end
						end
						QBCore.Functions.TriggerCallback('ps-fuel:server:PayForFuelGasStation', function(result)
							if result then
								SetFuel(vehicle, 100)
								PlaySound(-1, "5_SEC_WARNING", "HUD_MINI_GAME_SOUNDSET", 0, 0, 1)
								StopAnimTask(ped, "amb@world_human_security_shine_torch@male@base", "base", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
								DeleteObject(gasProp)
							end
						end, pumpLocation, data.pricePaid, Round(Config.RefillCost - data.vehicleFuel), false)
					end, function() -- Cancel
						QBCore.Functions.Notify(Lang:t("notify.refuel_cancel"), "error")
						StopAnimTask(ped, "amb@world_human_security_shine_torch@male@base", "base", 3.0, 3.0, -1, 2, 0, 0, 0, 0)
						DeleteObject(gasProp)
					end)
				end
			end
		end
	end
end)

-- Target Export

exports['qb-target']:AddTargetModel(props, {
	options = {
		{
			type = "client",
			event = "ps-fuel:client:buyCanMenu",
			icon = "fas fa-burn",
			label = "Buy Jerry Can",
			
		},
		--{
		--	type = "client",
		--	event = "ps-fuel:client:refuelCanMenu",
		--	icon = "fas fa-gas-pump",
		--	label = "Refuel Jerry Can",
		--	canInteract = function(entity)
		--		return isHoldingWeapon(GetHashKey("weapon_petrolcan"))
		--	end,
		--},
	},
	distance = 2.0
})
