ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RconPrint("^2["..GetCurrentResourceName().."] ^0: Garage ^3Initialized ^5By POGO#0644^0\n")

ESX.RegisterServerCallback("pGarage:GetOwnVehicle", function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    local idd = xPlayer.identifier
    MySQL.Async.fetchAll('SELECT * FROM player_veh WHERE owner = @owner', {
        ["@owner"] = idd
    }, function(result)
        callback(result)
    end)
end)

RegisterServerEvent("pGarare:RenameVeh")
AddEventHandler("pGarare:RenameVeh", function(plt, lbl)
	MySQL.Sync.execute("UPDATE player_veh SET label =@label WHERE plate=@plate",{['@label'] = lbl , ['@plate'] = plt})
end)

RegisterNetEvent("pGarage:RequestSpawn")
AddEventHandler("pGarage:RequestSpawn", function(plt, pos, hdg)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local idd = xPlayer.identifier

    MySQL.Async.fetchAll("SELECT * FROM player_veh WHERE owner = @owner AND parked = 1 AND plate = @plate",
    {['@owner'] = idd, ['@plate'] = plt},
    function(vehicle)
        if vehicle[1] ~= nil then
            MySQL.Async.execute("UPDATE player_veh SET parked = 0 WHERE owner = @owner AND plate = @plate", {['@owner'] = idd,['@plate'] = plt},
            function(data)
                TriggerClientEvent("pGarage:SpawnVeh", source, vehicle[1], pos, hdg)
            end)
        end
    end)
end)

RegisterNetEvent("pGarage:UpdateParkedStatus")
AddEventHandler("pGarage:UpdateParkedStatus", function(plt, prc)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local idd = xPlayer.identifier

    if prc ~= nil then

        if xPlayer.getMoney() >= prc then
            xPlayer.removeMoney(prc)
        
            MySQL.Async.fetchAll("SELECT * FROM player_veh WHERE owner = @owner AND parked = 0 AND plate = @plate",
            {['@owner'] = idd, ['@plate'] = plt},
            function(vehicle)
                if vehicle[1] ~= nil then
                    MySQL.Async.execute("UPDATE player_veh SET parked = 1 WHERE owner = @owner AND plate = @plate", {['@owner'] = idd,['@plate'] = plt})
                end
            end)
        else
            TriggerClientEvent("RageUI:Popup", source, {message="~b~Fonds insuffisant"})
        end
    else
        MySQL.Async.fetchAll("SELECT * FROM player_veh WHERE owner = @owner AND parked = 0 AND plate = @plate",
        {['@owner'] = idd, ['@plate'] = plt},
        function(vehicle)
            if vehicle[1] ~= nil then
                MySQL.Async.execute("UPDATE player_veh SET parked = 1 WHERE owner = @owner AND plate = @plate", {['@owner'] = idd,['@plate'] = plt})
            end
        end)
    end
end)

ESX.RegisterServerCallback('pGarage:StockVehicle',function(source,cb, vehicleProps)
	local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    local idd = xPlayer.identifier
	
	MySQL.Async.fetchAll("SELECT * FROM player_veh WHERE owner = @owner AND parked = 0 AND plate = @plate",
    {['@plate'] = vehicleProps.plate, ['@owner'] = idd}, 
    function(result)
		if result[1] ~= nil then
            MySQL.Async.execute("UPDATE player_veh SET props =@props WHERE plate=@plate",{
                ['@props'] = json.encode(vehicleProps),
                ['@plate'] = vehicleProps.plate
            }, function(rowsChanged)
                cb(true)
            end)
		else
			cb(false)
		end
	end)
end)

ESX.RegisterServerCallback('pGarage:GetAllPlate', function (source, cb, plate)
    MySQL.Async.fetchAll('SELECT 1 FROM player_veh WHERE plate = @plate', {
        ['@plate'] = plate
    }, function (result)
        cb(result[1] ~= nil)
    end)
end)

RegisterNetEvent("pGarage:Givecar")
AddEventHandler("pGarage:Givecar", function(veh, plt, prps)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.execute('INSERT INTO player_veh (owner,plate,model,props) VALUES(@owner,@plate,@model,@props)',
    {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = plt,
        ['@model'] = veh,
        ['@props'] = json.encode(prps),

    })
    RconPrint("^2["..GetCurrentResourceName().."] ^0: ^3New vehicle has registered ^0 "..plt.."\n")

end)

RegisterNetEvent("pGarage:UpdateVehicleOwner")
AddEventHandler("pGarage:UpdateVehicleOwner", function(plt, actualowner, newowner)
    local xTarget = ESX.GetPlayerFromId(actualowner)
    local xTargetnew = ESX.GetPlayerFromId(newowner)

    MySQL.Async.fetchAll('SELECT 1 FROM player_veh WHERE plate = @plate AND owner = @owner', {
        ["@owner"] = xTarget.identifier,
        ["@plate"] = plt
    }, function(result)
        if result ~= nil then
            MySQL.Async.execute('UPDATE player_veh SET owner = @owner where plate = @plate',
            {
                ["@owner"] = xTargetnew.identifier,
                ["@plate"] = plt
            })
        end
    end)

end)

RegisterNetEvent("pGarage:UpdateVehicleProps")
AddEventHandler("pGarage:UpdateVehicleProps", function(plt, prps)
    MySQL.Async.fetchAll('SELECT 1 FROM player_veh WHERE plate = @plate', {
        ["@plate"] = plt
    }, function(result)
        if result ~= nil then
            MySQL.Async.execute('UPDATE player_veh SET props = @props where plate = @plate',
            {
                ["@props"] = prps,
                ["@plate"] = plt
            })
        end
    end)

end)

RegisterNetEvent("pGarage:UpdateVehiclePlate")
AddEventHandler("pGarage:UpdateVehiclePlate", function(plt, newplate)
    MySQL.Async.fetchAll('SELECT 1 FROM player_veh WHERE plate = @plate', {
        ["@plate"] = plt
    }, function(result)
        if result ~= nil then
            MySQL.Async.execute('UPDATE player_veh SET plate = @plate where plate ='..plt,
            {
                ["@plate"] = newplate
            })
        end
    end)

end)