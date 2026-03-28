local hospitals = lib.load("data.hospitals")
local currentHospital = "pillbox"

-- Função para salvar as configurações
function saveHospitalConfig()
    TriggerServerEvent("ars_ambulancejob:saveHospitalConfig", currentHospital, hospitals[currentHospital])
end

-- Evento para receber confirmação de salvamento
RegisterNetEvent("ars_ambulancejob:configSaved", function(success)
    if success then
        utils.showNotification("Configuração salva com sucesso!")
    else
        utils.showNotification("Erro ao salvar configuração!")
    end
end)

-- Menu principal do hospital
function openHospitalMenu()
    local options = {
        {
            title = "Paramedic",
            description = "Configurar NPCs paramédicos",
            icon = "user-md",
            onSelect = function()
                openParamedicMenu()
            end
        },
        {
            title = "Boss Menu",
            description = "Configurar menu de chefe",
            icon = "crown",
            onSelect = function()
                openBossMenu()
            end
        },
        {
            title = "Zone & Blip",
            description = "Configurar área e ícone no mapa",
            icon = "map-marker-alt",
            onSelect = function()
                openZoneBlipMenu()
            end
        },
        {
            title = "Respawn Points",
            description = "Configurar pontos de renascimento",
            icon = "bed",
            onSelect = function()
                openRespawnMenu()
            end
        },
        {
            title = "Pharmacy",
            description = "Configurar farmácia",
            icon = "pills",
            onSelect = function()
                openPharmacyMenu()
            end
        },
        {
            title = "Garage",
            description = "Configurar garagem",
            icon = "car",
            onSelect = function()
                openGarageMenu()
            end
        },
        {
            title = "Clothes",
            description = "Configurar vestiário",
            icon = "tshirt",
            onSelect = function()
                openClothesMenu()
            end
        },
        {
            title = "Salvar Configuração",
            description = "Salvar todas as alterações",
            icon = "save",
            onSelect = function()
                saveHospitalConfig()
            end
        }
    }

    lib.registerContext({
        id = 'hospital_main_menu',
        title = 'Editor de Hospital - ' .. currentHospital:upper(),
        options = options
    })

    lib.showContext('hospital_main_menu')
end

-- Menu de Paramedic
function openParamedicMenu()
    local hospital = hospitals[currentHospital]
    local paramedic = hospital.paramedic

    local options = {
        {
            title = "Modelo do NPC",
            description = paramedic.model,
            icon = "user",
            onSelect = function()
                local input = lib.inputDialog('Editar Modelo do NPC', {
                    {type = 'input', label = 'Modelo', description = 'Nome do modelo do NPC', default = paramedic.model}
                })
                if input then
                    paramedic.model = input[1]
                    utils.showNotification("Modelo atualizado!")
                end
            end
        },
        {
            title = "Posições dos NPCs",
            description = #paramedic.pos .. " posições configuradas",
            icon = "map-pin",
            onSelect = function()
                openParamedicPositionsMenu()
            end
        },
        {
            title = "Adicionar Novo Paramedic",
            description = "Adicionar um novo paramédico usando ghost placement",
            icon = "plus",
            onSelect = function()
                addNewParamedic()
            end
        },
        {
            title = "Voltar",
            description = "Voltar ao menu principal",
            icon = "arrow-left",
            onSelect = function()
                openHospitalMenu()
            end
        }
    }

    lib.registerContext({
        id = 'paramedic_menu',
        title = 'Configuração de Paramedic',
        menu = 'hospital_main_menu',
        options = options
    })

    lib.showContext('paramedic_menu')
end

-- Menu de posições do paramedic
function openParamedicPositionsMenu()
    local hospital = hospitals[currentHospital]
    local paramedic = hospital.paramedic
    local options = {}

    for i, pos in ipairs(paramedic.pos) do
        options[#options + 1] = {
            title = "Posição " .. i,
            description = string.format("X: %.2f, Y: %.2f, Z: %.2f, H: %.2f", pos.x, pos.y, pos.z, pos.w),
            icon = "map-marker",
            onSelect = function()
                openParamedicPositionOptions(i)
            end
        }
    end

    lib.registerContext({
        id = 'paramedic_positions_menu',
        title = 'Posições dos Paramedics',
        menu = 'paramedic_menu',
        options = options
    })

    lib.showContext('paramedic_positions_menu')
end

