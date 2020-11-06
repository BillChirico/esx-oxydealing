ESX = nil

local isInMarker = false
local hasStartedMission = false

local vehicleSpawnLocations = {
  {x = 53.41, y = -1554.44, z = 29.46, h = 46.5},
  {x = 55.17, y = -1551.79, z = 29.46, h = 47.5},
  {x = 57.48, y = -1549.42, z = 29.46, h = 50.5},
  {x = 59.41, y = -1546.99, z = 29.46, h = 69.5},
  {x = 61.4, y = -1544.76, z = 29.46, h = 61.5}
}

Citizen.CreateThread(
  function()
    while ESX == nil do
      TriggerEvent(
        "esx:getSharedObject",
        function(obj)
          ESX = obj
        end
      )
      Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
      Citizen.Wait(100)
    end

    ESX.PlayerData = ESX.GetPlayerData()
  end
)

Citizen.CreateThread(
  function()
    while true do
      isInMarker = false

      local ped = PlayerPedId()
      local coords = GetEntityCoords(ped)
      local locationCoords = Config.OxyStart.OxyLocation.coords

      if (#(coords - locationCoords) < 2.0) then
        isInMarker = true
      end

      Citizen.Wait(500)
    end
  end
)

Citizen.CreateThread(
  function()
    while true do
      isInMarker = false

      local ped = PlayerPedId()
      local coords = GetEntityCoords(ped)
      local locationCoords = Config.OxyStart.OxyLocation.coords

      if (#(coords - locationCoords) < 2.0 and not hasStartedMission) then
        isInMarker = true
      end

      Citizen.Wait(500)
    end
  end
)

Citizen.CreateThread(
  function()
    while true do
      if (isInMarker and IsControlJustReleased(0, 38)) then
        local freespot, v = getParkingPosition(vehicleSpawnLocations)
        if (not freespot) then
          notify("~r~ There are no free parking spots, please wait")
          Citizen.Wait(0)
        end

        if (freespot) then
          local car = ("faggio")
          spawnCar(car)

          if (not hasStartedMission) then
            notify("~g~ Your oxy Faggio has been delivered")
            TriggerServerEvent("startOxyRun")
          end

          hasStartedMission = true
        end
      elseif (isInMarker) then
        ESX.ShowHelpNotification("Flex ~INPUT_CONTEXT~ to start dealing oxy", true, true)
      end

      Citizen.Wait(0)
    end
  end
)

function getParkingPosition(spots)
  for id, v in pairs(spots) do
    if GetClosestVehicle(v.x, v.y, v.z, 3.0, 0, 70) == 0 then
      return true, v
    end
  end
end

function spawnCar(car)
  -- Don't allow multiple spawns
  if (hasStartedMission) then
    notify("~r~ Your Faggio is already out!")
    return
  end

  local car = GetHashKey(car)

  RequestModel(car)
  while not HasModelLoaded(car) do
    RequestModel(car)
    Citizen.Wait(0)
  end

  local freespot, v = getParkingPosition(vehicleSpawnLocations)
  local vehicle = CreateVehicle(car, v.x, v.y, v.z, v.h, true, false)

  createNPC()
  SetNewWaypoint(v.x, v.y)
  SetJobBlip(-10.67, -1475.54, 30.54)
  SetVehicleHasBeenOwnedByPlayer(vehicle, true)
  SetEntityAsMissionEntity(vehicle, true, true)
end

function SetJobBlip(x, y, z)
  if DoesBlipExist(missionblip) then
    RemoveBlip(missionblip)
  end
  missionblip = AddBlipForCoord(x, y, z)
  SetBlipSprite(missionblip, 514)
  SetBlipColour(missionblip, 53)
  SetBlipRoute(missionblip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Destination")
  EndTextCommandSetBlipName(missionblip)
end

local created_ped = nil
function createNPC()
  created_ped = CreatePed(0, "g_m_y_famdnf_01", -10.67, -1475.54, 30.54 - 1, 200, true)
  FreezeEntityPosition(created_ped, true)
  SetEntityInvincible(created_ped, true)
  SetBlockingOfNonTemporaryEvents(created_ped, true)
  TaskStartScenarioInPlace(created_ped, "WORLD_HUMAN_COP_IDLES", 0, true)
end

function ClearPedTasks(ped)
end

local missionblip = nil
local blip = nil

local nearDealer = false

Citizen.CreateThread(
  function()
    while true do
      nearDealer = false

      local ped = created_ped
      local coords = GetEntityCoords(ped)

      if (#(coords - GetEntityCoords(GetPlayerPed(-1))) < 2.0) then
        nearDealer = true
      end

      Citizen.Wait(500)
    end
  end
)

Citizen.CreateThread(
  function()
    while true do
      if (nearDealer and IsControlJustReleased(0, 38)) then
        TaskTurnPedToFaceCoord(GetEntityCoords(GetPlayerPed(-1)))
        local model = GetEntityModel(created_ped)
        SetEntityAsNoLongerNeeded(created_ped)
        SetModelAsNoLongerNeeded(model)
        RemoveJobBlip(missionblip)
        TriggerServerEvent("sellOxy", "oxy")
      elseif (nearDealer) then
        ESX.ShowHelpNotification("Flex ~INPUT_CONTEXT~ to sell oxy", true, true)
      end

      Citizen.Wait(0)
    end
  end
)
