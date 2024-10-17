local QBCore = exports['qb-core']:GetCoreObject()
math.randomseed(os.time())

Init = function()
  VehicleShops = {}
  WarehouseVehicles = {}

  SqlFetch("SELECT * FROM "..(Config and Config.ShopTable or "vehicle_shops"),{},function(shopData)
    for k,v in pairs(shopData) do
      if v and v.locations and v.locations ~= '' and v.employees and v.employees ~= '' and v.stock and v.displays and v.displays ~= '' then
        VehicleShops[v.name] = {
          owner = (v.owner ~= "none" and v.owner or false),
          name = v.name,
          locations = json.decode(v.locations),
          employees = json.decode(v.employees),
          stock     = json.decode(v.stock),
          displays  = json.decode(v.displays),
          blipdetails = json.decode(v.blipdetails),
          warehouse = v.warehouse,
          funds     = v.funds,
          price     = v.price,
        }
      end
    end

    SqlFetch("SELECT * FROM "..(Config and Config.WarehouseTable or "vehicles"),{},function(vehData)
      for k,v in pairs(vehData) do
        table.insert(WarehouseVehicles,{name = v.name,model = v.model,price = v.price, shop = v.shop ~= nil and json.decode(v.shop) or {}})
      end

      ModReady = true
      print("Ready.")
      RefreshVehicles()
    end)
  end)

end


