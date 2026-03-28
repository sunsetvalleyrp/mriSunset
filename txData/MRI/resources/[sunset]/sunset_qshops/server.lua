-- ============================================================
--  sunset_qshops — Server
--  Framework : QBox (qbx_core + ox_inventory)
-- ============================================================

RegisterServerEvent("sunset_qshops:server:buyItem", function(itemName, shopId, qty)
    local src = source

    -- Sanitização
    if not itemName or not shopId then return end
    if not Config.Shops[shopId] then return end

    qty = math.floor(tonumber(qty) or 1)
    if qty < 1 then qty = 1 end
    if qty > 99 then qty = 99 end

    -- Localiza o item na loja
    local itemData = nil
    for _, v in pairs(Config.Shops[shopId].Items) do
        if v.item == itemName then
            itemData = v
            break
        end
    end

    if not itemData then
        print(("[sunset_qshops] Item '%s' não encontrado na loja '%s'."):format(itemName, shopId))
        return
    end

    local totalCost   = itemData.compra * qty
    local totalAmount = itemData.quantidade * qty

    -- --------------------------------------------------------
    --  Verifica se há espaço no inventário ANTES de cobrar
    -- --------------------------------------------------------
    local canCarry = exports.ox_inventory:CanCarryItem(src, itemData.item, totalAmount)

    if not canCarry then
        TriggerClientEvent("ox_lib:notify", src, {
            title       = Config.Shops[shopId].Nome,
            description = "Inventário cheio! Não é possível carregar mais itens.",
            type        = "error",
            duration    = 4000,
        })
        return
    end

    -- --------------------------------------------------------
    --  Verifica dinheiro
    -- --------------------------------------------------------
    local moneyCount = exports.ox_inventory:Search(src, "count", Config.MoneyItem)

    if not moneyCount or moneyCount < totalCost then
        TriggerClientEvent("ox_lib:notify", src, {
            title       = Config.Shops[shopId].Nome,
            description = ("Dinheiro insuficiente. Necessário: $%d | Carteira: $%d"):format(totalCost, moneyCount or 0),
            type        = "error",
            duration    = 4000,
        })
        return
    end

    -- --------------------------------------------------------
    --  Remove o dinheiro (valor total de uma vez)
    -- --------------------------------------------------------
    local removed = exports.ox_inventory:RemoveItem(src, Config.MoneyItem, totalCost)

    if not removed then
        TriggerClientEvent("ox_lib:notify", src, {
            title       = Config.Shops[shopId].Nome,
            description = "Erro ao processar pagamento. Tente novamente.",
            type        = "error",
            duration    = 4000,
        })
        return
    end

    -- --------------------------------------------------------
    --  Adiciona o item (espaço já validado acima)
    -- --------------------------------------------------------
    local added = exports.ox_inventory:AddItem(src, itemData.item, totalAmount)

    if not added then
        -- Estorno por segurança (não deveria chegar aqui)
        exports.ox_inventory:AddItem(src, Config.MoneyItem, totalCost)

        TriggerClientEvent("ox_lib:notify", src, {
            title       = Config.Shops[shopId].Nome,
            description = "Erro inesperado ao receber o item. Dinheiro estornado.",
            type        = "error",
            duration    = 4000,
        })
        return
    end

    -- --------------------------------------------------------
    --  Sucesso — UMA única notificação com tudo
    -- --------------------------------------------------------
    TriggerClientEvent("ox_lib:notify", src, {
        title       = Config.Shops[shopId].Nome,
        description = ("Você comprou **%dx %s** por $%d."):format(totalAmount, itemData.name, totalCost),
        type        = "success",
        duration    = 4000,
    })

    print(("[sunset_qshops] Jogador %d comprou %dx '%s' na loja '%s' por $%d."):format(
        src, totalAmount, itemData.item, shopId, totalCost
    ))
end)

print("^2[sunset_qshops]^7 Servidor carregado com sucesso.")
