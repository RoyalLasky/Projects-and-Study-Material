local QBCore = exports['qb-core']:GetCoreObject()
local editMode = false

VehicleShops = {}
VehicleShops.SpawnedVehicles = {}

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
  VehicleShops.Init()
end)

CreateThread(function()
  if LocalPlayer.state['isLoggedIn'] then
    VehicleShops.Init()
  end
end)

local function GetVehicleName(hash)
  return QBCore.Shared.VehicleHashes[hash]['brand']..' '.. QBCore.Shared.VehicleHashes[hash]['name'] or GetLabelText(GetDisplayNameFromVehicleModel(hash))
end

VehicleShops.Init = function()
  local start = GetGameTimer()
  while (GetGameTimer() - start) < 2000 do Wait(0); end
  QBCore.Functions.TriggerCallback("VehicleShops:GetVehicleShops",function(shopData)
    VehicleShops.Shops  = (shopData.shops or {})
    VehicleShops.WarehouseVehicles = (shopData.vehicles or {})
    VehicleShops.RefreshBlips()
    VehicleShops.Update()
  end)
end

VehicleShops.WarehouseRefresh = function(data)
  VehicleShops.WarehouseVehicles = data
  if InsideWarehouse then
    QBCore.Functions.Notify("Warehouse stock refreshsed. You must re-enter the building.")
    VehicleShops.LeaveWarehouse()
  end
end

VehicleShops.Update = function()
  while true do
    local wait_time = 0
    local plyPos = GetEntityCoords(PlayerPedId())
    if InsideWarehouse then
      local closest,closestDist
      for k,v in pairs(ShopVehicles) do
        local dist = #(plyPos - vector3(v.pos.x, v.pos.y, v.pos.z))
        if not closestDist or dist < closestDist then
          closest = v
          closestDist = dist
        end
      end

      if closest and closestDist and closestDist < 5.0 then
        local up = vector3(0.0,0.0,1.0)
        local posA = closest.pos.xyz + up

        if Config.FloatingNotification then
          Markers.ShowFloatingHelpNotification(closest.name.." ~g~[$"..closest.price.."]~s~\n~INPUT_DETONATE~ Purchase".. (editMode and '\n~INPUT_CONTEXT~ Edit Shop Access' or ''), vector3(posA.x, posA.y, posA.z))
        else
          DrawText3D(posA.x,posA.y,posA.z, closest.name.." [$~g~"..closest.price.."~s~]\n[~g~G~s~] Purchase",15.0, (editMode and '\n~INPUT_CONTEXT~ Edit Shop Access' or ''), vector3(posA.x, posA.y, posA.z))
        end


        if IsControlJustPressed(0,47) then
          VehicleShops.PurchaseStock(closest)
        end

        if editMode and IsControlJustPressed(0, 38) then
          VehicleShops.EditShopAccess(closest)
        end
      end
    else
      local closest,closestDist = VehicleShops.GetClosestShop()
      if closestDist < 100.0 then
        local closestVeh,vehDist
        for k,v in pairs(VehicleShops.Shops[closest].displays) do
          local dist = #(plyPos - vector3(v.location.x, v.location.y, v.location.z))
          if not vehDist or dist < vehDist then
            closestVeh = k
            vehDist = dist
          end

          if not VehicleShops.SpawnedVehicles[v.vehicle.plate] then
            RequestModel(v.vehicle.model)
            while not HasModelLoaded(v.vehicle.model) do Wait(0); end

            local veh = CreateVehicle(v.vehicle.model, v.location.x,v.location.y,v.location.z,v.location.heading, false,false)

            FreezeEntityPosition(veh,true)
            SetEntityAsMissionEntity(veh,true,true)
            SetVehicleUndriveable(veh,true)
            SetVehicleDoorsLocked(veh,2)

            SetEntityProofs(veh,true,true,true,true,true,true,true,true)
            SetVehicleTyresCanBurst(veh,false)

            SetModelAsNoLongerNeeded(v.vehicle.model)

            QBCore.Functions.SetVehicleProperties(veh, v.vehicle)

            v.entity = veh

            VehicleShops.SpawnedVehicles[v.vehicle.plate] = veh
          else
            if not last_spawn_message then
              last_spawn_message = GetGameTimer()
            else
              if GetGameTimer() - last_spawn_message > 1000 then
                last_spawn_message = GetGameTimer()
              end
            end
          end
        end

        --local vehDistCheck = Config.FloatingNotification and 4.0 or 3.0
        local vehDistCheck = 3.0

        if not VehicleShops.Moving and vehDist and vehDist < vehDistCheck then
          local pos = VehicleShops.Shops[closest].displays[closestVeh].location
          local label = GetVehicleName(VehicleShops.Shops[closest].displays[closestVeh].vehicle.model)
          local price = (VehicleShops.Shops[closest].displays[closestVeh].price or false)
          local min,max = GetModelDimensions( VehicleShops.Shops[closest].displays[closestVeh].vehicle.model )

          if Config.FloatingNotification then
            Markers.ShowFloatingHelpNotification(label .. (price and " - ~g~$"..price.."~s~\n~INPUT_DETONATE~ Purchase" or ''), vector3(pos.x, pos.y, pos.z + max.z))
          else
            DrawText3D(pos.x,pos.y,pos.z + max.z, label .. (price and " [$~g~"..price.."~s~]\n[~g~G~s~] Purchase" or ''),15.0)
          end

          if price then
            if IsControlJustReleased(0,47) then
              local doCont = true
              while doCont do
                local dist = #(GetEntityCoords(PlayerPedId()) - vector3(pos.x, pos.y, pos.z))
                if dist > 10.0 then
                  doCont = false
                end 

                if Config.FloatingNotification then
                  Markers.ShowFloatingHelpNotification(label .. (price and " - ~g~$"..price.."~s~\n~INPUT_DETONATE~ Confirm Purchase" or ''), vector3(pos.x, pos.y, pos.z + max.z))
                else
                  DrawText3D(pos.x,pos.y,pos.z + max.z, label .. (price and " [$~g~"..price.."~s~]\n[~g~G~s~] Confirm" or ''),15.0)
                end

                if IsControlJustPressed(0,47) then
                  Wait(100)
                  local ent = VehicleShops.SpawnedVehicles[VehicleShops.Shops[closest].displays[closestVeh].vehicle.plate]
                  VehicleShops.PurchaseDisplay(closest,closestVeh,ent)
                  doCont = false
                end
                Wait(0)
              end
            end
          end
        end
      else
        wait_time = 1000
      end
    end
    Wait(wait_time)
  end
end

VehicleShops.GetClosestShop = function()
  local pos = GetEntityCoords(PlayerPedId())
  local closest,closestDist
  for k,v in pairs(VehicleShops.Shops) do
    local dist = #(pos - vector3(v.locations.entry.x,v.locations.entry.y,v.locations.entry.z))
    if not closestDist or dist < closestDist then
      closestDist = dist
      closest = k
    end
  end
  return (closest or false),(closestDist or 9999)
end

VehicleShops.PurchasedShop = function(shop)
  local closest,dist = VehicleShops.GetClosestShop()
  QBCore.Functions.TriggerCallback("VehicleShops:PurchaseShop",function(can_buy)
    if can_buy then
      QBCore.Functions.Notify(string.format("You purchased the shop for $%i.",VehicleShops.Shops[closest].price))
    else
      QBCore.Functions.Notify("Can't afford that.", "error")
    end
  end,closest)
