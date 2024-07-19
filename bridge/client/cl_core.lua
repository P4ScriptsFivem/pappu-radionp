Core = nil
CoreName = nil
CoreReady = false
Citizen.CreateThread(function()
    for k, v in pairs(Cores) do
        if GetResourceState(v.ResourceName) == "starting" or GetResourceState(v.ResourceName) == "started" then
            CoreName = v.ResourceName
            Core = v.GetFramework()
            CoreReady = true
        end
    end
end)

function TriggerCallback(name, cb, ...)
    Config.ServerCallbacks[name] = cb
    TriggerServerEvent('pappu-radionp:server:triggerCallback', name, ...)
end

RegisterNetEvent('pappu-radionp:client:triggerCallback', function(name, ...)
    if Config.ServerCallbacks[name] then
        Config.ServerCallbacks[name](...)
        Config.ServerCallbacks[name] = nil
    end
end)

function Notify(text, length, type)
    if CoreName == "qb-core" then
        Core.Functions.Notify(text, length, type)
    elseif CoreName == "es_extended" then
        Core.ShowNotification(text)
    end
end

function GetPlayerData()
    if CoreName == "qb-core" then
        local player = Core.Functions.GetPlayerData()
        return player
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerData()
        return player
    end
end

function GetPlayerJob()
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local player = Core.Functions.GetPlayerData()
        return player.job
    elseif CoreName == "es_extended" then
        local player = Core.GetPlayerData()
        return player.job
    end
end

Citizen.CreateThread(function()
    -- Volume
	local volumeData = GetResourceKvpString('volume-pappu-radionp')
    if volumeData then RadioVolume = Round(tonumber(volumeData)) end
    if Config.ItemCheckLoop then
        while true do
            Citizen.Wait(5000)
            if onRadio then
                if CoreName == "qb-core" or CoreName == "qbx_core" then
                    if not DoRadioCheck() or PlayerData.metadata.isdead or PlayerData.metadata.inlaststand then
                        if RadioChannel ~= 0 then
                            leaveRadio()
                        end
                    end
                else
                    print(DoRadioCheck())
                    if not DoRadioCheck() then
                        if RadioChannel ~= 0 then
                            leaveRadio()
                        end
                    end
                end
            end
        end
    end
end)


AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    print('working #pappu100 radionp')
end)


function DoRadioCheck()
    if CoreName == "qb-core" or CoreName == "qbx_core" then
        local PlayerData = Core.Functions.GetPlayerData()
        while not next(PlayerData) do Citizen.Wait(0) end
        local hasOX = GetResourceState('ox_inventory') == 'started'
        if hasOX then
            local oxItems = exports.ox_inventory:GetPlayerItems()
            for k, v in pairs(oxItems) do
                if v.name == Config.RadioItem then
                    return true
                end
            end
            return false
        end
        for _, item in pairs(PlayerData.items) do
            if item.name == "radio" then
                return true
            end
        end
        return false
    elseif CoreName == "es_extended" then
        while not Core.IsPlayerLoaded() do Citizen.Wait(0) end
        local hasOX = GetResourceState('ox_inventory') == 'started'
        if hasOX then
            local oxItems = exports.ox_inventory:GetPlayerItems()
            for k, v in pairs(oxItems) do
                if v.name == Config.RadioItem then
                    return true
                end
            end
            return false
        end
        if Core.IsPlayerLoaded() then
            if Core.SearchInventory(Config.RadioItem, 1) then
                local hasItem = Core.SearchInventory(Config.RadioItem, 1) >= 1
                if hasItem then
                    return true
                end
            else
                return false
            end
        end
        return false
    end
end

--Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = Core.Functions.GetPlayerData()
    DoRadioCheck()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    DoRadioCheck({})
    PlayerData = {}
    leaveRadio()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    DoRadioCheck()
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    DoRadioCheck()
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        while not CoreReady do Citizen.Wait(0) end
        if CoreName == "qb-core" or CoreName == "qbx_core" then
            PlayerData = Core.Functions.GetPlayerData()
            DoRadioCheck()
        elseif CoreName == "es_extended" then
            DoRadioCheck()
        end
    end
end)