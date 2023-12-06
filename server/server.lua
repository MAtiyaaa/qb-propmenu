local QBCore = exports['qb-core']:GetCoreObject()
Config = {}
Config.debug = true
local spawnedProps = {}
if Config.debug then
    print("Debug mode enabled.")
end


RegisterServerEvent('boneped:spawnProp')
AddEventHandler('boneped:spawnProp', function(data)
    if Config.Debug then
        print("Server: Received 'boneped:spawnProp' event")
    end
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    
    if not player then
        if Config.Debug then
            print("Server: Player not found for source: " .. tostring(src))
            return
        end
    end

    if spawnedProps[src] then
        DeleteEntity(spawnedProps[src])
    end

    local playerPed = GetPlayerPed(src)
    local propHash = GetHashKey(data.prop)
    local playerCoords = GetEntityCoords(playerPed)
    local offsetX = playerCoords.x + data.positionOffset.x
    local offsetY = playerCoords.y + data.positionOffset.y
    local offsetZ = playerCoords.z + data.positionOffset.z
    local boneIndex = data.boneIndex
    if Config.Debug then
        print("Server: Creating prop at offset (" .. offsetX .. ", " .. offsetY .. ", " .. offsetZ .. ") with boneIndex " .. boneIndex)
    end    

    local prop = CreateObjectNoOffset(propHash, offsetX, offsetY, offsetZ, true, true, true)

    if not prop or prop == 0 then
        if Config.Debug then
            print("Server: Failed to create prop.")
        end
        TriggerClientEvent('QBCore:Notify', src, 'Failed to create prop.', 'error')
        return
    end

    spawnedProps[src] = prop
    TriggerClientEvent('boneped:attachProp', src, { prop = prop, boneIndex = boneIndex })
    if Config.Debug then
        print("Server: Prop created and attached successfully.")
    end    
    TriggerClientEvent('QBCore:Notify', src, 'Prop spawned successfully', 'success')
end)

RegisterServerEvent('boneped:updateProp')
AddEventHandler('boneped:updateProp', function(data)
    local src = source
    local prop = spawnedProps[src]

    if prop and DoesEntityExist(prop) then
        local playerPed = GetPlayerPed(src)
        local playerCoords = GetEntityCoords(playerPed)
        local newX = playerCoords.x + data.positionOffset.x
        local newY = playerCoords.y + data.positionOffset.y
        local newZ = playerCoords.z + data.positionOffset.z
        
        SetEntityCoords(prop, newX, newY, newZ, 0, 0, 0, 0)

        local radRotationX = math.rad(data.rotation.x)
        local radRotationY = math.rad(data.rotation.y)
        local radRotationZ = math.rad(data.rotation.z)
        SetEntityRotation(prop, radRotationX, radRotationY, radRotationZ, 2, true)
        if data.boneIndex then
            DetachEntity(prop, true, true)
            AttachEntityToEntity(prop, playerPed, data.boneIndex, 0, 0, 0, 0, 0, 0, 0, false, false, false, 2, true)
        end
        if Config.Debug then
            print("Server: Prop position and rotation updated.")
        end
    end
end)

RegisterServerEvent('boneped:closeMenu')
AddEventHandler('boneped:closeMenu', function()
    if Config.Debug then
        print("Server: 'boneped:closeMenu' event triggered")
    end
end)
