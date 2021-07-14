ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
    end
end)
Citizen.Trace("^2["..GetCurrentResourceName().."] ^0: Garage ^3Initialized ^5By POGO#0644^0\n")
local Garage = {}

local VehTab = {}
local carInstance = {}
local VehCam = nil
local vehSelected = nil

RMenu.Add('garage', 'main', RageUI.CreateMenu("", "~b~Garage", 10, 200))
RMenu:Get('garage', 'main').EnableMouse = false

RMenu.Add('garage', 'submycars', RageUI.CreateSubMenu(RMenu:Get('garage', 'main'), "", "~b~Mes Véhicules"))
RMenu.Add('garage', 'suboption', RageUI.CreateSubMenu(RMenu:Get('garage', 'submycars'), "", "~b~Mes Véhicules"))
RMenu.Add('garage', 'subranger', RageUI.CreateSubMenu(RMenu:Get('garage', 'main'), "", "~b~Ranger un véhicule"))
RMenu.Add('garage', 'subplace', RageUI.CreateSubMenu(RMenu:Get('garage', 'suboption'), "", "~b~Sortir un véhicule"))

RMenu:Get('garage', 'main').Closed = function() Garage.Menu = false FreezeEntityPosition(GetPlayerPed(-1), false) end
RMenu:Get("garage", "subranger").Closed = function() pGarage.CamManager("delete") end
RMenu:Get("garage", "subplace").Closed = function() pGarage.CamManager("delete") end