-- Menu de opções para uma posição específica do paramedic
function openParamedicPositionOptions(index)
    local hospital = hospitals[currentHospital]
    local paramedic = hospital.paramedic
    local pos = paramedic.pos[index]

    local options = {
        {
            title = "Editar Posição",
            description = "Usar ghost placement para reposicionar",
            icon = "edit",
            onSelect = function()
                editParamedicPosition(index)
            end
        },
        {
            title = "Teleportar para Posição",
            description = "Levar seu personagem para esta posição",
            icon = "location-arrow",
            onSelect = function()
                local ped = PlayerPedId()
                SetEntityCoords(ped, pos.x, pos.y, pos.z, false, false, false, false)
                SetEntityHeading(ped, pos.w)
                utils.showNotification("Teleportado para posição " .. index .. "!")
            end
        },
        {
            title = "Deletar Posição",
            description = "Remover esta posição de paramedic",
            icon = "trash",
            onSelect = function()
                table.remove(paramedic.pos, index)
                utils.showNotification("Posição " .. index .. " removida!")
                openParamedicPositionsMenu()
            end
        }
    }

    lib.registerContext({
        id = 'paramedic_position_options_menu',
        title = 'Opções da Posição ' .. index,
        menu = 'paramedic_positions_menu',
        options = options
    })

    lib.showContext('paramedic_position_options_menu')
end

-- Função para editar posição do paramedic usando ghost placement
function editParamedicPosition(index)
    local hospital = hospitals[currentHospital]
    local paramedic = hospital.paramedic

    startGhostPlacement({
        model = joaat("s_m_m_scientist_01"),
        animation = {
            dict = "amb@world_human_guard_police@male@idle_a",
            name = "idle_a"
        },
        position = "standing",
        onConfirm = function(coords, heading)
            paramedic.pos[index] = vec4(coords.x, coords.y, coords.z, heading)
            utils.showNotification("Posição " .. index .. " atualizada!")
        end,
        onCancel = function()
            utils.showNotification("Edição cancelada!")
        end
    })
end

-- Menu de Boss Menu
function openBossMenu()
    local hospital = hospitals[currentHospital]
    local bossmenu = hospital.bossmenu

    local options = {
        {
            title = "Posição",
            description = string.format("X: %.2f, Y: %.2f, Z: %.2f", bossmenu.pos.x, bossmenu.pos.y, bossmenu.pos.z),
            icon = "map-marker",
            onSelect = function()
                local input = lib.inputDialog('Editar Posição do Boss Menu', {
                    {type = 'number', label = 'X', default = bossmenu.pos.x},
                    {type = 'number', label = 'Y', default = bossmenu.pos.y},
                    {type = 'number', label = 'Z', default = bossmenu.pos.z}
                })
                if input then
                    bossmenu.pos = vec3(input[1], input[2], input[3])
                    utils.showNotification("Posição atualizada!")
                end
            end
        },
        {
            title = "Grade Mínima",
            description = "Grade mínima: " .. bossmenu.min_grade,
            icon = "shield-alt",
            onSelect = function()
                local input = lib.inputDialog('Editar Grade Mínima', {
                    {type = 'number', label = 'Grade Mínima', default = bossmenu.min_grade}
                })
                if input then
                    bossmenu.min_grade = input[1]
                    utils.showNotification("Grade mínima atualizada!")
                end
            end
        },
        {
            title = "Voltar",
            description = "Voltar ao menu principal",
            icon = "arrow-left",
            onSelect = function()
                openHospitalMenu()
            end
        }
    }

    lib.registerContext({
        id = 'bossmenu_menu',
        title = 'Configuração do Boss Menu',
        menu = 'hospital_main_menu',
        options = options
    })

    lib.showContext('bossmenu_menu')
end

