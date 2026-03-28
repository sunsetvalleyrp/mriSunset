-- ============================================================
--  WLScripts | server.lua  (QBOX / QBCore)
--  Script completo: Loot, Pagamento e Sincronização de Desmanche
-- ============================================================

local QBX = exports['qbx_core']

math.randomseed(os.time())

-- ============================================================
--  TABELAS DE LOOT E PAGAMENTO
-- ============================================================

local Loot = {
    ["prop_car_engine_01"] = {
        A = { chance = 100, min = 6, max = 10, itens = { "iron", "tools", "steel" } },
        B = { chance = 60,  min = 1, max = 3,  itens = { "copper", "aluminum" } },
        C = { chance = 35,  min = 1, max = 1,  itens = { "lockpick" } }
    },
    ["prop_car_bonnet_01"] = {
        A = { chance = 100, min = 5, max = 8, itens = { "iron", "tools" } },
        B = { chance = 50,  min = 1, max = 2, itens = { "aluminum", "copper" } },
        C = { chance = 20,  min = 1, max = 1, itens = { "lockpick" } }
    },
    ["prop_car_door_01"] = {
        A = { chance = 100, min = 5, max = 7, itens = { "iron", "tools" } },
        B = { chance = 40,  min = 1, max = 2, itens = { "aluminum" } },
        C = { chance = 15,  min = 1, max = 1, itens = { "lockpick" } }
    },
    ["prop_wheel_01"] = {
        A = { chance = 100, min = 4, max = 6, itens = { "plastic", "iron" } },
        B = { chance = 35,  min = 1, max = 2, itens = { "aluminum" } },
        C = { chance = 10,  min = 1, max = 1, itens = { "lockpick" } }
    }
}

local Pagamento = {
    ["prop_car_engine_01"] = { min = 900,  max = 1400 },
    ["prop_car_bonnet_01"] = { min = 500,  max = 800  },
    ["prop_car_door_01"]   = { min = 400,  max = 700  },
    ["prop_wheel_01"]      = { min = 250,  max = 450  },
}

-- ============================================================
--  ESTADO GLOBAL DE SINCRONIZAÇÃO
--  Formato: { [netId] = { [nomePeca] = true } }
-- ============================================================

local estadoVeiculos = {}

-- ============================================================
--  FUNÇÕES AUXILIARES
-- ============================================================

local function randomItem(lista)
    return lista[math.random(#lista)]
end

local function getPlayer(src)
    return QBX:GetPlayer(src)
end

-- ============================================================
--  EVENTOS: LOOT E PAGAMENTO
-- ============================================================

RegisterNetEvent('WLScripts:server:venderItem', function(propName)
    local src = source
    local player = getPlayer(src)
    if not player then return end

    local tabela = Loot[propName]
    if not tabela then return end

    local recompensas = {}

    for _, data in pairs(tabela) do
        if math.random(100) <= data.chance then
            table.insert(recompensas, {
                item     = randomItem(data.itens),
                quantidade = math.random(data.min, data.max)
            })
        end
    end

    -- Limita entre 1 e 3 recompensas
    local limite = math.random(1, 3)
    while #recompensas > limite do
        table.remove(recompensas, math.random(#recompensas))
    end

    -- Garante ao menos 1 recompensa
    if #recompensas == 0 then
        local primeira = next(tabela)
        local data = tabela[primeira]
        table.insert(recompensas, {
            item       = randomItem(data.itens),
            quantidade = data.min
        })
    end

    local textoItens = ""

    for _, v in pairs(recompensas) do
        player.Functions.AddItem(v.item, v.quantidade)
        textoItens = textoItens .. v.quantidade .. "x " .. v.item .. " "
    end

    local faixa     = Pagamento[propName]
    local pagamento = faixa and math.random(faixa.min, faixa.max) or 0

    if pagamento > 0 then
        player.Functions.AddMoney('black_money', pagamento)
    end

    TriggerClientEvent('WLScripts:client:vendaConfirmada', src, {
        itens     = textoItens,
        pagamento = pagamento
    })
end)

RegisterNetEvent('WLScripts:server:pagamentoFinal', function()
    local src = source
    local player = getPlayer(src)
    if not player then return end

    local pagamento = math.random(3000, 6000)

    player.Functions.AddMoney('black_money', pagamento)

    TriggerClientEvent('WLScripts:client:pagamentoFinalConfirmado', src, pagamento)
end)

-- ============================================================
--  EVENTOS: SINCRONIZAÇÃO DE ESTADO DE DESMANCHE
-- ============================================================

-- Player entra na área: consulta peças já removidas do veículo
RegisterNetEvent('WLScripts:server:consultarEstadoVeiculo', function(netId)
    local src = source
    local pecasRemovidas = estadoVeiculos[netId]

    if pecasRemovidas and next(pecasRemovidas) then
        TriggerClientEvent('WLScripts:client:sincronizarPecas', src, netId, pecasRemovidas)
    end
end)

-- Callback: verifica se uma peça específica já foi removida
lib.callback.register('WLScripts:server:verificarPeca', function(source, netId, peca)
    local estado = estadoVeiculos[netId]
    if estado and estado[peca] then
        return true  -- já foi removida
    end
    return false
end)

-- Registra remoção de peça e sincroniza com todos os players
RegisterNetEvent('WLScripts:server:registrarPecaRemovida', function(netId, peca)
    if not estadoVeiculos[netId] then
        estadoVeiculos[netId] = {}
    end

    estadoVeiculos[netId][peca] = true

    -- Broadcast para todos (quem removeu já atualizou localmente)
    TriggerClientEvent('WLScripts:client:sincronizarPecas', -1, netId, estadoVeiculos[netId])
end)

-- Veículo deletado: limpa estado para liberar memória
RegisterNetEvent('WLScripts:server:limparEstadoVeiculo', function(netId)
    estadoVeiculos[netId] = nil
end)
