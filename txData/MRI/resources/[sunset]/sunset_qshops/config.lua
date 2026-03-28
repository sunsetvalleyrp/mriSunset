Config = {}

-- ============================================================
--  CONFIGURAÇÕES GERAIS
-- ============================================================
Config.MoneyItem       = "money"     -- Item de dinheiro no inventário (carteira) — padrão ox_inventory QBox
Config.imgDir          = "nui://sunset_qshops/nui/inventario/"
Config.InteractKey     = 38          -- Tecla E (código FiveM)
Config.InteractDistance = 1.8        -- Distância para abrir a loja pressionando E
Config.MarkerDistance  = 4.0         -- Distância para exibir o texto flutuante
Config.ShowMarker      = true        -- Exibir marcador 3D no chão
Config.ShowFloatText   = true        -- Exibir texto flutuante acima do marcador

-- ============================================================
--  CONFIGURAÇÃO DE BLIPS
--  sprite => ícone do blip (lista: https://docs.fivem.net/game-references/blips/)
--  color  => cor do blip   (lista: https://docs.fivem.net/game-references/blips/#blip-colors)
--  scale  => tamanho do blip
--  label  => nome exibido no mapa
--  Um blip por loja — aparece apenas na primeira localização do shopId
-- ============================================================
Config.Blips = {
    ["supermarket"]        = { sprite = 52,  color = 2,  scale = 0.8, label = "Supermercado"       },
    ["boutique"]           = { sprite = 73,  color = 47, scale = 0.8, label = "Boutique"            },
    ["ammunation"]         = { sprite = 110, color = 1,  scale = 0.8, label = "Ammunation"          },
    ["feirante"]           = { sprite = 140, color = 2,  scale = 0.8, label = "Feirante"            },
    ["pescador"]           = { sprite = 356, color = 3,  scale = 0.8, label = "Pescador"            },
    ["digitalden"]         = { sprite = 174, color = 4,  scale = 0.8, label = "Digital Den"         },
    ["traficante"]         = { sprite = 75,  color = 1,  scale = 0.8, label = "Traficante"          },
    ["contrabandistaporto"]= { sprite = 380, color = 1,  scale = 0.8, label = "Contrabandista"      },
    ["contrabandistapier"] = { sprite = 380, color = 1,  scale = 0.8, label = "Contrabandista"      },
    ["eastcustoms"]        = { sprite = 446, color = 5,  scale = 0.8, label = "East Customs"        },
}


--  shopId   => chave da loja em Config.Shops
--  text     => nome exibido no texto flutuante
-- ============================================================
Config.Locations = {

    -- SUPERMERCADO
    { coords = vec3(25.65,   -1346.58, 29.49),  shopId = "supermarket",        text = "SUPERMERCADO"         },
    { coords = vec3(2556.75,  382.01,  108.62), shopId = "supermarket",        text = "SUPERMERCADO"         },
    { coords = vec3(1163.54, -323.04,  69.20),  shopId = "supermarket",        text = "SUPERMERCADO"         },
    { coords = vec3(-707.37, -913.68,  19.21),  shopId = "supermarket",        text = "SUPERMERCADO"         },
    { coords = vec3(-47.73,  -1757.25, 29.42),  shopId = "supermarket",        text = "SUPERMERCADO"         },
    { coords = vec3(373.90,   326.91,  103.56), shopId = "supermarket",        text = "SUPERMERCADO"         },
    { coords = vec3(-3243.10, 1001.23,  12.83), shopId = "supermarket",        text = "SUPERMERCADO"         },
    { coords = vec3(1729.38,  6415.54,  35.03), shopId = "supermarket",        text = "SUPERMERCADO"         },
    { coords = vec3(547.90,   2670.36,  42.15), shopId = "supermarket",        text = "SUPERMERCADO"         },
    { coords = vec3(1960.75,  3741.33,  32.34), shopId = "supermarket",        text = "SUPERMERCADO"         },
    { coords = vec3(2677.90,  3280.88,  55.24), shopId = "supermarket",        text = "SUPERMERCADO"         },
    { coords = vec3(1698.45,  4924.15,  42.06), shopId = "supermarket",        text = "SUPERMERCADO"         },
    { coords = vec3(-1820.93,  793.18, 138.11), shopId = "supermarket",        text = "SUPERMERCADO"         },

    -- BOUTIQUE
    { coords = vec3(420.74,   -809.68,  29.50), shopId = "boutique",           text = "BOUTIQUE"             },
    { coords = vec3(-816.96, -1075.93,  11.33), shopId = "boutique",           text = "BOUTIQUE"             },
    { coords = vec3(-1.10,    6513.72,  31.88), shopId = "boutique",           text = "BOUTIQUE"             },
    { coords = vec3(-1095.75, 2709.39,  19.11), shopId = "boutique",           text = "BOUTIQUE"             },
    { coords = vec3(1200.14,  2705.47,  38.23), shopId = "boutique",           text = "BOUTIQUE"             },
    { coords = vec3(81.17,   -1389.49,  29.38), shopId = "boutique",           text = "BOUTIQUE"             },
    { coords = vec3(1689.48,  4818.96,  42.06), shopId = "boutique",           text = "BOUTIQUE"             },

    -- AMMUNATION
    { coords = vec3(22.45,   -1107.82,  29.80), shopId = "ammunation",         text = "AMMUNATION"           },
    { coords = vec3(809.83,  -2157.09,  29.62), shopId = "ammunation",         text = "AMMUNATION"           },
    { coords = vec3(1696.14,  3759.39,  34.71), shopId = "ammunation",         text = "AMMUNATION"           },
    { coords = vec3(249.70,    -50.48,  69.95), shopId = "ammunation",         text = "AMMUNATION"           },
    { coords = vec3(840.79,  -1031.17,  28.20), shopId = "ammunation",         text = "AMMUNATION"           },
    { coords = vec3(-327.69,  6083.18,  31.46), shopId = "ammunation",         text = "AMMUNATION"           },
    { coords = vec3(-660.62,  -937.75,  21.83), shopId = "ammunation",         text = "AMMUNATION"           },
    { coords = vec3(-1308.24, -395.03,  36.70), shopId = "ammunation",         text = "AMMUNATION"           },
    { coords = vec3(-1115.26, 2697.76,  18.56), shopId = "ammunation",         text = "AMMUNATION"           },
    { coords = vec3(2566.53,   296.53, 108.74), shopId = "ammunation",         text = "AMMUNATION"           },
    { coords = vec3(-3169.27, 1088.06,  20.84), shopId = "ammunation",         text = "AMMUNATION"           },

    -- FEIRANTE
    -- { coords = vec3(1792.12,  4591.65,  37.69), shopId = "feirante",           text = "FEIRANTE"             },

    -- PESCADOR
    -- { coords = vec3(1527.09,  3782.33,  34.54), shopId = "pescador",           text = "PESCADOR"             },

    -- DIGITALDEN
    -- { coords = vec3(-657.12,  -858.83,  24.50), shopId = "digitalden",         text = "DIGITAL DEN"          },

    -- -- TRAFICANTE
    -- { coords = vec3(84.71,   -1959.17,  21.13), shopId = "traficante",         text = "TRAFICANTE"           },

    -- -- CONTRABANDISTA PORTO
    -- { coords = vec3(944.08,  -2978.41,   5.91), shopId = "contrabandistaporto", text = "CONTRABANDISTA"      },

    -- -- CONTRABANDISTA PIER
    -- { coords = vec3(-3424.44,  982.42,   8.35), shopId = "contrabandistapier",  text = "CONTRABANDISTA"      },

    -- -- EAST CUSTOMS
    -- { coords = vec3(873.94,  -2101.48,  30.46), shopId = "eastcustoms",        text = "EAST CUSTOMS"         },
}

-- ============================================================
--  LOJAS
--  Cada item aceita os campos:
--    item      => nome do item no inventário
--    name      => nome de exibição
--    descricao => descrição curta exibida no card
--    quantidade=> quantidade recebida por compra
--    compra    => preço em "dinheiro"
--    category  => categoria para filtro (ex: "bebidas", "comidas", "utilidades", "armas", "materiais")
-- ============================================================
Config.Shops = {

    ["supermarket"] = {
        Nome = "SUPERMERCADO",
        Items = {
            { item = "cola",   name = "Refrigerante de Cola",      descricao = "Refrigerante gelado e refrescante.",  quantidade = 1, compra = 10, category = "bebidas" },
            { item = "sprunk",        name = "Refrigerante de Limão",          descricao = "Refrigerante gelado e refrescante.",       quantidade = 1, compra = 13, category = "bebidas" },
            { item = "agua",        name = "Agua",          descricao = "Agua gelada e refrescante.",       quantidade = 1, compra = 3, category = "bebidas" },

            -- { item = "cheeseburger", name = "Cheeseburger", descricao = "Hamburguer suculento.", quantidade = 1, compra = 25, category = "comidas" },
            { item = "rosquinha", name = "Rosquinha", descricao = "Rosquinha deliciosa.", quantidade = 1, compra = 7, category = "comidas" },
            { item = "chocolate", name = "Chocolate", descricao = "chocolate delicioso.", quantidade = 1, compra = 3, category = "comidas" },

            -- { item = "seda", name = "Seda", descricao = "Seda.", quantidade = 1, compra = 25, category = "utilidades" },
        }
    },

    ["boutique"] = {
        Nome = "BOUTIQUE",
        Items = {
            { item = "mochila", name = "Mochila",  descricao = "Mochila pequena e resistente com capacidade para transportar itens.",   quantidade = 1, compra = 500, category = "acessorios" },
        }
    },

    ["ammunation"] = {
        Nome = "AMMUNATION",
        Items = {
            { item = "WEAPON_KNUCKLE", name = "Soco Inglês", descricao = "Dispositivo de metal encaixado nos nós dos dedos.", quantidade = 1, compra = 35,  category = "armas"      },
            { item = "WEAPON_KNIFE",   name = "Faca",        descricao = "Faca prática e afiada, ideal para cortes precisos durante a caça.",            quantidade = 1, compra = 100, category = "armas"      },
            { item = "WEAPON_HATCHET", name = "Machadinha",  descricao = "Machado pequeno e afiado, ideal para cortar arvores na floresta.",      quantidade = 1, compra = 200, category = "armas"      },
        }
    },

    ["feirante"] = {
        Nome = "FEIRANTE",
        Items = {
            { item = "adubo",        name = "Adubo",        descricao = "Composto orgânico que enriquece o solo para o cultivo de plantas.",   quantidade = 1, compra = 7,   category = "utilidades" },
            { item = "borrifador",   name = "Borrifador",   descricao = "Frasco com gatilho para borrifar líquidos. Muito útil no cultivo.",    quantidade = 1, compra = 5,   category = "utilidades" },
            { item = "garrafavazia", name = "Garrafa Vazia",descricao = "Frasco de vidro vazio. Pode ser usado para armazenar líquidos.",       quantidade = 1, compra = 1,   category = "utilidades" },
            { item = "vaso",         name = "Vaso",         descricao = "Vaso de cerâmica para plantio. Ideal para cultivar em espaços menores.",quantidade = 1, compra = 3,   category = "utilidades" },
        }
    },

    ["pescador"] = {
        Nome = "PESCADOR",
        Items = {
            { item = "isca",            name = "Isca",                  descricao = "Isca simples para atrair peixes comuns. Eficaz em águas rasas.",       quantidade = 1, compra = 20,  category = "utilidades" },
            { item = "isca2",           name = "Isca Premium",          descricao = "Isca especial que atrai peixes raros. Alta taxa de sucesso.",            quantidade = 1, compra = 50,  category = "utilidades" },
            { item = "vara",            name = "Vara de Pesca",         descricao = "Vara resistente e flexível para pescas de longa duração.",               quantidade = 1, compra = 250, category = "utilidades" },
            { item = "ticketbarco",     name = "Ticket Barco",          descricao = "Passagem para o barco de pesca. Acesso a pontos mais distantes.",        quantidade = 1, compra = 200, category = "utilidades" },
            { item = "ticketbarco2",    name = "Ticket Barco Premium",  descricao = "Passagem VIP com acesso às melhores áreas de pesca do mapa.",            quantidade = 1, compra = 750, category = "utilidades" },
        }
    },

    ["digitalden"] = {
        Nome = "DIGITAL DEN",
        Items = {
            { item = "celular",   name = "Smartphone",  descricao = "Dispositivo eletrônico para comunicação, acesso à internet e muito mais.",  quantidade = 1, compra = 3500, category = "eletronicos" },
            { item = "radio",     name = "Rádio",       descricao = "Aparelho para comunicação à distância em diferentes radiofrequências.",      quantidade = 1, compra = 2500, category = "eletronicos" },
            { item = "pendrive",  name = "Pendrive",    descricao = "Dispositivo de armazenamento portátil de dados digitais.",                   quantidade = 1, compra = 50,   category = "eletronicos" },
            { item = "notebook",  name = "Notebook",    descricao = "Computador portátil de alta performance para trabalho e entretenimento.",    quantidade = 1, compra = 5500, category = "eletronicos" },
        }
    },

    ["traficante"] = {
        Nome = "TRAFICANTE",
        Items = {
            { item = "baseado",    name = "Baseado",    descricao = "Cigarro artesanal. Produto ilegal. Use com cautela e discrição.",   quantidade = 10, compra = 50,   category = "ilegais"    },
            { item = "lockpick",   name = "Lockpick",   descricao = "Ferramenta para forçar fechaduras. Uso exclusivo de especialistas.", quantidade = 1,  compra = 100,  category = "ilegais"    },
            { item = "masterpick", name = "Masterpick", descricao = "Versão avançada do lockpick. Abre qualquer fechadura rapidamente.",  quantidade = 1,  compra = 1000, category = "ilegais"    },
        }
    },

    ["contrabandistaporto"] = {
        Nome = "CONTRABANDISTA",
        Items = {
            { item = "mola",       name = "Mola",                   descricao = "Peça mecânica pequena usada na montagem de armas artesanais.",       quantidade = 1,   compra = 50,   category = "ilegais" },
            { item = "gatilho",    name = "Gatilho",                descricao = "Componente de disparo para armas. Requer conhecimento técnico.",     quantidade = 1,   compra = 450,  category = "ilegais" },
            { item = "pecadearma", name = "Peças de Arma",          descricao = "Conjunto de peças para montagem de arma ilegal. Alto risco.",       quantidade = 1,   compra = 4500, category = "ilegais" },
            { item = "capsula",    name = "Cápsulas de Munição",    descricao = "Invólucros metálicos vazios para recarregamento de munição.",       quantidade = 100, compra = 100,  category = "ilegais" },
            { item = "polvora",    name = "Ziplock com Pólvora",    descricao = "Pólvora embalada a vácuo, usada na fabricação de munição.",         quantidade = 1,   compra = 200,  category = "ilegais" },
            { item = "projetil",   name = "Projéteis de Munição",   descricao = "Pontas de projétil para montagem de cartuchos de munição.",         quantidade = 100, compra = 200,  category = "ilegais" },
        }
    },

    ["contrabandistapier"] = {
        Nome = "CONTRABANDISTA",
        Items = {
            { item = "cartao",            name = "Cartão Limpo",          descricao = "Cartão em branco sem rastreio. Usado em transações ilegais.",   quantidade = 1, compra = 50,   category = "ilegais" },
            { item = "bilhetedecorrida",  name = "Bilhete de Corrida",    descricao = "Ingresso para corridas ilegais na cidade. Entrada exclusiva.",  quantidade = 1, compra = 150,  category = "ilegais" },
            { item = "lockpick",          name = "Lockpick",              descricao = "Ferramenta para forçar fechaduras. Uso exclusivo de especialistas.", quantidade = 1, compra = 100, category = "ilegais" },
            { item = "masterpick",        name = "Masterpick",            descricao = "Versão avançada do lockpick. Abre qualquer fechadura rapidamente.", quantidade = 1, compra = 1000, category = "ilegais" },
        }
    },

    ["eastcustoms"] = {
        Nome = "EAST CUSTOMS",
        Items = {
            { item = "pneu",              name = "Pneu",              descricao = "Pneu reserva de alta durabilidade para qualquer veículo.",              quantidade = 1, compra = 250,  category = "veiculos" },
            { item = "repairkit",         name = "KIT de Reparos",    descricao = "Kit completo para reparos emergenciais de veículos danificados.",        quantidade = 1, compra = 1250, category = "veiculos" },
            { item = "galaodegasolina",   name = "Galão de Gasolina", descricao = "Galão portátil com combustível para abastecer veículos no campo.",      quantidade = 1, compra = 100,  category = "veiculos" },
        }
    },
}