RefreshVehicles = function()
  local randomDefault = function(curPicked)
  local vehicle = WarehouseVehicles[math.random(#WarehouseVehicles)]
  while curPicked[vehicle] do vehicle = WarehouseVehicles[math.random(#WarehouseVehicles)]; Wait(0); end
    return vehicle
  end

  if type(Warehouse) ~= "table" or type(Warehouse.defaults) ~= "table" or
  not Warehouse.defaults.gridLength or
  not Warehouse.defaults.gridWidth  or
  not Warehouse.defaults.gridStart  then
    print("Error finding Warehouse.defaults value.")
    return
  end

  PickedVehicles = {}

  ShopVehicles = {}

  for x=Warehouse.defaults.gridStart.x,Warehouse.defaults.gridStart.x+(Warehouse.defaults.gridWidth * Warehouse.defaults.gridSpacingX),Warehouse.defaults.gridSpacingX do

    for y=Warehouse.defaults.gridStart.y,Warehouse.defaults.gridStart.y+(Warehouse.defaults.gridLength * Warehouse.defaults.gridSpacingY),Warehouse.defaults.gridSpacingY do

      local here = vector4(x,y,Warehouse.defaults.gridStart.z,Warehouse.defaults.gridHead)

      local vehicle = randomDefault(PickedVehicles)

      local randomVariation = math.floor(math.random(1, Warehouse.defaults.randomPriceVariation))

      local price = vehicle.price + (vehicle.price * randomVariation/100)

      table.insert(ShopVehicles,{model = vehicle.model,name = vehicle.name,price = QBCore.Shared.Round(price),pos = here, shop = vehicle.shop})

      PickedVehicles[vehicle] = true

    end

  end



  TriggerClientEvent("VehicleShops:WarehouseRefresh",-1,ShopVehicles)

  Wait( (Config and type(Config.RefreshTimer) == "number" and Config.RefreshTimer or (24 * 60 * 60 * 1000)) )

  print("Refreshing warehouse vehicles.")

  RefreshVehicles()

end



WaitForReady = function()

  while not ModReady do Wait(0); end

end



GetVehicleShops = function(source,callback)

  WaitForReady()

  callback({shops = VehicleShops, vehicles = ShopVehicles})

end



CreateShop = function(name,locations,price)

  local blip = {
    sprite = 225,
    color = 0,
    scale = 1.0
  }

  VehicleShops[#VehicleShops+1] = {

    owner = false,

    name = name,

    locations = locations,

    employees = {},

    stock = {},

    warehouse = true,

    blipdetails = json.encode(blip),

    displays = {},

    funds = 0,

    price = math.max(1,tonumber(price))

  }

  TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)

  SqlExecute("INSERT INTO "..(Config and Config.ShopTable or "vehicle_shops").." SET owner='none',name=@name,locations=@locations, warehouse = true, employees='{}',stock='{}',displays='{}',funds=0,price=@price, blipdetails=@blipdetails",{['@name'] = name, ['@locations'] = json.encode(locations),['@price'] = math.max(1,tonumber(price)), ['@blipdetails'] = json.encode(blip)})

end

PurchaseShop = function(source,callback,shop)
  local _source = source
  local xPlayer = QBCore.Functions.GetPlayer(_source)
  local can_buy = false

  if xPlayer.PlayerData.money['cash'] >= VehicleShops[shop].price then
    xPlayer.Functions.RemoveMoney('cash', VehicleShops[shop].price, GetCurrentResourceName()..' - Purchased Vehicle')
    can_buy = true
  elseif xPlayer.PlayerData.money['bank'] > VehicleShops[shop].price then
    xPlayer.Functions.RemoveMoney('bank', VehicleShops[shop].price, GetCurrentResourceName()..' - Purchased Vehicle')
    can_buy = true
  end

  if can_buy then
    local identifier = xPlayer.PlayerData.citizenid
    VehicleShops[shop].owner = identifier

    TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)
    SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET owner=@owner WHERE name=@name",{['@name'] = VehicleShops[shop].name, ['@owner'] = identifier})
    callback(true)
  else
    callback(false)
  end
end

GetVehicleOwner = function(source,callback,plate)
  local result = MySQL.query.await('SELECT * FROM player_vehicles WHERE plate = :plate', {['plate'] = plate})

  if result and result[1] then
    callback(result[1].citizenid)
  else
    callback(false)
  end
end

StockedVehicle = function(vehProps,shopId,doDelete, vehiclemodel, actualvehiclename)
  local src = source
  local xPlayer = QBCore.Functions.GetPlayer(src)

  TriggerEvent('rebel-lib:server:sendWebhook', Config.MasterWebhook, 2423811, "Vehicle Deposited for " .. VehicleShops[shopId].name, "Deposited a "..actualvehiclename.. "\n Plate: "..vehProps.plate..".", src)
  TriggerEvent('rebel-lib:server:sendWebhook', Config.Webhooks[VehicleShops[shopId].name].webhooks["stocked_vehicle"], 2423811, "Vehicle Deposited", "Deposited a "..actualvehiclename.. "\n Plate: "..vehProps.plate..".", src)

  if doDelete then
    MySQL.query.await("DELETE FROM player_vehicles WHERE plate= :plate", {['plate'] = vehProps.plate})
  end

  table.insert(VehicleShops[shopId].stock,{vehicle = vehProps})

  TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)

  SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET stock=@stock WHERE name=@name",{['@stock'] = json.encode(VehicleShops[shopId].stock), ['@name'] = VehicleShops[shopId].name})

end

VehiclePurchased = function(shopId,vehId,props,vehicle, actualvehiclename)
  local src = source
  local xPlayer = QBCore.Functions.GetPlayer(source)

  VehicleShops[shopId].funds = VehicleShops[shopId].funds - ShopVehicles[vehId].price

  local vehprice = ShopVehicles[vehId].price
  local vehplate = props.plate

  TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)

  SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET funds=@funds WHERE name=@name",{['@funds'] = VehicleShops[shopId].funds, ['@name'] = VehicleShops[shopId].name})

  local license = MySQL.scalar.await("SELECT license FROM players WHERE citizenid = ?", {VehicleShops[shopId].owner})

  MySQL.Async.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
    license,
    VehicleShops[shopId].owner,
    vehicle:lower(),
    props.model,
    json.encode(props),
    props.plate,
    0
  })

  TriggerEvent('rebel-lib:server:sendWebhook', Config.MasterWebhook, 2423811, "Warehouse Purchase for " .. VehicleShops[shopId].name, "bought a "..actualvehiclename.. "\n Plate: "..props.plate .."\n for $"..ShopVehicles[vehId].price..".", src)
  TriggerEvent('rebel-lib:server:sendWebhook', Config.Webhooks[VehicleShops[shopId].name].webhooks["vehicle_purchased"], 2423811, "Warehouse Purchase", "bought a "..actualvehiclename.. "\n Plate: "..props.plate.."\n for $"..ShopVehicles[vehId].price..".", src)
