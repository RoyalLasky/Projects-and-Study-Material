local isRayActive = false
local object = nil

local function startModelPositioning(model)
    if not isRayActive then
        if not IsModelValid(model) then
            lib.notify({
                title = "Invalid Model!",
                description = "Enter valid/supported model name",
                type = "error",

            })
            return
        end
        isRayActive = true
        lib.requestModel(model)
        object = CreateObject(GetHashKey(model), GetEntityCoords(PlayerPedId()), false)
        SetEntityCollision(object, false, true)
        local head = GetEntityHeading(object)
        Citizen.CreateThread(function ()
            while isRayActive do
                local hit, entity, coords = lib.raycast.cam(511, 4, 10)
                if hit==1 then
                    SetEntityCoords(object, coords)
                    PlaceObjectOnGroundProperly(object)
                end
                if IsControlPressed(0, 174) then
                    head = head==360 and 0 or head-0.5  --clockwise rotation
                end
                if IsControlPressed(0, 175) then
                    head = head==360 and 0 or head+0.5  --anticlockwise rotation
                end
                if IsControlJustPressed(0, 176) then
                    isRayActive = false
                end
                SetEntityHeading(object, head)
            end
            
            lib.setClipboard(tostring(vector4(GetEntityCoords(object),head)))
            SetTimeout(5000,function ()
                DeleteObject(object)
            end)
            lib.notify({
                title = "Coords Copied",
                description = "Coords copied to clipboard",
                type = "success",

            })
        end)
    end
end

local function stopModelPositioning()
    isRayActive = false
end