end

VehicleShops.PurchaseStockVehicle = function(vehicle_data,shop_key)
  if VehicleShops.Shops[shop_key].funds >= vehicle_data.price then
    QBCore.Functions.TriggerCallback('VehicleShops:CanPurchase', function(CanPurchase)
      if CanPurchase then
        local label = GetVehicleName(GetHashKey(vehicle_data.model))
        QBCore.Functions.Notify("You purchased "..label.." for $"..vehicle_data.price, "success")
      
        local plyPed = PlayerPedId()
        local plyPos = GetEntityCoords(plyPed)
        DoScreenFadeOut(500)
        Wait(500)
        local props = QBCore.Functions.GetVehicleProperties(vehicle_data.ent)
        QBCore.Functions.TriggerCallback("VehicleShops:GenerateNewPlate",function(newPlate)
          props.plate = newPlate
      
          RequestModel(props.model)
          while not HasModelLoaded(props.model) do Wait(0); end
      
          local newVeh = CreateVehicle(props.model,plyPos.x,plyPos.y,plyPos.z + 50.,0.0,true,true)
      
          props.mileage = 0
          props.serviced_at = 0
          props.class = GetVehicleClass(newVeh)

      
          TriggerServerEvent("VehicleShops:VehiclePurchased",shop_key,vehicle_data.key,props, GetDisplayNameFromVehicleModel(vehicle_data.model), GetVehicleName(props.model))
      
          QBCore.Functions.SetVehicleProperties(newVeh, props)
      
          SetVehicleEngineOn(newVeh,true,true,true)
          TaskWarpPedIntoVehicle(plyPed,newVeh,-1)
          exports['ps-fuel']:SetFuel(newVeh, 100.0)
          local targetPos = Warehouse.purchasedSpawns[math.random(#Warehouse.purchasedSpawns)]
          SetEntityCoordsNoOffset(newVeh,targetPos.x,targetPos.y,targetPos.z)
          SetEntityHeading(newVeh,targetPos.w)
          SetVehicleOnGroundProperly(newVeh)
          SetEntityAsMissionEntity(newVeh,true,true)
          DoScreenFadeIn(500)
      
          TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(newVeh))
      
          InsideWarehouse = false
          VehicleShops.DespawnShop()
          end)
      else
        QBCore.Functions.Notify("You are not allowed to purchase this vehicle for "..shop_key.." shop!", "error", 7500)
      end
    end, shop_key, vehicle_data.key)
  else
    QBCore.Functions.Notify("Not enough funds.","error")
  end
end



AddEventHandler('vehicleshops:client:PurchaseStockVehicle', function(data)
  VehicleShops.PurchaseStockVehicle(data.vehicle, data.value)
end)

AddEventHandler('VehicleShops:AddNewShopToAccess', function(data)
  local vehicle = data.vehicle
  local shopa = data.shopac

  local menu = {
    {
      header = 'Add new shop access to vehicle: '..vehicle.name.."?",
      isMenuHeader = true
    }
  }

  for k,v in pairs(VehicleShops.Shops) do
    menu[#menu+1] = {
      header = v.name,
      txt = '✅ Click here to add new shop access',
      params = {
        isServer = true,
        event = 'VehicleShops:AddNewShopAccess',
        args = {
          model = vehicle.model,
          vehid = vehicle.key,
          shop = v.name
        }
      }
    }
  end

  exports['qb-menu']:openMenu(menu)
end)

VehicleShops.EditShopAccess = function(vehicle)
  local elements = {
    {
      header = 'Edit Shop Access to '..GetVehicleName(GetHashKey(vehicle.model)),
      isMenuHeader = true
    }
  }

  local p = promise:new()

  QBCore.Functions.TriggerCallback('VehicleShops:GetVehicleShopAccess', function(sa)
    p:resolve(sa)
  end, vehicle.key)

  local shopsAccess = Citizen.Await(p)

  for i=1, #shopsAccess do
    elements[#elements+1] = {
      header = shopsAccess[i],
      txt = '❌ Click to remove this shop access',
      params = {
        isServer = true,
        event = 'VehicleShops:RemoveShopAccess',
        args = {
          vehid = vehicle.key,
          model = vehicle.model,
          shop = shopsAccess[i]
        }
      }
    }
  end

  elements[#elements+1] = {
    header = '📝 Add New Shop',
    params = {
      event = 'VehicleShops:AddNewShopToAccess',
      args = {
        vehicle = vehicle,
        shopac = shopsAccess
      }
    }
  }

  exports['qb-menu']:openMenu(elements)
end

VehicleShops.PurchaseStock = function(vehicle)
  local elements = {
    {
      header = 'Purchase Stock',
      isMenuHeader = true
    }
  }
  local PlayerData = QBCore.Functions.GetPlayerData()
  for key,val in pairs(VehicleShops.Shops) do
    if PlayerData.citizenid == val.owner then
      elements[#elements+1] = {
        header = ('[$%s] %s'):format(val.funds, val.name),
        params = {
          event = 'vehicleshops:client:PurchaseStockVehicle',
          args = {
            vehicle = vehicle,
            value = key
          }
        }
      }
    else
      for k,v in pairs(val.employees) do
        if v.identifier == PlayerData.citizenid then
          elements[#elements+1] = {
            header = ('[$%s] %s'):format(val.funds, val.name),
            params = {
              event = 'vehicleshops:client:PurchaseStockVehicle',
              args = {
                vehicle = vehicle,
                value = key
              }
            }
          }
        end
      end
    end
  end

  if #elements < 1 then
    elements[#elements+1] = {
      header = 'No shops to display.',
      disabled = true
    }
  end

  elements[#elements+1] = {
    header = '<- Close',
    params = {
      event = 'qb-menu:client:closeMenu'
    }
  }

  exports['qb-menu']:openMenu(elements)
end

VehicleShops.EnterWarehouse = function(...)
  local plyPed = PlayerPedId()
  QBCore.Functions.Notify("Spawning shop, please wait for models to load.")
  Wait(1000)

  DoScreenFadeOut(500)
  Wait(1500)

  SetEntityCoordsNoOffset(plyPed, Warehouse.exit.x,Warehouse.exit.y,Warehouse.exit.z+0.7)
  SetEntityHeading(plyPed, Warehouse.exit.w)
  --FreezeEntityPosition(plyPed, true)
  Wait(1500)
  
  VehicleShops.SpawnShop()
  --FreezeEntityPosition(plyPed, false)
  DoScreenFadeIn(500)

  InsideWarehouse = true

  local marker = {
    display  = Config.Markers.WarehouseExit,
    location = Warehouse.exit,
    maintext = "Exit Warehouse",
    scale    = vector3(0.5, 0.5, 0.5),
    color    = Config.FloatingNotification and "gold" or "green",
    type     = 1,
    distance = 1.0,
    control  = 38,
    callback = VehicleShops.LeaveWarehouse,
    args     = {"buy",k}
  }
  TriggerEvent("Markers:Add",marker,function(m)
    WarehouseMarker = m
  end)
end

RegisterNetEvent('vehicleshops:client:ManageDisplays', function(data)
  VehicleShops.ManageDisplays(data.shop_key)
end)

VehicleShops.ManageDisplays = function(shop_key)
  local shop = VehicleShops.Shops[shop_key]

  local elements = {
    {
      header = 'Display Vehicles',
      isMenuHeader = true
    }
  }
  for _,vehicle_data in pairs(shop.stock) do
    if vehicle_data and vehicle_data.vehicle and vehicle_data.vehicle.plate then
      elements[#elements+1] = {
        header = GetVehicleName(vehicle_data.vehicle.model),
        txt = vehicle_data.vehicle.plate,
        params = {
          event = 'vehicleshops:client:DoDisplayVehicle',
          args = {
            shop_key = shop_key,
            key = _,
            value = vehicle_data
          }
        }
      }
    end
  end

  if #elements == 1 then
    elements[#elements+1] = {
      header = 'No vehicles to display.',
      disabled = true
    }
  end

  elements[#elements+1] = {
    header = '<- Go Back',
    txt = 'Vehicle Management',
    params = {
      event = 'vehicleshops:client:ManageVehicles',
      args = {
        shop_key = shop_key
      }
    }
  }

  exports['qb-menu']:openMenu(elements)
end

RegisterNetEvent('vehicleshops:client:ManageDisplayed', function(data)
  VehicleShops.ManageDisplayed(data.shop_key)
end)

RegisterNetEvent('vehicleshops:client:ManageDisplayed2', function(data)
  TriggerEvent('vehicleshops:client:ManageVehicles', data)
  TriggerServerEvent("VehicleShops:RemoveDisplay", data.name, data.key, GetVehicleName(data.value.vehicle.model))
end)

VehicleShops.ManageDisplayed = function(shop_key)
  local shop_key = shop_key
  local shop = VehicleShops.Shops[shop_key]

  local elements = {
    {
      header = 'Store Vehicles',
      isMenuHeader = true
    }
  }
  if TableCount(shop.displays) > 0 then
    for _,vehicle_data in pairs(shop.displays) do
      if vehicle_data and vehicle_data.vehicle and vehicle_data.vehicle.plate then
        elements[#elements+1] = {
          header = GetVehicleName(vehicle_data.vehicle.model),
          txt = vehicle_data.vehicle.plate,
          params = {
            event = 'vehicleshops:client:ManageDisplayed2',
            args = {
              name = shop.name,
              value = vehicle_data,
              key = _,
              shop_key = shop_key
            }
          }
        }
      end
    end
  end

  elements[#elements+1] = {
    header = '<- Go Back',
    txt = 'Vehicle Management',
    params = {
      event = 'vehicleshops:client:ManageVehicles',
      args = {
        shop_key = shop_key
      }
    }    
  }

  exports['qb-menu']:openMenu(elements)
end

AddEventHandler('vehicleshops:client:DoSetPrice', function(data)
  VehicleShops.DoSetPrice(data.shop, data.key)
end)

VehicleShops.DoSetPrice = function(shop,vehicle)
  local dialog = exports['qb-input']:ShowInput({
    header = "Set price of " .. GetVehicleName(VehicleShops.Shops[shop].displays[vehicle].vehicle.model) .." (".. VehicleShops.Shops[shop].displays[vehicle].vehicle.plate..") ?",
    submitText = "Submit",
    inputs = {
        {
            text = "", -- text you want to be displayed as a place holder
            name = "amount", -- name of the input should be unique otherwise it might override
            type = "number", -- type of the input
            isRequired = true,
        },
    }
  })

  if dialog ~= nil then
    local amount = dialog.amount
    local price = (amount and tonumber(amount) and tonumber(amount) > 0 and tonumber(amount) or false)

    if price then
      local vehData = VehicleShops.Shops[shop].displays[vehicle]
      QBCore.Functions.Notify("You set the price for the "..GetVehicleName(vehData.vehicle.model).." at $"..price) 
      TriggerServerEvent("VehicleShops:SetPrice",vehicle,shop,price)
      VehicleShops.ManagementMenu(shop)
    else
      QBCore.Functions.Notify("Set a valid price.", "error")
      Wait(200)
      VehicleShops.DoSetPrice(shop,vehicle)
    end
  end
end

AddEventHandler('vehicleshops:client:AddFunds', function(data)
  local shop_key = data.shop_key

  local dialog = exports['qb-input']:ShowInput({
    header = shop_key.." - Add Funds",
    submitText = "Submit",
    inputs = {
        {
            text = "", -- text you want to be displayed as a place holder
            name = "amount", -- name of the input should be unique otherwise it might override
            type = "number", -- type of the input
            isRequired = true,
        },
    }
  })

  if dialog ~= nil then
      local amount = dialog.amount
      local funds = tonumber(amount) and tonumber(amount) > 0 and tonumber(amount) or false

      if funds then
        TriggerServerEvent("VehicleShops:AddFunds", shop_key, funds)
        VehicleShops.ManagementMenu(shop_key)
      end
  end
end)

AddEventHandler('vehicleshops:client:TakeFunds', function(data)
  local shop_key = data.shop_key

  local dialog = exports['qb-input']:ShowInput({
    header = shop_key.." - Withdraw Funds",
    submitText = "Submit",
    inputs = {
        {
            text = "", -- text you want to be displayed as a place holder
            name = "amount", -- name of the input should be unique otherwise it might override
            type = "number", -- type of the input
            isRequired = true,
        },
    }
  })

  if dialog ~= nil then
    local amount = dialog.amount
    local funds = amount and tonumber(amount) and tonumber(amount) and tonumber(amount) or false

    if funds then
      TriggerServerEvent("VehicleShops:TakeFunds", shop_key, funds)
      VehicleShops.ManagementMenu(shop_key)
    end
  end 
end)

RegisterNetEvent('vehicleshops:client:ManageShop', function(data)
  VehicleShops.ManageShop(data.shop_key)
end)

VehicleShops.ManageShop = function(shop_key)
  local shop_key = shop_key

  local elements = {
    {
      header = 'Shop Management',
      isMenuHeader = true
    },
    {
      header = 'Funds: $'..VehicleShops.Shops[shop_key].funds,
      disabled = true
    },
    {
      header = 'Add Funds',
      txt = 'Deposit Money into Shop Account',
      params = {
        event = 'vehicleshops:client:AddFunds',
        args = {
          shop_key = shop_key
        },
      },
    },
    {
      header = 'Withdraw Funds',
      txt = 'Take money from Shop Account',
      params = {
        event = 'vehicleshops:client:TakeFunds',
        args = {
          shop_key = shop_key
        },
      },
    },
    {
      header = '<- Go Back',
      txt = 'Main Menu',
      params = {
        event = 'vehicleshops:client:ManagementMenu',
        args = {
          shop_key = shop_key
        }
      }
    }
  }

  exports['qb-menu']:openMenu(elements)
end

AddEventHandler('vehicleshops:client:ManagePrices', function(data)
  VehicleShops.ManagePrices(data.shop_key)
end)

VehicleShops.ManagePrices = function(shop_key)
  local shop_key = shop_key
  local shop = VehicleShops.Shops[shop_key]

  local elements = {
    {
      header = 'Set Vehicle Price',
      isMenuHeader = true
    }
  }

  if TableCount(shop.displays) > 0 then
    for _,vehicle_data in pairs(shop.displays) do
      if vehicle_data and vehicle_data.vehicle and vehicle_data.vehicle.plate then
        elements[#elements+1] = {
          header = GetVehicleName(vehicle_data.vehicle.model),
          txt = vehicle_data.vehicle.plate,
          params = {
            event = 'vehicleshops:client:DoSetPrice',
            args = {
              shop = shop_key,
              value = vehicle_data,
              key = _
            }
          }
        }
      end
    end
  end

  elements[#elements+1] = {
    header = '<- Go Back',
    txt = 'Vehicle Management',
    params = {
      event = 'vehicleshops:client:ManageVehicles',
      args = {
        shop_key = shop_key
      }
    }
  }

  exports['qb-menu']:openMenu(elements)
end

RegisterNetEvent('vehicleshops:client:DriveVehicle', function(data)
  VehicleShops.DriveVehicle(data.shop_key)
end)

RegisterNetEvent('vehicleshops:client:DriveVehicle2', function(data)
  local shop_key = data.shop_key
  local vehicle = data.value
  local props = vehicle.vehicle
  QBCore.Functions.TriggerCallback("VehicleShops:DriveVehicle",function(can_drive)
    if can_drive then
      
      local pos = VehicleShops.Shops[shop_key].locations.purchased

      RequestModel(props.model)
      while not HasModelLoaded(props.model) do Wait(0); end

      local veh = CreateVehicle(props.model,pos.x,pos.y,pos.z,pos.heading,true,true)
      SetEntityAsMissionEntity(veh,true,true)
      QBCore.Functions.SetVehicleProperties(veh,props)
      TaskWarpPedIntoVehicle(PlayerPedId(),veh,-1)
      SetVehicleEngineOn(veh,true)
      TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
    else
      QBCore.Functions.Notify(msg)
    end
  end, shop_key, data.key, GetDisplayNameFromVehicleModel(data.value.vehicle.model), GetVehicleName(props.model))
end)

VehicleShops.DriveVehicle = function(shop_key)
  local shop_key = shop_key
  local shop = VehicleShops.Shops[shop_key]

  local elements = {
    {
      header = 'Drive Stock Vehicle',
      isMenuHeader = true
    }
  }
  if #shop.stock > 0 then
    for _,vehicle_data in pairs(shop.stock) do      
      if vehicle_data and vehicle_data.vehicle and vehicle_data.vehicle.plate then
        elements[#elements+1] = {
          header = GetVehicleName(vehicle_data.vehicle.model),
          txt = vehicle_data.vehicle.plate,
          params = {
            event = 'vehicleshops:client:DriveVehicle2',
            args = {
              key = _,
              value = vehicle_data,
              shop_key = shop_key
            }
          }
        }
      end
    end
  end

  elements[#elements+1] = {
    header = '<- Go Back',
    txt = 'Vehicle Management',
    params = {
      event = 'vehicleshops:client:ManageVehicles',
      args = {
        shop_key = shop_key
      }
    }
  }

  exports['qb-menu']:openMenu(elements)
end

AddEventHandler('vehicleshops:client:ManageVehicles', function(data)
  local shop_key = data.shop_key

  local elements = {
    {
      header = 'Vehicle Management',
      isMenuHeader = true
    },
    {
      header = "Display Vehicles", 
      params = {
        event = "vehicleshops:client:ManageDisplays",
        args = {
          shop_key = shop_key
        },
      },
    },
    {
      header = "Store Vehicles",
      params = {
        event = "vehicleshops:client:ManageDisplayed",
        args = {
          shop_key = shop_key
        },
      },
    },
end)




VehicleShops.FireMenu = function(shop_key)
  local xPlayer = QBCore.Functions.GetPlayerData()
  local shop_key = shop_key
  local elements = {
    {
      header = 'Fire Employee',
      isMenuHeader = true
    }
  }
  for k,v in pairs(VehicleShops.Shops[shop_key].employees) do
    if v.identifier ~= xPlayer.citizenid then
      elements[#elements+1] = {
        header = v.identity.firstname .. " " .. v.identity.lastname,
        txt = v.identifier,
        params = {
          event = 'vehicleshops:client:FirePlayer',
          args = {
            shop_key = shop_key,
            citizenid = v.identifier
          }
        }
      }
    end
  end



  exports['qb-menu']:openMenu(elements)
end

AddEventHandler('vehicleshops:client:PayPlayer', function(data)
  local shop_key = data.shop_key
  local citizenid = data.citizenid

  local dialog = exports['qb-input']:ShowInput({
    header = shop_key.." - Pay Amount",
    submitText = "Submit",
    inputs = {
        {
            text = "", -- text you want to be displayed as a place holder
            name = "amount", -- name of the input should be unique otherwise it might override
            type = "number", -- type of the input
            isRequired = true,
        },
    }
  })

  if dialog ~= nil then
    local amount = dialog.amount
    local funds = amount and tonumber(amount) and tonumber(amount) > 0 and tonumber(amount) or false

    if funds then
      if VehicleShops.Shops[shop_key].funds < funds then
        QBCore.Functions.Notify("Shop doesn't have this much funds.", "error")
      else
        TriggerServerEvent("VehicleShops:PayPlayer",shop_key, playerid, funds)
      end

      VehicleShops.ManageEmployees(shop_key)
    else
      QBCore.Functions.Notify("Invalid amount entered.", "error")
    end
  end
end)

VehicleShops.PayMenu = function(shop_key)
  local xPlayer = QBCore.Functions.GetPlayerData()
  local shop_key = shop_key
  local elements = {
    {
      header = 'Pay Employee',
      isMenuHeader = true
    }
  }
  end

  elements[#elements+1] = {
    header = '<- Go Back',
    txt = 'Employee Management',
    params = {
      event = 'vehicleshops:client:ManageEmployees',
      args = {
        shop_key = shop_key
      }
    }
  }

  exports['qb-menu']:openMenu(elements)
end


VehicleShops.ManageEmployees = function(shop_key)
  local shop_key = shop_key
  local elements = {
    {
      header = 'Employee Management',
      isMenuHeader = true
    },
    {
      header = 'Hire Employee',
      params = {
        event = 'vehicleshops:client:HireMenu',
        args = {
          shop_key = shop_key
        },
      },
    },
    {
      header = 'Fire Employee',
      params = {
        event = 'vehicleshops:client:FireMenu',
        args = {
          shop_key = shop_key
        },
      },
    },
    {
      header = 'Pay Employee',
      params = {
        event = 'vehicleshops:client:PayMenu',
        args = {
          shop_key = shop_key
        },
      },
    }
  }

end

AddEventHandler('vehicleshops:client:HireMenu', function(data)
  VehicleShops.HireMenu(data.shop_key)
end)

AddEventHandler('vehicleshops:client:FireMenu', function(data)
  VehicleShops.FireMenu(data.shop_key)
end)

AddEventHandler('vehicleshops:client:PayMenu', function(data)
  VehicleShops.PayMenu(data.shop_key)
end)

RegisterNetEvent('vehicleshops:client:ManagementMenu', function(data)
  VehicleShops.ManagementMenu(data.shop_key)
end)

VehicleShops.ManagementMenu = function(shop_key)
  local PlayerData = QBCore.Functions.GetPlayerData()
  local shop_key = shop_key
  local elements = {}

  if VehicleShops.Shops[shop_key].owner == PlayerData.citizenid then
    elements = {
      {
        header = VehicleShops.Shops[shop_key].name,
        txt = 'Main Menu',
        isMenuHeader = true
      },
      {
        header = 'Vehicle Management',
        params = {
          event = "vehicleshops:client:ManageVehicles",
          args = {
            shop_key = shop_key,
          },
        },
      },
      {
        header = 'Shop Management',
        params = {
          event = 'vehicleshops:client:ManageShop', 
          args = {
            shop_key = shop_key
          }
        }
      },
      {
        header = 'Employee Management',
        params = {
          event = 'vehicleshops:client:ManageEmployees', 
          args = {
            shop_key = shop_key
          }
        }
      },
    }
  else
    elements = {
      {
        header = VehicleShops.Shops[shop_key].name,
        txt = 'Main Menu',
        isMenuHeader = true
      },
      {
        header = 'Vehicle Management',
        params = {
          event = "vehicleshops:client:ManageVehicles",
          args = {
            shop_key = shop_key,
          },
        },
      },
    }
  end

  elements[#elements+1] = {
    header = '<- Close',
    params = {
      event = 'qb-menu:closeMenu'
    }
  }

  exports['qb-menu']:openMenu(elements)
end

VehicleShops.DepositVehicle = function(shop_key)
  local ply_ped = PlayerPedId()
  if IsPedInAnyVehicle(ply_ped,false) then
    local ply_veh = GetVehiclePedIsUsing(ply_ped,false)
    local driver = GetPedInVehicleSeat(ply_veh,-1)
    if driver == ply_ped then
      VehicleShops.CanStockVehicle(shop_key,ply_veh,function(can_store,do_delete)
        if can_store then
          local props = QBCore.Functions.GetVehicleProperties(ply_veh)
          TriggerServerEvent("VehicleShops:StockedVehicle",props,shop_key,do_delete, GetDisplayNameFromVehicleModel(props.model), GetVehicleName(props.model))
          TaskLeaveVehicle(ply_ped,ply_veh,0)
          TaskEveryoneLeaveVehicle(ply_veh)
          Wait(1000)
          SetEntityAsMissionEntity(ply_veh,false,false)
          Wait(200)
          DeleteVehicle(ply_veh)
          print("Vehicle Deleted.")
        end
      end)
    end
  end
end

VehicleShops.CanStockVehicle = function(shop_key,vehicle,callback)
  local plyPed = PlayerPedId()
  local isEmployed = false
  local PlayerData = QBCore.Functions.GetPlayerData()
  if VehicleShops.Shops[shop_key].owner == PlayerData.citizenid then 
    isEmployed = true
  else
    for k,v in pairs(VehicleShops.Shops[shop_key].employees) do
      if v.identifier == PlayerData.citizenid then
        isEmployed = true
        break
      end
    end
  end
  if not isEmployed then return false; end
  local props = QBCore.Functions.GetVehicleProperties(vehicle)
  QBCore.Functions.TriggerCallback("VehicleShops:GetVehicleOwner",function(owner)
    if owner and (VehicleShops.Shops[shop_key].owner:match(owner) or (PlayerData.citizenid):match(owner)) then
      callback(true,true)
    else
      if not owner then
        if Config.StockStolenPedVehicles then
          callback(true,false)
        else
          QBCore.Functions.Notify("You can't stock stolen vehicles.", "error", 5000)
          callback(false)
        end
        return
      else
        if Config.StockStolenPlayerVehicles then
          callback(true,true)
        else
          QBCore.Functions.Notify("You can't stock other players vehicles.", "error", 5000)
          callback(false)
        end
        return
      end
      callback(false)
    end
  end, props.plate)
end

VehicleShops.Interact = function(a,b)
  if (a == "buy") then
    VehicleShops.PurchasedShop()
  elseif (a == "deposit") then
    VehicleShops.DepositVehicle(b)
  elseif (a == "management") then
    VehicleShops.ManagementMenu(b)
  end
end

VehicleShops.LeaveWarehouse = function()
  local plyPed = PlayerPedId()
  SetEntityCoordsNoOffset(plyPed, Warehouse.entry.x,Warehouse.entry.y,Warehouse.entry.z)
  SetEntityHeading(plyPed, Warehouse.entry.w)
  VehicleShops.DespawnShop()
  InsideWarehouse = false

  TriggerEvent("Markers:Remove",WarehouseMarker)
end

VehicleShops.RefreshBlips = function()  
  local dictStreamed = false
  local startTime = GetGameTimer()

  local PlayerData = QBCore.Functions.GetPlayerData()
  local is_dealer = false
  for k,v in pairs(VehicleShops.Shops) do
    if v.warehouse then
      if v.owner == PlayerData.citizenid then
        is_dealer = true
      end

      if not is_dealer then
        for k,v in pairs(v.employees) do
          if v.identifier == PlayerData.citizenid then
            is_dealer = true
          end
        end
      end
    end
  end

  if DealerMarker and not is_dealer then
    RemoveBlip(DealerBlip)
    TriggerEvent("Markers:Remove",DealerMarker)
  elseif not DealerMarker and is_dealer then
    local pos = (Warehouse.entry)
    local blip = AddBlipForCoord(pos.x,pos.y,pos.z)
    SetBlipSprite(blip, 225)
    SetBlipColour(blip, 3)  
    SetBlipAsShortRange(blip,true)
    BeginTextCommandSetBlipName ("STRING")
    AddTextComponentString      ("Vehicle Warehouse")
    EndTextCommandSetBlipName   (blip)

    DealerBlip = blip

    local marker = {
      display  = Config.Markers.WarehouseEntry,
      location = pos,
      maintext = "Enter Warehouse",
      scale    = vector3(0.5, 0.5, 0.5),
      color    = Config.FloatingNotification and "gold" or "green",
      type     = 1,
      distance = 1.0,
      control  = 38,
      callback = VehicleShops.EnterWarehouse,
      args     = {"buy",k}
    }
    TriggerEvent("Markers:Add",marker,function(m)
      DealerMarker = m
    end)
  end

  for k,v in pairs(VehicleShops.Shops) do
    if not v.blip then
      SetAllVehicleGeneratorsActiveInArea(v.locations.entry.x - 50.0, v.locations.entry.y - 50.0, v.locations.entry.z - 50.0, v.locations.entry.x + 50.0, v.locations.entry.y + 50.0, v.locations.entry.z  + 50.0, false, false);
      local pos = (v.locations.entry)
      local blip = AddBlipForCoord(v.locations.blip.x, v.locations.blip.y, v.locations.blip.z)
      local bsprite = v.blipdetails ~= nil and v.blipdetails.sprite or 225
      local bcolor = v.blipdetails ~= nil and v.blipdetails.color or (v.owner == "none" and 0 or 5)
      local bscale = v.blipdetails ~= nil and v.blipdetails.scale or 1.0
      SetBlipSprite(blip, bsprite)
      SetBlipColour(blip, bcolor)  
      SetBlipScale(blip, bscale)
      BeginTextCommandSetBlipName ("STRING")
      AddTextComponentString      (v.name)
      SetBlipAsShortRange(blip,true)
      EndTextCommandSetBlipName   (blip)
      
      VehicleShops.Shops[k].blip = blip

      VehicleShops.Shops[k].markers = {}

      if not v.owner then
        local marker = {
          display  = Config.Markers.ShopPurchase,
          location = pos,
          maintext = "Purchase ~y~"..v.name.."~s~",
          subtext  = "~g~$"..v.price,
          scale    = vector3(0.5, 0.5, 0.5),
          color    = Config.FloatingNotification and "gold" or "green",
          type     = 1,
          distance = 1.0,
          control  = 38,
          callback = VehicleShops.Interact,
          args     = {"buy",k}
        }
        TriggerEvent("Markers:Add",marker,function(m)
          VehicleShops.Shops[k].markers["buy"] = m
        end)
      else
        local render_menus = false
        for k,v in pairs(VehicleShops.Shops[k].employees) do
          if v.identifier == PlayerData.citizenid then
            render_menus = true
          end
        end

        if not render_menus and PlayerData.citizenid == v.owner then
          render_menus = true
        end

        if render_menus then
          local marker = {
            display  = Config.Markers.Management,
            location = (v.locations.management),
            maintext = "Management",
            scale    = vector3(0.5, 0.5, 0.5),
            type     = 1,
            color    = Config.FloatingNotification and "gold" or "green",
            distance = 1.0,
            control  = 38,
            callback = VehicleShops.Interact,
            args     = {"management",k}
          }
          TriggerEvent("Markers:Add",marker,function(m)
            VehicleShops.Shops[k].markers["management"] = m
          end)
          local marker = {
            display  = Config.Markers.VehicleDeposit,
            location = (v.locations.deposit),
            maintext = "Deposit Vehicle",
            scale    = vector3(0.6,0.6,0.5),
            type     = 1,
            color    = "red",
            distance = 5.0,
            control  = 38,
            callback = VehicleShops.Interact,
            args     = {"deposit",k}
          }
          TriggerEvent("Markers:Add",marker,function(m)
            VehicleShops.Shops[k].markers["deposit"] = m
          end)
        end
      end
    end
  end
end

VehicleShops.Sync = function(data)
  if VehicleShops.Shops then
    for k,v in pairs(VehicleShops.Shops) do
      RemoveBlip(v.blip)
      if v.markers then
        for k,v in pairs(v.markers) do
          TriggerEvent("Markers:Remove",v)
        end
        v.markers = false
      end
      v.blip = false
    end

    VehicleShops.Shops = data
    VehicleShops.RefreshBlips()
  end
end

VehicleShops.SpawnShop = function()
  ShopVehicles = {}
  ShopLookup = {}
  local startTime = GetGameTimer()
  while not IsInteriorReady(GetInteriorAtCoords(GetEntityCoords(PlayerPedId()))) and GetGameTimer() - startTime < 5000 do Wait(0); end
  for k,v in pairs(VehicleShops.WarehouseVehicles) do
    local hash = GetHashKey(v.model)
    local started = GetGameTimer()
    RequestModel(hash)
    while not HasModelLoaded(hash) and (GetGameTimer() - started) < 10000 do Wait(0); end
    if HasModelLoaded(hash) then
      local veh = CreateVehicle(hash, v.pos.x,v.pos.y,v.pos.z, v.pos.w, false,false)

      ShopVehicles[k] = {ent = veh,pos = v.pos,price = v.price,name = v.name,model = v.model,key = k}
      ShopLookup[veh] = k

      FreezeEntityPosition(veh,true)
      SetEntityAsMissionEntity(veh,true,true)
      SetVehicleUndriveable(veh,true)
      SetVehicleDoorsLocked(veh,2)
    end
    SetModelAsNoLongerNeeded(hash)
  end  
end

VehicleShops.DespawnShop = function()
  if ShopVehicles then
    for k,v in pairs(ShopVehicles) do
      SetEntityAsMissionEntity(v.ent,true,true)
      DeleteEntity(v.ent)
    end
    ShopVehicles = {}
  end
end

VehicleShops.RemoveDisplay = function(shop,veh,data)
  if VehicleShops.SpawnedVehicles[veh] then
    DeleteVehicle(VehicleShops.SpawnedVehicles[veh])  
    VehicleShops.SpawnedVehicles[veh] = false
  end
  VehicleShops.Sync(data)
end  

VehicleShops.PurchaseDisplay = function(shop_key,veh_key,veh_ent)
  local price = VehicleShops.Shops[shop_key].displays[veh_key].price
  if not price then return; end
  local props = QBCore.Functions.GetVehicleProperties(veh_ent)
  QBCore.Functions.TriggerCallback("VehicleShops:TryBuy",function(canBuy,msg)
    if canBuy then
      RequestModel(props.model)
      while not HasModelLoaded(props.model) do Wait(0); end
      local pos = VehicleShops.Shops[shop_key].locations.purchased
      local veh = CreateVehicle(props.model,pos.x,pos.y,pos.z,pos.heading,true,true)
      SetEntityAsMissionEntity(veh,true,true)
      QBCore.Functions.SetVehicleProperties(veh,props)
      TaskWarpPedIntoVehicle(PlayerPedId(),veh,-1)
      SetVehicleEngineOn(veh,true)
      TriggerEvent('vehiclekeys:client:SetOwner', QBCore.Functions.GetPlate(veh))
      
      QBCore.Functions.Notify(msg)

    else
      QBCore.Functions.Notify(msg)
    end
  end,shop_key,veh_key,props.plate,GetVehicleClass(veh_ent),GetDisplayNameFromVehicleModel(props.model), GetVehicleName(props.model))
end

RegisterNetEvent('vehicleshops:client:DoDisplayVehicle', function(data)
  VehicleShops.DoDisplayVehicle(data.shop_key, data.key, data.value)
end)

VehicleShops.DoDisplayVehicle = function(shopKey,vehKey,vehData)
  local shop = VehicleShops.Shops[shopKey]
  local props = vehData.vehicle
  local pos = shop.locations.spawn

  Wait(500)

  RequestModel(props.model)
  while not HasModelLoaded(props.model) do Wait(0); end

  local displayVehicle = CreateVehicle(props.model, pos.x,pos.y,pos.z, pos.heading, false,false)
  SetEntityCollision(displayVehicle,true,true)
  while not DoesEntityExist(displayVehicle) do Wait(0); end 

  QBCore.Functions.SetVehicleProperties(displayVehicle, props)
  Wait(500)

  local scaleform = GetMoveScaleform()
  local controls = Controls["Moving_Vehicle"]

  targetPos = vector4(pos.x,pos.y,pos.z,pos.heading)

  SetEntityCoordsNoOffset(displayVehicle,pos.x,pos.y,pos.z)
  SetEntityCollision(displayVehicle,true,true)
  SetVehicleUndriveable(displayVehicle,true)
  FreezeEntityPosition(displayVehicle,true)

  VehicleShops.Moving = true

  while true do
    local didMove,didRot = false,false

    DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)

    if IsControlJustPressed(0,controls.cancel) then
      VehicleShops.Moving = false
      SetEntityAsMissionEntity(displayVehicle,true,true)
      DeleteVehicle(displayVehicle)

      VehicleShops.ManagementMenu(shop.name)
      return
    end

    if IsControlPressed(0,controls.place) then
      VehicleShops.Moving = false
      SetEntityAsMissionEntity(displayVehicle,true,true)
      DeleteVehicle(displayVehicle)
      TriggerServerEvent("VehicleShops:SetDisplayed",shopKey,vehKey,Vec2Tab(targetPos))

      VehicleShops.ManagementMenu(shop.name)
      return
    end

    local right,forward,up,pos = GetEntityMatrix(displayVehicle)

    if IsControlJustPressed(0,controls.ground) then
      SetVehicleOnGroundProperly(displayVehicle)
      local x,y,z = table.unpack(GetEntityCoords(displayVehicle))
      local heading = GetEntityHeading(displayVehicle)
      targetPos = vector4(x,y,z,heading)
    end

    local modA = 50
    local modB = 25
    local modC = 0.5

    if IsControlJustPressed(0,controls.zUp) or IsControlPressed(0,controls.zUp) then
      local target = targetPos.xyz + (up/modA)
      targetPos = vector4(target.x,target.y,target.z,targetPos.w)
      didMove = true
    end

    if IsControlJustPressed(0,controls.zDown) or IsControlPressed(0,controls.zDown) then
      local target = targetPos.xyz - (up/modA)
      targetPos = vector4(target.x,target.y,target.z,targetPos.w)
      didMove = true
    end

    if IsControlJustPressed(0,controls.xUp) or IsControlPressed(0,controls.xUp) then
      local target = targetPos.xyz + (forward/modB)
      targetPos = vector4(target.x,target.y,target.z,targetPos.w)
      didMove = true
    end

    if IsControlJustPressed(0,controls.xDown) or IsControlPressed(0,controls.xDown) then
      local target = targetPos.xyz - (forward/modB)
      targetPos = vector4(target.x,target.y,target.z,targetPos.w)
      didMove = true
    end

    if IsControlJustPressed(0,controls.yUp) or IsControlPressed(0,controls.yUp) then
      local target = targetPos.xyz + (right/modB)
      targetPos = vector4(target.x,target.y,target.z,targetPos.w)
      didMove = true
    end

    if IsControlJustPressed(0,controls.yDown) or IsControlPressed(0,controls.yDown) then
      local target = targetPos.xyz - (right/modB)
      targetPos = vector4(target.x,target.y,target.z,targetPos.w)
      didMove = true
    end

    if IsControlJustPressed(0,controls.rotRight) or IsControlPressed(0,controls.rotRight) then
      targetPos = vector4(targetPos.x,targetPos.y,targetPos.z,targetPos.w-modC)
      didRot = true
    end

    if IsControlJustPressed(0,controls.rotLeft) or IsControlPressed(0,controls.rotLeft) then
      targetPos = vector4(targetPos.x,targetPos.y,targetPos.z,targetPos.w+modC)
      didRot = true
    end

    if didMove then 
      FreezeEntityPosition(displayVehicle,false)
      SetEntityRotation(displayVehicle,0.0,0.0,targetPos.w,2)
      SetEntityCoordsNoOffset(displayVehicle,targetPos.xyz); 
      FreezeEntityPosition(displayVehicle,true)
    end
    if didRot then 
      FreezeEntityPosition(displayVehicle,false)
      SetEntityHeading(displayVehicle,targetPos.w); 
      FreezeEntityPosition(displayVehicle,true)
    end
    Wait(0)
  end
end

VehicleShops.CreateNew = function(...)
  local warnEntry,warnManage,warnSpawn,warnDeposit
  local locations = {}
    
  local closest,dist = VehicleShops.GetClosestShop()

  if closest and dist and dist < 20.0 then
    QBCore.Functions.Notify("You're too close to another vehicle shop.", "error")
    return
  end

  local name = false
  local price = false

  Wait(200)

  local dialog = exports['qb-input']:ShowInput({
    header = "Set Shop Name",
    submitText = "Submit",
    inputs = {
        {
            text = "Shop Name", -- text you want to be displayed as a place holder
            name = "name", -- name of the input should be unique otherwise it might override
            type = "text", -- type of the input
            isRequired = true,
        },
    }
  })

  if dialog then
    local n = dialog.name
    name = (n and tostring(n) and tostring(n):len() and tostring(n):len() > 0 and tostring(n) or false)
    if not name then QBCore.Functions.Notify("Enter a valid name next time.", "error", 7500) return end
  end

  Wait(200)

  local dialog2 = exports['qb-input']:ShowInput({
    header = "Set Shop Price",
    submitText = "Submit",
    inputs = {
        {
            text = "", -- text you want to be displayed as a place holder
            name = "price", -- name of the input should be unique otherwise it might override
            type = "number", -- type of the input
            isRequired = true,
        },
    }
  })

  if dialog2 then
    local p = dialog2.price
    local price = (p and tonumber(p) and tonumber(p) > 0 and tonumber(p) or false)
    if not price then QBCore.Functions.Notify("Enter a valid price next time.", "error", 7500) return end

    CreateThread(function()
      while true do
        if not locations.blip then
          if not warnBlip then
            QBCore.Functions.Notify("Press G to set the blip location.", "primary", 7500)
            warnBlip = true
          end
          if IsControlJustReleased(0,47) then
            locations.blip = Vec2Tab(GetEntityCoords(PlayerPedId()))
            Wait(0)
          end
        elseif not locations.entry then
          if not warnEntry then
            QBCore.Functions.Notify("Press G to set the entry/purchase shop location.", "primary", 7500)
            warnEntry = true
          end
          if IsControlJustReleased(0,47) then
            locations.entry = Vec2Tab(GetEntityCoords(PlayerPedId()))
            Wait(0)
          end
        elseif not locations.management then
          if not warnManage then
            QBCore.Functions.Notify("Press G to set the management menu location.", "primary", 7500)
            warnManage = true
          end
          if IsControlJustReleased(0,47) then
            locations.management = Vec2Tab(GetEntityCoords(PlayerPedId()))
            Wait(0)
          end
        elseif not locations.spawn then
          if not warnSpawn then
            QBCore.Functions.Notify("Press G to set the vehicle spawn location (inside).", "primary", 7500)
            warnSpawn = true
          end
          if IsControlJustReleased(0,47) then
            local plyPed = PlayerPedId()
            local pos = GetEntityCoords(plyPed)
            local heading = GetEntityHeading(plyPed)
            locations.spawn = Vec2Tab(vector4(pos.x,pos.y,pos.z,heading))
            Wait(0)
          end
        elseif not locations.purchased then
          if not warnPurchased then
            QBCore.Functions.Notify("Press G to set the vehicle spawn location (outside).", "primary", 7500)
            warnPurchased = true
          end
          if IsControlJustReleased(0,47) then
            local plyPed = PlayerPedId()
            local pos = GetEntityCoords(plyPed)
            local heading = GetEntityHeading(plyPed)
            locations.purchased = Vec2Tab(vector4(pos.x,pos.y,pos.z,heading))
            Wait(0)
          end
        elseif not locations.deposit then
          if not warnDeposit then        
            QBCore.Functions.Notify("Press G to set the vehicle deposit location.", "primary", 7500)
            warnDeposit = true
          end
          if IsControlJustReleased(0,47) then
            locations.deposit = Vec2Tab(GetEntityCoords(PlayerPedId()))
            Wait(0)
          end
        else 
          QBCore.Functions.Notify("Shop created, name: "..name..", price: "..price, "primary", 15000)
          TriggerServerEvent("VehicleShops:Create", name, locations, price)
          return
        end
        Wait(0)
      end
    end)
  end


end

RegisterNetEvent("VehicleShops:Sync")
AddEventHandler("VehicleShops:Sync", VehicleShops.Sync)

RegisterNetEvent("VehicleShops:RemoveDisplay")
AddEventHandler("VehicleShops:RemoveDisplay", VehicleShops.RemoveDisplay)

RegisterNetEvent("VehicleShops:CreateNew")
AddEventHandler("VehicleShops:CreateNew",VehicleShops.CreateNew)

RegisterNetEvent("VehicleShops:WarehouseRefresh")
AddEventHandler("VehicleShops:WarehouseRefresh",VehicleShops.WarehouseRefresh)

RegisterNetEvent('VehicleShops:EditMenu', function()
  local menu = {
    {
      header = 'Vehicle Shop Edit Menu',
      isMenuHeader = true
    }
  }

  for k,v in pairs(VehicleShops.Shops) do
    menu[#menu+1] = {
      header = v.name,
      params = {
        event = 'VehicleShops:EditVehicleShop',
        args = {
          shop_key = v.name
        }
      }
    }
  end

  menu[#menu+1] = {
    header = '<- Close Menu',
    params = {
      event = 'qb-menu:closeMenu'
    }
  }

  exports['qb-menu']:openMenu(menu)
end)

AddEventHandler('VehicleShops:ToggleWarehouse', function(data)
  local shop_key = data.shop_key
  TriggerServerEvent('VehicleShops:ToggleWarehouse', shop_key)
end)

AddEventHandler('VehicleShops:ChangeOwnership', function(data)
  local shop_key = data.shop_key

  local dialog = exports['qb-input']:ShowInput({
    header = "New Owner",
    submitText = "Submit",
    inputs = {
        {
            text = "CitzenID", -- text you want to be displayed as a place holder
            name = "cid", -- name of the input should be unique otherwise it might override
            type = "text", -- type of the input
            isRequired = true,
        },
    }
  })

  if dialog then
    local citizenid = tostring(dialog.cid)

    if citizenid and string.len(citizenid) > 7 then
      TriggerServerEvent('VehicleShops:ChangeOwnership', shop_key, citizenid)
    else
      QBCore.Functions.Notify("Citizen ID should be more than 7!", "error")
    end
  end
end)

RegisterNetEvent('VehicleShops:EditVehicleShop', function(data)
  local shop_key = data.shop_key
  local hasaccess = "False"

  if VehicleShops.Shops[shop_key].warehouse then
    hasaccess = "True"
  end

  local menu = {
    {
      header = shop_key..' - Edit Menu',
      isMenuHeader = true
    },
    {
      header = 'Blip Options',
      params = {
        event = 'VehicleShops:EditBlipOption',
        args = {
          shop_key = shop_key,
        },
      },
    },
    {
      header = 'Set Owner',
      txt = 'Change ownership of '..shop_key,
      params = {
        event = 'VehicleShops:ChangeOwnership',
        args = {
          shop_key = shop_key
        },
      },
    },
    {
      header = 'Toggle Warehouse Permission',
      txt = 'Access (current): '..hasaccess,
      params = {
        event = 'VehicleShops:ToggleWarehouse',
        args = {
          shop_key = shop_key
        }
      }
    },
    {
      header = '<- Go Back',
      txt = 'Vehicle Shop Edit Menu',
      params = {
        event = 'VehicleShops:EditMenu'
      }
    }
  }

  exports['qb-menu']:openMenu(menu)
end)

AddEventHandler('VehicleShops:ChangeBlipOption', function(data)
  local shop_key = data.shop_key
  local type = data.type

  if type == "sprite" then
    local dialog = exports['qb-input']:ShowInput({
      header = "Set Blip Sprite",
      submitText = "Submit",
      inputs = {
          {
              text = "BlipId", -- text you want to be displayed as a place holder
              name = "blipid", -- name of the input should be unique otherwise it might override
              type = "number", -- type of the input
              isRequired = true,
          },
      }
    })

    if dialog then
      local blipid = tonumber(dialog.blipid) or false

      if blipid then
        TriggerServerEvent('VehicleShops:ChangeBlipOption', shop_key, type, blipid)
      else
        QBCore.Functions.Notify("Sprite is not an number!", "error")
      end
    end
  elseif type == "color" then
    local dialog = exports['qb-input']:ShowInput({
      header = "Set Blip Color",
      submitText = "Submit",
      inputs = {
          {
              text = "ColorId", -- text you want to be displayed as a place holder
              name = "color", -- name of the input should be unique otherwise it might override
              type = "number", -- type of the input
              isRequired = true,
          },
      }
    })

    if dialog then
      local color = tonumber(dialog.color) or false

      if color then
        TriggerServerEvent('VehicleShops:ChangeBlipOption', shop_key, type, color)
      else
        QBCore.Functions.Notify("Color ID is not an number!", "error")
      end
    end
  elseif type == "scale" then
    local dialog = exports['qb-input']:ShowInput({
      header = "Set Blip Scale (0.01 - 1.0)",
      submitText = "Submit",
      inputs = {
          {
              text = "Scale", -- text you want to be displayed as a place holder
              name = "scale", -- name of the input should be unique otherwise it might override
              type = "number", -- type of the input
              isRequired = true,
          },
      }
    })

    if dialog then
      local scale = tonumber(dialog.scale) or false

      if scale then
        TriggerServerEvent('VehicleShops:ChangeBlipOption', shop_key, type, scale)
      else
        QBCore.Functions.Notify("Scale is not an number!", "error")
      end
    end
  elseif type == "location" then
    local pos = GetEntityCoords(PlayerPedId())
    TriggerServerEvent('VehicleShops:ChangeBlipLocation', shop_key, pos)
  end
end)

AddEventHandler('VehicleShops:EditBlipOption', function(data)
  local shop_key = data.shop_key

  local menu = {
    {
      header = shop_key ..' - Blip Option',
      isMenuHeader = true
    },
    {
      header = 'Change Blip Location',
      txt = 'Move the blip location to your current position',
      params ={
        event = 'VehicleShops:ChangeBlipOption',
        args = {
          shop_key = shop_key,
          type = 'location',
        },
      },
    },
    {
      header = 'Change Blip Sprite',
      txt = 'Current Sprite: '..VehicleShops.Shops[shop_key].blipdetails.sprite,
      params = {
        event = 'VehicleShops:ChangeBlipOption',
        args = {
          shop_key = shop_key,
          type = 'sprite',
        },
      },
    },
    {
      header = 'Change Blip Color',
      txt = 'Current Color ID: '..VehicleShops.Shops[shop_key].blipdetails.color,
      params = {
        event = 'VehicleShops:ChangeBlipOption',
        args = {
          shop_key = shop_key,
          type = 'color',
        },
      },
    },
    {
      header = 'Change Blip Scale',
      txt = 'Current Scale: '..VehicleShops.Shops[shop_key].blipdetails.scale,
      params = {
        event = 'VehicleShops:ChangeBlipOption',
        args = {
          shop_key = shop_key,
          type = 'scale',
        },
      },
    },
    {
      header = '<- Go Back',
      txt = shop_key..' - Edit Menu',
      params = {
        event = 'VehicleShops:EditVehicleShop',
        args = {
          shop_key = shop_key
        }
      }
    }
  }

  exports['qb-menu']:openMenu(menu)
end)

RegisterNUICallback('CloseMenu', function(data, cb)
  SetNuiFocus(false, false)
  IsInShopMenu = false
  cb(false)
end)

-- Edit Mode
RegisterNetEvent('VehicleShops:EditMode', function()
  editMode = not editMode
end)