end



CopyTable = function(tab)

  local r = {}

  for k,v in pairs(tab) do

    if type(v) == "table" then

      r[k] = CopyTable(v)

    else

      r[k] = v

    end

  end

  return r

end



SetDisplayed = function(shop,veh,pos)

  local vehData = CopyTable(VehicleShops[shop].stock[veh])

  vehData.location = pos

  VehicleShops[shop].displays[vehData.vehicle.plate] = vehData

  for k,v in pairs(VehicleShops[shop].stock) do

    if v.vehicle.plate == vehData.vehicle.plate then

      table.remove(VehicleShops[shop].stock,k)

      break

    end

  end



  SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET stock=@stock,displays=@displays WHERE name=@name",{['@stock'] = json.encode(VehicleShops[shop].stock), ['@displays'] = json.encode(VehicleShops[shop].displays), ['@name'] = VehicleShops[shop].name})

  TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)

end



RemoveDisplay = function(shop,veh, vehname)
  local src = source
  local vehData = CopyTable(VehicleShops[shop].displays[veh])

  vehData.price = nil
  table.insert(VehicleShops[shop].stock,vehData)

  for k,v in pairs(VehicleShops[shop].displays) do

    if vehData.vehicle.plate == v.vehicle.plate then
      VehicleShops[shop].displays[k] = nil
      TriggerClientEvent('QBCore:Notify', src, "You've removed "..vehname.." ["..v.vehicle.plate.."] from display.")
      break
    end

  end


  SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET stock=@stock,displays=@displays WHERE name=@name",{['@stock'] = json.encode(VehicleShops[shop].stock), ['@displays'] = json.encode(VehicleShops[shop].displays), ['@name'] = VehicleShops[shop].name})

  TriggerClientEvent("VehicleShops:RemoveDisplay",-1,shop,veh,VehicleShops)

end



SetPrice = function(veh,shop,price)

  VehicleShops[shop].displays[veh].price = price

  TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)

  SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET displays=@displays WHERE name=@name",{['@displays'] = json.encode(VehicleShops[shop].displays), ['@name'] = VehicleShops[shop].name})

end