-- Menu de Zone & Blip
function openZoneBlipMenu()
    local hospital = hospitals[currentHospital]
    local zone = hospital.zone
    local blip = hospital.blip

    local options = {
        {
            title = "Posição da Zona",
            description = string.format("X: %.2f, Y: %.2f, Z: %.2f", zone.pos.x, zone.pos.y, zone.pos.z),
            icon = "map-marker",
            onSelect = function()
                local input = lib.inputDialog('Editar Posição da Zona', {
                    {type = 'number', label = 'X', default = zone.pos.x},
                    {type = 'number', label = 'Y', default = zone.pos.y},
                    {type = 'number', label = 'Z', default = zone.pos.z}
                })
                if input then
                    zone.pos = vec3(input[1], input[2], input[3])
                    utils.showNotification("Posição da zona atualizada!")
                end
            end
        },
        {
            title = "Definir Posição da Zona (Localização Atual)",
            description = "Usar a localização atual do player",
            icon = "crosshairs",
            onSelect = function()
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                zone.pos = vec3(coords.x, coords.y, coords.z)
                utils.showNotification(string.format("Posição da zona definida para: X: %.2f, Y: %.2f, Z: %.2f", coords.x, coords.y, coords.z))
            end
        },
        {
            title = "Tamanho da Zona",
            description = string.format("X: %.1f, Y: %.1f, Z: %.1f", zone.size.x, zone.size.y, zone.size.z),
            icon = "expand",
            onSelect = function()
                local input = lib.inputDialog('Editar Tamanho da Zona', {
                    {type = 'number', label = 'X', default = zone.size.x},
                    {type = 'number', label = 'Y', default = zone.size.y},
                    {type = 'number', label = 'Z', default = zone.size.z}
                })
                if input then
                    zone.size = vec3(input[1], input[2], input[3])
                    utils.showNotification("Tamanho da zona atualizado!")
                end
            end
        },
        {
            title = "Configuração do Blip",
            description = blip.name .. " (Tipo: " .. blip.type .. ")",
            icon = "map",
            onSelect = function()
                openBlipConfigMenu()
            end
        },
        {
            title = "Voltar",
            description = "Voltar ao menu principal",
            icon = "arrow-left",
            onSelect = function()
                openHospitalMenu()
            end
        }
    }

    lib.registerContext({
        id = 'zone_blip_menu',
        title = 'Configuração de Zone & Blip',
        menu = 'hospital_main_menu',
        options = options
    })

    lib.showContext('zone_blip_menu')
end

-- Menu de configuração do Blip
function openBlipConfigMenu()
    local hospital = hospitals[currentHospital]
    local blip = hospital.blip

    local options = {
        {
            title = "Nome",
            description = blip.name,
            icon = "tag",
            onSelect = function()
                local input = lib.inputDialog('Editar Nome do Blip', {
                    {type = 'input', label = 'Nome', default = blip.name}
                })
                if input then
                    blip.name = input[1]
                    utils.showNotification("Nome atualizado!")
                end
            end
        },
        {
            title = "Tipo",
            description = "Tipo: " .. blip.type,
            icon = "map-pin",
            onSelect = function()
                local input = lib.inputDialog('Editar Tipo do Blip', {
                    {type = 'number', label = 'Tipo', default = blip.type}
                })
                if input then
                    blip.type = input[1]
                    utils.showNotification("Tipo atualizado!")
                end
            end
        },
        {
            title = "Escala",
            description = "Escala: " .. blip.scale,
            icon = "expand-arrows-alt",
            onSelect = function()
                local input = lib.inputDialog('Editar Escala do Blip', {
                    {type = 'number', label = 'Escala', default = blip.scale, step = 0.1}
                })
                if input then
                    blip.scale = input[1]
                    utils.showNotification("Escala atualizada!")
                end
            end
        },
        {
            title = "Cor",
            description = "Cor: " .. blip.color,
            icon = "palette",
            onSelect = function()
                local input = lib.inputDialog('Editar Cor do Blip', {
                    {type = 'number', label = 'Cor', default = blip.color}
                })
                if input then
                    blip.color = input[1]
                    utils.showNotification("Cor atualizada!")
                end
            end
        },
        {
            title = "Posição",
            description = string.format("X: %.2f, Y: %.2f, Z: %.2f", blip.pos.x, blip.pos.y, blip.pos.z),
            icon = "map-marker",
            onSelect = function()
                local input = lib.inputDialog('Editar Posição do Blip', {
                    {type = 'number', label = 'X', default = blip.pos.x},
                    {type = 'number', label = 'Y', default = blip.pos.y},
                    {type = 'number', label = 'Z', default = blip.pos.z}
                })
                if input then
                    blip.pos = vec3(input[1], input[2], input[3])
                    utils.showNotification("Posição atualizada!")
                end
            end
        },
        {
            title = "Voltar",
            description = "Voltar ao menu de zone & blip",
            icon = "arrow-left",
            onSelect = function()
                openZoneBlipMenu()
            end
        }
    }

    lib.registerContext({
        id = 'blip_config_menu',
        title = 'Configuração do Blip',
        menu = 'zone_blip_menu',
        options = options
    })

    lib.showContext('blip_config_menu')
