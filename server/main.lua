ESX = nil

TriggerEvent(
	"esx:getSharedObject",
	function(obj)
		ESX = obj
	end
)

RegisterServerEvent("sellOxy")
AddEventHandler(
	"sellOxy",
	function(itemName)
		local xPlayer = ESX.GetPlayerFromId(source)
		local price = 500
		local amount = math.random(1, 3)
		local xItem = xPlayer.getInventoryItem(itemName)

		-- Player does not have enough of oxy to sell so set it to 1
		if xPlayer.getInventoryItem(itemName).count > amount then
			amount = 1
		end

		-- Player does not have any more oxy
		if xPlayer.getInventoryItem(itemName).count < 1 then
			xPlayer.showNotification("~r~You do not have any more oxy to sell!")
			TriggerClientEvent("endOxyJob", source)
			return
		end

		price = ESX.Math.Round(price * amount)

		xPlayer.addMoney(price)

		xPlayer.removeInventoryItem(xItem.name, amount)
		xPlayer.showNotification(
			"~g~You sold " .. amount .. " " .. xItem.label .. " for a total of $" .. ESX.Math.GroupDigits(price)
		)
	end
)

RegisterNetEvent("startOxyRun")
AddEventHandler(
	"startOxyRun",
	function()
		local xPlayer = ESX.GetPlayerFromId(source)

		xPlayer.addInventoryItem("oxy", 10 - xPlayer.getInventoryItem("oxy").count)
	end
)