TryBuy = function(source,callback,shop,veh,plate,class,vehiclemodel,actualvehiclename)
  local src = source
  local xPlayer = QBCore.Functions.GetPlayer(src)

  local vehicle = VehicleShops[shop].displays[veh]

  local can_purchase = false
  
  local vehiclePrice = vehicle.price

  local xPlayer_discord = nil

  local discount = 0
  local stackablediscount = 0
  local highestdiscountroles = 0

  if VehicleShops[shop].name ~= "Auction" then

    for k,v in pairs(GetPlayerIdentifiers(src)) do
      if string.find(v, "discord") then
        xPlayer_discord = v:gsub("discord:", "")
      end
    end

    if exports.Badger_Discord_API:GetDiscordRoles(src) then

      for k,v in pairs(exports.Badger_Discord_API:GetDiscordRoles(src)) do
        if Config.DiscountRoles[tonumber(v)] then
          stackablediscount += Config.DiscountRoles[tonumber(v)]
        end
      end

      for k,v in pairs(exports.Badger_Discord_API:GetDiscordRoles(src)) do
        if Config.HighestRole[tonumber(v)] then
          if highestdiscountroles < Config.HighestRole[tonumber(v)] then
            highestdiscountroles = Config.HighestRole[tonumber(v)]
          end
        end
      end
    end
  
  end

  Wait(500)
  discount = stackablediscount + highestdiscountroles


  local purchase_price = vehiclePrice * (1 - discount) 

  if xPlayer.PlayerData.money['cash'] >= purchase_price then
    can_purchase = true
    xPlayer.Functions.RemoveMoney('cash', purchase_price, GetCurrentResourceName()..' - Purchased Vehicle')
  elseif xPlayer.PlayerData.money['bank'] >= purchase_price then
    can_purchase = true
    xPlayer.Functions.RemoveMoney('bank', purchase_price, GetCurrentResourceName()..' - Purchased Vehicle')
  end

  if can_purchase then

    local identifier = xPlayer.PlayerData.citizenid
    VehicleShops[shop].funds = VehicleShops[shop].funds + vehicle.price
    local plate = VehicleShops[shop].displays[veh].vehicle.plate
    print(plate)
    local plate2 = plate

    TriggerEvent("VehicleShops:PurchaseComplete",identifier,VehicleShops[shop].displays[veh].vehicle.plate)

    MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        xPlayer.PlayerData.license,
        xPlayer.PlayerData.citizenid,
        vehiclemodel:lower(),
        VehicleShops[shop].displays[veh].vehicle.model,
        json.encode(VehicleShops[shop].displays[veh].vehicle),
        VehicleShops[shop].displays[veh].vehicle.plate,
        0
    })

    VehicleShops[shop].displays[veh] = nil

    SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET stock=@stock,displays=@displays,funds=@funds WHERE name=@name",{

      ['@stock'] = json.encode(VehicleShops[shop].stock),

      ['@displays'] = json.encode(VehicleShops[shop].displays),

      ['@funds'] = VehicleShops[shop].funds,

      ['@name'] = VehicleShops[shop].name

    })

    TriggerClientEvent("VehicleShops:RemoveDisplay",-1,shop,veh,VehicleShops)

    TriggerEvent("VehicleShops:PurchasedVehicle",plate,class)
    
    local discountamount = discount * 100

    
    TriggerEvent('rebel-lib:server:sendWebhook', Config.MasterWebhook, 2423811, "Vehicle sold from " .. shop, " bought a "..actualvehiclename.. "\n Plate: "..plate2 .."\n for $"..purchase_price.."  \nOriginal Price: $"..vehicle.price.."  \nDiscount: "..discountamount.."%", src)
    TriggerEvent('rebel-lib:server:sendWebhook', Config.Webhooks[VehicleShops[shop].name].webhooks["vehicle_sold"], 2423811, "Vehicle sold", " bought a "..actualvehiclename.. "\n Plate: "..plate2 .."\n for $"..purchase_price.."  \nOriginal Price: $"..vehicle.price.."  \nDiscount: "..discountamount.."%", src)
    callback(true, "You've bought a vehicle for $"..purchase_price.."! You got a discount of: "..discountamount.."%. Original Price: "..vehiclePrice..".")
  else
    callback(false,"You can't afford that.")
  end
end

DriveVehicle = function(source,callback,shop,veh, vehiclemodel, actualvehiclename)
  local src = source
  local xPlayer = QBCore.Functions.GetPlayer(source)
  local vehData = CopyTable(VehicleShops[shop].stock[veh])

  for k,v in pairs(VehicleShops[shop].stock) do
    if v.vehicle.plate == vehData.vehicle.plate then
      table.remove(VehicleShops[shop].stock,k)
      break
    end
  end

  local license = MySQL.scalar.await('SELECT license FROM players WHERE citizenid = :citizenid', {['citizenid'] = VehicleShops[shop].owner})

  MySQL.Async.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
    license,
    VehicleShops[shop].owner,
    vehiclemodel:lower(),
    vehData.vehicle.model,
    json.encode(vehData.vehicle),
    vehData.vehicle.plate,
    0
  })

  TriggerEvent('rebel-lib:server:sendWebhook', Config.MasterWebhook, 2423811, "Player test drive from " .. shop, " test drove a "..actualvehiclename.. "\n Plate: "..vehData.vehicle.plate..".", src)
  TriggerEvent('rebel-lib:server:sendWebhook', Config.Webhooks[VehicleShops[shop].name].webhooks["vehicle_test_driven"], 2423811, "Player test drive", " test drove a "..actualvehiclename.. "\n Plate: "..vehData.vehicle.plate..".", src)

  SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET stock=@stock,displays=@displays WHERE name=@name",{['@stock'] = json.encode(VehicleShops[shop].stock), ['@displays'] = json.encode(VehicleShops[shop].displays), ['@name'] = VehicleShops[shop].name})

  TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)

  callback(true)
