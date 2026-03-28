-- ============================================================
--  sunset_qjobs — Config
-- ============================================================

Config = {}

Config.MarkerDistance   = 10.0
Config.InteractDistance = 2.5
Config.StopRadius       = 18.0
Config.GarageRadius     = 12.0
Config.InteractKey      = 38

Config.MoneyItem = "money"

-- ============================================================
--  BLIPS
-- ============================================================
Config.Blips = {
    motorista_onibus = {
        sprite = 513,
        color  = 2,
        scale  = 0.50,
        label  = "Central dos Motoristas",
    },
    caminhoneiro = {
        sprite = 477,
        color  = 2,
        scale  = 0.50,
        label  = "Central dos Caminhoneiros",
    },
    entregador = {
        sprite = 478,
        color  = 2,
        scale  = 0.50,
        label  = "Central dos Entregadores",
    },
}

-- ============================================================
--  REPUTAÇÃO — cw-rep
-- ============================================================
Config.ReputacaoSkills = {
    motorista_onibus = "busdriver",
    caminhoneiro     = "trucker",
    entregador       = "cargo",
}

-- ============================================================
--  PEDS NOS LOCAIS DE TRABALHO
-- ============================================================
Config.Peds = {
    motorista_onibus = {
        model  = "s_m_m_busdriver_01",
        coords = vector4(434.64, -654.19, 27.75, 180.0),
    },
    caminhoneiro = {
        model  = "s_m_m_trucker_01",
        coords = vector4(-839.62, 5398.5, 34.62, 345.06),
    },
    entregador = {
        model  = "s_m_m_postal_01",
        coords = vector4(78.87, 112.54, 81.17, 156.02),
    },
}

