local Config = lib.load("config")

function GetDiscordId(identifiers)
    for _, id in ipairs(identifiers) do
        if string.match(id, "^discord:") then
            return string.gsub(id, "discord:", "")
        end
    end
    return nil
end

function GetLicenseId(identifiers)
    for _, id in ipairs(identifiers) do
        if string.match(id, "^license:") or string.match(id, "^license2:") then
            return id
        end
    end
    return nil
end

RegisterServerEvent('ars_ambulancejob:deathlog:OnPlayerKilled', function(data)
    if Config.Debug then
        print("^5DEBUG^7: ^4Deathlog triggered^7")
    end
    local webhookUrl = Config.Discord.Settings.Webhook
    local sourcePlayer = source
    local playerName = GetPlayerName(sourcePlayer)

    -- Gimmie data!
    local message = data.message
    local weapon = data.weapon
    local street = data.street
    local coords = data.coords
    local killerServerId = data.killer
    local deathReason = data.deathReason or locale("deathlog_killed")

    local victimIds = GetPlayerIdentifiers(sourcePlayer)
    local victimDiscordId = GetDiscordId(victimIds)
    local victimLicense = GetLicenseId(victimIds)
    local victimCharacterName = playerName
    if Framework and Framework.getPlayerName then
        local charName = Framework.getPlayerName(sourcePlayer)
        if charName then
            victimCharacterName = charName
        end
    end

    local killerDiscordId
    local killerLicense
    local killerCharacterName = locale("deathlog_unknown")
    local killerName = locale("deathlog_unknown")

    if killerServerId and killerServerId > 0 then
        local killerIds = GetPlayerIdentifiers(killerServerId)
        if killerIds then
            killerDiscordId = GetDiscordId(killerIds)
            killerLicense = GetLicenseId(killerIds)
            killerName = GetPlayerName(killerServerId) or locale("deathlog_unknown")
            killerCharacterName = killerName
            if Framework and Framework.getPlayerName then
                local charName = Framework.getPlayerName(killerServerId)
                if charName then
                    killerCharacterName = charName
                end
            end
        end
    end

    if Config.Debug then
        print("^5DEBUG^7: ^4Player Name:^7", playerName)
        print("^5DEBUG^7: ^4Victim Discord ID:^7", victimDiscordId)
        print("^5DEBUG^7: ^4Killer Server ID:^7", tostring(killerServerId))
        print("^5DEBUG^7: ^4Killer Name:^7", killerName)
        print("^5DEBUG^7: ^4Killer Discord ID:^7", killerDiscordId or "N/A")
        print("^5DEBUG^7: ^4Killer License:^7", killerLicense or "N/A")
        print("^5DEBUG^7: ^8Message:^7", message)
        print("^5DEBUG^7: ^2Weapon:^7", weapon)
        print("^5DEBUG^7: ^3Street:^7", street)
        print("^5DEBUG^7: ^3Position:^7", coords)
    end

    -- Format time
    local timeString = os.date('%Y-%m-%d %H:%M:%S')

    local fields = {
        {["name"] = locale("deathlog_victim"), ["value"] = playerName, ["inline"] = true},
        {["name"] = locale("deathlog_victim_id"), ["value"] = tostring(sourcePlayer), ["inline"] = true},
        {["name"] = locale("deathlog_victim_character_name"), ["value"] = victimCharacterName, ["inline"] = true},
        {["name"] = locale("deathlog_victim_license"), ["value"] = victimLicense or locale("deathlog_na"), ["inline"] = false},
        {["name"] = locale("deathlog_victim_discord"), ["value"] = victimDiscordId and ("discord:" .. victimDiscordId) or locale("deathlog_na"), ["inline"] = false},
        {["name"] = locale("deathlog_death_reason"), ["value"] = deathReason, ["inline"] = true},
        {["name"] = locale("deathlog_time"), ["value"] = timeString, ["inline"] = true},
        {["name"] = locale("deathlog_weapon"), ["value"] = weapon or locale("deathlog_unknown"), ["inline"] = true},
    }

    if killerServerId and killerServerId > 0 then
        fields[#fields + 1] = {["name"] = locale("deathlog_killer"), ["value"] = killerName, ["inline"] = true}
        fields[#fields + 1] = {["name"] = locale("deathlog_killer_id"), ["value"] = tostring(killerServerId), ["inline"] = true}
        fields[#fields + 1] = {["name"] = locale("deathlog_killer_character_name"), ["value"] = killerCharacterName, ["inline"] = true}
        fields[#fields + 1] = {["name"] = locale("deathlog_killer_license"), ["value"] = killerLicense or locale("deathlog_na"), ["inline"] = false}
        fields[#fields + 1] = {["name"] = locale("deathlog_killer_discord"), ["value"] = killerDiscordId and ("discord:" .. killerDiscordId) or locale("deathlog_na"), ["inline"] = false}
    end

    local embed = {
        {
            ["color"] = 16711680,
            ["title"] = locale("deathlog_title"),
            ["fields"] = fields,
            ["timestamp"] = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            ["footer"] = {
                ["text"] = Config.Discord.Settings.Name,
                ["icon_url"] = Config.Discord.Settings.Images,
            },
        }
    }

    PerformHttpRequest(webhookUrl, function(err, text, headers)
        if err == 0 then
            print("^5DEBUG^7: ^7Add your ^8webhook^7 in ^8Config.lua^7!!! Error:", err)
        elseif err ~= 200 and err ~= 204 then
            print("^5DEBUG^7: ^4Error sending death log to Discord:^7 Error:", err)
        end
    end, 'POST', json.encode({embeds = embed}), {['Content-Type'] = 'application/json'})
end)
