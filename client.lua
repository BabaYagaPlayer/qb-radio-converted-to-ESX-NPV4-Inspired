ESX = exports["es_extended"]:getSharedObject()
local PlayerData = ESX.GetPlayerData() -- Just for resource restart (same as event handler)
local radioMenu = false
local onRadio = false
local RadioChannel = 0
local RadioVolume = 50
local hasRadio = false
local radioProp = nil

-- Function
local function LoadAnimDic(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
end

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

local function connecttoradio(channel)
    RadioChannel = channel
    if onRadio then
        exports["pma-voice"]:setRadioChannel(0)
    else
        onRadio = true
        exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
    end
    exports["pma-voice"]:setRadioChannel(channel)
    if SplitStr(tostring(channel), ".")[2] ~= nil and SplitStr(tostring(channel), ".")[2] ~= "" then
        ESX.ShowNotification('Joined to radio: ' .. channel .. ' MHz', 'success')
    else
        ESX.ShowNotification('Joined to radio: ' .. channel .. '.00 MHz', 'success')
    end
end

local function closeEvent()
    TriggerEvent("InteractSound_CL:PlayOnOne","click",0.6)
end

local function leaveradio()
    closeEvent()
    RadioChannel = 0
    onRadio = false
    exports["pma-voice"]:setRadioChannel(0)
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
    ESX.ShowNotification('You have left the radio', 'error')
end

local function toggleRadioAnimation(pState)
    LoadAnimDic("cellphone@")
    if pState then
        TriggerEvent("attachItemRadio","radio01")
        TaskPlayAnim(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
        radioProp = CreateObject(`prop_cs_hand_radio`, 1.0, 1.0, 1.0, 1, 1, 0)
        AttachEntityToEntity(radioProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
    else
        StopAnimTask(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 1.0)
        ClearPedTasks(PlayerPedId())
        if radioProp ~= 0 then
            DeleteObject(radioProp)
            radioProp = 0
        end
    end
end

local function toggleRadio(toggle)
    radioMenu = toggle
    SetNuiFocus(radioMenu, radioMenu)
    if radioMenu then
        toggleRadioAnimation(true)
        SendNUIMessage({type = "open"})
    else
        toggleRadioAnimation(false)
        SendNUIMessage({type = "close"})
    end
end

local function IsRadioOn()
    return onRadio
end

local function DoRadioCheck(PlayerItems)
    local _hasRadio = false

    for _, item in pairs(PlayerItems) do
        if item.name == "radio" then
            _hasRadio = true
            break;
        end
    end

    hasRadio = _hasRadio
end

-- Exports
exports("IsRadioOn", IsRadioOn)

-- Events
RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
    DoRadioCheck(PlayerData.inventory)
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    DoRadioCheck({})
    PlayerData = {}
    leaveradio()
end)

RegisterNetEvent('esx:setPlayerData', function(key, val)
    if key == 'inventory' then
        PlayerData.inventory = val
        DoRadioCheck(PlayerData.inventory)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        ESX.TriggerServerCallback('esx:getPlayerData', function(playerData)
            PlayerData = playerData
            DoRadioCheck(PlayerData.inventory)
        end)
    end
end)

RegisterNetEvent('esx_radio:use', function()
    toggleRadio(not radioMenu)
end)

RegisterNetEvent('esx_radio:onRadioDrop', function()
    if RadioChannel ~= 0 then
        leaveradio()
    end
end)

-- NUI Callbacks
RegisterNUICallback('joinRadio', function(data, cb)
    local rchannel = tonumber(data.channel)
    if rchannel ~= nil then
        if rchannel <= Config.MaxFrequency and rchannel ~= 0 then
            if rchannel ~= RadioChannel then
                if Config.RestrictedChannels[rchannel] ~= nil then
                    if Config.RestrictedChannels[rchannel][PlayerData.job.name] and PlayerData.job.onduty then
                        connecttoradio(rchannel)
                    else
                        TriggerEvent('qs-smartphone:client:notify', {
                            title = 'Radio',
                            text = 'Locked Channel',
                            icon = "./img/apps/radio.png",
                            timeout = 1500
                        })
                    end
                else
                    connecttoradio(rchannel)
                end
            else
                TriggerEvent('qs-smartphone:client:notify', {
                    title = 'Radio',
                    text = 'You are already on this channel',
                    icon = "./img/apps/radio.png",
                    timeout = 1500
                })
            end
        else
            TriggerEvent('qs-smartphone:client:notify', {
                title = 'Radio',
                text = 'Channel does not exist',
                icon = "./img/apps/radio.png",
                timeout = 1500
            })        end
    else
        TriggerEvent('qs-smartphone:client:notify', {
            title = 'Radio',
            text = 'Channel does not exist',
            icon = "./img/apps/radio.png",
            timeout = 1500
        })    
    end
    cb("ok")
end)

RegisterNUICallback('leaveRadio', function(_, cb)
    if RadioChannel == 0 then
        TriggerEvent('qs-smartphone:client:notify', {
            title = 'Radio',
            text = 'You are not connected',
            icon = "./img/apps/radio.png",
            timeout = 1500
        })      else
        leaveradio()
    end
    cb("ok")
end)

RegisterNUICallback("volumeUp", function(_, cb)
    if RadioVolume <= 95 then
        RadioVolume = RadioVolume + 5
        ESX.ShowNotification('Radio volume: ' .. RadioVolume, 'success')
        exports["pma-voice"]:setRadioVolume(RadioVolume)
    else
        TriggerEvent('qs-smartphone:client:notify', {
            title = 'Radio',
            text = 'Voice Volume is maxed',
            icon = "./img/apps/radio.png",
            timeout = 1500
        })     
     end
    cb('ok')
end)

RegisterNUICallback("volumeDown", function(_, cb)
    if RadioVolume >= 10 then
        RadioVolume = RadioVolume - 5
        ESX.ShowNotification('Radio volume: ' .. RadioVolume, 'success')
        exports["pma-voice"]:setRadioVolume(RadioVolume)
    else
        TriggerEvent('qs-smartphone:client:notify', {
            title = 'Radio',
            text = 'Voice Volume is at lowest',
            icon = "./img/apps/radio.png",
            timeout = 1500
        })    
    end
    cb('ok')
end)

RegisterNUICallback("increaseradiochannel", function(_, cb)
    local newChannel = RadioChannel + 1
    connecttoradio(newChannel)
    ESX.ShowNotification('Changed to channel: ' .. newChannel, 'success')
    cb("ok")
end)

RegisterNUICallback("decreaseradiochannel", function(_, cb)
    if not onRadio then return end
    local newChannel = RadioChannel - 1
    if newChannel >= 1 then
        connecttoradio(newChannel)
        ESX.ShowNotification('Changed to channel: ' .. newChannel, 'success')
        cb("ok")
    end
end)

RegisterNUICallback('poweredOff', function(_, cb)
    leaveradio()
    cb("ok")
end)

RegisterNUICallback('escape', function(_, cb)
    toggleRadio(false)
    cb("ok")
end)

-- Main Thread
CreateThread(function()
    while true do
        Wait(1000)
        if ESX.PlayerLoaded and onRadio then
            if not hasRadio or PlayerData.metadata.isdead or PlayerData.metadata.inlaststand then
                if RadioChannel ~= 0 then
                    leaveradio()
                end
            end
        end
    end
end)