-- ============================================================
--  EMPREGOS
--  tipo = "paradas" : múltiplos pontos sequenciais (ônibus)
--  tipo = "entrega" : um ponto de entrega + trailer (caminhão)
-- ============================================================
Config.Jobs = {

    -- ----------------------------------------------------------
    --  MOTORISTA DE ÔNIBUS
    -- ----------------------------------------------------------
    motorista_onibus = {
        Nome        = "MOTORISTA DE ÔNIBUS",
        NomeCentral = "CENTRAL DOS MOTORISTAS",
        Categoria   = "transporte",
        Descricao   = "Transporte público de passageiros pelas linhas da cidade.",
        tipo        = "paradas",

        SpawnVeiculo = {
            vector4(425.10, -642.20, 28.50, 181.06),
            vector4(421.51, -642.44, 28.50, 180.40),
        },

        Location = vector3(434.64, -654.19, 28.75),

        -- Níveis — desbloqueio igual ao entregador/caminhoneiro
        Niveis = {
            {
                id          = "sul",
                label       = "Rota Sul",
                descricao   = "Centro → Elysian Island → Doca Sul",
                payMin      = 500,
                payMax      = 700,
                xpMin       = 50,
                xpMax       = 70,
                veiculo     = "airbus",
                nivelMinimo = 1,
            },
            {
                id          = "norte",
                label       = "Rota Norte",
                descricao   = "Centro → Mission Row → Vinewood Hills",
                payMin      = 800,
                payMax      = 1100,
                xpMin       = 80,
                xpMax       = 110,
                veiculo     = "coach",
                nivelMinimo = 2,
            },
            {
                id          = "leste",
                label       = "Rota Leste",
                descricao   = "Centro → LSIA → La Mesa → East LS",
                payMin      = 1200,
                payMax      = 1600,
                xpMin       = 120,
                xpMax       = 160,
                veiculo     = "bus",
                nivelMinimo = 5,
            },
            {
                id          = "oeste",
                label       = "Rota Oeste",
                descricao   = "Centro → Strawberry → Vespucci → Del Perro",
                payMin      = 1800,
                payMax      = 2200,
                xpMin       = 180,
                xpMax       = 220,
                veiculo     = "bus",
                nivelMinimo = 10,
            },
        },

        -- Paradas por rota
        Rotas = {
            sul = {
                paradas = {
                    vector3(415.34, -720.88, 29.20),
                    vector3(390.10, -810.45, 29.00),
                    vector3(355.70, -905.33, 25.50),
                    vector3(318.90, -1005.20, 24.80),
                    vector3(276.45, -1085.10, 28.10),
                    vector3(242.30, -1148.75, 27.80),
                    vector3(205.60, -1215.40, 28.00),
                    vector3(162.20, -1285.90, 28.30),
                    vector3(128.80, -1348.60, 28.45),
                    vector3( 98.30, -1402.10, 28.55),
                },
            },
            norte = {
                paradas = {
                    vector3(434.00, -588.50, 29.30),
                    vector3(412.80, -518.40, 31.50),
                    vector3(383.60, -448.20, 34.10),
                    vector3(352.30, -388.60, 37.80),
                    vector3(318.50, -320.90, 40.20),
                    vector3(287.70, -254.80, 43.50),
                    vector3(258.40, -194.30, 46.30),
                    vector3(232.60, -144.50, 48.70),
                    vector3(207.90, -100.20, 51.00),
                    vector3(186.40,  -58.70, 52.30),
                },
            },
            leste = {
                paradas = {
                    vector3(502.20, -660.50, 28.60),
                    vector3(582.80, -660.10, 29.00),
                    vector3(662.40, -680.30, 29.20),
                    vector3(742.60, -700.80, 29.50),
                    vector3(822.90, -740.20, 29.70),
                    vector3(892.30, -792.60, 30.00),
                    vector3(962.70, -842.40, 30.20),
                    vector3(1032.50,-892.80, 30.40),
                    vector3(1102.30,-936.60, 30.60),
                    vector3(1162.80,-971.20, 30.80),
                },
            },
            oeste = {
                paradas = {
                    vector3(362.40, -650.20, 29.00),
                    vector3(282.80, -642.60, 29.20),
                    vector3(202.60, -642.10, 29.40),
                    vector3(122.30, -641.80, 29.60),
                    vector3( 42.10, -641.50, 29.80),
                    vector3(-48.50, -651.30, 30.00),
                    vector3(-138.80,-661.90, 30.20),
                    vector3(-218.60,-672.40, 29.50),
                    vector3(-298.30,-682.80, 28.80),
                    vector3(-378.50,-692.60, 28.50),
                },
            },
        },
    },

    -- ----------------------------------------------------------
    --  CAMINHONEIRO
    -- ----------------------------------------------------------
    caminhoneiro = {
        Nome        = "CAMINHONEIRO",
        NomeCentral = "CENTRAL DOS CAMINHONEIROS",
        Categoria   = "transporte",
        Descricao   = "Transporte de madeira para serrarias e depósitos da região.",
        tipo        = "truck",

        Veiculo = "phantom",
        Trailer = "trailerlogs",

        SpawnVeiculo = {
            vector4(-809.57, 5412.09, 34.01, 56.93),
            vector4(-805.00, 5412.09, 34.01, 56.93),
            vector4(-813.00, 5412.09, 34.01, 56.93),
        },
        TrailerSpawn = {
            vector4(-798.60, 5410.84, 33.97, 9.83),
            vector4(-794.00, 5410.84, 33.97, 9.83),
            vector4(-803.00, 5410.84, 33.97, 9.83),
        },

        Location = vector3(-839.66, 5398.57, 34.62),

        -- Pagamento baseado na distância percorrida
        -- O valor final é calculado entre PayMin e PayMax proporcionalmente
        Pagamento = { min = 1000, max = 2000 },

        -- Níveis — mesma estrutura do entregador
        Niveis = {
            {
                id          = "n1",
                label       = "Iniciante",
                descricao   = "Rotas curtas de entrega de madeira.",
                xpMin       = 8,
                xpMax       = 12,
                nivelMinimo = 1,
            },
            {
                id          = "n2",
                label       = "Experiente",
                descricao   = "Rotas de média distância com mais recompensa.",
                xpMin       = 15,
                xpMax       = 22,
                nivelMinimo = 2,
            },
            {
                id          = "n3",
                label       = "Veterano",
                descricao   = "Longas rotas com alto valor de carga.",
                xpMin       = 25,
                xpMax       = 35,
                nivelMinimo = 5,
            },
            {
                id          = "n4",
                label       = "Elite",
                descricao   = "Entregas de precisão para clientes premium.",
                xpMin       = 40,
                xpMax       = 55,
                nivelMinimo = 10,
            },
        },

        -- Pontos de entrega aleatórios (adicione quantos quiser)
        PontosEntrega = {
            vector3(-1094.24, -1639.99,  4.40),   -- Serraria Sul
            vector3(  -90.95, -2647.34,  6.02),   -- Depósito Sul
            vector3( 1381.96,  -742.03, 67.23),   -- Fábrica Leste
            vector3(  -98.83, -1024.52, 27.27),   -- Depósito Central
            vector3( -550.12,  -835.60, 24.78),   -- Armazém Oeste
        },
    },

    -- ----------------------------------------------------------
    --  ENTREGADOR
    -- ----------------------------------------------------------
    entregador = {
        Nome        = "ENTREGADOR",
        NomeCentral = "CENTRAL DOS ENTREGADORES",
        Categoria   = "transporte",
        Descricao   = "Entrega de encomendas e mercadorias.",
        tipo        = "sedex",

        SpawnVeiculo = {
            vector4(69.28, 118.47, 79.03, 160.25),
            vector4(73.50, 118.47, 79.03, 160.25),
            vector4(77.70, 118.47, 79.03, 160.25),
        },

        Trailer      = nil,
        TrailerSpawn = nil,

        Location = vector3(78.86, 112.46, 81.17),

        NumEntregas = 10,

        -- --------------------------------------------------------
        --  NÍVEIS — cada nível é uma "rota" separada na NUI
        --  nivelMinimo : nível mínimo do transportador no cw-rep
        -- --------------------------------------------------------
        Niveis = {
            {
                id          = "n1",
                label       = "Iniciante",
                descricao   = "Rotas urbanas simples pela cidade.",
                payMin      = 750,
                payMax      = 1000,
                xpMin       = 5,
                xpMax       = 7,
                nivelMinimo = 1,
            },
            {
                id          = "n2",
                label       = "Experiente",
                descricao   = "Rotas mais longas com maior recompensa.",
                payMin      = 1200,
                payMax      = 1600,
                xpMin       = 8,
                xpMax       = 12,
                nivelMinimo = 2,
            },
            {
                id          = "n3",
                label       = "Veterano",
                descricao   = "Entregas expressas em toda a cidade.",
                payMin      = 1800,
                payMax      = 2400,
                xpMin       = 13,
                xpMax       = 18,
                nivelMinimo = 5,
            },
            {
                id          = "n4",
                label       = "Elite",
                descricao   = "Cargas de alto valor com máxima eficiência.",
                payMin      = 2600,
                payMax      = 3200,
                xpMin       = 20,
                xpMax       = 28,
                nivelMinimo = 10,
            },
        },

        -- Pontos de entrega (selecionados aleatoriamente)
        PontosEntrega = {
            vector3(-1251.76, -2798.57, 13.95),
            vector3(-1060.58,  -227.31, 38.20),
            vector3(  113.96, -2979.96,  6.01),
            vector3( -411.28, -2793.48,  6.00),
        },
    },
}