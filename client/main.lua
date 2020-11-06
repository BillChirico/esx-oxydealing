ESX = nil

local isInMarker = false
local hasStartedMission = false
local vehicle = nil
local missionblip = nil

local vehicleSpawnLocations = {
  {x = 53.41, y = -1554.44, z = 29.46, h = 46.5},
  {x = 55.17, y = -1551.79, z = 29.46, h = 47.5},
  {x = 57.48, y = -1549.42, z = 29.46, h = 50.5},
  {x = 59.41, y = -1546.99, z = 29.46, h = 69.5},
  {x = 61.4, y = -1544.76, z = 29.46, h = 61.5}
}

local drugBuyerLocations = {
  {x = 11.26, y = -1669.32, z = 29.25, h = 269.5},
  {x = -36.08, y = -1756.84, z = 29.42, h = 320.5},
  {x = 195.08, y = -1920.33, z = 22.57, h = 277.5},
  {x = 359.42, y = -1720.59, z = 29.27, h = 180.5},
  {x = 377.0, y = -1779.19, z = 29.27, h = 50.5},
  {x = 400.12, y = -1826.71, z = 28.39, h = 35.5}
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
            notify("~g~ Your Faggio has been delivered")
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
  vehicle = CreateVehicle(car, v.x, v.y, v.z, v.h, true, false)
  local buyer = math.randomchoice(drugBuyerLocations)

  createNPC(buyer.x, buyer.y, buyer.z)
  SetJobBlip(buyer.x, buyer.y, buyer.z)

  SetNewWaypoint(v.x, v.y)
  SetVehicleHasBeenOwnedByPlayer(vehicle, true)
  SetEntityAsMissionEntity(vehicle, true, true)
  TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
end

function SetJobBlip(x, y, z)
  missionblip = AddBlipForCoord(x, y, z)
  SetBlipSprite(missionblip, 514)
  SetBlipColour(missionblip, 53)
  SetBlipRoute(missionblip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Destination")
  EndTextCommandSetBlipName(missionblip)
end

local created_ped = nil
function createNPC(x, y, z)
  created_ped = CreatePed(0, "g_m_y_famdnf_01", x, y, z, 200, true)
  FreezeEntityPosition(created_ped, true)
  SetEntityInvincible(created_ped, true)
  SetBlockingOfNonTemporaryEvents(created_ped, true)
  TaskStartScenarioInPlace(created_ped, "WORLD_HUMAN_COP_IDLES", 0, true)
end

function ClearPedTasks(ped)
  local model = GetEntityModel(ped)
  SetEntityAsNoLongerNeeded(ped)
  SetModelAsNoLongerNeeded(model)
end

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
      if (nearDealer and IsControlJustReleased(0, 38) and not IsPedInAnyVehicle(GetPlayerPed(-1), false) and hasStartedMission) then
        TaskTurnPedToFaceCoord(GetEntityCoords(GetPlayerPed(-1)))
        TriggerServerEvent("sellOxy", "oxy")
        ClearPedTasks(created_ped)

        local buyer = math.randomchoice(drugBuyerLocations)

        createNPC(buyer.x, buyer.y, buyer.z)
        SetJobBlip(buyer.x, buyer.y, buyer.z)

        if DoesBlipExist(missionblip) then
          RemoveBlip(missionblip)
        end
      elseif (nearDealer and not IsPedInAnyVehicle(GetPlayerPed(-1), false)) then
        ESX.ShowHelpNotification("Flex ~INPUT_CONTEXT~ to sell oxy", true, true)
      end

      Citizen.Wait(0)
    end
  end
)

RegisterNetEvent("endOxyJob")
AddEventHandler(
  "endOxyJob",
  function()
    hasStartedMission = false
    ClearPedTasks(created_ped)
  end
)