function OpenGarageRageUIMenu(places, prc)

    if Garage.Menu then
        Garage.Menu = false
    else
        Garage.Menu = true
        RageUI.Visible(RMenu:Get('garage', 'main'), true)
        FreezeEntityPosition(GetPlayerPed(-1), true)

        Citizen.CreateThread(function()
			while Garage.Menu do
                RageUI.IsVisible(RMenu:Get('garage', 'main'), false, false, true, function()

                    RageUI.Button("Mes Véhicules", false, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        if Selected then
                            VehTab = {}
                            Vehicle_RefreshTable()
                        end
                    end, RMenu:Get('garage', 'submycars'))

                    RageUI.Button("Ranger un véhicule", false, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                    end, RMenu:Get('garage', 'subranger'))
                end)

                RageUI.IsVisible(RMenu:Get('garage', 'submycars'), false, false, true, function()

                    if #VehTab ~= 0 then
                        for i = 1 , #VehTab,1 do
                            local itm = VehTab[i]
                            local vehlbl = GetLabelText(GetDisplayNameFromVehicleModel(itm.model))
                            local vehplace = GetVehicleModelNumberOfSeats(itm.model)

                            state = ""
                            if itm.parked == "1" or itm.parked == 1 then state = "~g~Rentrer" else state = "~r~Sortie" end
                            if itm.label == "NULL" or itm.label == NULL or itm.label == vehlbl then itm.label = vehlbl else itm.label = itm.label end

                            RageUI.Button(itm.label.." (~b~"..itm.plate.."~s~)", "Nombre de place : "..vehplace.."\nVéhicule : "..vehlbl, {RightLabel = state}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    vehSelected = itm
                                end
                            end, RMenu:Get('garage', 'suboption'))
                        end
                    else
                        RageUI.Separator("~r~Vous n'avez pas de véhicule.")
                    end

                end)

                RageUI.IsVisible(RMenu:Get('garage', 'suboption'), false, false, true, function()
                    local c = vehSelected
                    RageUI.Separator("↓↓ ~y~"..c.label.."~s~ ↓↓")

                    if c.parked == "1" or c.parked == 1 then
                        RageUI.Button("Sortir", false, {RightLabel = "→→→"}, true, function(Hovered, Active, Selected)
                        end, RMenu:Get('garage', 'subplace'))
                    elseif c.parked == "0" or c.parked == 0 then
                        RageUI.Button("Sortir", false, {}, false, function(Hovered, Active, Selected)
                        end)

                        if not DoesBlipExist(PersoCarblip) then
                            RageUI.Button("Rappeler le véhicule", false, {RightLabel = "~g~$"..prc}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    TriggerServerEvent("pGarage:UpdateParkedStatus", c.plate, prc)
                                    RageUI.GoBack()
                                    ESX.SetTimeout(100, function()
                                        Vehicle_RefreshTable()
                                    end)
                                end
                            end)
                        end
                    end

                    RageUI.Button("Renommer", false, {}, true, function(Hovered, Active, Selected)
                        if Selected then
                            local name = KeyboardInput("entryname", "~b~Renommer", c.label, 25)
                            if name ~= nil then
                                TriggerServerEvent("pGarare:RenameVeh", c.plate, name)
                                RageUI.Visible(RMenu:Get('garage', 'suboption'), false)
                                RageUI.Visible(RMenu:Get('garage', 'main'), true)
                                RageUI.Popup({message="~b~Véhicule renommer !"})
                            else
                                RageUI.Popup({message="~r~Veuillez insérer du texte !"})
                            end
                        end
                    end)
                end)

                RageUI.IsVisible(RMenu:Get('garage', 'subplace'), false, false, false, function()
                    local c = vehSelected
                    RageUI.Separator("↓↓ ~y~"..c.label.."~s~ ↓↓")
                    RageUI.Separator("↓↓ ~y~Choisir une place de parking~s~ ↓↓")
                    for k,v in pairs(places) do
                        local pointclear = ESX.Game.IsSpawnPointClear(v.pos, 3.0)
                        if pointclear then
                            RageUI.Button("Place #"..k, false, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    TriggerServerEvent("pGarage:RequestSpawn", c.plate, vector3(v.pos.x, v.pos.y, v.pos.z), v.heading)
                                end
                                if Active then
                                    pGarage.CamManager("create", vector3(v.pos.x-6.0, v.pos.y-3.0, v.pos.z +1.5), vector3(v.pos.x, v.pos.y, v.pos.z))
                                    DrawMarker(1, v.pos.x, v.pos.y, v.pos.z-0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 3.0, 255, 255, 255, 150, 0, 0, 2, 0, nil, nil, 0)
                                end
                            end)
                        else
                            local veh = ESX.Game.GetClosestVehicle(v.pos)
                            local plate = GetVehicleNumberPlateText(veh)
                            RageUI.Button("~c~Place #"..k, false, {RightBadge = RageUI.BadgeStyle.Lock}, true, function(Hovered, Active, Selected)
                                if Active then
                                    pGarage.CamManager("create", vector3(v.pos.x-6.0, v.pos.y-3.0, v.pos.z +1.5), vector3(v.pos.x, v.pos.y, v.pos.z))
                                    DrawMarker(1, v.pos.x, v.pos.y, v.pos.z-0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 3.0, 255, 50, 50, 150, 0, 0, 2, 0, nil, nil, 0)
                                end
                            end)
                        end
                    end
                end)

                RageUI.IsVisible(RMenu:Get('garage', 'subranger'), false, false, false, function()
                    RageUI.Separator("↓↓ ~y~Place de parking~s~ ↓↓")
                    for k,v in pairs(places) do
                        local pointclear = ESX.Game.IsSpawnPointClear(v.pos, 2.0)
                        if pointclear then
                            RageUI.Button("Place #"..k, false, {RightLabel = "~g~Libre"}, true, function(Hovered, Active, Selected)
                                if Active then
                                    pGarage.CamManager("create", vector3(v.pos.x-6.0, v.pos.y-3.0, v.pos.z +1.5), vector3(v.pos.x, v.pos.y, v.pos.z))
                                    DrawMarker(1, v.pos.x, v.pos.y, v.pos.z-0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 3.0, 255, 255, 255, 150, 0, 0, 2, 0, nil, nil, 0)
                                end
                            end)
                        else
                            local veh = ESX.Game.GetClosestVehicle(v.pos)
                            local plate = GetVehicleNumberPlateText(veh)
                            RageUI.Button("Place #"..k.." - ~b~("..plate..")", false, {RightLabel = "~r~Ranger →"}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    local vehProps  = pGarage.GetVehicleProperties(veh)
                                    ESX.TriggerServerCallback('pGarage:StockVehicle',function(valid)
                                        if(valid) then
                                            for k,v in pairs (carInstance) do
                                                if ESX.Math.Trim(v.plate) == ESX.Math.Trim(vehProps.plate) then
                                                    table.remove(carInstance, k)
                                                end
                                            end
                                            DeleteEntity(veh)
                                            TriggerServerEvent("pGarage:UpdateParkedStatus", vehProps.plate)
                                            RageUI.Popup({message="~b~Véhicule ranger."})
                                        else
                                            RageUI.Popup({message="~r~Ce véhicule n'est pas le tien."})
                                        end
                                    end,vehProps)
                                end
                                if Active then
                                    pGarage.CamManager("create", vector3(v.pos.x-6.0, v.pos.y-3.0, v.pos.z +1.5), vector3(v.pos.x, v.pos.y, v.pos.z))
                                    DrawMarker(1, v.pos.x, v.pos.y, v.pos.z-0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 3.0, 255, 50, 50, 150, 0, 0, 2, 0, nil, nil, 0)
                                end
                            end)
                        end
                    end
                end)

				Wait(0)
			end
		end)
	end

