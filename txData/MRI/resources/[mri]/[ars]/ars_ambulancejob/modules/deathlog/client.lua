local Config = lib.load("config")
local weapons = lib.load("data.weapons")

local Weapon_Groups = {
    [2685387236] = 'Melee',
    [-1609580060] = 'Melee',
    [4257178988] = 'Melee',
    [-37788308] = 'Melee',
    [3566412244] = 'Melee',
    [-728555052] = 'Melee',
    [416676503] = 'Pistol',
    [970310034] = 'Assault Rifle',
    [860033945] = 'Shotgun',
    [1159398588] = 'LMG',
    [3337201093] = 'SMG',
    [-957766203] = 'SMG',
    [3082541095] = 'Sniper',
    [-1212426201] = 'Sniper',
    [2725924767] = 'Heavy',
    [-1569042529] = 'Heavy',
    [690389602] = 'Stunned',
    [1548507267] = 'Throwable',
}

local function getWeaponData(weaponHash)
    if weapons[weaponHash] then
        return weapons[weaponHash]
    end

    for key, value in pairs(weapons) do
        if type(key) == "string" then
            local hash = GetHashKey(key)
            if hash == weaponHash then
                return value, key
            end
        end
    end

    return nil, nil
end

local function processPlayerDeath()
    local playerPed = cache.ped or PlayerPedId()
    local sourceOfDeath = GetPedSourceOfDeath(playerPed)
    local killerPed = GetPedKiller(playerPed)
    local coords = GetEntityCoords(playerPed)
    local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))

    local killerServerId
    local vehicleName
    local isVehicleKill = false

    if LocalPlayer.state.deathKillerServerId then
        killerServerId = LocalPlayer.state.deathKillerServerId
        if LocalPlayer.state.deathIsVehicleKill then
            isVehicleKill = true
        end
        if Config.Debug then
            print('^5Deathlog^7: Usando assassino do evento - Server ID: ' .. tostring(killerServerId) .. ', IsVehicleKill: ' .. tostring(isVehicleKill))
        end
        LocalPlayer.state:set("deathKillerServerId", nil, true)
        LocalPlayer.state:set("deathIsVehicleKill", nil, true)
    end

    if not killerServerId and killerPed and killerPed ~= 0 then
        if IsPedAPlayer(killerPed) then
            killerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(killerPed))
            if Config.Debug then
                print('^5Deathlog^7: Usando GetPedKiller() - Server ID: ' .. tostring(killerServerId))
            end
        end
    end

    if not killerServerId and sourceOfDeath and sourceOfDeath ~= 0 then
        if IsEntityAVehicle(sourceOfDeath) then
            local driver = GetPedInVehicleSeat(sourceOfDeath, -1)
            if driver and driver ~= 0 then
                if IsPedAPlayer(driver) then
                    local veh = GetVehiclePedIsIn(driver, false)
                    if veh and veh ~= 0 then
                        local modelHash = GetEntityModel(veh)
                        local modelName = GetDisplayNameFromVehicleModel(modelHash)
                        vehicleName = GetLabelText(modelName)

                        if vehicleName == "NULL" then
                            vehicleName = modelName
                        end

                        killerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(driver))
                    end
                end
                isVehicleKill = true
            end
        elseif IsEntityAPed(sourceOfDeath) and IsPedAPlayer(sourceOfDeath) then
            if not killerServerId then -- Só usar se GetPedKiller não encontrou nada
                killerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(sourceOfDeath))
            end
        end
    end

    local weaponName = locale("deathlog_unknown")
    local deathReasonShort = locale("deathlog_killed")
    local deathReason = locale("deathlog_was_killed")

    local causeOfDeath = LocalPlayer.state.deathWeaponHash
    if causeOfDeath then
        if Config.Debug then
            print('^5Deathlog^7: Usando arma do evento - Hash: ' .. tostring(causeOfDeath))
        end
        LocalPlayer.state:set("deathWeaponHash", nil, true)
    else
        causeOfDeath = GetPedCauseOfDeath(playerPed)
        if Config.Debug then
            print('^5Deathlog^7: Usando GetPedCauseOfDeath() - Hash: ' .. tostring(causeOfDeath))
        end
    end

    local weaponData, weaponKey = getWeaponData(causeOfDeath)

    if weaponData then
        deathReason = weaponData[1] or locale("deathlog_was_killed")
        deathReasonShort = weaponData[2] or locale("deathlog_killed")

        if weaponKey then
            local weaponNameKey = weaponKey:gsub("WEAPON_", ""):lower()
            local localizedName = locale(weaponNameKey)
            if localizedName and localizedName ~= weaponNameKey then
                weaponName = localizedName
            else
                weaponName = weaponNameKey:gsub("^%l", string.upper)
                if weaponNameKey == "knife" then
                    weaponName = locale("deathlog_knife")
                elseif weaponNameKey == "nightstick" then
                    weaponName = locale("deathlog_nightstick")
                elseif weaponNameKey == "pistol" then
                    weaponName = locale("deathlog_pistol")
                elseif weaponNameKey == "combatpistol" then
                    weaponName = locale("deathlog_combat_pistol")
                elseif weaponNameKey == "smg" then
                    weaponName = locale("deathlog_smg")
                elseif weaponNameKey == "assaultrifle" then
                    weaponName = locale("deathlog_assault_rifle")
                elseif weaponNameKey == "sniperrifle" then
                    weaponName = locale("deathlog_sniper_rifle")
                end
            end
        else
            if causeOfDeath == -842959696 then
                weaponName = locale("deathlog_fall_damage")
            else
                weaponName = deathReason:gsub("been ", ""):gsub("been_", "")
            end
        end
    else
        if causeOfDeath == -842959696 then
            weaponName = locale("deathlog_fall_damage")
            deathReasonShort = locale("deathlog_fell")
            deathReason = locale("deathlog_fell_to_death")
        elseif causeOfDeath == -100946242 or causeOfDeath == 148160082 then
            weaponName = locale("deathlog_animal")
            deathReasonShort = locale("deathlog_mauled")
            deathReason = locale("deathlog_mauled_by_animal")
        else
            local weaponGroup = GetWeapontypeGroup(causeOfDeath)
            local groupName = Weapon_Groups[weaponGroup] or locale("deathlog_unknown")

            local reasonMap = {
                ['Melee'] = locale("stabbed"),
                ['Pistol'] = locale("shot"),
                ['Assault Rifle'] = locale("shot"),
                ['Shotgun'] = locale("shot"),
                ['LMG'] = locale("shot"),
                ['SMG'] = locale("shot"),
                ['Sniper'] = locale("shot"),
                ['Heavy'] = locale("deathlog_exploded"),
                ['Stunned'] = locale("deathlog_stunned"),
                ['Throwable'] = locale("deathlog_exploded"),
            }

            local groupNameMap = {
                ['Melee'] = locale("deathlog_melee"),
                ['Pistol'] = locale("deathlog_pistol"),
                ['Assault Rifle'] = locale("deathlog_assault_rifle"),
                ['Shotgun'] = locale("deathlog_shotgun"),
                ['LMG'] = locale("deathlog_lmg"),
                ['SMG'] = locale("deathlog_smg"),
                ['Sniper'] = locale("deathlog_sniper_rifle"),
                ['Heavy'] = locale("deathlog_heavy"),
                ['Stunned'] = locale("deathlog_stunned"),
                ['Throwable'] = locale("deathlog_throwable"),
            }
            weaponName = groupNameMap[groupName] or groupName
            deathReasonShort = reasonMap[groupName] or locale("deathlog_killed")
            deathReason = locale("deathlog_was_killed")
        end
    end

    if isVehicleKill then
        deathReason = locale("deathlog_flattened")
        deathReasonShort = locale("deathlog_run_over")
        weaponName = vehicleName or locale("deathlog_vehicle")
    end

    local isSuicide = false
    local isNPCKill = LocalPlayer.state.deathIsNPCKill or false
    local currentServerId = cache.serverId or GetPlayerServerId(PlayerId())

    local isFallDamage = causeOfDeath == -842959696
    local isAnimal = causeOfDeath == -100946242 or causeOfDeath == 148160082

    if isNPCKill then
        LocalPlayer.state:set("deathIsNPCKill", nil, true)
    end

    if not isFallDamage and not isAnimal and not isNPCKill then
        if killerServerId and killerServerId == currentServerId then
            isSuicide = true
        elseif not killerServerId and sourceOfDeath == 0 and not isNPCKill then
            isSuicide = true
        end
    end

    if isSuicide then
        deathReason = locale("deathlog_suicide")
        deathReasonShort = locale("deathlog_suicide_reason")
        if not weaponData or weaponName == locale("deathlog_unknown") or weaponName == locale("deathlog_melee") or weaponName == locale("deathlog_pistol") or weaponName == locale("deathlog_knife") then
            weaponName = locale("deathlog_self_inflicted")
        end
        killerServerId = nil
    elseif isNPCKill then
        deathReason = locale("deathlog_killed_by_npc") or "foi morto por um NPC"
        deathReasonShort = locale("deathlog_killed_by_npc_short") or "Morto por NPC"
    end

    local victimName = GetPlayerName(PlayerId())
    local message

    if killerServerId and killerServerId > 0 and not isSuicide and not isNPCKill then
        local killerName = GetPlayerName(GetPlayerFromServerId(killerServerId)) or locale("deathlog_unknown")
        message = string.format('**%s** %s by **%s** with a %s',
            victimName,
            deathReason,
            killerName,
            weaponName
        )
    elseif isNPCKill then
        message = string.format('**%s** %s (%s)',
            victimName,
            deathReason,
            weaponName
        )
    else
        message = string.format('**%s** %s (%s)',
            victimName,
            deathReason,
            weaponName
        )
    end

    if isNPCKill or isSuicide then
        killerServerId = nil
    end

    if Config.Debug then
        print('^5Deathlog^7: Death processed - Weapon: ' .. weaponName .. ', Reason: ' .. deathReasonShort)
        print('^5Deathlog^7: Killer Server ID: ' .. tostring(killerServerId))
        print('^5Deathlog^7: Is Suicide: ' .. tostring(isSuicide))
        print('^5Deathlog^7: Is NPC Kill: ' .. tostring(isNPCKill))
        print('^5Deathlog^7: Killer Ped: ' .. tostring(killerPed))
        print('^5Deathlog^7: Source Of Death: ' .. tostring(sourceOfDeath))
    end

    TriggerServerEvent('ars_ambulancejob:deathlog:OnPlayerKilled', {
        message = message,
        weapon = weaponName,
        street = streetName,
        coords = coords,
        killer = killerServerId,
        deathReason = deathReasonShort
    })
end

exports("DeathLog", processPlayerDeath)
