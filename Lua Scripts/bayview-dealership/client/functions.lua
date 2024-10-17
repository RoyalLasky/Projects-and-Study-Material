TableCount = function(tab)
  local c = 0
  for k,v in pairs(tab) do if v then c = c + 1; end; end
  return
end

Tab2Vec = function(tab)
  if tab.w or tab.h or tab.heading then
    return vector4(tab.x,tab.y,tab.z,(tab.w or tab.h or tab.heading))
  else
    return vector3(tab.x,tab.y,tab.z)
  end
end

Vec2Tab = function(vec)
  return (type(vec) == "vector3" and {x = vec.x, y = vec.y, z = vec.z} or {x = vec.x, y = vec.y, z = vec.z, heading = vec.w})
end

DrawText3D = function(x,y,z, text, d)
  coords = vector3(x,y,z)

  local camCoords = GetGameplayCamCoords()
  local distance = #(coords - camCoords)

  if not size then size = 1 end
  if not font then font = 1 end

  local dist = Vdist(GetEntityCoords(GetPlayerPed(-1)),coords)

  local scale = (size / distance) * 2
  local fov = (1 / GetGameplayCamFov()) * 100
  scale = scale * fov
 
end

GetMoveScaleform = function()
  local scaleform = RequestScaleformMovie('instructional_buttons')
  while not HasScaleformMovieLoaded(scaleform) do Citizen.Wait(0) end

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(4)
  InstructionButton(GetControlInstructionalButton(0, Controls["Moving_Vehicle"].ground, true))
  InstructionButtonMessage("Ground")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(5)
  InstructionButton(GetControlInstructionalButton(0, Controls["Moving_Vehicle"].cancel, true))
  InstructionButtonMessage("Cancel")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
  PushScaleformMovieFunctionParameterInt(6)
  InstructionButton(GetControlInstructionalButton(0, Controls["Moving_Vehicle"].place, true))
  InstructionButtonMessage("Place")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
  PopScaleformMovieFunctionVoid()

  PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
  PushScaleformMovieFunctionParameterInt(0)
  PushScaleformMovieFunctionParameterInt(0)
  PushScaleformMovieFunctionParameterInt(0)
  PushScaleformMovieFunctionParameterInt(80)
  PopScaleformMovieFunctionVoid()

  return scaleform
end

InstructionButton = function(ControlButton)
  N_0xe83a3e3557a56640(ControlButton)
end

InstructionButtonMessage = function(text)
  BeginTextCommandScaleformString("STRING")
  AddTextComponentScaleform(text)
  EndTextCommandScaleformString()
end
