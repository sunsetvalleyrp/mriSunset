local hospitals = lib.load("data.hospitals")
local adminGroups = lib.load("config").adminGroup

-- Função helper para verificar permissões de admin
local function isAdmin(source)
    for _, group in ipairs(adminGroups) do
        if IsPlayerAceAllowed(source, group) then
            return true
        end
    end
    return false
end

-- Função para salvar as configurações no arquivo
local function saveHospitalConfig(hospitalName, config)
    local filePath = GetResourcePath(GetCurrentResourceName()) .. "/data/hospitals.lua"

    -- Criar o conteúdo do arquivo
    local content = "return {\n"
    content = content .. '    ["' .. hospitalName .. '"] = {\n'

    -- Paramedic
    if config.paramedic then
        content = content .. "        paramedic = {\n"
        content = content .. '            model = "' .. config.paramedic.model .. '",\n'
        content = content .. "            pos = {\n"
        for i, pos in ipairs(config.paramedic.pos) do
            content = content .. string.format("                vec4(%.2f, %.2f, %.2f, %.2f)", pos.x, pos.y, pos.z, pos.w)
            if i < #config.paramedic.pos then
                content = content .. ","
            end
            content = content .. "\n"
        end
        content = content .. "            }\n"
        content = content .. "        },\n"
    end

    -- Boss Menu
    if config.bossmenu then
        content = content .. "        bossmenu = {\n"
        content = content .. string.format("            pos = vec3(%.2f, %.2f, %.2f),\n",
            config.bossmenu.pos.x, config.bossmenu.pos.y, config.bossmenu.pos.z)
        content = content .. "            min_grade = " .. config.bossmenu.min_grade .. "\n"
        content = content .. "        },\n"
    end

    -- Zone
    if config.zone then
        content = content .. "        zone = {\n"
        content = content .. string.format("            pos = vec3(%.2f, %.2f, %.2f),\n",
            config.zone.pos.x, config.zone.pos.y, config.zone.pos.z)
        content = content .. string.format("            size = vec3(%.1f, %.1f, %.1f),\n",
            config.zone.size.x, config.zone.size.y, config.zone.size.z)
        content = content .. "        },\n"
    end

    -- Blip
    if config.blip then
        content = content .. "        blip = {\n"
        content = content .. "            enable = " .. tostring(config.blip.enable) .. ",\n"
        content = content .. '            name = "' .. config.blip.name .. '",\n'
        content = content .. "            type = " .. config.blip.type .. ",\n"
        content = content .. "            scale = " .. config.blip.scale .. ",\n"
        content = content .. "            color = " .. config.blip.color .. ",\n"
        content = content .. string.format("            pos = vec3(%.2f, %.2f, %.2f),\n",
            config.blip.pos.x, config.blip.pos.y, config.blip.pos.z)
        content = content .. "        },\n"
    end

    -- Respawn
    if config.respawn then
        content = content .. "        respawn = {\n"
        for i, point in ipairs(config.respawn) do
            content = content .. "            {\n"
            content = content .. string.format("                bedPoint = vec4(%.2f, %.2f, %.2f, %.2f),\n",
                point.bedPoint.x, point.bedPoint.y, point.bedPoint.z, point.bedPoint.w)
            content = content .. string.format("                spawnPoint = vec4(%.2f, %.2f, %.2f, %.2f),\n",
                point.spawnPoint.x, point.spawnPoint.y, point.spawnPoint.z, point.spawnPoint.w)
            if point.isDeadRespawn then
                content = content .. "                isDeadRespawn = true,\n"
            end
            content = content .. "            }"
            if i < #config.respawn then
                content = content .. ","
            end
            content = content .. "\n"
        end
        content = content .. "        },\n"
    end

    -- Pharmacy
    if config.pharmacy then
        content = content .. "        pharmacy = {\n"
        for name, shop in pairs(config.pharmacy) do
            content = content .. '            ["' .. name .. '"] = {\n'
            content = content .. "                job = " .. tostring(shop.job) .. ",\n"
            content = content .. '                label = "' .. shop.label .. '",\n'
            content = content .. "                grade = " .. shop.grade .. ", -- works only if job true\n"
            content = content .. string.format("                pos = vec3(%.2f, %.2f, %.2f),\n",
                shop.pos.x, shop.pos.y, shop.pos.z)

            -- Blip da farmácia
            if shop.blip then
                content = content .. "                blip = {\n"
                content = content .. "                    enable = " .. tostring(shop.blip.enable) .. ",\n"
                content = content .. '                    name = "' .. shop.blip.name .. '",\n'
                content = content .. "                    type = " .. shop.blip.type .. ",\n"
                content = content .. "                    scale = " .. shop.blip.scale .. ",\n"
                content = content .. "                    color = " .. shop.blip.color .. ",\n"
                content = content .. string.format("                    pos = vec3(%.2f, %.2f, %.2f),\n",
                    shop.blip.pos.x, shop.blip.pos.y, shop.blip.pos.z)
                content = content .. "                },\n"
            end

            -- Itens
            content = content .. "                items = {\n"
            for _, item in ipairs(shop.items) do
                content = content .. string.format('                    { name = "%s",    label = "%s",   icon = "%s", price = %d }',
                    item.name, item.label, item.icon, item.price)
                if _ < #shop.items then
                    content = content .. ","
                end
                content = content .. "\n"
            end
            content = content .. "                }\n"
            content = content .. "            },\n"
        end
        content = content .. "        },\n"
    end

    -- Garage
    if config.garage then
        content = content .. "        garage = {\n"
        for name, garageConfig in pairs(config.garage) do
            content = content .. '            ["' .. name .. '"] = {\n'
            content = content .. string.format("                pedPos = vector4(%.4f, %.4f, %.4f, %.4f),\n",
                garageConfig.pedPos.x, garageConfig.pedPos.y, garageConfig.pedPos.z, garageConfig.pedPos.w)
            content = content .. '                model = "' .. garageConfig.model .. '",\n'
            content = content .. string.format("                spawn = vector4(%.2f, %.2f, %.2f, %.1f),\n",
                garageConfig.spawn.x, garageConfig.spawn.y, garageConfig.spawn.z, garageConfig.spawn.w)
            content = content .. string.format("                deposit = vector3(%.2f, %.2f, %.2f),\n",
                garageConfig.deposit.x, garageConfig.deposit.y, garageConfig.deposit.z)
            content = content .. string.format("                driverSpawnCoords = vector3(%.2f, %.2f, %.2f),\n",
                garageConfig.driverSpawnCoords.x, garageConfig.driverSpawnCoords.y, garageConfig.driverSpawnCoords.z)
            content = content .. "\n"
            content = content .. "                vehicles = {\n"
            for _, vehicle in ipairs(garageConfig.vehicles) do
                content = content .. "                    {\n"
                content = content .. '                        label = "' .. vehicle.label .. '",\n'
                content = content .. '                        spawn_code = "' .. vehicle.spawn_code .. '",\n'
                content = content .. "                        min_grade = " .. vehicle.min_grade .. ",\n"
                content = content .. "                        modifications = {} -- es. {color1 = {255, 12, 25}}\n"
                content = content .. "                    },\n"
            end
            content = content .. "                }\n"
            content = content .. "            }\n"
        end
        content = content .. "        },\n"
    end

    -- Clothes
    if config.clothes then
        content = content .. "        clothes = {\n"
        content = content .. "            enable = " .. tostring(config.clothes.enable) .. ",\n"
        content = content .. string.format("            pos = vector4(%.4f, %.4f, %.4f, %.4f),\n",
            config.clothes.pos.x, config.clothes.pos.y, config.clothes.pos.z, config.clothes.pos.w)
        content = content .. '            model = "' .. config.clothes.model .. '",\n'

        -- Roupas masculinas
        content = content .. "            male = {\n"
        for grade, outfits in pairs(config.clothes.male) do
            content = content .. "                [" .. grade .. "] = {\n"
            for name, outfit in pairs(outfits) do
                content = content .. '                    ["' .. name .. '"] = {\n'
                for key, value in pairs(outfit) do
                    content = content .. '                        ["' .. key .. '"]    = ' .. value .. ",\n"
                end
                content = content .. "                    },\n"
            end
            content = content .. "                },\n"
        end
        content = content .. "            },\n"

        -- Roupas femininas
        content = content .. "            female = {\n"
        for grade, outfits in pairs(config.clothes.female) do
            content = content .. "                [" .. grade .. "] = {\n"
            for name, outfit in pairs(outfits) do
                content = content .. '                    ["' .. name .. '"] = {\n'
                for key, value in pairs(outfit) do
                    content = content .. '                        ["' .. key .. '"]    = ' .. value .. ",\n"
                end
                content = content .. "                    },\n"
            end
            content = content .. "                },\n"
        end
        content = content .. "            },\n"
        content = content .. "        },\n"
    end

    content = content .. "    },\n"
    content = content .. "}\n"

    -- Salvar o arquivo
    local file = io.open(filePath, "w")
    if file then
        file:write(content)
        file:close()
        return true
    else
        return false
    end
end

-- Evento para salvar configuração
RegisterNetEvent("ars_ambulancejob:saveHospitalConfig", function(hospitalName, config)
    local source = source
    if not isAdmin(source) then
        return
    end

    local success = saveHospitalConfig(hospitalName, config)
    if success then
        TriggerClientEvent("ars_ambulancejob:configSaved", source, true)
    else
        TriggerClientEvent("ars_ambulancejob:configSaved", source, false)
    end
end)

-- Evento para obter configuração atual
RegisterNetEvent("ars_ambulancejob:getHospitalConfig", function(hospitalName)
    local source = source
    if not isAdmin(source) then
        return
    end

    local config = hospitals[hospitalName]
    if config then
        TriggerClientEvent("ars_ambulancejob:receiveHospitalConfig", source, hospitalName, config)
    end
end)

lib.addCommand("hospitaleditor", {
    help = "Abrir o editor de hospitais",
    restricted = adminGroups
}, function(source, args, raw)
    lib.callback.await("ars_ambulancejob:openEditor", source)
end)
