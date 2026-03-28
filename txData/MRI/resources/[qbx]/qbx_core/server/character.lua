local config = require 'config.server'
local logger = require 'modules.logger'
local storage = require 'server.storage.main'
local starterItems = require 'config.shared'.starterItems

---@param license2 string
---@param license? string
local function getAllowedAmountOfCharacters(license2, license)
    return config.characters.playersNumberOfCharacters[license2] or license and config.characters.playersNumberOfCharacters[license] or config.characters.defaultNumberOfCharacters
end

---@param chars PlayerEntity[]
---@return integer
local function sumDiamondsAcrossCharacters(chars)
    local total = 0
    for i = 1, #chars do
        total += tonumber(chars[i].diamonds) or 0
    end
    return total
end

---@param license2 string
---@param license? string
---@param cost integer
---@return boolean
---@param maxSlots integer
---@param cid integer
---@return boolean
local function slotRequiresDiamondPayment(maxSlots, cid)
    local freeN = math.floor(tonumber(config.characters.freeCharacterSlots) or 1)
    if freeN < 0 then freeN = 0 end
    freeN = math.min(freeN, maxSlots)
    if cid > maxSlots then return true end
    return cid > freeN
end

---@param license2 string
---@param license? string
---@param cost integer
---@return boolean
local function tryDeductDiamondsAcrossCharacters(license2, license, cost)
    local rows = MySQL.query.await(
        'SELECT citizenid, COALESCE(diamonds, 0) AS diamonds FROM players WHERE license = ? OR license = ? ORDER BY COALESCE(diamonds, 0) DESC',
        { license2, license }
    )
    if not rows then return false end
    local remaining = cost
    for i = 1, #rows do
        if remaining <= 0 then break end
        local d = tonumber(rows[i].diamonds) or 0
        if d > 0 then
            local take = math.min(d, remaining)
            MySQL.update.await('UPDATE players SET diamonds = GREATEST(COALESCE(diamonds, 0) - ?, 0) WHERE citizenid = ?', { take, rows[i].citizenid })
            remaining -= take
        end
    end
    return remaining <= 0
end

---@param source Source
---@param requestedCid integer
---@return { allow: boolean, reason?: string, dialogType?: 'free'|'paid', cost?: integer, totalDiamonds?: integer }
lib.callback.register('qbx_core:server:gateCreateCharacter', function(source, requestedCid)
    local license2 = GetPlayerIdentifierByType(source --[[@as string]], 'license2')
    local license = GetPlayerIdentifierByType(source --[[@as string]], 'license')
    local chars = storage.fetchAllPlayerEntities(license2, license)
    local maxSlots = getAllowedAmountOfCharacters(license2, license)
    local cid = math.floor(tonumber(requestedCid) or 0)
    local cost = math.floor(tonumber(config.characters.extraCharacterDiamondCost) or 10000)

    if cid < 1 then
        return { allow = false, reason = locale('error.char_invalid_slot') }
    end

    if cid <= maxSlots then
        if chars[cid] then
            return { allow = false, reason = locale('error.char_slot_occupied') }
        end
        if not slotRequiresDiamondPayment(maxSlots, cid) then
            return { allow = true, dialogType = 'free' }
        end
        local totalDiamonds = sumDiamondsAcrossCharacters(chars)
        if totalDiamonds < cost then
            return {
                allow = false,
                reason = locale('error.char_not_enough_diamonds', lib.math.groupdigits(cost), lib.math.groupdigits(totalDiamonds)),
            }
        end
        return { allow = true, dialogType = 'paid', cost = cost, totalDiamonds = totalDiamonds }
    end

    if #chars < maxSlots then
        return { allow = false, reason = locale('error.char_invalid_slot') }
    end

    if cid ~= #chars + 1 then
        return { allow = false, reason = locale('error.char_invalid_slot') }
    end

    local totalDiamonds = sumDiamondsAcrossCharacters(chars)
    if totalDiamonds < cost then
        return {
            allow = false,
            reason = locale('error.char_not_enough_diamonds', lib.math.groupdigits(cost), lib.math.groupdigits(totalDiamonds)),
        }
    end

    return { allow = true, dialogType = 'paid', cost = cost, totalDiamonds = totalDiamonds }
end)

