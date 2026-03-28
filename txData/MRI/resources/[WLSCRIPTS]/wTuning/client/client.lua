-- =============================================
-- GarageX Tuning - client.lua
-- QBOX | Tecla E dentro do veiculo na zona
-- =============================================

local isOpen        = false
local targetVehicle = 0

-- MOD INDICES
local ModMap = {
    motor       = { index = 11, toggle = false },
    turbo       = { index = 18, toggle = true  },
    suspension  = { index = 15, toggle = false },
    freios      = { index = 12, toggle = false },
    armadura    = { index = 16, toggle = false },
    transmissao = { index = 13, toggle = false },
}

local ItemModValues = {
    motor_s1 = { slot='motor',       modValue=0    },
    motor_s2 = { slot='motor',       modValue=1    },
    motor_s3 = { slot='motor',       modValue=2    },
    motor_s4 = { slot='motor',       modValue=3    },
    turbo_s1 = { slot='turbo',       modValue=true },
    turbo_s2 = { slot='turbo',       modValue=true },
    turbo_s3 = { slot='turbo',       modValue=true },
    turbo_s4 = { slot='turbo',       modValue=true },
    susp_s1  = { slot='suspension',  modValue=0    },
    susp_s2  = { slot='suspension',  modValue=1    },
    susp_s3  = { slot='suspension',  modValue=2    },
    susp_s4  = { slot='suspension',  modValue=4    },
    freio_s1 = { slot='freios',      modValue=0    },
    freio_s2 = { slot='freios',      modValue=1    },
    freio_s3 = { slot='freios',      modValue=2    },
    freio_s4 = { slot='freios',      modValue=3    },
    arm_s1   = { slot='armadura',    modValue=0    },
    arm_s2   = { slot='armadura',    modValue=1    },
    arm_s3   = { slot='armadura',    modValue=2    },
    arm_s4   = { slot='armadura',    modValue=4    },
    trans_s1 = { slot='transmissao', modValue=0    },
    trans_s2 = { slot='transmissao', modValue=1    },
    trans_s3 = { slot='transmissao', modValue=2    },
    trans_s4 = { slot='transmissao', modValue=3    },
}

-- =============================================
-- HELPERS
-- =============================================
local function IsNearWorkshop()
    local myPos = GetEntityCoords(PlayerPedId())
    for _, loc in ipairs(Config.Location) do
        if #(myPos - loc.markerposition) < loc.dist then
            return true
        end
    end
    return false
end

local function GetCurrentTuning(vehicle)
    local result     = {}
    local stageFound = {}
    for itemId, data in pairs(ItemModValues) do
        local mod = ModMap[data.slot]
        if mod then
            local ok = false
            if mod.toggle then
                ok = IsToggleModOn(vehicle, mod.index)
            else
                local currentMod = GetVehicleMod(vehicle, mod.index)
                local expectedValue = data.modValue
                -- Para S4: o valor instalado é o máximo do veículo, não um número fixo
                -- Verifica se o itemId termina em _s4
                if string.sub(itemId, -3) == '_s4' then
                    local maxMod = GetNumVehicleMods(vehicle, mod.index) - 1
                    if maxMod >= 0 then
                        expectedValue = maxMod
                    end
                end
                ok = currentMod == expectedValue
            end
            if ok then
                local s = tonumber(string.sub(itemId, -1)) or 0
                if s > (stageFound[data.slot] or 0) then
                    stageFound[data.slot] = s
                    result[data.slot]     = itemId
                end
            end
        end
    end
    return result
end

-- =============================================
-- ABRIR NUI
-- =============================================
local function OpenTuningUI(vehicle)
    if not vehicle or vehicle == 0 then return end
    local pd      = exports.qbx_core:GetPlayerData()
    local balance = pd.money and pd.money.bank or 0
    local cash    = pd.money and pd.money.cash or 0
    local model   = GetEntityModel(vehicle)
    local name    = GetLabelText(GetDisplayNameFromVehicleModel(model))
    if not name or name == 'NULL' or name == '' then name = 'Veiculo' end

    isOpen        = true
    targetVehicle = vehicle
    SetNuiFocus(true, true)
    SendNUIMessage({
        action        = 'openUI',
        balance       = balance,
        cash          = cash,
        vehicleName   = name,
        vehiclePlate  = GetVehicleNumberPlateText(vehicle),
        currentTuning = GetCurrentTuning(vehicle),
    })
end

