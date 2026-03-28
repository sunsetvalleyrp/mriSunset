-- ============================================================
--  big_desmanche | client.lua  (QBOX / QBCore)
-- ============================================================

local desmanchandoVeiculos = {}   -- [veh] = { pecas, pecasRemovidas, quantidade_pecas_do_veiculo }
local propNaMao            = nil  -- handle do objeto na mão
local propNameNaMao        = nil  -- nome do prop na mão
local estaRemovendo        = false

----------------------------------------------------
-- NOTIFICAÇÕES (lib do QBOX / ox_lib)
----------------------------------------------------

local function Notify(msg, tipo)
    -- ox_lib notify (incluído no QBOX)
    lib.notify({ title = 'Desmanche', description = msg, type = tipo or 'inform' })
end

----------------------------------------------------
-- DETECTAR TIPO DE VEÍCULO
----------------------------------------------------

local function detectarTipoVeiculo(veh)
    local classe = GetVehicleClass(veh)
    if classe == 8 then return "moto" end

    local model = GetEntityModel(veh)
    local seats  = GetVehicleModelNumberOfSeats(model)
    return seats <= 2 and "2portas" or "4portas"
end

----------------------------------------------------
-- GERAR PEÇAS DO VEÍCULO
----------------------------------------------------

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

    -- Remove entradas nil (bone inexistente no modelo)
    for k, v in pairs(pecas) do
        if not v then pecas[k] = nil end
    end

    return pecas
end

----------------------------------------------------
-- REMOVER PEÇA DO VEÍCULO (visual)
----------------------------------------------------

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

----------------------------------------------------
-- CRIAR PROP NA MÃO
----------------------------------------------------

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

----------------------------------------------------
-- OBTER PROP CONFIG A PARTIR DO NOME DA PEÇA
----------------------------------------------------

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

----------------------------------------------------
-- PROCESSAR REMOÇÃO
----------------------------------------------------

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

----------------------------------------------------
-- PEGAR VEÍCULOS NA ÁREA
----------------------------------------------------

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

----------------------------------------------------
-- THREAD: DETECTAR VEÍCULOS PARA DESMANCHE
----------------------------------------------------

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
                    -- Ignora veículos controlados por jogadores
                    if not desmanchandoVeiculos[veh] and not IsEntityAVehicle(veh) == false then
                        local pecas = gerarPecasVeiculo(veh)
                        local total = 0
                        for _ in pairs(pecas) do total = total + 1 end

                        if total > 0 then
                            desmanchandoVeiculos[veh] = {
                                pecas                       = pecas,
                                pecasRemovidas              = {},
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

----------------------------------------------------
-- THREAD: REMOVER PEÇAS (E + texto de instrução)
----------------------------------------------------

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

                        -- Instrução na tela
                        if not propNaMao then
                            lib.showTextUI('[E] Coletar peça: ' .. peca, { position = 'left-center' })
                        end

                        if not propNaMao and not estaRemovendo and IsControlJustPressed(0, 38) then
                            estaRemovendo = true
                            lib.hideTextUI()

                            -- Progresso visual (ox_lib)
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

        -- Esconde a UI se saiu do raio
        if sleep == 1000 then lib.hideTextUI() end

        Wait(sleep)
    end
end)

----------------------------------------------------
-- THREAD: VENDER PEÇAS
----------------------------------------------------

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
                        TriggerServerEvent('big_desmanche:server:venderItem', propNameNaMao)

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

----------------------------------------------------
-- EVENTO: CONFIRMAÇÃO DE VENDA
----------------------------------------------------

RegisterNetEvent('big_desmanche:client:vendaConfirmada', function(data)
    Notify(
        'Peça vendida! Itens: ' .. data.itens .. '| $' .. data.pagamento .. ' em dinheiro sujo',
        'success'
    )
end)

----------------------------------------------------
-- EVENTO: PAGAMENTO FINAL
----------------------------------------------------

RegisterNetEvent('big_desmanche:client:pagamentoFinalConfirmado', function(pagamento)
    Notify('Desmanche finalizado! Você recebeu $' .. pagamento .. ' em dinheiro sujo.', 'success')
end)
