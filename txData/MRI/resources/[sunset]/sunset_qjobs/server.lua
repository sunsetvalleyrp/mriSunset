-- ============================================================
--  sunset_qjobs — Server
--  Framework : MRI_QBOX (qbx_core + ox_inventory)
-- ============================================================

-- ============================================================
--  BANCO DE DADOS
-- ============================================================
CreateThread(function()
    exports.oxmysql:execute([[
        CREATE TABLE IF NOT EXISTS `sunset_qjobs_stats` (
            `citizenid`        VARCHAR(50)  NOT NULL,
            `player_name`      VARCHAR(100) NOT NULL DEFAULT 'Desconhecido',
            `job_id`           VARCHAR(50)  NOT NULL,
            `routes_completed` INT UNSIGNED NOT NULL DEFAULT 0,
            `total_xp`         INT UNSIGNED NOT NULL DEFAULT 0,
            `total_earned`     INT UNSIGNED NOT NULL DEFAULT 0,
            `total_distance`   INT UNSIGNED NOT NULL DEFAULT 0,
            PRIMARY KEY (`citizenid`, `job_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]], {})
    -- Migração silenciosa para tabelas já existentes
    exports.oxmysql:execute("ALTER TABLE `sunset_qjobs_stats` ADD COLUMN IF NOT EXISTS `total_distance` INT UNSIGNED NOT NULL DEFAULT 0", {})
end)

-- ============================================================
--  HELPERS
-- ============================================================
local function GetCitizenId(src)
    local Player = exports.qbx_core:GetPlayer(src)
    return Player and Player.PlayerData.citizenid or nil
end

local function GetCharName(src)
    local Player = exports.qbx_core:GetPlayer(src)
    if not Player then return "Desconhecido" end
    local ci = Player.PlayerData.charinfo
    return ci and (ci.firstname .. " " .. ci.lastname) or "Desconhecido"
end

local function UpdateStats(src, jobId, xpGained, moneyEarned, distanceMeters)
    local cid  = GetCitizenId(src)
    if not cid then return end
    exports.oxmysql:execute([[
        INSERT INTO `sunset_qjobs_stats`
            (`citizenid`, `player_name`, `job_id`, `routes_completed`, `total_xp`, `total_earned`, `total_distance`)
        VALUES (?, ?, ?, 1, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            `player_name`      = VALUES(`player_name`),
            `routes_completed` = `routes_completed` + 1,
            `total_xp`         = `total_xp`         + VALUES(`total_xp`),
            `total_earned`     = `total_earned`      + VALUES(`total_earned`),
            `total_distance`   = `total_distance`    + VALUES(`total_distance`)
    ]], { cid, GetCharName(src), jobId, xpGained, moneyEarned, distanceMeters or 0 })
end

-- ============================================================
--  SPAWN DO VEÍCULO (+ trailer opcional)
--  Client escolhe o ponto de spawn e envia as coordenadas
-- ============================================================
lib.callback.register("sunset_qjobs:server:spawnVehicle", function(source, jobId, routeId, spawnPt, trailerPt)
    local job  = Config.Jobs[jobId]
    if not job or not spawnPt then return { netid = false } end

    local vehModel = "boxville2"
    if job.tipo == "truck" then
        vehModel = job.Veiculo or "phantom"
    elseif job.tipo == "sedex" then
        vehModel = "boxville2"
    elseif job.tipo == "paradas" and job.Niveis then
        -- Busca o veiculo no nível selecionado
        for _, n in ipairs(job.Niveis) do
            if n.id == routeId and n.veiculo then
                vehModel = n.veiculo; break
            end
        end
    elseif job.Rotas and job.Rotas[routeId] then
        vehModel = job.Rotas[routeId].veiculo or "bus"
    end

    local veh = CreateVehicle(GetHashKey(vehModel), spawnPt.x, spawnPt.y, spawnPt.z, spawnPt.w, true, true)
    while not DoesEntityExist(veh) do Wait(10) end

    local result = { netid = NetworkGetNetworkIdFromEntity(veh) }

    if job.Trailer and trailerPt then
        local trailer = CreateVehicle(GetHashKey(job.Trailer), trailerPt.x, trailerPt.y, trailerPt.z, trailerPt.w, true, true)
        while not DoesEntityExist(trailer) do Wait(10) end
        result.trailerNetid = NetworkGetNetworkIdFromEntity(trailer)
    end

    return result
end)

-- ============================================================
--  COMPLETAR ROTA
-- ============================================================
RegisterServerEvent("sunset_qjobs:server:completaRota", function(jobId, routeId, distanceMeters)
    local src = source

    if not jobId or not routeId then return end
    local job = Config.Jobs[jobId]
    if not job then return end

    local pagamento, xp
    local dist = math.floor(tonumber(distanceMeters) or 0)

    if job.tipo == "sedex" then
        local nivel = nil
        for _, n in ipairs(job.Niveis or {}) do
            if n.id == routeId then nivel = n; break end
        end
        if not nivel then
            nivel = (job.Niveis and job.Niveis[1]) or { payMin = 750, payMax = 1000, xpMin = 5, xpMax = 7 }
        end
        pagamento = math.random(nivel.payMin, nivel.payMax)
        xp        = math.random(nivel.xpMin,  nivel.xpMax)

    elseif job.tipo == "truck" then
        -- Pagamento proporcional à distância percorrida (entre min e max)
        local nivel = nil
        for _, n in ipairs(job.Niveis or {}) do
            if n.id == routeId then nivel = n; break end
        end
        if not nivel then nivel = job.Niveis and job.Niveis[1] end

        local payMin = job.Pagamento and job.Pagamento.min or 1000
        local payMax = job.Pagamento and job.Pagamento.max or 2000
        -- Normaliza distância: 0km = payMin, 100km+ = payMax
        local distKm   = math.max(0, dist / 1000)
        local fator    = math.min(1.0, distKm / 100.0)
        pagamento = math.floor(payMin + (payMax - payMin) * fator)
        xp        = nivel and math.random(nivel.xpMin, nivel.xpMax) or 20
    else
        -- paradas com Niveis
        if job.Niveis then
            local nivel = nil
            for _, n in ipairs(job.Niveis) do
                if n.id == routeId then nivel = n; break end
            end
            if not nivel then nivel = job.Niveis[1] end
            pagamento = math.random(nivel.payMin, nivel.payMax)
            xp        = math.random(nivel.xpMin,  nivel.xpMax)
        else
            -- legado: rotas sem Niveis
            local rota = job.Rotas and job.Rotas[routeId]
            if not rota then return end
            pagamento = math.random(rota.payMin, rota.payMax)
            xp        = rota.xp or 10
        end
    end

    local added = exports.ox_inventory:AddItem(src, Config.MoneyItem, pagamento)
    if not added then
        TriggerClientEvent("ox_lib:notify", src, { title = job.Nome, description = "Erro ao processar pagamento.", type = "error", duration = 5000 })
        return
    end

    local skillName = Config.ReputacaoSkills[jobId] or "motorista"
    local ok, err = pcall(function() exports["cw-rep"]:updateSkill(src, skillName, xp) end)
    if not ok then print(("[sunset_qjobs] Aviso cw-rep: %s"):format(err)) end

    UpdateStats(src, jobId, xp, pagamento, dist)

    TriggerClientEvent("ox_lib:notify", src, {
        title       = job.Nome,
        description = ("Trabalho concluído! **$%d** | **+%d XP** | **%d km** percorridos."):format(pagamento, xp, math.floor(dist / 1000)),
        type        = "success", duration = 5000,
    })

    TriggerClientEvent("sunset_qjobs:client:rotaConcluida", src, { jobId = jobId, routeId = routeId, pago = pagamento, xp = xp })

    print(("[sunset_qjobs] Jogador %d | %s/%s | $%d | +%d XP | %dm"):format(src, jobId, routeId, pagamento, xp, dist))
end)

-- ============================================================
--  CONSULTA DE NÍVEL — cw-rep
-- ============================================================
lib.callback.register("sunset_qjobs:server:getPlayerLevel", function(source, skillName)
    local src = source
    local level = 1
    local ok, result = pcall(function()
        return exports["cw-rep"]:getSkillLevel(src, skillName)
    end)
    if ok and type(result) == "number" then level = result end
    return level
end)
RegisterServerEvent("sunset_qjobs:server:cancelaRota", function(jobId, routeId, vehNetid, trailerNetid)
    local src = source
    print(("[sunset_qjobs] Jogador %d cancelou %s/%s"):format(src, routeId or "?", jobId or "?"))

    -- Deleta veículos server-side para garantir remoção para todos
    if trailerNetid then
        local trailer = NetworkGetEntityFromNetworkId(trailerNetid)
        if DoesEntityExist(trailer) then DeleteEntity(trailer) end
    end
    if vehNetid then
        local veh = NetworkGetEntityFromNetworkId(vehNetid)
        if DoesEntityExist(veh) then DeleteEntity(veh) end
    end
end)

-- ============================================================
--  RANKING — top 10 por XP
-- ============================================================
lib.callback.register("sunset_qjobs:server:getRanking", function(source, jobId)
    if not jobId then return {} end
    local rows = exports.oxmysql:executeSync([[
        SELECT player_name, total_xp, routes_completed, total_distance
        FROM sunset_qjobs_stats
        WHERE job_id = ?
        ORDER BY total_xp DESC LIMIT 10
    ]], { jobId })
    return rows or {}
end)

print("^2[sunset_qjobs]^7 Servidor carregado com sucesso.")