-- =============================================
-- FECHAR UI
-- =============================================
local function CloseUI()
    if not isOpen then return end
    isOpen        = false
    targetVehicle = 0
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'forceClose' })
end

RegisterNUICallback('closeUI', function(_, cb)
    CloseUI()
    cb('ok')
end)

-- Thread de segurança: fecha com ESC mesmo sem fetch chegar
CreateThread(function()
    while true do
        Wait(0)
        if isOpen then
            if IsControlJustReleased(0, 200) or IsDisabledControlJustReleased(0, 200) then
                CloseUI()
            end
        end
    end
end)

-- =============================================
-- RETURN ITEM — devolve item ao inventário
-- removeFromVehicle: enviado pela NUI
--   true  = item estava instalado no carro → servidor remove mod físico via evento
--   false = item estava só na NUI          → só devolve ao inventário
-- =============================================
RegisterNUICallback('returnItem', function(data, cb)
    local itemId          = data.itemId
    local slotId          = data.slotId
    local removeFromVehicle = data.removeFromVehicle

    if not itemId or itemId == '' then cb('err') return end

    -- Se era pré-instalado, remove o mod físico do veículo agora no client
    -- (mais rápido e confiável do que esperar o roundtrip servidor→client)
    if removeFromVehicle then
        local vehicle = targetVehicle ~= 0 and targetVehicle or GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            SetVehicleModKit(vehicle, 0)
            local mod = ModMap[slotId]
            if mod then
                if mod.toggle then
                    ToggleVehicleMod(vehicle, mod.index, false)
                else
                    SetVehicleMod(vehicle, mod.index, -1, false)
                end
            end
        end
    end

    -- Notifica servidor para devolver item ao inventário
    TriggerServerEvent('garagex_tuning:returnItem', {
        itemId          = itemId,
        slotId          = slotId,
        removeFromVehicle = removeFromVehicle,
    })
    cb('ok')
end)

-- =============================================
-- APPLY TUNING — instala peças novas
-- =============================================
RegisterNUICallback('applyTuning', function(data, cb)
    local items   = data.items
    local vehicle = targetVehicle ~= 0 and targetVehicle or GetVehiclePedIsIn(PlayerPedId(), false)
    if not items or #items == 0 or vehicle == 0 then cb('err') return end
    TriggerServerEvent('garagex_tuning:applyTuning', {
        items = items,
        plate = GetVehicleNumberPlateText(vehicle),
        netId = NetworkGetNetworkIdFromEntity(vehicle),
    })
    cb('ok')
end)

-- =============================================
-- MODS APROVADOS — aplica mods físicos no carro
-- =============================================
RegisterNetEvent('garagex_tuning:modsApproved', function(items)
    local vehicle = targetVehicle ~= 0 and targetVehicle or GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end

    -- Salva todos os mods existentes ANTES de SetVehicleModKit
    -- pois ele reseta tudo e apagaria os pré-instalados (ex: freio_s4, trans_s4)
    local savedMods    = {}
    local savedToggles = {}
    for slotId, mod in pairs(ModMap) do
        if mod.toggle then
            savedToggles[mod.index] = IsToggleModOn(vehicle, mod.index)
        else
            local v = GetVehicleMod(vehicle, mod.index)
            if v ~= -1 then savedMods[mod.index] = v end
        end
    end
    savedToggles[18] = IsToggleModOn(vehicle, 18) -- turbo usado pelo motor_s4

    -- Aplica mod kit (necessário para habilitar modificações)
    SetVehicleModKit(vehicle, 0)

    -- Reaplica os mods que já estavam no carro
    for index, value in pairs(savedMods) do
        SetVehicleMod(vehicle, index, value, false)
    end
    for index, value in pairs(savedToggles) do
        ToggleVehicleMod(vehicle, index, value)
    end

    -- Aplica os mods novos por cima (sobrescreve apenas os slots alterados)
    for _, item in ipairs(items) do
        local mod = ModMap[item.slotId]
        if mod then
            if mod.toggle then
                ToggleVehicleMod(vehicle, mod.index, item.modValue == true or item.modValue == 'true')
            else
                local value = tonumber(item.modValue) or 0
                -- Para S4: usa o valor máximo real que o veículo suporta nesse mod index
                -- Evita o bug onde modValue=3 não existe no veículo e o GTA ignora silenciosamente
                if string.sub(tostring(item.id), -2) == 's4' and not mod.toggle then
                    local maxMod = GetNumVehicleMods(vehicle, mod.index) - 1
                    if maxMod >= 0 then
                        value = maxMod
                    end
                end
                SetVehicleMod(vehicle, mod.index, value, false)
            end
        end
        if item.id == 'motor_s4' then ToggleVehicleMod(vehicle, 18, true) end
    end

    lib.notify({ title='GarageX Tuning', description='Modificacoes instaladas!', type='success' })
    local pd = exports.qbx_core:GetPlayerData()
    SendNUIMessage({
        action  = 'updateBalance',
        balance = pd.money and pd.money.bank or 0,
        cash    = pd.money and pd.money.cash or 0,
    })
end)

