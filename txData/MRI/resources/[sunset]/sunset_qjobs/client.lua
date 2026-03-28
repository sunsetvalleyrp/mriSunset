-- ============================================================
--  sunset_qjobs — Client
--  Framework : MRI_QBOX (qbx_core + ox_inventory)
-- ============================================================

local menuActive    = false
local isJobActive   = false
local activeJobId   = nil
local activeRouteId = nil
local currentStop   = 1
local activeVehicle = nil
local trailerVehicle = nil
local stopBlip      = nil
local garageBlip    = nil
local routeDistance = 0.0

-- Estado exclusivo do tipo "sedex"
local sedexPhase    = 0
local sedexLoaded   = 0
local sedexDelivered = 0
local sedexPoints   = {}
local sedexSubPhase = "driving"
local sedexBoxProp  = nil   -- pilha de caixas no depósito
local sedexCarryProp = nil  -- caixa attachada na mão ao entregar

-- ============================================================
--  TEXTO 3D
-- ============================================================
local function DrawText3D(x, y, z, text)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then return end
    local camX, camY, camZ = table.unpack(GetGameplayCamCoords())
    if #(vector3(camX, camY, camZ) - vector3(x, y, z)) > 6.0 then return end
    SetTextScale(0.0, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 220)
    SetTextEntry("STRING")
    SetTextCentre(1)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(sx, sy)
end