end

local function GenerateNewPlate(source, callback) -- FUNCTION TAKEN FROM QB-VEHICLESHOP
  local plate = QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(1)
  local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
  if result then
      return GeneratePlate()
  else
      callback(plate:upper())
  end
end

AddFunds = function(shop_key,amount)

  local _source = source

  local xPlayer = QBCore.Functions.GetPlayer(_source)

  local can_purchase = false

  if xPlayer.PlayerData.money['cash'] >= amount then
    can_purchase = true
    xPlayer.Functions.RemoveMoney('cash', amount, GetCurrentResourceName()..' - Deposit Money')
  elseif xPlayer.PlayerData.money['bank'] >= amount then
    can_purchase = true
    xPlayer.Functions.RemoveMoney('bank', amount, GetCurrentResourceName()..' - Deposit Money')
  end

  if can_purchase then
    VehicleShops[shop_key].funds = VehicleShops[shop_key].funds + amount
    SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET funds=funds + @amount WHERE name=@name",{['@amount'] = amount, ['@name'] = VehicleShops[shop_key].name})
    TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)
    TriggerClientEvent("QBCore:Notify", _source, "You added $"..amount.." to the shops funds.", "success")
  else
    TriggerClientEvent("QBCore:Notify", _source, "You can't afford that.", "error")
  end
end



TakeFunds = function(shop_key,amount)
  local _source = source

  if VehicleShops[shop_key].funds >= amount then
    local xPlayer = QBCore.Functions.GetPlayer(_source)
    local identifier = xPlayer.PlayerData.citizenid

    if identifier == VehicleShops[shop_key].owner then
      xPlayer.Functions.AddMoney("bank", amount, GetCurrentResourceName()..' - Withdraw Money')
      VehicleShops[shop_key].funds = VehicleShops[shop_key].funds - amount
      SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET funds=funds - @amount WHERE name=@name",{['@amount'] = amount, ['@name'] = VehicleShops[shop_key].name})
      TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)
      TriggerClientEvent("QBCore:Notify", _source, "You took $"..amount.." from the shops funds.", "success")

    end
  else
    TriggerClientEvent("QBCore:Notify", _source, "The shop doesn't have that many funds.", "error")
  end
end



HirePlayer = function(shop_key,target_id)
  local mPlayer = QBCore.Functions.GetPlayer(source)
  local mIdentifier = mPlayer.PlayerData.citizenid

  local shop = VehicleShops[shop_key]

  if shop and shop.owner and shop.owner == mIdentifier then

    local xPlayer = QBCore.Functions.GetPlayer(target_id)
    local identifier = xPlayer.PlayerData.citizenid

    table.insert(VehicleShops[shop_key].employees,{
      identifier = identifier,
      identity   = {firstname = xPlayer.PlayerData.charinfo.firstname, lastname = xPlayer.PlayerData.charinfo.lastname}
    })

    SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET employees=@employees WHERE name=@name",{['@employees'] = json.encode(VehicleShops[shop_key].employees), ['@name'] = VehicleShops[shop_key].name})
    TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)

  end
end


FirePlayer = function(shop_key,target_id)
  local mPlayer = QBCore.Functions.GetPlayer(source)
  local mIdentifier = mPlayer.PlayerData.citizenid

  local shop = VehicleShops[shop_key]

  if shop and shop.owner and shop.owner == mIdentifier then

    for k,v in pairs(VehicleShops[shop_key].employees) do

      if v.identifier == target_id then
        table.remove(VehicleShops[shop_key].employees,k)
        break
      end

    end

    SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET employees=@employees WHERE name=@name",{['@employees'] = json.encode(VehicleShops[shop_key].employees), ['@name'] = VehicleShops[shop_key].name})
    TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)
  end
end



