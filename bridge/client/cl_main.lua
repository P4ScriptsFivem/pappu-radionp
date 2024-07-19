local radioMenu = false
onRadio = false
RadioChannel = 0
local RadioVolume = 30
local radioProp = nil

--Function
local function SplitStr(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[#t+1] = str
    end
    return t
end

local function connectToRadio(channel)
    RadioChannel = channel
    if onRadio then
        if Config.VoiceSystem == "pma-voice" then
            exports["pma-voice"]:setRadioChannel(0)
        elseif Config.VoiceSystem == "saltychat" then
            exports.saltychat:SetRadioChannel(0, true)
        end
    else
        onRadio = true
        if Config.VoiceSystem == "pma-voice" then
            exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
        end
    end
    if Config.VoiceSystem == "pma-voice" then
        exports["pma-voice"]:setRadioChannel(channel)
    elseif Config.VoiceSystem == "saltychat" then
        exports.saltychat:SetRadioChannel(channel, true)
    end
    if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
        Notify("You're connected to: " .. channel .. " MHz", 'success')
    else
        Notify("You're connected to: " .. channel .. " .00 MHz", 'success')
    end
end

local function closeEvent()
	TriggerEvent("InteractSound_CL:PlayOnOne","click",0.6)
end

function leaveRadio()
    closeEvent()
    RadioChannel = 0
    onRadio = false
    if Config.VoiceSystem == "pma-voice" then
        exports["pma-voice"]:removePlayerFromRadio()
        exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
    elseif Config.VoiceSystem == "saltychat" then
        local getPlayerRadioChannel = exports.saltychat:GetRadioChannel(true)
        if getPlayerRadioChannel or getPlayerRadioChannel ~= '' then
            exports.saltychat:SetRadioChannel('', true)
        end
    end
    Notify("You left the channel.", 'error')
end

local function toggleRadioAnimation(pState)
	LoadAnimDict("cellphone@")
	if pState then
		TriggerEvent("attachItemRadio","radio01")
		TaskPlayAnim(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
		radioProp = CreateObject(`prop_cs_hand_radio`, 1.0, 1.0, 1.0, 1, 1, 0)
		AttachEntityToEntity(radioProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
	else
		StopAnimTask(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 1.0)
		ClearPedTasks(PlayerPedId())
		if DoesEntityExist(radioProp) then
			DeleteObject(radioProp)
            DeleteEntity(radioProp)
			radioProp = nil
		end
	end
end

function LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
end

local function toggleRadio(toggle)
    radioMenu = toggle
    SetNuiFocus(radioMenu, radioMenu)
    if radioMenu then
        toggleRadioAnimation(true)
		SendNUIMessage({action = "openRadio", volume = RadioVolume, max = Config.MaxFrequency})
    else
        toggleRadioAnimation(false)
        SendNUIMessage({action = "closeRadio"})
    end
end

local function IsRadioOn()
    return onRadio
end

--Exports
exports("IsRadioOn", IsRadioOn)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        if RadioChannel ~= 0 then
            leaveRadio()
            toggleRadio(false)
        end
    end
end)

RegisterNetEvent('pappu-radionp:use:client', function()
    toggleRadio(not radioMenu)
end)

RegisterNetEvent('pappu-radionp:onRadioDrop', function()
    if RadioChannel ~= 0 then
        leaveRadio()
    end
end)

Citizen.CreateThread(function()
    -- Volume
	local volumeData = GetResourceKvpString('volume-pappu-radionp')
    if volumeData then RadioVolume = Round(tonumber(volumeData)) end
end)

function Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end

RegisterNUICallback('callback', function(data)
	if data.action == "nuiFocus" then
		SetNuiFocus(false, false)
		toggleRadio(false)
	elseif data.action == "powerOff" then
        if RadioChannel ~= 0 then
		    leaveRadio()
        end
    elseif data.action == "volumeDown" then
        if RadioVolume > 1 then
            RadioVolume = RadioVolume - 1
            if Config.VoiceSystem == "pma-voice" then
                exports["pma-voice"]:setRadioVolume(RadioVolume)
            elseif Config.VoiceSystem == "saltychat" then
                exports.saltychat:SetRadioVolume(RadioVolume)
            end
            SendNUIMessage({action = "updateVolume", volume = RadioVolume})
            SetResourceKvp('volume-pappu-radionp', RadioVolume)
        end
    elseif data.action == "volumeUp" then
        if RadioVolume <= 100 then
            RadioVolume = RadioVolume + 1
            if Config.VoiceSystem == "pma-voice" then
                exports["pma-voice"]:setRadioVolume(RadioVolume)
            elseif Config.VoiceSystem == "saltychat" then
                exports.saltychat:SetRadioVolume(RadioVolume)
            end
            SendNUIMessage({action = "updateVolume", volume = RadioVolume})
            SetResourceKvp('volume-pappu-radionp', RadioVolume)
        end
    elseif data.action == "joinRadio" then
        local rchannel = tonumber(data.channel)
        if rchannel ~= nil then
            if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
                if rchannel ~= RadioChannel then
                    if Config.RestrictedChannels[rchannel] ~= nil then
                        local job = GetPlayerJob()
                        if CoreName == "qb-core" or CoreName == "qbx_core" then
                            if Config.RestrictedChannels[rchannel][job.name] and job.onduty then
                                connectToRadio(rchannel)
                            else
                                Notify("You can not connect to this signal!", 'error')
                            end
                        elseif CoreName == "es_extended" then
                            if Config.RestrictedChannels[rchannel][job.name] then
                                connectToRadio(rchannel)
                            else
                                Notify("You can not connect to this signal!", 'error')
                            end
                        end
                    else
                        connectToRadio(rchannel)
                    end
                else
                    Notify("You're already connected to this channel" , 'error')
                end
            else
                Notify("This frequency is not available.", 'error')
            end
        else
            Notify("This frequency is not available." , 'error')
        end
	end
end)

Citizen.CreateThread(function()
    for k, v in pairs(Config.RestrictedChannels) do
        RegisterNetEvent('pappu-radionp:joinRadioChannel:client-' .. k, function()
            if DoRadioCheck() then
                local rchannel = tonumber(k)
                if rchannel ~= nil then
                    if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
                        if rchannel ~= RadioChannel then
                            if Config.RestrictedChannels[rchannel] ~= nil then
                                local job = GetPlayerJob()
                                if CoreName == "qb-core" or CoreName == "qbx_core" then
                                    if Config.RestrictedChannels[rchannel][job.name] and job.onduty then
                                        connectToRadio(rchannel)
                                    else
                                        Notify("You can not connect to this signal!", 'error')
                                    end
                                elseif CoreName == "es_extended" then
                                    if Config.RestrictedChannels[rchannel][job.name] then
                                        connectToRadio(rchannel)
                                    else
                                        Notify("You can not connect to this signal!", 'error')
                                    end
                                end
                            else
                                connectToRadio(rchannel)
                            end
                        else
                            Notify("You're already connected to this channel" , 'error')
                        end
                    else
                        Notify("This frequency is not available.", 'error')
                    end
                else
                    Notify("This frequency is not available." , 'error')
                end
            else
                Notify("You dont have radio item." , 'error')
            end
        end)
    end
end)