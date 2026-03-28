Config = {}

-- =============================================
-- FRAMEWORK: QBOX
-- =============================================

-- =============================================
-- LOCALIZAÇÕES DAS OFICINAS
-- =============================================
Config.Location = {
    {
        markerposition = vector3(-211.84, -1324.07, 30.89),
        dist           = 10.0,
        blipsprite     = 72,
        blipscale      = 0.8,
        blipcolor      = 5,
        blipname       = "GarageX Tuning",
    },
    -- Adicione mais localizações:
    -- {
    --     markerposition = vector3(x, y, z),
    --     dist           = 10.0,
    --     blipsprite     = 72,
    --     blipscale      = 0.8,
    --     blipcolor      = 5,
    --     blipname       = "GarageX Tuning 2",
    -- },
}

-- =============================================
-- TEXTOS
-- =============================================
Config.Locales = {
    interactmessage   = "Pressione ~INPUT_CONTEXT~ para acessar o tuning",
    buymessage        = "~g~Modificações instaladas com sucesso!",
    nomessage         = "~r~Saldo insuficiente!",
    itemrequired      = "~r~Você não possui a peça necessária!",
}

-- =============================================
-- PAGAMENTO
-- =============================================
Config.PaymentMethods = {
    bank = true,
    cash = true,
}

-- =============================================
-- MARKER
-- =============================================
Config.Marker = {
    type   = 1,
    size   = vector3(2.0, 2.0, 0.5),
    color  = { r = 255, g = 165, b = 0, a = 100 },
    rotate = true,
}

-- =============================================
-- ITENS DE TUNING (para shared/items.lua do QBX)
-- Adicione estes itens no seu items.lua
-- =============================================
--[[
ITENS PARA ADICIONAR NO items.lua:

['motor_s1']      = { name = 'motor_s1',   label = 'Motor Stage 1',       weight = 5000, type = 'item', image = 'motor_s1.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Motor Stage 1 — Ajuste básico de carburador' },
['motor_s2']      = { name = 'motor_s2',   label = 'Motor Stage 2',       weight = 5000, type = 'item', image = 'motor_s2.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Motor Stage 2 — Kit de injeção melhorado' },
['motor_s3']      = { name = 'motor_s3',   label = 'Motor Stage 3',       weight = 5000, type = 'item', image = 'motor_s3.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Motor Stage 3 — Cabeçote high performance' },
['motor_s4']      = { name = 'motor_s4',   label = 'Motor Stage 4',       weight = 5000, type = 'item', image = 'motor_s4.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Motor Stage 4 — Motor race completo + turbo' },
['turbo_s1']      = { name = 'turbo_s1',   label = 'Turbo Stage 1',       weight = 3000, type = 'item', image = 'turbo_s1.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Turbo Stage 1 — Turbocompressor básico' },
['turbo_s2']      = { name = 'turbo_s2',   label = 'Turbo Stage 2',       weight = 3000, type = 'item', image = 'turbo_s2.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Turbo Stage 2 — Alto fluxo de ar' },
['turbo_s3']      = { name = 'turbo_s3',   label = 'Turbo Stage 3',       weight = 3000, type = 'item', image = 'turbo_s3.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Turbo Stage 3 — Alta pressão' },
['turbo_s4']      = { name = 'turbo_s4',   label = 'Turbo Stage 4',       weight = 3000, type = 'item', image = 'turbo_s4.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Turbo Stage 4 — Twin-turbo race' },
['susp_s1']       = { name = 'susp_s1',    label = 'Suspensão Stage 1',   weight = 4000, type = 'item', image = 'susp_s1.png',    unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Suspensão Stage 1 — Molas esportivas' },
['susp_s2']       = { name = 'susp_s2',    label = 'Suspensão Stage 2',   weight = 4000, type = 'item', image = 'susp_s2.png',    unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Suspensão Stage 2 — Kit ajustável' },
['susp_s3']       = { name = 'susp_s3',    label = 'Suspensão Stage 3',   weight = 4000, type = 'item', image = 'susp_s3.png',    unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Suspensão Stage 3 — Amortecedor performance' },
['susp_s4']       = { name = 'susp_s4',    label = 'Suspensão Stage 4',   weight = 4000, type = 'item', image = 'susp_s4.png',    unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Suspensão Stage 4 — Setup de competição' },
['freio_s1']      = { name = 'freio_s1',   label = 'Freios Stage 1',      weight = 3500, type = 'item', image = 'freio_s1.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Freios Stage 1 — Pastilhas esportivas' },
['freio_s2']      = { name = 'freio_s2',   label = 'Freios Stage 2',      weight = 3500, type = 'item', image = 'freio_s2.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Freios Stage 2 — Discos ventilados' },
['freio_s3']      = { name = 'freio_s3',   label = 'Freios Stage 3',      weight = 3500, type = 'item', image = 'freio_s3.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Freios Stage 3 — Sistema sport completo' },
['freio_s4']      = { name = 'freio_s4',   label = 'Freios Stage 4',      weight = 3500, type = 'item', image = 'freio_s4.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Freios Stage 4 — Competição máxima' },
['arm_s1']        = { name = 'arm_s1',     label = 'Blindagem Stage 1',   weight = 8000, type = 'item', image = 'arm_s1.png',     unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Blindagem Stage 1 — Proteção básica' },
['arm_s2']        = { name = 'arm_s2',     label = 'Blindagem Stage 2',   weight = 8000, type = 'item', image = 'arm_s2.png',     unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Blindagem Stage 2 — Reforço de chassi' },
['arm_s3']        = { name = 'arm_s3',     label = 'Blindagem Stage 3',   weight = 8000, type = 'item', image = 'arm_s3.png',     unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Blindagem Stage 3 — Balística básica' },
['arm_s4']        = { name = 'arm_s4',     label = 'Blindagem Stage 4',   weight = 8000, type = 'item', image = 'arm_s4.png',     unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Blindagem Stage 4 — Militarizada total' },
['trans_s1']      = { name = 'trans_s1',   label = 'Transmissão Stage 1', weight = 4500, type = 'item', image = 'trans_s1.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Transmissão Stage 1 — Câmbio esportivo' },
['trans_s2']      = { name = 'trans_s2',   label = 'Transmissão Stage 2', weight = 4500, type = 'item', image = 'trans_s2.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Transmissão Stage 2 — Caixa melhorada' },
['trans_s3']      = { name = 'trans_s3',   label = 'Transmissão Stage 3', weight = 4500, type = 'item', image = 'trans_s3.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Transmissão Stage 3 — Alta performance' },
['trans_s4']      = { name = 'trans_s4',   label = 'Transmissão Stage 4', weight = 4500, type = 'item', image = 'trans_s4.png',   unique = false, useable = false, shouldClose = false, combinable = nil, description = 'Transmissão Stage 4 — Câmbio race total' },
]]
