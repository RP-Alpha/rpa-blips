CreateThread(function()
    for _, info in pairs(Config.Blips) do
        local blip = AddBlipForCoord(info.coords.x, info.coords.y, info.coords.z)
        SetBlipSprite(blip, info.sprite)
        SetBlipDisplay(blip, info.display or 4)
        SetBlipScale(blip, info.scale or 0.8)
        SetBlipColour(blip, info.color)
        SetBlipAsShortRange(blip, true)
        
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.label)
        EndTextCommandSetBlipName(blip)
    end
end)
