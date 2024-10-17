local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Commands.Add('vehshop:create', 'Create a vehicle shop', {}, false, function(source, args)
  TriggerClientEvent("VehicleShops:CreateNew", source)
end, AdminGroup)

QBCore.Commands.Add('vehshop:edit', 'Edit a vehicle shop', {}, false, function(source, args)
  TriggerClientEvent("VehicleShops:EditMenu", source)
end, AdminGroup)

QBCore.Commands.Add('vehshop:editmode', 'Edit vehicle stock warehouse access', {}, false, function(source, args)
  TriggerClientEvent('VehicleShops:EditMode', source)
end, AdminGroup)