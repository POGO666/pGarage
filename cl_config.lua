Config = {}

Config.pGarage = {

    {
        pos = vector3(275.48, -344.84, 45.17),
        places = {
            {pos = vector3(265.61, -332.09, 44.92),heading = 250.0,},
            {pos = vector3(277.72, -340.2, 44.92),heading = 70.0,},
            {pos = vector3(282.59, -342.17, 44.92),heading = 250.0,},
            {pos = vector3(294.86, -346.55, 44.92),heading = 70.0,},
        },
        returnprice = 1000,
        blip = {
            label = "Garage", 
            ID = 357, 
            Color = 26
        },
    },
}


Citizen.CreateThread(function()

    for k,v in pairs(Config.pGarage) do
        if v.blip ~= nil then
            local blip = AddBlipForCoord(v.pos)
            SetBlipSprite(blip, v.blip.ID)
            SetBlipScale(blip, 0.7)
            SetBlipColour(blip, v.blip.Color)
            SetBlipAsShortRange(blip, true)
            SetBlipCategory(blip, 8)
        
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.blip.label)
            EndTextCommandSetBlipName(blip)
        end
    end

end)