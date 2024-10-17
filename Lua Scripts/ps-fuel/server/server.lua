-- Variables

local QBCore = exports['qb-core']:GetCoreObject()

-- Functions

local function GlobalTax(value)
	local tax = (value / 100 * Config.GlobalTax)
	return tax
end

-- Server Events

RegisterNetEvent("ps-fuel:server:OpenMenu", function (vehicleFuel, inGasStation, hasWeapon, gasStationId)
	local src = source
	if not src then return end
	local player = QBCore.Functions.GetPlayer(src)
	if not player then return end
	local fuelStock, fuelPrice = getFuelPriceAndStockFromGasStationScript(gasStationId)
	local amount = Round(Config.RefillCost - vehicleFuel) * fuelPrice
	local tax = GlobalTax(amount)
	local total = math.ceil(amount + tax)
	if inGasStation == true and not hasWeapon then
		if fuelStock > Round(Config.RefillCost - vehicleFuel) then
			TriggerClientEvent('qb-menu:client:openMenu', src, {
				{
					header = 'Gas Station (Fuel price $'..(fuelPrice)..')',
					txt = 'The total cost is going to be: $'..total..' including taxes.' ,
					params = {
						event = "ps-fuel:client:RefuelVehicle",
						args = {pricePaid=total,vehicleFuel=vehicleFuel},
					}
				},
			})
		else
			TriggerClientEvent("gas_station:Notify",src,"negado","Insufficient fuel in stock to refuel this vehicle.",8000)
		end
	else
		TriggerClientEvent('qb-menu:client:openMenu', src, {
			{
				header = 'Gas Station',
				txt = 'Refuel from jerry can' ,
				params = {
					event = "ps-fuel:client:RefuelVehicle",
				}
			},
		})
	end
end)

QBCore.Functions.CreateCallback('ps-fuel:server:fuelCan', function(source, cb)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local itemData = Player.Functions.GetItemByName("weapon_petrolcan")
    cb(itemData)
end)

RegisterNetEvent("ps-fuel:server:PayForFuel", function (amount)
	local src = source
	if not src then return end
	local player = QBCore.Functions.GetPlayer(src)
	if not player then return end
	player.Functions.RemoveMoney('cash', amount)
end)

QBCore.Functions.CreateCallback('ps-fuel:server:PayForFuelGasStation', function(source, cb, gasStationId, pricePaid, fuelAmount, buycan)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local cashBalance = Player.PlayerData.money.cash
	if not Player then return end
	if buycan then
		local fuelStock, fuelPrice = getFuelPriceAndStockFromGasStationScript(gasStationId)
		if fuelStock == 0 then
			TriggerClientEvent('QBCore:Notify', src, "The Gas station does not have enough fuel for you to purchase a gas can.", "success")
			cb(false)
		elseif cashBalance < Config.canCost then
			TriggerClientEvent('QBCore:Notify', src, "You do not have enough money to purchase a gas can.", "success")
			cb(false)
		else
			Player.Functions.RemoveMoney('cash', pricePaid)
			exports.ox_inventory:AddItem(src, "WEAPON_PETROLCAN", 1, false, false, false)
			TriggerClientEvent('QBCore:Notify', src, "You purchased a jerry can for $"..Config.canCost, "success")
			removeStockFromGasStationScript(gasStationId,pricePaid,100)
			cb(true)
		end
	else
    	if cashBalance >= pricePaid and removeStockFromGasStationScript(gasStationId,pricePaid,fuelAmount) then
			Player.Functions.RemoveMoney('cash', pricePaid)
    	    cb(true)
    	else
    	    TriggerClientEvent('QBCore:Notify', src, "You dont have enough cash", "error")
    	    cb(false)
    	end
	end
end)

--QBCore.Functions.CreateCallback('ps-fuel:server:fuelCanPurchase', function(source, cb)
--    local src = source
--    local Player = QBCore.Functions.GetPlayer(src)
--    local cashBalance = Player.PlayerData.money.cash
--	if not Player then return end
--    if cashBalance >= Config.canCost then
--		--Player.Functions.RemoveMoney('cash', Config.canCost)
--        --Player.Functions.AddItem("weapon_petrolcan", 1, false)
--		--exports.ox_inventory:AddItem(src, "WEAPON_PETROLCAN", 1, false, false, false)
--		TriggerClientEvent('QBCore:Notify', src, "You purchased a jerry can for $"..Config.canCost, "success")
--        cb(true)
--    else
--        TriggerClientEvent('QBCore:Notify', src, "You dont have enough cash on you..", "error")
--        cb(false)
--    end
--end)

RegisterNetEvent('ps-fuel:Server:setJerryDurability', function(durability)
	local src = source
    local petrolCan = exports.ox_inventory:GetCurrentWeapon(src)
    if petrolCan ~= nil then
        petrolCan.metadata.ammo = durability
        petrolCan.metadata.durability = durability
        local petrolCanSlot = petrolCan.slot
        local petrolCanMetaData = petrolCan.metadata
        exports.ox_inventory:SetMetadata(src, petrolCanSlot, petrolCanMetaData)
    end
end)

RegisterNetEvent("ps-fuel:server:RemoveCan", function()
	local src = source
	if not src then return end
	local player = QBCore.Functions.GetPlayer(src)
	if not player then return end
	exports.ox_inventory:RemoveItem(src, "WEAPON_PETROLCAN", 1, false, false)
end)

function Round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end

function getFuelPriceAndStockFromGasStationScript(gasStationId)
	if not gasStationId then
		return Config.defaultGasStock, Config.defaultGasPrice
	end

	local sql = "SELECT stock, price FROM gas_station_business WHERE gas_station_id = @gas_station_id";
	local query = MySQL.Sync.fetchAll(sql, {['@gas_station_id'] = gasStationId});
	
	if not query or not query[1] then
		return Config.defaultGasStock, Config.defaultGasPrice
	end

	local sql = "UPDATE `gas_station_business` SET total_visits = total_visits + 1 WHERE gas_station_id = @gas_station_id";
	MySQL.Sync.execute(sql, {['@gas_station_id'] = gasStationId});
	return query[1].stock, query[1].price/100
end

function removeStockFromGasStationScript(gasStationId,pricePaid,fuelAmount)
	if not gasStationId then
		return true
	end

	local sql = "SELECT stock, price FROM gas_station_business WHERE gas_station_id = @gas_station_id";
	local query = MySQL.Sync.fetchAll(sql, {['@gas_station_id'] = gasStationId});
	
	if not query or not query[1] then
		return true
	end

	if query[1].stock < fuelAmount then
		return false
	end

	local sql = "UPDATE `gas_station_business` SET stock = @stock, customers = customers + 1, money = money + @price, total_money_earned = total_money_earned + @price, gas_sold = gas_sold + @amount WHERE gas_station_id = @gas_station_id";
	MySQL.Sync.execute(sql, {['@gas_station_id'] = gasStationId, ['@stock'] = (query[1].stock - fuelAmount), ['@price'] = pricePaid, ['@amount'] = fuelAmount});
	
	local sql = "INSERT INTO `gas_station_balance` (gas_station_id,income,title,amount,date) VALUES (@gas_station_id,@income,@title,@amount,@date)";
	MySQL.Sync.execute(sql, {['@gas_station_id'] = gasStationId, ['@income'] = 0, ['@title'] = "Fuel sold ("..fuelAmount.." Liters)", ['@amount'] = pricePaid, ['@date'] = os.time()});
	return true
end