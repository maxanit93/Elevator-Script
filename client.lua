ESX = nil


local teleportPoints = {
    {
        label = "Main entrance",
        coords = vector4(-268.3286, -961.8920, 31.2231, 290.0930)
    },
    {
        label = "Floor 1",
        coords = vector4(-273.5131, -967.1332, 77.2313, 249.8966)
    },
    {
        label = "Floor 2",
        coords = vector4(-269.6623, -941.2114, 92.5109, 64.4389)
    }
}


local pedData = { 
    pedModel = "a_m_m_business_01", 
    pedCoords = vector3(-268.8445, -962.3786, 31.2231)
}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    
    RequestModel(GetHashKey(pedData.pedModel))
    while not HasModelLoaded(GetHashKey(pedData.pedModel)) do
        Citizen.Wait(10)
    end

    local ped = CreatePed(4, pedData.pedModel, pedData.pedCoords.x, pedData.pedCoords.y, pedData.pedCoords.z - 1.0, 0.0, false, true)
    SetEntityHeading(ped, 0.0)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())

        for _, v in pairs(teleportPoints) do
            local distance = #(playerCoords - vector3(v.coords.x, v.coords.y, v.coords.z))

            if distance < 10.0 then
                
                DrawMarker(1, v.coords.x, v.coords.y, v.coords.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 0, 100, false, true, 2, false, nil, nil, false)
            end

            if distance < 3.0 then
                ESX.ShowHelpNotification("Drücke ~INPUT_CONTEXT~ um den Fahrstuhl zu öffnen")
                if IsControlJustReleased(0, 38) then
                    local elements = {}
                    for _, tp in pairs(teleportPoints) do
                        table.insert(elements, {label = tp.label, value = tp.label})
                    end

                    ESX.UI.Menu.CloseAll()
                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Elevator Script', { -- If you change the script name then you have to write the renamed one in "Elevator Script"
                        title = 'Elevator',
                        align = 'top-left',
                        elements = elements
                    }, function(data, menu)
                        local selected
                        for _, tp in pairs(teleportPoints) do
                            if tp.label == data.current.value then
                                selected = tp
                                break
                            end
                        end
                        if selected then
                            DoScreenFadeOut(500)
                            Citizen.Wait(500)
                            SetEntityCoords(PlayerPedId(), selected.coords.x, selected.coords.y, selected.coords.z)
                            SetEntityHeading(PlayerPedId(), selected.coords.w or 0.0)
                            DoScreenFadeIn(500)
                        end
                        menu.close()
                    end, function(data, menu)
                        menu.close()
                    end)
                end
            end
        end
    end
end)