PayPlayer = function(shop_key,target_id,amount)

  local mPlayer = QBCore.Functions.GetPlayer(source)

  local mIdentifier = mPlayer.PlayerData.citizenid

  local shop = VehicleShops[shop_key]
  if shop and shop.owner and shop.owner == mIdentifier and shop.funds >= amount then

    amount = math.floor(amount)

    for k,v in pairs(VehicleShops[shop_key].employees) do

      if v.identifier == target_id then

        local xPlayer = QBCore.Functions.GetPlayer(target_id)

        if xPlayer then
          xPlayer.Functions.AddMoney('bank', amount, GetCurrentResourceName()..' - Job Pay')

          shop.funds = shop.funds - amount

          TriggerClientEvent("QBCore:Notify",source, string.format("Payed %s %s $%i.",v.identity.firstname,v.identity.lastname,amount))

          SqlExecute("UPDATE "..(Config and Config.ShopTable or "vehicle_shops").." SET funds=funds - @amount WHERE name=@name",{['@amount'] = amount, ['@name'] = VehicleShops[shop_key].name})

          TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)
        else
          TriggerClientEvent("QBCore:Notify", source, "Player is not online.", "success")
        end

        break

      end

    end

  end

end


MySQL.ready(Init)

QBCore.Functions.CreateCallback("VehicleShops:GetVehicleShops", GetVehicleShops)
QBCore.Functions.CreateCallback("VehicleShops:GetVehicleOwner", GetVehicleOwner)
QBCore.Functions.CreateCallback("VehicleShops:GenerateNewPlate", GenerateNewPlate)
QBCore.Functions.CreateCallback("VehicleShops:TryBuy", TryBuy)
QBCore.Functions.CreateCallback("VehicleShops:PurchaseShop", PurchaseShop)
QBCore.Functions.CreateCallback("VehicleShops:DriveVehicle", DriveVehicle)

-- Get closest player sv
QBCore.Functions.CreateCallback('VehicleShops:GetPlayers', function(source, cb)
	local src = source
	local players = {}
	local PlayerPed = GetPlayerPed(src)
	local pCoords = GetEntityCoords(PlayerPed)
	for k, v in pairs(QBCore.Functions.GetPlayers()) do
		local targetped = GetPlayerPed(v)
		local tCoords = GetEntityCoords(targetped)
		local dist = #(pCoords - tCoords)
		if PlayerPed ~= targetped and dist < 10 then
			local ped = QBCore.Functions.GetPlayer(v)
			players[#players+1] = {
        id = v,
        coords = GetEntityCoords(targetped),
        name = ped.PlayerData.charinfo.firstname .. " " .. ped.PlayerData.charinfo.lastname,
        citizenid = ped.PlayerData.citizenid,
        sources = GetPlayerPed(ped.PlayerData.source),
        sourceplayer = ped.PlayerData.source
			}
		end
	end
		table.sort(players, function(a, b)
			return a.name < b.name
		end)

	cb(players)
end)

RegisterNetEvent("VehicleShops:Create", CreateShop)
RegisterNetEvent("VehicleShops:AddFunds", AddFunds)
RegisterNetEvent("VehicleShops:TakeFunds", TakeFunds)
RegisterNetEvent("VehicleShops:StockedVehicle", StockedVehicle)
RegisterNetEvent("VehicleShops:SetDisplayed", SetDisplayed)
RegisterNetEvent("VehicleShops:SetPrice", SetPrice)
RegisterNetEvent("VehicleShops:HirePlayer", HirePlayer)
RegisterNetEvent("VehicleShops:FirePlayer", FirePlayer)
RegisterNetEvent("VehicleShops:PayPlayer", PayPlayer)
RegisterNetEvent("VehicleShops:VehiclePurchased", VehiclePurchased)
RegisterNetEvent("VehicleShops:RemoveDisplay", RemoveDisplay)

