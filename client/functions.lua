function alert(msg)
  SetTextComponentFormat("STRING")
  AddTextComponentString(msg)
  DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function notify(msg)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(msg)
  DrawNotification(false, false)
end

function RemoveJobBlip(blip)
  if DoesBlipExist(blip) then
    RemoveBlip(blip)
  end
end

function math.randomchoice(t) --Selects a random item from a table
  local keys = {}
  for key, value in pairs(t) do
    keys[#keys + 1] = key
  end
  index = keys[math.random(1, #keys)]
  return t[index]
end