RegisterNetEvent('garagex_tuning:modsDenied', function(reason)
    lib.notify({ title='GarageX Tuning', description=reason or 'Erro ao instalar.', type='error' })
end)

-- =============================================
-- REMOVE MOD DO VEÍCULO (fallback via servidor)
-- Chamado pelo servidor quando removeFromVehicle=true
-- Normalmente o client já faz isso no NUICallback,
-- mas este evento serve como segurança extra
-- =============================================
RegisterNetEvent('garagex_tuning:removeMod', function(data)
    local vehicle = targetVehicle ~= 0 and targetVehicle or GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return end
    local slotId = data and data.slotId
    if not slotId then return end
    SetVehicleModKit(vehicle, 0)
    local mod = ModMap[slotId]
    if mod then
        if mod.toggle then
            ToggleVehicleMod(vehicle, mod.index, false)
        else
            SetVehicleMod(vehicle, mod.index, -1, false)
        end
    end
end)

-- =============================================
-- THREAD: BLIPS
-- =============================================
CreateThread(function()
    Wait(3000)
    print('^2[GarageX] Criando ' .. #Config.Location .. ' blip(s)...^7')
    for i, loc in ipairs(Config.Location) do
        local blip = AddBlipForCoord(loc.markerposition.x, loc.markerposition.y, loc.markerposition.z)
        SetBlipSprite(blip, loc.blipsprite)
        SetBlipScale(blip, loc.blipscale)
        SetBlipColour(blip, loc.blipcolor)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(loc.blipname)
        EndTextCommandSetBlipName(blip)
        print('^2[GarageX] Blip #' .. i .. ' criado em ' .. tostring(loc.markerposition) .. '^7')
    end
end)

-- =============================================
-- THREAD: MARKER + INTERAÇÃO
-- =============================================
CreateThread(function()
    print('^2[GarageX] Thread de marker iniciada.^7')
    local helpShowing = false
    while true do
        if isOpen then
            if helpShowing then
                lib.hideTextUI()
                helpShowing = false
            end
            Wait(500)
        else
            local ped    = PlayerPedId()
            local myPos  = GetEntityCoords(ped)
            local inZone = false

            for _, loc in ipairs(Config.Location) do
                local dist = #(myPos - loc.markerposition)
                if dist < 80.0 then
                    DrawMarker(
                        1,
                        loc.markerposition.x, loc.markerposition.y, loc.markerposition.z,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        2.0, 2.0, 0.8,
                        255, 165, 0, 150,
                        false, false, 2, true, nil, nil, false
                    )
                end
                if dist < loc.dist then
                    inZone = true
                end
            end

            local vehicle = GetVehiclePedIsIn(ped, false)

            if inZone and vehicle ~= 0 then
                if not helpShowing then
                    lib.showTextUI('[E] Abrir Tuning', { position='bottom-center', icon='wrench' })
                    helpShowing = true
                end
                if IsControlJustReleased(0, 38) then
                    lib.hideTextUI()
                    helpShowing = false
                    OpenTuningUI(vehicle)
                end
                Wait(0)
            elseif inZone and vehicle == 0 then
                if not helpShowing then
                    lib.showTextUI('Entre em um veiculo para tunear', { position='bottom-center', icon='car' })
                    helpShowing = true
                end
                Wait(500)
            else
                if helpShowing then
                    lib.hideTextUI()
                    helpShowing = false
                end
                Wait(500)
            end
        end
    end
end)

-- =============================================
-- COMANDO /tuning
-- =============================================
RegisterCommand('tuning', function()
    local ped     = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        local myPos = GetEntityCoords(ped)
        for _, v in ipairs(GetGamePool('CVehicle')) do
            if #(GetEntityCoords(v) - myPos) < 10.0 then vehicle = v break end
        end
    end
    if vehicle ~= 0 then
        OpenTuningUI(vehicle)
    else
        lib.notify({ title='GarageX', description='Entre em um veiculo!', type='error' })
    end
end, false)
