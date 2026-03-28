# Corrija buracos e personalize o mapa (Atualizado para A Safehouse in the Hills)

O objetivo deste script é corrigir os buracos no mapa carregando zonas que não são carregadas por padrão. Adicionei muitos locais para carregar, com base no [script do Mikeeh](https://forum.fivem.net/t/release-load-unloaded-ipls/5911). Se você só quiser corrigir os buracos no mapa, use este recurso como está.

Este recurso foi completamente reescrito do zero desde a v2.0. Você pode personalizar praticamente todos os interiores compráveis do modo história e do online a partir dos seus próprios recursos.

## Download
- Versão mais recente: https://github.com/Bob74/bob74_ipl/releases/latest

- Código-fonte: https://github.com/Bob74/bob74_ipl

## [Wiki](https://github.com/Bob74/bob74_ipl/wiki)
- A Wiki foi criada para ajudar você a personalizar seus interiores como quiser. Ela contém todas as funções que você pode usar para cada interior.
- Cada página da Wiki tem um exemplo no final para mostrar como você pode usá-la no seu próprio recurso.
- Também no final da Wiki são mostrados os valores padrão definidos por `IPL_NAME.LoadDefault()`.

## Instalação
1. Baixe a [versão mais recente](https://github.com/Bob74/bob74_ipl/releases/latest).
2. Extraia `bob74_ipl.zip` e copie a pasta `bob74_ipl` para a sua pasta `resources`.
3. Adicione `start bob74_ipl` ao seu arquivo `server.cfg`.

## Capturas de tela
- [Álbum After Hours](https://imgur.com/a/Qg96l0D)
- [Álbum Variado](https://imgur.com/a/cs9Ip4d)
- [Álbum de Correções de IPL](https://imgur.com/a/1Sfl4)

## Changelog

<details><summary>Clique para visualizar</summary>
(DD/MM/AAAA)

---
20/12/2025 - 2.6.0
- Adicionado suporte a "Um Refúgio nas Colinas"
- Corrigidos erros de digitação nos arquivos de "The Contract"
- Corrigido descarregamento de entidades desativadas após reinício do recurso

18/06/2025 - 2.5.0
- Adicionado suporte a "Money Fronts"
- Adicionado interior de fliperama

18/04/2025 - 2.4.2
- Corrigida chamada de nativas de interior com tipos inválidos

25/02/2025 - 2.4.1
- Adicionada porta do hangar
- Pasta "Bottom Dollar Bounties" renomeada para um nome mais claro

27/12/2024 - 2.4.0
- Adicionado suporte a "Agents of Sabotage"
- Corrigidas cores de tonalidade da garagem Eclipse Boulevard (@DevSekai)

28/08/2024 - 2.3.3
- Corrigida porta no navio cargueiro (@NeenGame)
- Corrigido interior do Franklin (@NeenGame)

24/08/2024 - 2.3.2
- Adicionados interiores do Kosatka e do "The Music Locker"
- Prefixo `Citizen` removido do código

10/08/2024 - 2.3.1
- Correção de mundo não renderizando dentro de escritórios de segurança
- Corrigidos erros de digitação nos arquivos de "Los Santos Tuners"

02/07/2024 - 2.3.0
- Adicionado suporte a "Bottom Dollar Bounties"

14/04/2024 - 2.2.1
- Permitido desativar correções de San Andreas Mercenaries
- Permitido definir o navio cargueiro do jogo base como afundado
- `ChopShopSalvage.Ipl.Load()` renomeado para `ChopShopSalvage.Ipl.Exterior.Load()`
- `DrugWarsFreakshop.Ipl.Load()` renomeado para `DrugWarsFreakshop.Ipl.Exterior.Load()`
- `DrugWarsGarage.Ipl.Load()` renomeado para `DrugWarsGarage.Ipl.Exterior.Load()`

06/04/2024 - 2.2.0
- Adicionado suporte a "Los Santos Drug Wars"
- Adicionado suporte a "San Andreas Mercenaries"
- Adicionado suporte a "The Chop Shop"
- IPLs base ausentes adicionadas

27/03/2024 - 2.1.4
- Melhorias em North Yankton (https://github.com/Bob74/bob74_ipl/pull/131 @TheIndra55)

05/12/2023 - 2.1.3
- Adicionado trecho de trilho ausente próximo a Davis Quartz (https://github.com/Bob74/bob74_ipl/pull/129 @TheIndra55)

10/01/2023 - 2.1.2
- Correção de nativa e atualização de nomes de nativas (@NeenGame)

24/10/2022 - 2.1.1
- Correção de buraco no muro de Vespucci Beach
- Correção da porta da casa de barcos em Sandy Shores
- Correção do telhado da loja 24/7 de GTA 5 em Sandy Shores
- Correção de prédio industrial próximo ao armazém do Lester
- Correção de buracos de colisão perto do complexo da Lost MC

11/10/2022 - 2.1.0a
- Objetos da Facility de Doomsday tornados não-rede

03/08/2022 - 2.1.0
- Adicionado suporte a "The Criminal Enterprises"

02/05/2022 - 2.0.15
- Código reformatado
- `.gitignore` não utilizado removido
- Versão atualizada em `fxmanifest.lua`
- Performance melhorada

21/04/2022 - 2.0.14
- Correção de cores dos padrões de carpete da cobertura do cassino

12/02/2022 - 2.0.13a
- Correção do Music Roof

12/02/2022 - 2.0.13
- IPLs do Contract adicionadas: Garage, Studio, Offices, Music Roof, Billboards

10/02/2022 - 2.0.12
- Correção do telhado do FIB

07/02/2022 - 2.0.11
- IPLs do Tuners adicionadas: Garage, Meth Lab, Meetup

18/01/2022 - 2.0.10b
- Alterada a água dos iates para não-rede.

01/08/2021 - 2.0.10a
- Performance melhorada
- Corrigido buraco na fonte do FIB
- Corrigido erro que aparecia se o IPL do cassino estava carregado, mas o build do jogo não era suficiente
- Corrigidos alguns erros de digitação no arquivo README

19/07/2021 - 2.0.10
- IPLs do Diamond Casino adicionadas: Casino, Garage, VIP garage, Penthouse
- Import: atualização forçada das CEO Garages
- `fx_version` em `fxmanifest` atualizado para cerulean
- Link da lista de IPL atualizado em `fxmanifest` e listas antigas de Props e Interior ID removidas
- Erro de digitação de export corrigido em `michael.lua`
- Espaço desnecessário removido no IPL de north_yankton

27/05/2020 - 2.0.9a
- Corrigida desativação do Hospital Pillbox
- `ResetInteriorVariables` corrigido

23/04/2020 - 2.0.9
- `__resource.lua` obsoleto substituído por `fxmanifest.lua`
- Roda-gigante adicionada no píer de Del Perro
- `client.lua` reformatado

20/10/2019 - 2.0.8
- Nightclubs: emissores de gelo seco adicionados
- Heist & Gunrunning: água adicionada nas banheiras de hidromassagem dos iates (para ativar/desativar)
- Offices: adicionada forma de abrir e fechar os cofres
- Facility: vidro de privacidade adicionado
- Bahama Mamas e PillBox Hospital movidos para seus próprios arquivos
- Erro `ReleaseNamedRendertarget` corrigido
- Código limpo e otimizado

22/03/2019 - 2.0.7c
- CEO Offices: garagem padrão carregada alterada para ImportCEOGarage4.Part.Garage2 para evitar glitches no escritório

15/01/2019 - 2.0.7b
- Nightclubs: erro de digitação das luzes falsas corrigido

15/01/2019 - 2.0.7a
- Nightclubs: adicionada a capacidade de definir sem pódio (usando `AfterHoursNightclubs.Interior.Podium.none`)

14/01/2019 - 2.0.7
- A forma como o trailer do Trevor é tratada foi alterada e uma entrada na Wiki foi adicionada.
- Adicionada uma forma de abrir ou fechar os portões de Zancudo com uma entrada na Wiki.

12/01/2019 - 2.0.6
- Adicionados interior e exteriores de nightclubs
- Portões de Zancudo removidos por padrão (arquivo bob74_ipl/gtav/base.lua: `RequestIpl("CS3_07_MPGates")` agora está comentado)

29/12/2018 - 2.0.5a
- Nome do export de BikerClubhouse1 corrigido

19/12/2018 - 2.0.5
- Corrigido erro de digitação que impedia impressoras, itens de segurança e pilhas de dinheiro de aparecerem na fábrica de dinheiro falso

10/11/2018 - 2.0.4
- Corrigido problema em que as paredes inferiores do clubhouse2 não recebiam cor na primeira inicialização do recurso
- Nomes dos membros de gangue corrigidos (formato antigo)
- Mod shop da CEO garage 3 (ImportCEOGarage3) desativada porque sobrepõe a CEO office 3 (FinanceOffice3)

08/11/2018 - 2.0.3
- Nome da gangue de bikers, missões e fotos dos membros adicionados
- Nome da organização do escritório CEO adicionado

05/11/2018 - 2.0.1
- Sobreposição no Rio Zancudo removida
- Trailer próximo ao Rio Zancudo adicionado

04/11/2018 - 2.0.0
- Plugin totalmente reescrito
- Suporte para todas as DLCs (até The Doomsday Heist)
- Capacidade de personalizar facilmente interiores compráveis do modo história e do online
- Você ainda pode usá-lo como está se quiser IPL e interiores carregados; o plugin define um estilo padrão para cada um
- Confira a Wiki para descobrir como: https://github.com/Bob74/bob74_ipl/wiki

26/06/2017
- IPL opcional adicionada
- Exteriores de bunkers (ativados)
- Interior de bunkers
- Escritórios CEO
- Locais dos Bikers (alguns ainda têm bugs)
- Locais de Import/Export
- Removido o truque para abrir o esconderijo da Lost, já que a última atualização já o abre

19/06/2017
- Corrigido buraco no Rio Zancudo
- Corrigido buraco em Cassidy Creek
- Grafite opcional adicionado em alguns outdoors (ativado por padrão)
- Interior do esconderijo da Lost aberto

14/06/2017
- Lançamento original
</details>

## Colaboradores

<a href="https://github.com/Bob74/bob74_ipl/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=Bob74/bob74_ipl" />
</a>