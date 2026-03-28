-- ============================================================
--  big_desmanche | server.lua  (QBOX / QBCore)
-- ============================================================

local QBX = exports['qbx_core']

math.randomseed(os.time())

------------------------------------------------
-- LOOT TABLE POR PEÇA
------------------------------------------------

local Loot = {

    ------------------------------------------------
    -- MOTOR
    ------------------------------------------------
    ["prop_car_engine_01"] = {
        A = {
            chance = 100,
            min    = 6,
            max    = 10,
            itens  = { "ferro", "ferramenta", "aco" }
        },
        B = {
            chance = 60,
            min    = 1,
            max    = 3,
            itens  = { "cobre", "aluminio" }
        },
        C = {
            chance = 35,
            min    = 1,
            max    = 1,
            itens  = { "lockpick" }
        }
    },

    ------------------------------------------------
    -- CAPÔ
    ------------------------------------------------
    ["prop_car_bonnet_01"] = {
        A = {
            chance = 100,
            min    = 5,
            max    = 8,
            itens  = { "ferro", "ferramenta" }
        },
        B = {
            chance = 50,
            min    = 1,
            max    = 2,
            itens  = { "aluminio", "cobre" }
        },
        C = {
            chance = 20,
            min    = 1,
            max    = 1,
            itens  = { "lockpick" }
        }
    },

    ------------------------------------------------
    -- PORTA
    ------------------------------------------------
    ["prop_car_door_01"] = {
        A = {
            chance = 100,
            min    = 5,
            max    = 7,
            itens  = { "ferro", "ferramenta" }
        },
        B = {
            chance = 40,
            min    = 1,
            max    = 2,
            itens  = { "aluminio" }
        },
        C = {
            chance = 15,
            min    = 1,
            max    = 1,
            itens  = { "lockpick" }
        }
    },

    ------------------------------------------------
    -- RODA
    ------------------------------------------------
    ["prop_wheel_01"] = {
        A = {
            chance = 100,
            min    = 4,
            max    = 6,
            itens  = { "plastico", "ferro" }
        },
        B = {
            chance = 35,
            min    = 1,
            max    = 2,
            itens  = { "aluminio" }
        },
        C = {
            chance = 10,
            min    = 1,
            max    = 1,
            itens  = { "lockpick" }
        }
    }
}

------------------------------------------------
-- PAGAMENTO EM DINHEIRO SUJO POR TIPO DE PEÇA
------------------------------------------------

local Pagamento = {
    ["prop_car_engine_01"] = { min = 900,  max = 1400 },
    ["prop_car_bonnet_01"] = { min = 500,  max = 800  },
    ["prop_car_door_01"]   = { min = 400,  max = 700  },
    ["prop_wheel_01"]      = { min = 250,  max = 450  },
}

------------------------------------------------
-- HELPERS
------------------------------------------------

local function randomItem(lista)
    return lista[math.random(#lista)]
end

local function getPlayer(src)
    local player = QBX:GetPlayer(src)
    if not player then
        print(string.format("^1[big_desmanche] Jogador %s não encontrado.^0", src))
    end
    return player
end

------------------------------------------------
-- VENDER PEÇA
------------------------------------------------

RegisterNetEvent('big_desmanche:server:venderItem', function(propName)
    local src    = source
    local player = getPlayer(src)
    if not player then return end

    -- Valida o prop recebido
    local tabela = Loot[propName]
    if not tabela then
        print("^1[big_desmanche] Prop sem loot: " .. tostring(propName) .. "^0")
        return
    end

    ------------------------------------------------
    -- ROLAR CATEGORIAS
    ------------------------------------------------

    local recompensas = {}

    for _, data in pairs(tabela) do
        if math.random(100) <= data.chance then
            local item       = randomItem(data.itens)
            local quantidade = math.random(data.min, data.max)
            table.insert(recompensas, { item = item, quantidade = quantidade })
        end
    end

    ------------------------------------------------
    -- LIMITAR ENTRE 1 E 3 TIPOS
    ------------------------------------------------

    local limite = math.random(1, 3)
    while #recompensas > limite do
        table.remove(recompensas, math.random(#recompensas))
    end

    -- Garante pelo menos 1 recompensa
    if #recompensas == 0 then
        local primeiraCategoria = next(tabela)
        local data = tabela[primeiraCategoria]
        table.insert(recompensas, {
            item      = randomItem(data.itens),
            quantidade = data.min
        })
    end

    ------------------------------------------------
    -- ENTREGAR ITENS
    ------------------------------------------------

    local textoItens = ""

    for _, v in pairs(recompensas) do
        player.Functions.AddItem(v.item, v.quantidade)
        textoItens = textoItens .. v.quantidade .. "x " .. v.item .. " "
    end

    ------------------------------------------------
    -- DINHEIRO SUJO (100% GARANTIDO)
    ------------------------------------------------

    local faixa     = Pagamento[propName]
    local pagamento = faixa and math.random(faixa.min, faixa.max) or 0

    if pagamento > 0 then
        player.Functions.AddMoney('black_money', pagamento, 'desmanche-venda-peca')
    end

    ------------------------------------------------
    -- NOTIFY (client)
    ------------------------------------------------

    TriggerClientEvent('big_desmanche:client:vendaConfirmada', src, {
        itens     = textoItens,
        pagamento = pagamento
    })

    print(string.format(
        "[big_desmanche] Jogador %s vendeu '%s' | Itens: %s | Dinheiro sujo: $%d",
        src, propName, textoItens, pagamento
    ))
end)

------------------------------------------------
-- PAGAMENTO FINAL DO DESMANCHE (veículo zerado)
------------------------------------------------

RegisterNetEvent('big_desmanche:server:pagamentoFinal', function()
    local src    = source
    local player = getPlayer(src)
    if not player then return end

    local pagamento = math.random(3000, 6000)

    player.Functions.AddMoney('black_money', pagamento, 'desmanche-pagamento-final')

    TriggerClientEvent('big_desmanche:client:pagamentoFinalConfirmado', src, pagamento)

    print(string.format(
        "[big_desmanche] Jogador %s recebeu pagamento final de $%d",
        src, pagamento
    ))
end)
