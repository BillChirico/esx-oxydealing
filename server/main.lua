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
		local amount = math.random(1, 2)
		local xItem = xPlayer.getInventoryItem(itemName)

		price = ESX.Math.Round(price * amount)

		xPlayer.addMoney(price)

		xPlayer.removeInventoryItem(xItem.name, amount)
		xPlayer.showNotification(_U("dealer_sold", amount, xItem.label, ESX.Math.GroupDigits(price)))
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
