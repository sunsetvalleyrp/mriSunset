-- ============================================================
--  WLScripts | client.lua  (QBOX / QBCore)
-- ============================================================

local desmanchandoVeiculos = {}
local propNaMao            = nil
local propNameNaMao        = nil
local estaRemovendo        = false

local function Notify(msg, tipo)
    lib.notify({ title = 'Desmanche', description = msg, type = tipo or 'inform' })
end

local function detectarTipoVeiculo(veh)
    local classe = GetVehicleClass(veh)
    if classe == 8 then return "moto" end

    local model = GetEntityModel(veh)
    local seats  = GetVehicleModelNumberOfSeats(model)
    return seats <= 2 and "2portas" or "4portas"
end

local function gerarPecasVeiculo(veh)
    local tipo  = detectarTipoVeiculo(veh)
    local pecas = {}

    local function getBone(name)
        local idx = GetEntityBoneIndexByName(veh, name)
        if idx == -1 then return nil end
        local x, y, z = table.unpack(GetWorldPositionOfEntityBone(veh, idx))
        return vector3(x, y, z)
    end

    if tipo == "moto" then
        pecas["Roda_Frente"] = getBone("wheel_lf")
        pecas["Roda_Tras"]   = getBone("wheel_lr")
        pecas["Motor"]       = getBone("engine")

    elseif tipo == "2portas" then
        pecas["Porta_Direita"]       = getBone("door_dside_f")
        pecas["Porta_Esquerda"]      = getBone("door_pside_f")
        pecas["Roda_EsquerdaFrente"] = getBone("wheel_lf")
        pecas["Roda_DireitaFrente"]  = getBone("wheel_rf")
        pecas["Roda_EsquerdaTras"]   = getBone("wheel_lr")
        pecas["Roda_DireitaTras"]    = getBone("wheel_rr")
        pecas["Motor"]               = getBone("engine")

    elseif tipo == "4portas" then
        pecas["Porta_Direita"]       = getBone("door_dside_f")
        pecas["Porta_Esquerda"]      = getBone("door_pside_f")
        pecas["Porta_DireitaTras"]   = getBone("door_dside_r")
        pecas["Porta_EsquerdaTras"]  = getBone("door_pside_r")
        pecas["Roda_EsquerdaFrente"] = getBone("wheel_lf")
        pecas["Roda_DireitaFrente"]  = getBone("wheel_rf")
        pecas["Roda_EsquerdaTras"]   = getBone("wheel_lr")
        pecas["Roda_DireitaTras"]    = getBone("wheel_rr")
        pecas["Motor"]               = getBone("engine")
    end

    for k, v in pairs(pecas) do
        if not v then pecas[k] = nil end
    end

    return pecas
end

local function removerPecaDoVeiculo(veh, peca)
    local classe = GetVehicleClass(veh)

    if string.find(peca, "Porta") then
        local mapa = {
            Porta_Direita      = 0,
            Porta_Esquerda     = 1,
            Porta_DireitaTras  = 2,
            Porta_EsquerdaTras = 3,
        }
        local idx = mapa[peca]
        if idx then SetVehicleDoorBroken(veh, idx, true) end

    elseif string.find(peca, "Roda") then
        if classe ~= 8 then
            local mapa = {
                Roda_EsquerdaFrente = 0,
                Roda_DireitaFrente  = 1,
                Roda_EsquerdaTras   = 4,
                Roda_DireitaTras    = 5,
            }
            local idx = mapa[peca]
            if idx then SetVehicleTyreBurst(veh, idx, true, 1000) end
        else
            if peca == "Roda_Frente" then SetVehicleTyreBurst(veh, 0, true, 1000) end
            if peca == "Roda_Tras"   then SetVehicleTyreBurst(veh, 4, true, 1000) end
        end

    elseif peca == "Motor" then
        SetVehicleDoorOpen(veh, 4, false, false)
        Wait(800)
        SetVehicleEngineHealth(veh, 0)
    end
end

local function criarPropNaMao(ped, propName)
    local hash = GetHashKey(propName)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local prop = CreateObject(hash, 0.0, 0.0, 0.0, true, true, true)

    AttachEntityToEntity(
        prop, ped,
        GetPedBoneIndex(ped, 57005),
        0.1, 0.0, -0.05,
        0.0, 90.0, 0.0,
        true, true, false, true, 1, true
    )

    SetModelAsNoLongerNeeded(hash)
    return prop
end