-- ============================================================
--  BLIPS
-- ============================================================
CreateThread(function()
    for jobId, job in pairs(Config.Jobs) do
        local blipCfg = Config.Blips[jobId]
        if blipCfg and job.Location then
            local blip = AddBlipForCoord(job.Location.x, job.Location.y, job.Location.z)
            SetBlipSprite(blip, blipCfg.sprite)
            SetBlipColour(blip, blipCfg.color)
            SetBlipScale(blip, blipCfg.scale)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(blipCfg.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- ============================================================
--  HELPERS — BLIPS DE ROTA
-- ============================================================
local function SetStopBlip(coords, label)
    if stopBlip then RemoveBlip(stopBlip) end
    stopBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(stopBlip, 545)
    SetBlipColour(stopBlip, 3)
    SetBlipScale(stopBlip, 0.50)
    SetBlipRoute(stopBlip, true)
    SetBlipRouteColour(stopBlip, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label or "Próxima Parada")
    EndTextCommandSetBlipName(stopBlip)
end

local function SetDeliveryBlip(coords)
    if stopBlip then RemoveBlip(stopBlip) end
    stopBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(stopBlip, 478)
    SetBlipColour(stopBlip, 3)
    SetBlipScale(stopBlip, 0.50)
    SetBlipAsShortRange(stopBlip, false)
    SetBlipRoute(stopBlip, true)
    SetBlipRouteColour(stopBlip, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Ponto de Entrega")
    EndTextCommandSetBlipName(stopBlip)
end

local function SetGarageBlip(coords)
    if garageBlip then RemoveBlip(garageBlip) end
    garageBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(garageBlip, 357)
    SetBlipColour(garageBlip, 2)
    SetBlipScale(garageBlip, 0.50)
    SetBlipRoute(garageBlip, true)
    SetBlipRouteColour(garageBlip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Retornar à Garagem")
    EndTextCommandSetBlipName(garageBlip)
end

local function ClearRouteBlips()
    if stopBlip   then RemoveBlip(stopBlip);   stopBlip   = nil end
    if garageBlip then RemoveBlip(garageBlip); garageBlip = nil end
end

-- ============================================================
--  HELPER — total de paradas por job/rota
-- ============================================================
local function GetTotalStops(jobId, routeId)
    local job = Config.Jobs[jobId]
    if not job then return 1 end
    if job.tipo == "sedex" then return job.NumEntregas or 10 end
    if not job.Rotas or not job.Rotas[routeId] then return 1 end
    if job.tipo == "paradas" then return #job.Rotas[routeId].paradas end
    return 1
end

-- ============================================================
--  ABRIR / FECHAR MENU
-- ============================================================
-- Pre-declarada para que OpenMenu possa chamá-la
local CloseMenu

local function BuildNUIJob(jobId)
    local job = Config.Jobs[jobId]

    -- Jobs com Niveis (sedex, truck, paradas com bloqueio)
    if job.Niveis then
        local skillName = Config.ReputacaoSkills[jobId] or "busdriver"
        local playerLevel = lib.callback.await("sunset_qjobs:server:getPlayerLevel", false, skillName) or 1

        local rotas = {}
        for _, nivel in ipairs(job.Niveis) do
            local numParadas = 1
            if job.tipo == "paradas" and job.Rotas and job.Rotas[nivel.id] then
                numParadas = #job.Rotas[nivel.id].paradas
            elseif job.NumEntregas then
                numParadas = job.NumEntregas
            end

            rotas[#rotas + 1] = {
                id          = nivel.id,
                label       = nivel.label,
                descricao   = nivel.descricao,
                payMin      = nivel.payMin or (job.Pagamento and job.Pagamento.min) or 0,
                payMax      = nivel.payMax or (job.Pagamento and job.Pagamento.max) or 0,
                xpMin       = nivel.xpMin,
                xpMax       = nivel.xpMax,
                paradas     = numParadas,
                nivelMinimo = nivel.nivelMinimo,
                bloqueado   = (playerLevel < nivel.nivelMinimo),
                cor         = "#39d353",
            }
        end

        return {
            id        = jobId,
            nome      = job.Nome,
            categoria = job.Categoria,
            descricao = job.Descricao,
            tipo      = job.tipo,
            payMin    = rotas[1] and rotas[1].payMin or 0,
            payMax    = rotas[#rotas] and rotas[#rotas].payMax or 0,
            rotas     = rotas,
        }
    end

    -- Fallback: jobs sem Niveis (legado)
    local rotas  = {}
    local minPay = math.huge
    local maxPay = 0

    for routeId, rota in pairs(job.Rotas or {}) do
        local stops = job.tipo == "paradas" and #rota.paradas or 1
        rotas[#rotas + 1] = {
            id        = routeId,
            label     = rota.label,
            descricao = rota.descricao,
            payMin    = rota.payMin,
            payMax    = rota.payMax,
            paradas   = stops,
            xp        = rota.xp,
            cor       = rota.cor,
        }
        if rota.payMin < minPay then minPay = rota.payMin end
        if rota.payMax > maxPay then maxPay = rota.payMax end
    end

    return {
        id        = jobId,
        nome      = job.Nome,
        categoria = job.Categoria,
        descricao = job.Descricao,
        tipo      = job.tipo,
        payMin    = minPay == math.huge and 0 or minPay,
        payMax    = maxPay,
        rotas     = rotas,
    }
end

local function OpenMenu(jobId)
    if menuActive then return end
    menuActive = true
    SetNuiFocus(true, true)
    TransitionToBlurred(500)

    local job = Config.Jobs[jobId]
    if not job then
        CloseMenu()
        return
    end

    local activeJobData = nil
    if isJobActive and activeJobId and Config.Jobs[activeJobId] then
        local aJob = Config.Jobs[activeJobId]
        if aJob.tipo == "sedex" then
            activeJobData = {
                jobId      = activeJobId,
                routeId    = "sedex",
                stop       = sedexDelivered,
                totalStops = aJob.NumEntregas or 10,
                tipo       = "sedex",
            }
        else
            activeJobData = {
                jobId      = activeJobId,
                routeId    = activeRouteId,
                stop       = currentStop,
                totalStops = GetTotalStops(activeJobId, activeRouteId),
                tipo       = aJob.tipo,
            }
        end
    end

    SendNUIMessage({
        action     = "showMenu",
        jobs       = { BuildNUIJob(jobId) },
        panelTitle = job.NomeCentral,
        activeJob  = activeJobData,
    })
end

CloseMenu = function()
    if not menuActive then return end
    menuActive = false
    SetNuiFocus(false, false)
    TransitionFromBlurred(500)
    SendNUIMessage({ action = "hideMenu" })
end

-- ============================================================
--  SPAWN SERVER-SIDE (comum para os dois jobs)
-- ============================================================
local function SpawnJobVehicle(jobId, routeId)
    local job = Config.Jobs[jobId]

    -- Escolhe ponto de spawn livre
    local spawnPt = job.SpawnVeiculo[1]
    for _, pt in ipairs(job.SpawnVeiculo) do
        local near = GetClosestVehicle(pt.x, pt.y, pt.z, 6.0, 0, 70)
        if not DoesEntityExist(near) then
            spawnPt = pt
            break
        end
    end

    -- Para caminhões, escolhe também o ponto do trailer
    local trailerPt = nil
    if job.tipo == "entrega" and job.TrailerSpawn then
        trailerPt = job.TrailerSpawn[1]
        for i, pt in ipairs(job.TrailerSpawn) do
            local near = GetClosestVehicle(pt.x, pt.y, pt.z, 6.0, 0, 70)
            if not DoesEntityExist(near) then
                trailerPt = pt
                break
            end
        end
    end

    local result = lib.callback.await("sunset_qjobs:server:spawnVehicle", false,
        jobId, routeId,
        { x = spawnPt.x, y = spawnPt.y, z = spawnPt.z, w = spawnPt.w },
        trailerPt and { x = trailerPt.x, y = trailerPt.y, z = trailerPt.z, w = trailerPt.w } or nil
    )

    return result
end

-- ============================================================
--  INICIAR ROTA — ÔNIBUS (tipo "paradas")
-- ============================================================
local function StartBusJob(jobId, routeId)
    local job = Config.Jobs[jobId]

    -- Busca o nível selecionado (com veiculo e paradas)
    local nivel = nil
    for _, n in ipairs(job.Niveis or {}) do
        if n.id == routeId then nivel = n; break end
    end
    if not nivel then nivel = job.Niveis and job.Niveis[1] end

    local rota = job.Rotas and job.Rotas[routeId]
    if not rota then
        lib.notify({ title = job.Nome, description = "Rota não encontrada.", type = "error" })
        return
    end

    isJobActive   = true
    activeJobId   = jobId
    activeRouteId = routeId
    currentStop   = 1
    routeDistance = 0.0

    local result = SpawnJobVehicle(jobId, routeId)
    if not result or not result.netid then
        isJobActive = false
        lib.notify({ title = job.Nome, description = "Erro ao spawnar o veículo.", type = "error" })
        return
    end

    activeVehicle = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(result.netid) then
            return NetToVeh(result.netid)
        end
    end, "Não foi possível carregar o veículo.", 5000)

    if not activeVehicle then isJobActive = false; return end

    SetVehicleOnGroundProperly(activeVehicle)
    SetVehicleHasBeenOwnedByPlayer(activeVehicle, true)
    SetVehicleNeedsToBeHotwired(activeVehicle, false)
    TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(activeVehicle))
    SetVehicleEngineOn(activeVehicle, true, true)

    -- Blip do veículo
    local vehBlip = AddBlipForEntity(activeVehicle)
    SetBlipSprite(vehBlip, 513); SetBlipColour(vehBlip, 2); SetBlipScale(vehBlip, 0.85)
    SetBlipAsShortRange(vehBlip, false)
    SetBlipRoute(vehBlip, true); SetBlipRouteColour(vehBlip, 2)
    BeginTextCommandSetBlipName("STRING"); AddTextComponentString("Seu Ônibus"); EndTextCommandSetBlipName(vehBlip)

    local rotaLabel = nivel and nivel.label or routeId
    lib.notify({
        title       = job.Nome,
        description = ("Rota **%s** iniciada! Entre no ônibus."):format(rotaLabel),
        type        = "inform", duration = 5000,
    })

    CreateThread(function()
        -- Aguarda entrar no ônibus para definir o GPS
        local boarded = false
        while isJobActive and not boarded do
            Wait(500)
            if GetVehiclePedIsIn(PlayerPedId(), false) == activeVehicle then
                boarded = true
                RemoveBlip(vehBlip)
                SetStopBlip(rota.paradas[1], ("Parada 1/%d"):format(#rota.paradas))
                lib.notify({ title = job.Nome, description = ("Boa viagem! **%d paradas** na rota."):format(#rota.paradas), type = "success", duration = 4000 })
            end
        end

        while isJobActive do
            Wait(500)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local rota_        = Config.Jobs[activeJobId].Rotas[activeRouteId]

            if DoesEntityExist(activeVehicle) then
                routeDistance = routeDistance + (GetEntitySpeed(activeVehicle) * 0.5)
            end

            if currentStop <= #rota_.paradas then
                local dist = #(playerCoords - rota_.paradas[currentStop])
                if dist <= Config.StopRadius then
                    currentStop = currentStop + 1
                    if currentStop <= #rota_.paradas then
                        SetStopBlip(rota_.paradas[currentStop], ("Parada %d/%d"):format(currentStop, #rota_.paradas))
                        lib.notify({ title = "Parada Concluída", description = ("Próxima parada: **%d/%d**"):format(currentStop, #rota_.paradas), type = "success", duration = 3000 })
                    else
                        if stopBlip then RemoveBlip(stopBlip); stopBlip = nil end
                        SetGarageBlip(Config.Jobs[activeJobId].Location)
                        lib.notify({ title = "Paradas Concluídas!", description = "Retorne à **garagem** e finalize a rota para receber.", type = "success", duration = 6000 })
                    end
                    SendNUIMessage({ action = "updateStop", stop = currentStop - 1, totalStops = #rota_.paradas, tipo = "paradas" })
                end
            else
                local garageDist  = #(playerCoords - Config.Jobs[activeJobId].Location)
                local pedOutOfVeh = GetVehiclePedIsIn(PlayerPedId(), false) == 0
                SendNUIMessage({ action = "canFinalize", value = (garageDist <= Config.GarageRadius and pedOutOfVeh) })
            end
        end
    end)
end

-- ============================================================
--  INICIAR ROTA — CAMINHÃO (tipo "truck")
-- ============================================================
local function StartTruckJob(jobId, routeId)
    local job = Config.Jobs[jobId]
    if not job then return end

    -- Encontra o nível selecionado
    local nivel = nil
    for _, n in ipairs(job.Niveis or {}) do
        if n.id == routeId then nivel = n; break end
    end
    if not nivel then nivel = job.Niveis and job.Niveis[1] end
    if not nivel then return end

    -- Seleciona ponto de entrega aleatório
    local ptIdx = math.random(1, #job.PontosEntrega)
    local entregaPt = job.PontosEntrega[ptIdx]

    isJobActive   = true
    activeJobId   = jobId
    activeRouteId = routeId
    currentStop   = 1
    routeDistance = 0.0

    -- Escolhe spawn livre para o caminhão
    local spawnPt = job.SpawnVeiculo[1]
    for _, pt in ipairs(job.SpawnVeiculo) do
        local near = GetClosestVehicle(pt.x, pt.y, pt.z, 8.0, 0, 70)
        if not DoesEntityExist(near) then spawnPt = pt; break end
    end

    -- Escolhe spawn livre para o trailer
    local trailerPt = job.TrailerSpawn[1]
    for _, pt in ipairs(job.TrailerSpawn) do
        local near = GetClosestVehicle(pt.x, pt.y, pt.z, 8.0, 0, 70)
        if not DoesEntityExist(near) then trailerPt = pt; break end
    end

    local result = lib.callback.await("sunset_qjobs:server:spawnVehicle", false,
        jobId, routeId,
        { x = spawnPt.x,   y = spawnPt.y,   z = spawnPt.z,   w = spawnPt.w   },
        { x = trailerPt.x, y = trailerPt.y, z = trailerPt.z, w = trailerPt.w }
    )

    if not result or not result.netid then
        isJobActive = false
        lib.notify({ title = job.Nome, description = "Erro ao spawnar o caminhão.", type = "error" })
        return
    end

    -- Aguarda caminhão
    activeVehicle = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(result.netid) then return NetToVeh(result.netid) end
    end, "Não foi possível carregar o caminhão.", 5000)

    if not activeVehicle then isJobActive = false; return end

    SetVehicleOnGroundProperly(activeVehicle)

    -- Aguarda e acopla trailer
    if result.trailerNetid then
        trailerVehicle = lib.waitFor(function()
            if NetworkDoesEntityExistWithNetworkId(result.trailerNetid) then return NetToVeh(result.trailerNetid) end
        end, "Não foi possível carregar o trailer.", 5000)

        if trailerVehicle then
            SetVehicleOnGroundProperly(trailerVehicle)
            Wait(500)
            AttachVehicleToTrailer(activeVehicle, trailerVehicle, 20.0)
        end
    end

    SetVehicleHasBeenOwnedByPlayer(activeVehicle, true)
    SetVehicleNeedsToBeHotwired(activeVehicle, false)
    TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(activeVehicle))
    SetVehicleEngineOn(activeVehicle, true, true)

    -- Blip do caminhão
    local vehBlip = AddBlipForEntity(activeVehicle)
    SetBlipSprite(vehBlip, 477); SetBlipColour(vehBlip, 2); SetBlipScale(vehBlip, 0.50)
    SetBlipAsShortRange(vehBlip, false)
    SetBlipRoute(vehBlip, true); SetBlipRouteColour(vehBlip, 2)
    BeginTextCommandSetBlipName("STRING"); AddTextComponentString("Seu Caminhão"); EndTextCommandSetBlipName(vehBlip)

    SetDeliveryBlip(entregaPt)

    lib.notify({
        title       = job.Nome,
        description = ("Rota **%s** iniciada! Leve o engate até o destino."):format(nivel.label),
        type        = "inform", duration = 5000,
    })
    SendNUIMessage({ action = "updateStop", stop = 1, totalStops = 2, tipo = "entrega" })

    CreateThread(function()
        local vanBlipRemoved = false
        local lastDistUpdate = GetGameTimer()

        while isJobActive do
            Wait(500)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local inVeh = GetVehiclePedIsIn(PlayerPedId(), false) == activeVehicle

            -- Remove blip do caminhão ao entrar
            if not vanBlipRemoved and inVeh then
                RemoveBlip(vehBlip)
                vanBlipRemoved = true
            end

            -- Acumula distância
            if DoesEntityExist(activeVehicle) and inVeh then
                routeDistance = routeDistance + (GetEntitySpeed(activeVehicle) * 0.5)
            end

            if currentStop == 1 then
                local dist = #(playerCoords - vector3(entregaPt.x, entregaPt.y, entregaPt.z))
                if dist <= Config.StopRadius then
                    -- Desacopla e deleta o trailer
                    if DoesEntityExist(trailerVehicle) then
                        DetachVehicleFromTrailer(activeVehicle)
                        Wait(300)
                        NetworkFadeOutEntity(trailerVehicle, true, false)
                        Wait(600)
                        DeleteVehicle(trailerVehicle)
                        trailerVehicle = nil
                    end

                    currentStop = 2
                    ClearRouteBlips()
                    SetGarageBlip(job.Location)

                    lib.notify({
                        title       = "Engate Entregue!",
                        description = "Retorne o caminhão ao **depósito** e finalize a rota para receber.",
                        type        = "success", duration = 6000,
                    })
                    SendNUIMessage({ action = "updateStop", stop = 2, totalStops = 2, tipo = "entrega" })
                end

            elseif currentStop == 2 then
                local garageDist  = #(playerCoords - job.Location)
                local pedOutOfVeh = GetVehiclePedIsIn(PlayerPedId(), false) == 0
                SendNUIMessage({ action = "canFinalize", value = (garageDist <= Config.GarageRadius and pedOutOfVeh) })
            end
        end
    end)
end

-- ============================================================
--  INICIAR TRABALHO — ENTREGADOR (tipo "sedex")
--  Fases: 2=entregando | 3=retornando  (fase 1 removida)
-- ============================================================
local function ShuffleTable(t)
    local n = #t
    for i = n, 2, -1 do
        local j = math.random(i)
        t[i], t[j] = t[j], t[i]
    end
    return t
end

local function StartSedexJob(jobId, routeId)
    local job = Config.Jobs[jobId]
    if not job then return end

    -- Encontra o nível selecionado
    local nivel = nil
    for _, n in ipairs(job.Niveis or {}) do
        if n.id == routeId then nivel = n; break end
    end
    if not nivel then nivel = job.Niveis and job.Niveis[1] end
    if not nivel then return end

    isJobActive    = true
    activeJobId    = jobId
    activeRouteId  = nivel.id   -- ex: "n1", "n2"...
    routeDistance  = 0.0
    sedexPhase     = 2           -- começa direto na fase de entrega
    sedexLoaded    = 0
    sedexDelivered = 0
    sedexSubPhase  = "driving"

    -- Lista embaralhada de pontos
    local pts = {}
    for _, pt in ipairs(job.PontosEntrega) do pts[#pts + 1] = pt end
    while #pts < job.NumEntregas do
        for _, pt in ipairs(job.PontosEntrega) do
            pts[#pts + 1] = pt
            if #pts >= job.NumEntregas then break end
        end
    end
    ShuffleTable(pts)
    sedexPoints = pts

    -- Spawn da van — escolhe ponto livre
    local spawnPt = job.SpawnVeiculo[1]
    for _, pt in ipairs(job.SpawnVeiculo) do
        local near = GetClosestVehicle(pt.x, pt.y, pt.z, 5.0, 0, 70)
        if not DoesEntityExist(near) then spawnPt = pt; break end
    end

    local result = lib.callback.await("sunset_qjobs:server:spawnVehicle", false,
        jobId, "sedex",
        { x = spawnPt.x, y = spawnPt.y, z = spawnPt.z, w = spawnPt.w },
        nil
    )

    if not result or not result.netid then
        isJobActive = false; sedexPhase = 0
        lib.notify({ title = job.Nome, description = "Erro ao spawnar a van.", type = "error" })
        return
    end

    activeVehicle = lib.waitFor(function()
        if NetworkDoesEntityExistWithNetworkId(result.netid) then return NetToVeh(result.netid) end
    end, "Não foi possível carregar a van.", 5000)

    if not activeVehicle then isJobActive = false; sedexPhase = 0; return end

    SetVehicleOnGroundProperly(activeVehicle)
    SetVehicleHasBeenOwnedByPlayer(activeVehicle, true)
    SetVehicleNeedsToBeHotwired(activeVehicle, false)
    TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(activeVehicle))

    -- Blip da van
    local vehBlip = AddBlipForEntity(activeVehicle)
    SetBlipSprite(vehBlip, 67); SetBlipColour(vehBlip, 2); SetBlipScale(vehBlip, 0.50)
    SetBlipAsShortRange(vehBlip, false)
    SetBlipRoute(vehBlip, true); SetBlipRouteColour(vehBlip, 2)
    BeginTextCommandSetBlipName("STRING"); AddTextComponentString("Sua Van"); EndTextCommandSetBlipName(vehBlip)

    -- Blip do primeiro ponto de entrega
    SetDeliveryBlip(sedexPoints[1])

    lib.notify({ title = job.Nome, description = ("Van pronta! Pegue a van e faça as **%d entregas**."):format(job.NumEntregas), type = "inform", duration = 6000 })
    SendNUIMessage({ action = "updateStop", stop = 0, totalStops = job.NumEntregas, tipo = "sedex" })

    -- ============================================================
    --  FASE 2 — ENTREGAR ENCOMENDAS
    --  driving  : vai ao ponto de entrega na van
    --  carrying : saiu da van, pega caixa da traseira, leva ao ponto
    -- ============================================================
    CreateThread(function()
        local lastDistUpdate = GetGameTimer()
        local vanBlipRemoved = false

        while isJobActive and sedexPhase == 2 do
            Wait(0)

            local now   = GetGameTimer()
            local ped   = PlayerPedId()
            local pc    = GetEntityCoords(ped)
            local inVeh = GetVehiclePedIsIn(ped, false) ~= 0

            -- Remove blip da van assim que o jogador entra
            if not vanBlipRemoved and inVeh and GetVehiclePedIsIn(ped, false) == activeVehicle then
                RemoveBlip(vehBlip)
                vanBlipRemoved = true
            end

            -- Acumula distância a cada 500ms
            if (now - lastDistUpdate) >= 500 then
                lastDistUpdate = now
                if inVeh and DoesEntityExist(activeVehicle) then
                    routeDistance = routeDistance + (GetEntitySpeed(activeVehicle) * 0.5)
                end
            end

            local currentPt = sedexPoints[sedexDelivered + 1]
            if not currentPt then
                if DoesEntityExist(sedexCarryProp) then DeleteObject(sedexCarryProp); sedexCarryProp = nil end
                ClearPedTasks(ped)
                sedexPhase = 3
                ClearRouteBlips()
                SetGarageBlip(job.Location)
                lib.notify({ title = "Entregas Concluídas!", description = "Retorne à **central** e finalize a rota para receber.", type = "success", duration = 6000 })
                SendNUIMessage({ action = "updateStop", stop = sedexDelivered, totalStops = job.NumEntregas, tipo = "sedex" })
                break
            end

            local ptVec    = vector3(currentPt.x, currentPt.y, currentPt.z)
            local distToPt = #(pc - ptVec)

            -- Saiu da van perto do destino → pega caixa da traseira
            if sedexSubPhase == "driving" then
                if not inVeh and DoesEntityExist(activeVehicle) then
                    local vanCoords = GetEntityCoords(activeVehicle)
                    if distToPt <= 50.0 and #(pc - vanCoords) <= 6.0 then
                        if IsControlJustPressed(0, Config.InteractKey) then
                            -- Animação correta: dom_trucking style
                            local animDict = "anim@heists@box_carry@"
                            RequestAnimDict(animDict)
                            while not HasAnimDictLoaded(animDict) do Wait(10) end
                            TaskPlayAnim(ped, animDict, "idle", 2.0, 2.5, -1, 49, 0, false, false, false)

                            -- Prop correto e bone correto (igual dom_trucking)
                            local boxHash = GetHashKey("prop_cs_cardbox_01")
                            RequestModel(boxHash)
                            while not HasModelLoaded(boxHash) do Wait(10) end
                            sedexCarryProp = CreateObject(boxHash, pc.x, pc.y, pc.z, true, true, true)
                            AttachEntityToEntity(
                                sedexCarryProp, ped,
                                GetPedBoneIndex(ped, 0x60F2),  -- bone igual dom_trucking
                                -0.1, 0.4, 0,
                                0, 90.0, 0,
                                true, true, false, true, 5, true
                            )
                            SetModelAsNoLongerNeeded(boxHash)

                            sedexSubPhase = "carrying"
                            lib.notify({ title = "Encomenda em mãos!", description = "Leve até o **ponto de entrega**.", type = "inform", duration = 3000 })
                        end
                    end
                end

            -- Chegou ao ponto → entrega
            elseif sedexSubPhase == "carrying" then
                -- Raio de 5.0m (mais generoso) para não frustrar o jogador
                if distToPt <= 5.0 and IsControlJustPressed(0, Config.InteractKey) then
                    if DoesEntityExist(sedexCarryProp) then DeleteObject(sedexCarryProp); sedexCarryProp = nil end
                    ClearPedTasks(ped)

                    sedexDelivered = sedexDelivered + 1
                    sedexSubPhase  = "driving"
                    lib.notify({ title = "Encomenda Entregue!", description = ("%d/%d entregas realizadas"):format(sedexDelivered, job.NumEntregas), type = "success", duration = 3000 })
                    SendNUIMessage({ action = "updateStop", stop = sedexDelivered, totalStops = job.NumEntregas, tipo = "sedex" })

                    if sedexDelivered < job.NumEntregas then
                        ClearRouteBlips()
                        SetDeliveryBlip(sedexPoints[sedexDelivered + 1])
                    end
                end
            end
        end
    end)

    -- Thread de texto 3D
    CreateThread(function()
        while isJobActive and sedexPhase == 2 do
            Wait(0)
            local ped = PlayerPedId()
            local pc  = GetEntityCoords(ped)
            local currentPt = sedexPoints[sedexDelivered + 1]
            if not currentPt then break end

            if sedexSubPhase == "driving" and GetVehiclePedIsIn(ped, false) == 0 then
                if DoesEntityExist(activeVehicle) then
                    local vanCoords = GetEntityCoords(activeVehicle)
                    if #(pc - vanCoords) <= 6.0 and #(pc - vector3(currentPt.x, currentPt.y, currentPt.z)) <= 50.0 then
                        DrawText3D(vanCoords.x, vanCoords.y, vanCoords.z + 1.5, "[E] PEGAR ENCOMENDA DA VAN")
                    end
                end
            elseif sedexSubPhase == "carrying" then
                if #(pc - vector3(currentPt.x, currentPt.y, currentPt.z)) <= 10.0 then
                    DrawText3D(currentPt.x, currentPt.y, currentPt.z + 1.0, "[E] ENTREGAR ENCOMENDA")
                end
            end
        end
    end)

    -- FASE 3 — RETORNO
    CreateThread(function()
        while isJobActive and sedexPhase ~= 3 do Wait(500) end
        while isJobActive and sedexPhase == 3 do
            Wait(500)
            local pc = GetEntityCoords(PlayerPedId())
            local pedOutOfVeh = GetVehiclePedIsIn(PlayerPedId(), false) == 0
            SendNUIMessage({ action = "canFinalize", value = (#(pc - job.Location) <= Config.GarageRadius and pedOutOfVeh) })
        end
    end)
end
local function StartJob(jobId, routeId)
    if isJobActive then return end
    local job = Config.Jobs[jobId]
    if not job then return end

    if job.tipo == "sedex" then
        StartSedexJob(jobId, routeId)
    elseif job.tipo == "truck" then
        StartTruckJob(jobId, routeId)
    else
        StartBusJob(jobId, routeId)
    end
end

-- ============================================================
--  HELPER — Remove chaves do veículo com segurança
-- ============================================================
local function RemoveVehicleKeys(vehicle)
    if not DoesEntityExist(vehicle) then return end
    local plate = GetVehicleNumberPlateText(vehicle)
    if not plate or plate == "" then return end
    -- Tenta remover chaves client-side (comum em todas as bridges)
    pcall(function() TriggerEvent('vehiclekeys:client:RemoveKeys', plate) end)
    -- Tenta remover server-side (alguns bridges suportam)
    pcall(function() TriggerServerEvent('vehiclekeys:server:RemoveKeys', plate) end)
    -- Compatibilidade com qb-vehiclekeys
    pcall(function() TriggerServerEvent('QBCore:Server:RemoveVehicleKey', plate) end)
end

-- ============================================================
--  CANCELAR ROTA
-- ============================================================
local function CancelJob()
    if not isJobActive then return end

    local vehNetid     = DoesEntityExist(activeVehicle)  and NetworkGetNetworkIdFromEntity(activeVehicle)  or nil
    local trailerNetid = DoesEntityExist(trailerVehicle) and NetworkGetNetworkIdFromEntity(trailerVehicle) or nil

    TriggerServerEvent("sunset_qjobs:server:cancelaRota", activeJobId, activeRouteId, vehNetid, trailerNetid)

    isJobActive   = false
    activeJobId   = nil
    activeRouteId = nil
    currentStop   = 1
    routeDistance = 0.0

    -- Limpa estado sedex
    sedexPhase     = 0
    sedexLoaded    = 0
    sedexDelivered = 0
    sedexSubPhase  = "driving"
    sedexPoints    = {}
    if DoesEntityExist(sedexBoxProp) then DeleteObject(sedexBoxProp) end
    if DoesEntityExist(sedexCarryProp) then DeleteObject(sedexCarryProp) end
    sedexCarryProp = nil
    ClearPedTasks(PlayerPedId())
    sedexBoxProp = nil

    ClearRouteBlips()

    if DoesEntityExist(trailerVehicle) then DeleteVehicle(trailerVehicle) end
    trailerVehicle = nil
    RemoveVehicleKeys(activeVehicle)
    if DoesEntityExist(activeVehicle) then DeleteVehicle(activeVehicle) end
    activeVehicle = nil

    lib.notify({ title = "Turno Cancelado", description = "Você abandonou o turno. Nenhum pagamento realizado.", type = "error", duration = 4000 })
end

-- ============================================================
--  NUI CALLBACKS
-- ============================================================
RegisterNUICallback("closeMenu", function(data, cb)
    CloseMenu()
    cb("ok")
end)

RegisterNUICallback("startJob", function(data, cb)
    if data and data.jobId and data.routeId then
        CloseMenu()
        Wait(600)
        StartJob(data.jobId, data.routeId)
    end
    cb("ok")
end)

RegisterNUICallback("finalizeJob", function(data, cb)
    if not isJobActive then cb("ok") return end

    local jId  = activeJobId
    local rId  = activeRouteId
    local dist = math.floor(routeDistance)

    isJobActive   = false
    activeJobId   = nil
    activeRouteId = nil
    currentStop   = 1
    routeDistance = 0.0

    -- Limpa estado sedex
    sedexPhase     = 0
    sedexLoaded    = 0
    sedexDelivered = 0
    sedexSubPhase  = "driving"
    sedexPoints    = {}
    if DoesEntityExist(sedexBoxProp) then DeleteObject(sedexBoxProp) end
    sedexBoxProp = nil

    if DoesEntityExist(sedexCarryProp) then DeleteObject(sedexCarryProp) end
    sedexCarryProp = nil
    ClearPedTasks(PlayerPedId())
    ClearRouteBlips()

    if DoesEntityExist(trailerVehicle) then
        NetworkFadeOutEntity(trailerVehicle, true, false)
        Wait(600)
        DeleteVehicle(trailerVehicle)
    end
    trailerVehicle = nil

    if DoesEntityExist(activeVehicle) then
        RemoveVehicleKeys(activeVehicle)
        NetworkFadeOutEntity(activeVehicle, true, false)
        Wait(800)
        DeleteVehicle(activeVehicle)
    end
    activeVehicle = nil

    TriggerServerEvent("sunset_qjobs:server:completaRota", jId, rId, dist)
    CloseMenu()
    cb("ok")
end)

RegisterNUICallback("cancelJob", function(data, cb)
    CloseMenu()
    CancelJob()
    cb("ok")
end)

RegisterNUICallback("getRanking", function(data, cb)
    if not data or not data.jobId then cb({}) return end
    local result = lib.callback.await("sunset_qjobs:server:getRanking", false, data.jobId)
    cb(result or {})
end)

-- ============================================================
--  EVENTO: rota concluída
-- ============================================================
RegisterNetEvent("sunset_qjobs:client:rotaConcluida", function(data)
    SendNUIMessage({ action = "jobFinished", pago = data.pago, xp = data.xp })
end)

-- ============================================================
--  PEDS NOS LOCAIS DE TRABALHO
-- ============================================================
CreateThread(function()
    for jobId, pedCfg in pairs(Config.Peds or {}) do
        local hash = GetHashKey(pedCfg.model)
        RequestModel(hash)
        while not HasModelLoaded(hash) do Wait(50) end
        local ped = CreatePed(4, hash,
            pedCfg.coords.x, pedCfg.coords.y, pedCfg.coords.z - 1.0,
            pedCfg.coords.w, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetModelAsNoLongerNeeded(hash)
    end
end)

-- ============================================================
--  THREAD DE PROXIMIDADE
-- ============================================================
CreateThread(function()
    SetNuiFocus(false, false)

    while true do
        Wait(500)

        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearestJob   = nil
        local nearestJobId = nil
        local nearestDist  = Config.MarkerDistance + 1.0

        for jobId, job in pairs(Config.Jobs) do
            if job.Location then
                local dist = #(playerCoords - job.Location)
                if dist < nearestDist then
                    nearestDist  = dist
                    nearestJob   = job
                    nearestJobId = jobId
                end
            end
        end

        if nearestJob then
            while nearestJob do
                Wait(0)
                playerCoords = GetEntityCoords(PlayerPedId())
                local dist   = #(playerCoords - nearestJob.Location)

                if dist <= Config.InteractDistance and not menuActive then
                    if IsControlJustPressed(0, Config.InteractKey) then
                        OpenMenu(nearestJobId)
                    end
                end

                if dist > Config.MarkerDistance then
                    nearestJob   = nil
                    nearestJobId = nil
                end
            end
        end
    end
end)

print("^2[sunset_qjobs]^7 Cliente carregado com sucesso.")