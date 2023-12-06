QBCore = exports['qb-core']:GetCoreObject()
Config = {}
Config.debug = true
local lastSpawnedProp = nil

if Config.debug then
    print("Debug mode enabled.")
end

RegisterNUICallback('spawnProp', function(data, cb)
    if Config.Debug then
        print("Client: Received prop spawn data", json.encode(data))
    end
    local playerPed = PlayerPedId()
    local boneIndex = data.boneIndex
    if lastSpawnedProp and DoesEntityExist(lastSpawnedProp) then
        DeleteEntity(lastSpawnedProp)
        lastSpawnedProp = nil
    end
    if boneIndex == -1 then
        if Config.Debug then
            print("Client: Invalid bone index.")
        end
        cb({ status = 'error', message = 'Invalid bone index.' })
        return
    end

    local eventData = {
        prop = data.prop, 
        boneIndex = boneIndex, 
        positionOffset = data.positionOffset, 
        rotation = data.rotation 
    }
    if Config.Debug then
        print("Client: Triggering server event 'boneped:spawnProp' with data:", json.encode(eventData))
    end
    TriggerServerEvent('boneped:spawnProp', eventData)
    cb({ status = 'ok' })
end)

RegisterNetEvent('boneped:attachProp')
AddEventHandler('boneped:attachProp', function(data)
    local playerPed = PlayerPedId()
    lastSpawnedProp = data.prop
    local rotation = data.rotation or { x = 0, y = 0, z = 0 }
    if lastSpawnedProp and DoesEntityExist(lastSpawnedProp) then
        DeleteEntity(lastSpawnedProp);
    end
    local radRotationX = degreesToRadians(rotation.x)
    local radRotationY = degreesToRadians(rotation.y)
    local radRotationZ = degreesToRadians(rotation.z)

    AttachEntityToEntity(data.prop, playerPed, data.boneIndex, 0.0, 0.0, 0.0, radRotationX, radRotationY, radRotationZ, false, false, false, false, 2, true)
    
    if Config and Config.Debug then
        print("Client: Prop attached successfully.")
    end
end)
function degreesToRadians(degrees)
    return degrees * 0.0174533
end

RegisterNUICallback('updateProp', function(data, cb)
    if lastSpawnedProp and DoesEntityExist(lastSpawnedProp) then
        local radRotationX = degreesToRadians(data.rotation.x)
        local radRotationY = degreesToRadians(data.rotation.y)
        local radRotationZ = degreesToRadians(data.rotation.z)

        SetEntityCoords(lastSpawnedProp, data.positionOffset.x, data.positionOffset.y, data.positionOffset.z, false, false, false, true)
        SetEntityRotation(lastSpawnedProp, radRotationX, radRotationY, radRotationZ, 2, true)
    end
    cb({ status = 'ok' })
end)


RegisterNUICallback('closeMenu', function(data, cb)
    if Config.Debug then
        print("Client: Close menu requested.")
    end
    SetNuiFocus(false, false)
    cb({ status = 'ok' })
end)

RegisterNUICallback('notifyClipboard', function(data, cb)
    QBCore.Functions.Notify("Prop details saved to clipboard", "success")
    cb({ status = 'ok' })
end)

RegisterCommand('boneped', function()
    if Config.Debug then
        print("Client: Open menu command issued.")
    end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'openMenu' })
end, false)