local function getPropConfig(peca)
    if string.find(peca, "Porta") then
        return Config.props.portas
    elseif string.find(peca, "Roda") then
        return Config.props.rodas
    elseif peca == "Motor" then
        return Config.props.motor
    end
    return Config.props.capo
end

local function processarRemocaoPeca(ped, veh, data, peca)
    local propConfig = getPropConfig(peca)

    removerPecaDoVeiculo(veh, peca)

    propNaMao     = criarPropNaMao(ped, propConfig)
    propNameNaMao = propConfig

    data.pecasRemovidas[peca] = true
    data.quantidade_pecas_do_veiculo = data.quantidade_pecas_do_veiculo - 1

    Notify("Peça removida! Vá vender no ponto de venda.", "success")

    if data.quantidade_pecas_do_veiculo <= 0 then
        DeleteVehicle(veh)
        desmanchandoVeiculos[veh] = nil
    end
end

local function GetVehiclesInArea(coords, radius)
    local vehicles = {}
    local handle, veh = FindFirstVehicle()
    local success

    repeat
        local pos = GetEntityCoords(veh)
        if #(coords - pos) <= radius then
            table.insert(vehicles, veh)
        end
        success, veh = FindNextVehicle(handle)
    until not success

    EndFindVehicle(handle)
    return vehicles
end

CreateThread(function()
    while true do
        local sleep  = 1000
        local ped    = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for _, v in pairs(Config.coordenadas_locais_desmanche) do
            local dist = #(coords - vector3(v.x, v.y, v.z))

            if dist <= 20 then
                sleep = 500

                local vehs = GetVehiclesInArea(coords, Config.raioDeteccaoVeiculo)

                for _, veh in pairs(vehs) do
                    if not desmanchandoVeiculos[veh] and not IsEntityAVehicle(veh) == false then
                        local pecas = gerarPecasVeiculo(veh)
                        local total = 0
                        for _ in pairs(pecas) do total = total + 1 end

                        if total > 0 then
                            desmanchandoVeiculos[veh] = {
                                pecas = pecas,
                                pecasRemovidas = {},
                                quantidade_pecas_do_veiculo = total
                            }
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep  = 1000
        local ped    = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for veh, data in pairs(desmanchandoVeiculos) do
            for peca, pos in pairs(data.pecas) do
                if not data.pecasRemovidas[peca] and pos then
                    local dist = #(coords - pos)

                    if dist <= Config.raioPeca then
                        sleep = 0

                        if not propNaMao and not estaRemovendo and IsControlJustPressed(0, 38) then
                            estaRemovendo = true
                            lib.hideTextUI()

                            if lib.progressBar({
                                duration = Config.tempoRemocao,
                                label    = 'Removendo peça...',
                                useWhileDead = false,
                                canCancel    = true,
                                disable = { move = true, car = true, combat = true },
                                anim    = { scenario = 'WORLD_HUMAN_WELDING' }
                            }) then
                                processarRemocaoPeca(ped, veh, data, peca)
                            else
                                Notify("Remoção cancelada.", "error")
                            end

                            estaRemovendo = false
                        end
                    end
                end
            end
        end

        if sleep == 1000 then lib.hideTextUI() end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep  = 1000
        local ped    = PlayerPedId()
        local coords = GetEntityCoords(ped)

        if propNaMao then
            for _, v in pairs(Config.coordenadas_locais_venderPecas) do
                local dist = #(coords - vector3(v.x, v.y, v.z))

                if dist <= 5.0 then
                    sleep = 0
                    lib.showTextUI('[E] Vender peça', { position = 'left-center' })

                    if IsControlJustPressed(0, 38) then
                        lib.hideTextUI()
                        TriggerServerEvent('WLScripts:server:venderItem', propNameNaMao)

                        DeleteEntity(propNaMao)
                        propNaMao     = nil
                        propNameNaMao = nil
                    end
                end
            end
        end

        if sleep == 1000 then lib.hideTextUI() end
        Wait(sleep)
    end
end)

RegisterNetEvent('WLScripts:client:vendaConfirmada', function(data)
    Notify('Peça vendida! Itens: ' .. data.itens .. '| $' .. data.pagamento .. ' em dinheiro sujo','success')
end)

RegisterNetEvent('WLScripts:client:pagamentoFinalConfirmado', function(pagamento)
    Notify('Desmanche finalizado! Você recebeu $' .. pagamento .. ' em dinheiro sujo.', 'success')
end)