-- Blips --
RegisterNetEvent('VehicleShops:ChangeBlipOption', function(shop, type, id)
  local src = source

  if QBCore.Functions.HasPermission(src, "god") then
    local result = MySQL.scalar.await("SELECT `blipdetails` FROM `vehicle_shops` WHERE `name` = ?", {shop})

    if result then
      local blip = json.decode(result)

      if type == "sprite" then
        blip.sprite = id
        VehicleShops[shop].blipdetails.sprite = id
      elseif type == "color" then
        blip.color = id
        VehicleShops[shop].blipdetails.color = id
      elseif type == "scale" then
        blip.scale = id
        VehicleShops[shop].blipdetails.scale = id
      end

      MySQL.update.await('UPDATE `vehicle_shops` SET `blipdetails` = ? WHERE `name` = ?', {json.encode(blip), shop})
      Wait(500)
      TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)
    end
  end
end)

RegisterNetEvent('VehicleShops:ToggleWarehouse', function(shop)
  local src = source

  if QBCore.Functions.HasPermission(src, "god") then
    VehicleShops[shop].warehouse = not VehicleShops[shop].warehouse
    MySQL.update.await('UPDATE `vehicle_shops` SET `warehouse` = ?', {VehicleShops[shop].warehouse})
    Wait(500)
    TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)
  end
end)

RegisterNetEvent('VehicleShops:ChangeOwnership', function(shop, citizenid)
  local src = source

  if QBCore.Functions.HasPermission(src, "god") then
    local result = MySQL.scalar.await("SELECT citizenid FROM players WHERE citizenid = ?", {citizenid})

    if result then
      MySQL.update("UPDATE vehicle_shops SET owner = ? WHERE name = ?", {citizenid, shop})
      TriggerClientEvent('QBCore:Notify', src, "You've changed the owner of "..shop.." to "..citizenid, "success")
    else
      TriggerClientEvent('QBCore:Notify', src, "The player citizenid doesn't exist!", "error")
    end
  end
end)

RegisterNetEvent('VehicleShops:ChangeBlipLocation', function(shop, pos)
  local src = source

  if QBCore.Functions.HasPermission(src, "god") then
    local result = MySQL.query.await("SELECT locations FROM vehicle_shops WHERE name = ?", {shop})

    if result and result[1] then
      local locations = json.decode(result[1].locations)
      locations.blip = pos
      MySQL.update.await('UPDATE vehicle_shops SET locations = ? WHERE name = ?', {json.encode(locations), shop})


      VehicleShops[shop].locations = locations
      Wait(500)
      TriggerClientEvent("VehicleShops:Sync",-1,VehicleShops)
    end
  end
end)

QBCore.Functions.CreateCallback('VehicleShops:CanPurchase', function(source, cb, shopId, vehId)
  local canPurchase = false
  local shopAccess = ShopVehicles[vehId].shop

  for i=1, #shopAccess do
    if shopId == shopAccess[i] then
      canPurchase = true
      break
    end
  end

  cb(canPurchase)
end)

QBCore.Functions.CreateCallback("VehicleShops:GetVehicleShopAccess", function(source, cb, vehId)
  cb(ShopVehicles[vehId].shop)
end)

RegisterNetEvent('VehicleShops:AddNewShopAccess', function(data)
  local src = source
  local vehModel = data.model
  local shopAccess = ShopVehicles[data.vehid].shop or {}
  local newShop = data.shop

  if QBCore.Functions.HasPermission(src, AdminGroup) then
    shopAccess[#shopAccess+1] = newShop

    MySQL.Sync.execute('UPDATE vehicles SET shop = ? WHERE model = ?', {
      json.encode(shopAccess),
      vehModel
    })
  end
end)

RegisterNetEvent('VehicleShops:RemoveShopAccess', function(data)
  local src = source
  local vehModel = data.model
  local remShop = data.shop
  local shopAccess = ShopVehicles[data.vehid].shop

  if QBCore.Functions.HasPermission(src, AdminGroup) then
    for i=1, #shopAccess do
      if remShop == shopAccess[i] then
        table.remove(shopAccess, i)
        break
      end
    end

    MySQL.Sync.execute('UPDATE vehicles SET shop = ? WHERE model = ?', {
      json.encode(shopAccess),
      vehModel
    })
  end
end)