lib.callback.register('qbx_core:server:getExtraCharacterOffer', function(source)
    local license2 = GetPlayerIdentifierByType(source --[[@as string]], 'license2')
    local license = GetPlayerIdentifierByType(source --[[@as string]], 'license')
    local chars = storage.fetchAllPlayerEntities(license2, license)
    local maxSlots = getAllowedAmountOfCharacters(license2, license)
    local cost = math.floor(tonumber(config.characters.extraCharacterDiamondCost) or 10000)

    if #chars < maxSlots then
        return { show = false, canPay = false, cost = cost }
    end

    local totalDiamonds = sumDiamondsAcrossCharacters(chars)
    return {
        show = true,
        canPay = totalDiamonds >= cost,
        cost = cost,
        totalDiamonds = totalDiamonds,
    }
end)

---@param source Source
local function giveStarterItems(source)
    if GetResourceState('ox_inventory') == 'missing' then return end
    while not exports.ox_inventory:GetInventory(source) do
        Wait(100)
    end
    for i = 1, #starterItems do
        local item = starterItems[i]
        if item.metadata and type(item.metadata) == 'function' then
            exports.ox_inventory:AddItem(source, item.name, item.amount, item.metadata(source))
        else
            exports.ox_inventory:AddItem(source, item.name, item.amount, item.metadata)
        end
    end
end

lib.callback.register('qbx_core:server:getCharacters', function(source)
    local license2, license = GetPlayerIdentifierByType(source, 'license2'), GetPlayerIdentifierByType(source, 'license')
    return storage.fetchAllPlayerEntities(license2, license), getAllowedAmountOfCharacters(license2, license)
end)

lib.callback.register('qbx_core:server:getPreviewPedData', function(_, citizenId)
    local ped = storage.fetchPlayerSkin(citizenId)
    if not ped then return end

    return ped.skin, ped.model and joaat(ped.model)
end)

lib.callback.register('qbx_core:server:loadCharacter', function(source, citizenId)
    local success = Login(source, citizenId)
    if not success then return end

    logger.log({
        source = 'qbx_core',
        webhook = config.logging.webhook['joinleave'],
        event = 'Loaded',
        color = 'green',
        message = ('**%s** (%s |  ||%s|| | %s | %s | %s) loaded'):format(GetPlayerName(source), GetPlayerIdentifierByType(source, 'discord') or 'undefined', GetPlayerIdentifierByType(source, 'ip') or 'undefined', GetPlayerIdentifierByType(source, 'license2') or GetPlayerIdentifierByType(source, 'license') or 'undefined', citizenId, source)
    })
    lib.print.info(('%s (Citizen ID: %s ID: %s) has successfully loaded!'):format(GetPlayerName(source), citizenId, source))
end)

---@param data unknown
---@return table? newData
lib.callback.register('qbx_core:server:createCharacter', function(source, data)
    local license2 = GetPlayerIdentifierByType(source --[[@as string]], 'license2')
    local license = GetPlayerIdentifierByType(source --[[@as string]], 'license')
    local chars = storage.fetchAllPlayerEntities(license2, license)
    local maxSlots = getAllowedAmountOfCharacters(license2, license)
    local cid = math.floor(tonumber(data.cid) or 0)
    local cost = math.floor(tonumber(config.characters.extraCharacterDiamondCost) or 10000)

    if cid < 1 then return end

    local chargedDiamonds = false

    if cid <= maxSlots then
        if chars[cid] then return end
        if slotRequiresDiamondPayment(maxSlots, cid) then
            if sumDiamondsAcrossCharacters(chars) < cost then return end
            if not tryDeductDiamondsAcrossCharacters(license2, license, cost) then return end
            chargedDiamonds = true
        end
    else
        if #chars < maxSlots or cid ~= #chars + 1 then return end
        if sumDiamondsAcrossCharacters(chars) < cost then return end
        if not tryDeductDiamondsAcrossCharacters(license2, license, cost) then return end
        chargedDiamonds = true
    end

    local newData = {}
    newData.charinfo = data

    local success = Login(source, nil, newData)
    if not success then
        if chargedDiamonds and chars[1] and chars[1].citizenid then
            MySQL.update.await('UPDATE players SET diamonds = COALESCE(diamonds, 0) + ? WHERE citizenid = ?', { cost, chars[1].citizenid })
        end
        return
    end

    giveStarterItems(source)

    lib.print.info(('%s has created a character'):format(GetPlayerName(source)))
    return newData
end)

--- Deprecated. This event is kept for backward compatibility only and is no longer used internally.
RegisterNetEvent('qbx_core:server:deleteCharacter', function(citizenId)
    local src = source
    DeleteCharacter(src --[[@as number]], citizenId)
    Notify(src, locale('success.character_deleted'), 'success')
end)