end

Citizen.CreateThread(function()
    while true do
        att = 500
        local pCoords = GetEntityCoords(GetPlayerPed(-1), false)
        for k,v in pairs(Config.pGarage) do
            local mPos = Vdist(pCoords, v.pos)

            if not Garage.Menu then
                if mPos <= 10.0 then
                    att = 1
                    DrawMarker(1, v.pos.x, v.pos.y, v.pos.z-0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 150, 200, 170, 0, 0, 0, 1, nil, nil, 0)
                
                    if mPos <= 1.5 then
                        ShowHelpNotification("Appuyez sur ~INPUT_PICKUP~ pour interagir")
                        if IsControlJustPressed(0, 51) then
                            OpenGarageRageUIMenu(v.places, v.returnprice)
                        end
                    end
                end
            end
        end
        Citizen.Wait(att)
    end
end)

function Vehicle_RefreshTable()
    VehTab = {}
    ESX.TriggerServerCallback("pGarage:GetOwnVehicle", function(data) 
        VehTab = data
    end)
end

RegisterNetEvent("pGarage:SpawnVeh")
AddEventHandler('pGarage:SpawnVeh', function(vh,pos,heading)
    PlaySoundFrontend(-1, "Put_Away", "Phone_SoundSet_Michael", 1)

    ESX.Game.SpawnVehicle(vh.model, pos, heading, function(callback_vehicle)
        pGarage.SetVehicleProperties(callback_vehicle, json.decode(vh.props))
        SetModelAsNoLongerNeeded(json.decode(vh.props)["model"])
        local vehlbl = GetLabelText(GetDisplayNameFromVehicleModel(vh.model))
        if vh.label == "NULL" or vh.label == NULL or vh.label == vehlbl then vh.label = vehlbl else vh.label = vh.label end

        --blip
        PersoCarblip = AddBlipForEntity(callback_vehicle)
        SetBlipSprite(PersoCarblip, 225)
        ShowHeadingIndicatorOnBlip(PersoCarblip, true)
        SetBlipRotation(PersoCarblip, math.ceil(GetEntityHeading(callback_vehicle)))
        SetBlipScale(PersoCarblip, 0.65)
        SetBlipShrink(PersoCarblip, true)
        ShowFriendIndicatorOnBlip(PersoCarblip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(vh.label)
        EndTextCommandSetBlipName(PersoCarblip)
        --end blip
        table.insert(carInstance, {vehicleentity = callback_vehicle, plate = vh.plate})
        SetVehicleNumberPlateText(callback_vehicle, vh.plate)
	end)
    ESX.SetTimeout(300, function()
        Wait(10)
        Vehicle_RefreshTable()
    end)
end)