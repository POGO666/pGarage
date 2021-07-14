# pGarage
Garage in RageUI for FiveM [ESX]

[Preview](https://youtu.be/L530UG0tRfQ)

[Other Preview](https://streamable.com/duebyf)

[Discord](https://discord.gg/fcrvNbgazk)

```lua
TriggerClientEvent("pGarage:RequestGivecar", vehicle) --> Add car to player.

TriggerServerEvent("pGarage:UpdateVehicleOwner", plate, actualowner, newowner) --> Update owner of vehicle by plate.

TriggerServerEvent("pGarage:UpdateVehicleProps", plate, props) --> Update props of vehicle by plate.

TriggerServerEvent("pGarage:UpdateVehiclePlate", plate, newplate) --> Update plate of vehicle.

-- in sv_garage
--For test
RegisterCommand('givecar_test', function(source, args)
    TriggerClientEvent("pGarage:RequestGivecar", source, args[1])
end)
-- writte /givecar_test carname


-- in es_extended/client/function.lua
--change
modLivery         = GetVehicleLivery(vehicle)
--to
modLivery         = GetVehicleMod(vehicle, 48)
```
