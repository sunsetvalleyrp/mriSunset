local menuActive    = false
local currentShopId = nil

-- ============================================================
--  TEXTO SIMPLES DE INTERAÇÃO
-- ============================================================

local function DrawText3D(x, y, z, text)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then return end

    local camX, camY, camZ = table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(camX, camY, camZ) - vector3(x, y, z))
    if dist > 6.0 then return end

    local scale = 0.35

    SetTextScale(0.0, scale)
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
--  CRIAÇÃO DE BLIPS
--  Um blip por localização, sempre visível no mapa completo
-- ============================================================

CreateThread(function()
    for _, loc in pairs(Config.Locations) do
        local shopId  = loc.shopId
        local blipCfg = Config.Blips[shopId]

        if blipCfg then
            local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
            SetBlipSprite(blip, blipCfg.sprite)
            SetBlipColour(blip, blipCfg.color)
            SetBlipScale(blip, blipCfg.scale)
            SetBlipAsShortRange(blip, true) -- visível no mapa completo
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(blipCfg.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)



local function OpenShop(shopId)
    if menuActive then return end
    if not shopId or not Config.Shops[shopId] then return end

    currentShopId = shopId
    menuActive    = true

    SetNuiFocus(true, true)
    TransitionToBlurred(500)

    SendNUIMessage({
        action   = "showMenu",
        shopName = Config.Shops[shopId].Nome,
        items    = Config.Shops[shopId].Items,
        imgDir   = Config.imgDir,
    })
end

local function CloseShop()
    if not menuActive then return end

    menuActive    = false
    currentShopId = nil

    SetNuiFocus(false, false)
    TransitionFromBlurred(500)
    SendNUIMessage({ action = "hideMenu" })
end

-- ============================================================
--  NUI CALLBACKS
-- ============================================================

RegisterNUICallback("buyItem", function(data, cb)
    if data and data.itemName and currentShopId then
        local qty = math.floor(tonumber(data.qty) or 1)
        if qty < 1 then qty = 1 end
        TriggerServerEvent("sunset_qshops:server:buyItem", data.itemName, currentShopId, qty)
    end
    cb("ok")
end)

RegisterNUICallback("closeMenu", function(data, cb)
    CloseShop()
    cb("ok")
end)

-- ============================================================
--  EVENTO PARA TARGET / NPC (olhinho)
-- ============================================================

RegisterNetEvent("sunset_qshops:client:openShop", function(shopId)
    OpenShop(shopId)
end)

-- ============================================================
--  THREAD DE PROXIMIDADE
-- ============================================================

CreateThread(function()
    SetNuiFocus(false, false)

    while true do
        Wait(500)

        local playerCoords    = GetEntityCoords(PlayerPedId())
        local nearestLocation = nil
        local nearestDist     = Config.MarkerDistance + 1.0

        for _, loc in pairs(Config.Locations) do
            local dist = #(playerCoords - loc.coords)
            if dist < nearestDist then
                nearestDist     = dist
                nearestLocation = loc
            end
        end

        if nearestLocation then
            currentShopId = nearestLocation.shopId

            while nearestLocation do
                Wait(0)
                playerCoords = GetEntityCoords(PlayerPedId())
                local dist   = #(playerCoords - nearestLocation.coords)

                -- Texto simples ao entrar no raio de interação
                if dist <= Config.InteractDistance and not menuActive then
                    DrawText3D(
                        nearestLocation.coords.x,
                        nearestLocation.coords.y,
                        nearestLocation.coords.z + 1.0,
                        "[E] ACESSAR"
                    )

                    if IsControlJustPressed(0, Config.InteractKey) then
                        OpenShop(nearestLocation.shopId)
                    end
                end

                -- Saiu do raio
                if dist > Config.MarkerDistance then
                    nearestLocation = nil
                    currentShopId   = nil
                end
            end
        end
    end
end)

print("^2[sunset_qshops]^7 Cliente carregado com sucesso.")
