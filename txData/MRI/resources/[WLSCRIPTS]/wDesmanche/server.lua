-- ============================================================
--  WLScripts | server.lua  (QBOX / QBCore)
-- ============================================================

local QBX = exports['qbx_core']

math.randomseed(os.time())

-- ============================================================
--  Controle global de peças removidas por veículo (netId)
-- ============================================================

local pecasRemovidasGlobal = {} -- [netId] = { [nomePeca] = true }

RegisterNetEvent('WLScripts:server:registrarPecaRemovida', function(vehNetId, peca)
    if not pecasRemovidasGlobal[vehNetId] then
        pecasRemovidasGlobal[vehNetId] = {}
    end
    pecasRemovidasGlobal[vehNetId][peca] = true

    -- Sincroniza com todos os outros clients
    TriggerClientEvent('WLScripts:client:syncPecaRemovida', -1, vehNetId, peca)
end)

RegisterNetEvent('WLScripts:server:limparVeiculo', function(vehNetId)
    pecasRemovidasGlobal[vehNetId] = nil
end)

-- ============================================================
--  Loot e Pagamento
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

local function randomItem(lista)
    return lista[math.random(#lista)]
end

local function getPlayer(src)
    return QBX:GetPlayer(src)
end

RegisterNetEvent('WLScripts:server:venderItem', function(propName)
    local src    = source
    local player = getPlayer(src)
    if not player then return end

    local tabela = Loot[propName]
    if not tabela then return end

    local recompensas = {}

    for _, data in pairs(tabela) do
        if math.random(100) <= data.chance then
            table.insert(recompensas, {
                item      = randomItem(data.itens),
                quantidade = math.random(data.min, data.max)
            })
        end
    end

    local limite = math.random(1, 3)
    while #recompensas > limite do
        table.remove(recompensas, math.random(#recompensas))
    end

    if #recompensas == 0 then
        local primeira = next(tabela)
        local data     = tabela[primeira]
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
        itens      = textoItens,
        pagamento  = pagamento
    })
end)

RegisterNetEvent('WLScripts:server:pagamentoFinal', function()
    local src    = source
    local player = getPlayer(src)
    if not player then return end

    local pagamento = math.random(3000, 6000)

    player.Functions.AddMoney('black_money', pagamento)

    TriggerClientEvent('WLScripts:client:pagamentoFinalConfirmado', src, pagamento)
end)