end

-- Menu de Pharmacy
function openPharmacyMenu()
    local hospital = hospitals[currentHospital]
    local pharmacy = hospital.pharmacy
    local options = {}

    for name, shop in pairs(pharmacy) do
        options[#options + 1] = {
            title = shop.label,
            description = string.format("Itens: %d | Grade: %d | Job: %s",
                #shop.items, shop.grade, shop.job and "Sim" or "Não"),
            icon = "pills",
            onSelect = function()
                openPharmacyShopMenu(name)
            end
        }
    end

    options[#options + 1] = {
        title = "Voltar",
        description = "Voltar ao menu principal",
        icon = "arrow-left",
        onSelect = function()
            openHospitalMenu()
        end
    }

    lib.registerContext({
        id = 'pharmacy_menu',
        title = 'Configuração de Pharmacy',
        menu = 'hospital_main_menu',
        options = options
    })

    lib.showContext('pharmacy_menu')
end

-- Menu de farmácia específica
function openPharmacyShopMenu(shopName)
    local hospital = hospitals[currentHospital]
    local shop = hospital.pharmacy[shopName]

    local options = {
        {
            title = "Label",
            description = shop.label,
            icon = "tag",
            onSelect = function()
                local input = lib.inputDialog('Editar Label', {
                    {type = 'input', label = 'Label', default = shop.label}
                })
                if input then
                    shop.label = input[1]
                    utils.showNotification("Label atualizado!")
                end
            end
        },
        {
            title = "Apenas Job",
            description = shop.job and "Sim" or "Não",
            icon = "briefcase",
            onSelect = function()
                shop.job = not shop.job
                utils.showNotification("Apenas job " .. (shop.job and "ativado" or "desativado") .. "!")
            end
        },
        {
            title = "Grade Mínima",
            description = "Grade mínima: " .. shop.grade,
            icon = "shield-alt",
            onSelect = function()
                local input = lib.inputDialog('Editar Grade Mínima', {
                    {type = 'number', label = 'Grade Mínima', default = shop.grade}
                })
                if input then
                    shop.grade = input[1]
                    utils.showNotification("Grade mínima atualizada!")
                end
            end
        },
        {
            title = "Posição",
            description = string.format("X: %.2f, Y: %.2f, Z: %.2f",
                shop.pos.x, shop.pos.y, shop.pos.z),
            icon = "map-marker",
            onSelect = function()
                local input = lib.inputDialog('Editar Posição', {
                    {type = 'number', label = 'X', default = shop.pos.x},
                    {type = 'number', label = 'Y', default = shop.pos.y},
                    {type = 'number', label = 'Z', default = shop.pos.z}
                })
                if input then
                    shop.pos = vec3(input[1], input[2], input[3])
                    utils.showNotification("Posição atualizada!")
                end
            end
        },
        {
            title = "Voltar",
            description = "Voltar às farmácias",
            icon = "arrow-left",
            onSelect = function()
                openPharmacyMenu()
            end
        }
    }

    lib.registerContext({
        id = 'pharmacy_shop_menu',
        title = 'Farmácia: ' .. shop.label,
        menu = 'pharmacy_menu',
        options = options
    })

    lib.showContext('pharmacy_shop_menu')
end

-- Menu de Garage
function openGarageMenu()
    local hospital = hospitals[currentHospital]
    local garage = hospital.garage
    local options = {}

    for name, config in pairs(garage) do
        options[#options + 1] = {
            title = name,
            description = string.format("Veículos: %d | NPC: %s",
                #config.vehicles, config.model),
            icon = "car",
            onSelect = function()
                openGarageConfigMenu(name)
            end
        }
    end

    options[#options + 1] = {
        title = "Voltar",
        description = "Voltar ao menu principal",
        icon = "arrow-left",
        onSelect = function()
            openHospitalMenu()
        end
    }

    lib.registerContext({
        id = 'garage_menu',
        title = 'Configuração de Garage',
        menu = 'hospital_main_menu',
        options = options
    })

    lib.showContext('garage_menu')
end

-- Menu de configuração de garagem
function openGarageConfigMenu(garageName)
    local hospital = hospitals[currentHospital]
    local garage = hospital.garage[garageName]

    local options = {
        {
            title = "Modelo do NPC",
            description = garage.model,
            icon = "user",
            onSelect = function()
                local input = lib.inputDialog('Editar Modelo do NPC', {
                    {type = 'input', label = 'Modelo', default = garage.model}
                })
                if input then
                    garage.model = input[1]
                    utils.showNotification("Modelo atualizado!")
                end
            end
        },
        {
            title = "Posição do NPC",
            description = string.format("X: %.2f, Y: %.2f, Z: %.2f, H: %.2f",
                garage.pedPos.x, garage.pedPos.y, garage.pedPos.z, garage.pedPos.w),
            icon = "map-marker",
            onSelect = function()
                local input = lib.inputDialog('Editar Posição do NPC', {
                    {type = 'number', label = 'X', default = garage.pedPos.x},
                    {type = 'number', label = 'Y', default = garage.pedPos.y},
                    {type = 'number', label = 'Z', default = garage.pedPos.z},
                    {type = 'number', label = 'Heading', default = garage.pedPos.w}
                })
                if input then
                    garage.pedPos = vec4(input[1], input[2], input[3], input[4])
                    utils.showNotification("Posição do NPC atualizada!")
                end
            end
        },
        {
            title = "Ponto de Spawn",
            description = string.format("X: %.2f, Y: %.2f, Z: %.2f, H: %.2f",
                garage.spawn.x, garage.spawn.y, garage.spawn.z, garage.spawn.w),
            icon = "car",
            onSelect = function()
                local input = lib.inputDialog('Editar Ponto de Spawn', {
                    {type = 'number', label = 'X', default = garage.spawn.x},
                    {type = 'number', label = 'Y', default = garage.spawn.y},
                    {type = 'number', label = 'Z', default = garage.spawn.z},
                    {type = 'number', label = 'Heading', default = garage.spawn.w}
                })
                if input then
                    garage.spawn = vec4(input[1], input[2], input[3], input[4])
                    utils.showNotification("Ponto de spawn atualizado!")
                end
            end
        },
        {
            title = "Voltar",
            description = "Voltar às garagens",
            icon = "arrow-left",
            onSelect = function()
                openGarageMenu()
            end
        }
    }

    lib.registerContext({
        id = 'garage_config_menu',
        title = 'Garagem: ' .. garageName,
        menu = 'garage_menu',
        options = options
    })

    lib.showContext('garage_config_menu')
end

-- Menu de Clothes
function openClothesMenu()
    local hospital = hospitals[currentHospital]
    local clothes = hospital.clothes

    local options = {
        {
            title = "Ativado",
            description = clothes.enable and "Sim" or "Não",
            icon = "toggle-on",
            onSelect = function()
                clothes.enable = not clothes.enable
                utils.showNotification("Vestiário " .. (clothes.enable and "ativado" or "desativado") .. "!")
            end
        },
        {
            title = "Modelo do NPC",
            description = clothes.model,
            icon = "user",
            onSelect = function()
                local input = lib.inputDialog('Editar Modelo do NPC', {
                    {type = 'input', label = 'Modelo', default = clothes.model}
                })
                if input then
                    clothes.model = input[1]
                    utils.showNotification("Modelo atualizado!")
                end
            end
        },
        {
            title = "Posição",
            description = string.format("X: %.2f, Y: %.2f, Z: %.2f, H: %.2f",
                clothes.pos.x, clothes.pos.y, clothes.pos.z, clothes.pos.w),
            icon = "map-marker",
            onSelect = function()
                local input = lib.inputDialog('Editar Posição', {
                    {type = 'number', label = 'X', default = clothes.pos.x},
                    {type = 'number', label = 'Y', default = clothes.pos.y},
                    {type = 'number', label = 'Z', default = clothes.pos.z},
                    {type = 'number', label = 'Heading', default = clothes.pos.w}
                })
                if input then
                    clothes.pos = vec4(input[1], input[2], input[3], input[4])
                    utils.showNotification("Posição atualizada!")
                end
            end
        },
        {
            title = "Voltar",
            description = "Voltar ao menu principal",
            icon = "arrow-left",
            onSelect = function()
                openHospitalMenu()
            end
        }
    }

    lib.registerContext({
        id = 'clothes_menu',
        title = 'Configuração de Clothes',
        menu = 'hospital_main_menu',
        options = options
    })

    lib.showContext('clothes_menu')
end

-- Função de ghost placement reutilizável
function startGhostPlacement(options)
    local pedModel = options.pedModel or `a_m_m_business_01`
    local animDict = options.animDict or "amb@world_human_sunbathe@male@back@base"
    local animName = options.animName or "base"
    local ghostPed = nil
    local heading = GetEntityHeading(PlayerPedId())
    local placing = true
    local alpha = options.alpha or 128
    local lastCoords = nil
    local canPlace = false
    local onConfirm = options.onConfirm
    local onCancel = options.onCancel
    local title = options.title or "Ghost Placement"
    local isStanding = options.isStanding or false

    -- Carregar modelo e animação
    RequestModel(pedModel)
    while not HasModelLoaded(pedModel) do
        Wait(10)
    end

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Wait(10)
    end

    -- Criar ped fantasma invisível inicialmente
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    ghostPed = CreatePed(4, pedModel, playerCoords.x, playerCoords.y, playerCoords.z, heading, false, true)

    if not DoesEntityExist(ghostPed) then
        utils.showNotification("Erro ao criar ped fantasma!")
        return
    end

    SetEntityAlpha(ghostPed, 0, false) -- Invisível inicialmente
    SetEntityCollision(ghostPed, false, false)
    SetEntityInvincible(ghostPed, true)
    SetBlockingOfNonTemporaryEvents(ghostPed, true)
    FreezeEntityPosition(ghostPed, true)
    SetEntityHeading(ghostPed, heading) -- Aplicar heading inicial

    if isStanding then
        TaskStandStill(ghostPed, -1)
    else
        TaskPlayAnim(ghostPed, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
    end

    utils.showNotification("Ped fantasma criado! " .. title)

    -- Mostrar instruções iniciais
    lib.showTextUI('[E] Confirmar | [Backspace] Cancelar | [Scroll] Girar | Mova o mouse para posicionar', {
        position = "top-center"
    })

    -- Loop de posicionamento
    CreateThread(function()
        while placing do
            -- Raycast do centro da tela para o chão usando a função correta
            local hit, entityHit, endCoords, surfaceNormal, materialHash = lib.raycast.fromCamera(511, 4, 50.0)
            canPlace = false

            -- Debug: mostrar coordenadas do raycast
            if hit and endCoords then
                utils.debug("Raycast hit: " .. tostring(endCoords.x) .. ", " .. tostring(endCoords.y) .. ", " .. tostring(endCoords.z))
            else
                utils.debug("Raycast não encontrou nada ou retorno inválido")
            end

            if hit and endCoords then
                lastCoords = endCoords
                -- Ajuste para evitar clipping no solo
                SetEntityCoordsNoOffset(ghostPed, endCoords.x, endCoords.y, endCoords.z + 1.0, false, false, false)
                SetEntityHeading(ghostPed, heading) -- Manter heading atualizado
                SetEntityAlpha(ghostPed, alpha, false) -- Visível quando posição válida
                canPlace = true

                -- Mudar animação baseada na fase
                if isStanding then
                    -- Em pé
                    ClearPedTasks(ghostPed)
                    TaskStandStill(ghostPed, -1)
                else
                    -- Deitado
                    TaskPlayAnim(ghostPed, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
                end

                                -- Atualizar UI com status positivo
                lib.showTextUI(string.format('📋 CONTROLES:  \nE - Confirmar  \nBackspace - Cancelar  \nScroll - Girar  \nÂngulo: %.0f°', heading), {
                    position = "right-center",
                    style = {
                        borderRadius = '12px',
                        backgroundColor = '#059669',
                        color = 'white',
                        padding = '15px 20px',
                        boxShadow = '0 4px 12px rgba(5, 150, 105, 0.3)',
                        border = '2px solid #a7f3d0',
                        fontSize = '13px',
                        fontWeight = 'bold',
                        lineHeight = '1.4'
                    }
                })
            else
                -- Se não pode colocar, deixa o ped invisível mas mantém o heading
                SetEntityAlpha(ghostPed, 0, false)
                SetEntityHeading(ghostPed, heading) -- Manter heading mesmo invisível

                -- Atualizar UI com status negativo
                lib.showTextUI('📋 CONTROLES:  \nE - Confirmar  \nBackspace - Cancelar  \nScroll - Girar  \n\n✗ Posição inválida - Mova o mouse para encontrar uma superfície', {
                    position = "right-center",
                    style = {
                        borderRadius = '12px',
                        backgroundColor = '#dc2626',
                        color = 'white',
                        padding = '15px 20px',
                        boxShadow = '0 4px 12px rgba(220, 38, 38, 0.3)',
                        border = '2px solid #fecaca',
                        fontSize = '13px',
                        fontWeight = 'bold',
                        lineHeight = '1.4'
                    }
                })
            end

            -- Girar com scroll do mouse
            if IsControlJustPressed(0, 14) then -- scroll up
                heading = (heading + 5) % 360
                SetEntityHeading(ghostPed, heading)
            elseif IsControlJustPressed(0, 15) then -- scroll down
                heading = (heading - 5) % 360
                SetEntityHeading(ghostPed, heading)
            end

            -- Confirmar com E
            if IsControlJustPressed(0, 38) and canPlace and lastCoords then
                placing = false
                DeleteEntity(ghostPed)
                lib.hideTextUI()
                -- Descarregar animações e modelos
                RemoveAnimDict(animDict)
                SetModelAsNoLongerNeeded(pedModel)

                if onConfirm then
                    onConfirm(vec4(lastCoords.x, lastCoords.y, lastCoords.z, heading))
                end
                return
            end

            -- Cancelar com Backspace
            if IsControlJustPressed(0, 177) then
                placing = false
                DeleteEntity(ghostPed)
                lib.hideTextUI()
                -- Descarregar animações e modelos
                RemoveAnimDict(animDict)
                SetModelAsNoLongerNeeded(pedModel)

                if onCancel then
                    onCancel()
                else
                    utils.showNotification("Adição cancelada.")
                end
                return
            end

            Wait(0)
        end
    end)
end

-- Função específica para adicionar paramédico
function addNewParamedic()
    local hospital = hospitals[currentHospital]
    local paramedic = hospital.paramedic

    startGhostPlacement({
        pedModel = `s_m_m_doctor_01`, -- Modelo de médico
        isStanding = true, -- Em pé
        title = "Adicionar novo paramédico",
        onConfirm = function(pos)
            paramedic.pos[#paramedic.pos + 1] = pos
            utils.showNotification("Novo paramédico adicionado!")
            openParamedicPositionsMenu()
        end,
        onCancel = function()
            utils.showNotification("Adição de paramédico cancelada.")
            openParamedicPositionsMenu()
        end
    })
end

-- Função específica para adicionar ponto de respawn
function startGhostPlacementForBed()
    local hospital = hospitals[currentHospital]
    local bedPoint = nil
    local spawnPoint = nil
    local currentPhase = "bed" -- "bed" ou "spawn"

    local function onBedConfirm(pos)
        bedPoint = pos
        currentPhase = "spawn"
        utils.showNotification("Cama definida! Agora posicione o ponto de spawn.")

        -- Iniciar segunda fase para spawn
        startGhostPlacement({
            pedModel = `a_m_m_business_01`,
            isStanding = true,
            title = "Posicionar spawn point",
            onConfirm = function(spawnPos)
                spawnPoint = spawnPos
                -- Salvar ponto completo
                hospital.respawn[#hospital.respawn + 1] = {
                    bedPoint = bedPoint,
                    spawnPoint = spawnPoint,
                    isDeadRespawn = false
                }
                utils.showNotification("Novo ponto de respawn adicionado!")
                openRespawnMenu()
            end,
            onCancel = function()
                utils.showNotification("Adição de ponto cancelada.")
                openRespawnMenu()
            end
        })
    end

    startGhostPlacement({
        pedModel = `a_m_m_business_01`,
        isStanding = false, -- Deitado para cama
        title = "Posicionar cama",
        onConfirm = onBedConfirm,
        onCancel = function()
            utils.showNotification("Adição de ponto cancelada.")
            openRespawnMenu()
        end
    })
end

-- Substituir a opção de adicionar novo ponto no openRespawnMenu
function openRespawnMenu()
    local hospital = hospitals[currentHospital]
    local respawn = hospital.respawn
    local options = {}

    for i, point in ipairs(respawn) do
        options[#options + 1] = {
            title = "Ponto de Respawn " .. i,
            description = string.format("Cama: %.2f, %.2f, %.2f | Spawn: %.2f, %.2f, %.2f",
                point.bedPoint.x, point.bedPoint.y, point.bedPoint.z,
                point.spawnPoint.x, point.spawnPoint.y, point.spawnPoint.z),
            icon = "bed",
            onSelect = function()
                openRespawnPointMenu(i)
            end
        }
    end

    options[#options + 1] = {
        title = "Adicionar Novo Ponto",
        description = "Adicionar um novo ponto de respawn (visual)",
        icon = "plus",
        onSelect = function()
            startGhostPlacementForBed()
        end
    }

    options[#options + 1] = {
        title = "Voltar",
        description = "Voltar ao menu principal",
        icon = "arrow-left",
        onSelect = function()
            openHospitalMenu()
        end
    }

    lib.registerContext({
        id = 'respawn_menu',
        title = 'Pontos de Respawn',
        menu = 'hospital_main_menu',
        options = options
    })

    lib.showContext('respawn_menu')
end

function openRespawnPointMenu(index)
    local hospital = hospitals[currentHospital]
    local point = hospital.respawn[index]

    local options = {
        {
            title = "Posição da Cama",
            description = string.format("X: %.2f, Y: %.2f, Z: %.2f, H: %.2f",
                point.bedPoint.x, point.bedPoint.y, point.bedPoint.z, point.bedPoint.w),
            icon = "bed",
            onSelect = function()
                local input = lib.inputDialog('Editar Posição da Cama', {
                    {type = 'number', label = 'X', default = point.bedPoint.x},
                    {type = 'number', label = 'Y', default = point.bedPoint.y},
                    {type = 'number', label = 'Z', default = point.bedPoint.z},
                    {type = 'number', label = 'Heading', default = point.bedPoint.w}
                })
                if input then
                    point.bedPoint = vec4(input[1], input[2], input[3], input[4])
                    utils.showNotification("Posição da cama atualizada!")
                end
            end
        },
        {
            title = "Teleportar para a cama",
            description = "Levar seu personagem para a posição da cama",
            icon = "location-arrow",
            onSelect = function()
                local ped = PlayerPedId()
                SetEntityCoords(ped, point.bedPoint.x, point.bedPoint.y, point.bedPoint.z, false, false, false, false)
                SetEntityHeading(ped, point.bedPoint.w)
                utils.showNotification("Teleportado para a cama!")
            end
        },
        {
            title = "Posição do Spawn",
            description = string.format("X: %.2f, Y: %.2f, Z: %.2f, H: %.2f",
                point.spawnPoint.x, point.spawnPoint.y, point.spawnPoint.z, point.spawnPoint.w),
            icon = "map-marker",
            onSelect = function()
                local input = lib.inputDialog('Editar Posição do Spawn', {
                    {type = 'number', label = 'X', default = point.spawnPoint.x},
                    {type = 'number', label = 'Y', default = point.spawnPoint.y},
                    {type = 'number', label = 'Z', default = point.spawnPoint.z},
                    {type = 'number', label = 'Heading', default = point.spawnPoint.w}
                })
                if input then
                    point.spawnPoint = vec4(input[1], input[2], input[3], input[4])
                    utils.showNotification("Posição do spawn atualizada!")
                end
            end
        },
        {
            title = "Respawn de Morte",
            description = point.isDeadRespawn and "Ativado" or "Desativado",
            icon = "skull",
            onSelect = function()
                point.isDeadRespawn = not point.isDeadRespawn
                utils.showNotification("Respawn de morte " .. (point.isDeadRespawn and "ativado" or "desativado") .. "!")
            end
        },
        {
            title = "Remover Ponto",
            description = "Remover este ponto de respawn",
            icon = "trash",
            onSelect = function()
                table.remove(hospital.respawn, index)
                utils.showNotification("Ponto de respawn removido!")
                openRespawnMenu()
            end
        },
        {
            title = "Voltar",
            description = "Voltar aos pontos de respawn",
            icon = "arrow-left",
            onSelect = function()
                openRespawnMenu()
            end
        }
    }

    lib.registerContext({
        id = 'respawn_point_menu',
        title = 'Ponto de Respawn ' .. index,
        menu = 'respawn_menu',
        options = options
    })

    lib.showContext('respawn_point_menu')
end

lib.callback.register("ars_ambulancejob:openEditor", function()
    openHospitalMenu()
end)
