-- =============================================
-- GarageX Tuning - server.lua
-- Framework: QBOX
-- =============================================

-- =============================================
-- ITEM PRICES (server-side validation)
-- =============================================
local ItemPrices = {
    motor_s1 = 5000,
    motor_s2 = 12000,
    motor_s3 = 25000,
    motor_s4 = 300000,
    turbo_s1 = 8000,
    turbo_s2 = 18000,
    turbo_s3 = 35000,
    turbo_s4 = 120000,
    susp_s1  = 3000,
    susp_s2  = 7000,
    susp_s3  = 15000,
    susp_s4  = 60000,
    freio_s1 = 4000,
    freio_s2 = 9000,
    freio_s3 = 20000,
    freio_s4 = 80000,
    arm_s1   = 10000,
    arm_s2   = 22000,
    arm_s3   = 45000,
    arm_s4   = 150000,
    trans_s1 = 5500,
    trans_s2 = 13000,
    trans_s3 = 27000,
    trans_s4 = 110000,
}

-- Valid slots
local ValidSlots = {
    motor = true, turbo = true, suspension = true,
    freios = true, armadura = true, transmissao = true,
}

-- =============================================
-- APPLY TUNING EVENT
-- =============================================
RegisterNetEvent('garagex_tuning:applyTuning', function(data)
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local items = data.items
    if not items or #items == 0 then
        TriggerClientEvent('garagex_tuning:modsDenied', src, 'Nenhuma peça enviada.')
        return
    end

    -- =============================================
    -- VALIDATE & CALCULATE TOTAL
    -- =============================================
    local totalCost      = 0
    local validatedItems = {}

    for _, item in ipairs(items) do
        local itemId = item.id
        local slotId = item.slotId

        local serverPrice = ItemPrices[itemId]
        if not serverPrice then
            TriggerClientEvent('garagex_tuning:modsDenied', src, 'Item inválido: ' .. tostring(itemId))
            return
        end

        if not ValidSlots[slotId] then
            TriggerClientEvent('garagex_tuning:modsDenied', src, 'Slot inválido: ' .. tostring(slotId))
            return
        end

        local playerItem = Player.Functions.GetItemByName(itemId)
        if not playerItem or playerItem.amount < 1 then
            TriggerClientEvent('garagex_tuning:modsDenied', src, 'Você não possui a peça: ' .. tostring(itemId))
            return
        end

        totalCost = totalCost + serverPrice
        table.insert(validatedItems, {
            id       = itemId,
            slotId   = slotId,
            modValue = item.modValue,
            price    = serverPrice,
        })
    end

    -- =============================================
    -- CHECK BALANCE & DEDUCT PAYMENT
    -- =============================================
    local bankMoney  = Config.PaymentMethods.bank and Player.Functions.GetMoney('bank') or 0
    local cashMoney  = Config.PaymentMethods.cash and Player.Functions.GetMoney('cash') or 0
    local totalAvail = bankMoney + cashMoney

    if totalAvail < totalCost then
        TriggerClientEvent('garagex_tuning:modsDenied', src,
            string.format('Saldo insuficiente! Necessário: R$%d | Banco: R$%d | Dinheiro: R$%d',
                totalCost, bankMoney, cashMoney))
        return
    end

    local fromBank = 0
    local fromCash = 0

    if bankMoney >= totalCost then
        fromBank = totalCost
    elseif cashMoney >= totalCost then
        fromCash = totalCost
    else
        fromBank = bankMoney
        fromCash = totalCost - bankMoney
    end

    if fromBank > 0 then
        local ok = Player.Functions.RemoveMoney('bank', fromBank, 'garagex-tuning')
        if not ok then
            TriggerClientEvent('garagex_tuning:modsDenied', src, 'Falha ao debitar do banco.')
            return
        end
    end

    if fromCash > 0 then
        local ok = Player.Functions.RemoveMoney('cash', fromCash, 'garagex-tuning')
        if not ok then
            if fromBank > 0 then
                Player.Functions.AddMoney('bank', fromBank, 'garagex-tuning-refund')
            end
            TriggerClientEvent('garagex_tuning:modsDenied', src, 'Falha ao debitar dinheiro em mãos.')
            return
        end
    end

    local paymentLog = string.format('Banco: R$%d | Dinheiro: R$%d', fromBank, fromCash)

    -- =============================================
    -- REMOVE ITEMS FROM INVENTORY
    -- =============================================
    for _, item in ipairs(validatedItems) do
        Player.Functions.RemoveItem(item.id, 1)
    end

    -- =============================================
    -- APPROVE MODS ON CLIENT
    -- =============================================
    TriggerClientEvent('garagex_tuning:modsApproved', src, validatedItems)

    print(string.format('[GarageX Tuning] Player %s instalou tuning. Custo: R$%d | %s', src, totalCost, paymentLog))
end)

-- =============================================
-- RETURN ITEM TO INVENTORY
-- removeFromVehicle = true  → item estava fisicamente no carro (pré-instalado)
--                             o client.lua já remove o mod do veículo,
--                             aqui só devolvemos o item ao inventário
-- removeFromVehicle = false → item estava apenas na NUI (não instalado ainda),
--                             só devolve ao inventário
-- Em ambos os casos a lógica do servidor é a mesma:
-- devolve o item. A remoção física do mod é feita no client via
-- TriggerServerEvent → RegisterNetEvent 'garagex_tuning:removeModFromVehicle'
-- =============================================
RegisterNetEvent('garagex_tuning:returnItem', function(data)
    local src    = source
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local itemId          = data and data.itemId
    local removeFromVehicle = data and data.removeFromVehicle

    if not itemId or itemId == '' then return end

    -- Devolve o item ao inventário
    Player.Functions.AddItem(itemId, 1)
    print(string.format('[GarageX] Item %s devolvido ao jogador %s (removeFromVehicle=%s)',
        itemId, src, tostring(removeFromVehicle)))

    -- Se o item estava instalado no carro, notifica o client para remover o mod físico
    if removeFromVehicle then
        TriggerClientEvent('garagex_tuning:removeMod', src, { slotId = data.slotId })
    end
end)

-- =============================================
-- GIVE TUNING ITEMS (Admin command)
-- =============================================
RegisterCommand('darpeças', function(src, args)
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return end

    local allItems = {
        'motor_s1','motor_s2','motor_s3','motor_s4',
        'turbo_s1','turbo_s2','turbo_s3','turbo_s4',
        'susp_s1','susp_s2','susp_s3','susp_s4',
        'freio_s1','freio_s2','freio_s3','freio_s4',
        'arm_s1','arm_s2','arm_s3','arm_s4',
        'trans_s1','trans_s2','trans_s3','trans_s4',
    }

    for _, itemId in ipairs(allItems) do
        Player.Functions.AddItem(itemId, 1)
    end

    print('[GarageX] Todas as peças dadas ao jogador ' .. src)
end, true)
