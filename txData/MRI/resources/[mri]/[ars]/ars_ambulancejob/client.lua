local DoesEntityExist = DoesEntityExist
local DeletePed       = DeletePed
local CreateThread    = CreateThread

player                = {}
player.injuries       = {}

local hospitals       = lib.load("data.hospitals")
local emsJobs         = lib.load("config").emsJobs
local clothingScript  = lib.load("config").clothingScript
local debug           = lib.load("config").debug
local function createZones()
    for index, hospital in pairs(hospitals) do
        local cfg = hospital

        if cfg.blip.enable then
            utils.createBlip(cfg.blip)
        end

        lib.zones.box({
            name = 'ars_hospital:' .. index,
            coords = cfg.zone.pos,
            size = cfg.zone.size,
            clothes = clothingScript and cfg.clothes,
            debug = debug,
            rotation = 0.0,
            onEnter = function(self)
                initGarage(cfg.garage, emsJobs)

                if self.clothes then
                    initClothes(self.clothes, emsJobs)
                end

                initParamedic()
            end,
            onExit = function(self)
                for k, v in pairs(peds) do
                    if DoesEntityExist(v) then
                        DeletePed(v)
                    end
                end

                unloadGarage()
            end
        })
    end
end


CreateThread(createZones)


exports('bandage', function(data, slot)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)
    local health = GetEntityHealth(playerPed)

    if health < maxHealth then
        exports.ox_inventory:useItem(data, function(data)
            if data then
                lib.progressBar({
                    duration = 5000,
                    position = 'bottom',
                    label = 'Fazendo curativo...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = false,
                        combat = true
                    },
                    anim = {
                        bone = 28422,
                        dict = 'missheistdockssetup1clipboard@idle_a',
                        clip = 'idle_a', flag = 49
                    },
                    prop = {
                        model = 'prop_ld_health_pack',
                        pos = vec3(-0.1, -0.05, -0.1),
                        rot = vec3(0.0, 0.0, 0.0)
                    },
                })
                SetEntityHealth(playerPed, math.min(maxHealth, math.floor(health + maxHealth / 16)))
                lib.notify({description = 'Você se sente melhor...'})
            end
        end)
    else
        lib.notify({type = 'error', description = 'Você não precisa de um curativo agora.'})
        return false
    end
end)

exports('analgesic', function(data, slot)
    local playerPed = PlayerPedId()
    local maxHealth = GetEntityMaxHealth(playerPed)
    local health = GetEntityHealth(playerPed)

    if health < maxHealth then
        exports.ox_inventory:useItem(data, function(data)
            if data then
                lib.progressBar({
                    duration = 4000,
                    position = 'bottom',
                    label = 'Tomando analgésico...',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                        move = false,
                        combat = true
                    },
                    anim = {
                        dict = 'mp_player_intdrink',
                        clip = 'loop_bottle', flag = 49
                    },
                    prop = {
                        model = 'prop_cs_pills',
                        pos = vec3(0.15, 0.04, 0.01),
                        rot = vec3(-90.0, 0.0, 0.0),
                        bone = 18905
                    },
                })
                SetEntityHealth(playerPed, math.min(maxHealth, math.floor(health + maxHealth / 20)))
                lib.notify({description = 'A dor diminuiu...'})
            end
        end)
    else
        lib.notify({type = 'error', description = 'Você não precisa de um analgésico agora.'})
        return false
    end
end)

-- Registra o uso do item de adrenalina com o ox_target
exports.ox_target:addGlobalPlayer({
    {
        name = 'use_adrenaline',
        label = 'Usar Adrenalina',
        icon = 'fa-solid fa-syringe',
        distance = 2.5,
        canInteract = function(entity, distance, coords, name, bone)
            local count = exports.ox_inventory:Search('count', 'adrenaline', 1)
            if count <= 0 then return end

            local targetServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
            local data = lib.callback.await('ars_ambulancejob:getData', false, targetServerId)
            local isDead = data.status.isDead

            return isDead
        end,
        onSelect = function(data)
            local targetPlayerId = GetPlayerServerId(NetworkGetEntityOwner(data.entity))

            local success = lib.progressBar({
                duration = 5000,
                label = 'Aplicando adrenalina...',
                canCancel = true,
                disable = {
                    car = true,
                    move = true,
                    combat = true
                },
                anim = { dict = 'amb@medic@standing@tendtodead@base', clip = 'base' },
            })

            if success then
                TriggerServerEvent('ars_ambulancejob:reviveWithAdrenaline', targetPlayerId)
            else
                lib.notify({ title = 'Adrenalina', description = 'Aplicação cancelada ou falhou.', type = 'error' })
            end
        end
    }
})
