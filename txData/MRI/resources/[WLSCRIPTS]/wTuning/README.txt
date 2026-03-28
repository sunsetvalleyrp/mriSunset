===================================================
  GarageX Tuning - Instalação e Debug
===================================================

1. INSTALAÇÃO
-------------
- Extraia a pasta "garagex_tuning" dentro de resources/[seu-servidor]/
- Adicione no server.cfg:
    ensure garagex_tuning

- Certifique-se que ox_lib e qbx_core estão rodando ANTES:
    ensure ox_lib
    ensure qbx_core
    ensure garagex_tuning


2. COMO USAR
------------
- Entre em um veículo
- Vá até a marca laranja no mapa (ou coordenada -211.84, -1324.07, 30.89)
- Quando aparecer [E] Abrir Tuning, pressione E
- Arraste as peças do inventário esquerdo para os slots do carro


3. SE NÃO APARECER O BLIP/MARKER
----------------------------------
Abra o console F8 no FiveM e procure por mensagens como:
  [GarageX] Criando 1 blip(s)...
  [GarageX] Blip #1 criado em ...
  [GarageX] Thread de marker iniciada.

Se NÃO aparecer nenhuma dessas linhas:
  → O recurso não está sendo carregado. Verifique o server.cfg.

Se aparecer erro como "attempt to index nil value 'Config'":
  → O config.lua não está sendo carregado. Verifique o fxmanifest.lua.

Se aparecer erro com "ox_lib":
  → Certifique-se que ox_lib está instalado e com ensure ANTES do garagex_tuning.


4. COMANDO DE EMERGÊNCIA
------------------------
No chat do jogo (estando dentro de um veículo):
  /tuning
Abre a NUI sem precisar estar na zona.


5. COORDENADA PADRÃO
---------------------
A oficina fica em: -211.84, -1324.07, 30.89
(Próximo à Los Santos Customs no sul da cidade)

Para mudar o local, edite o config.lua:
  markerposition = vector3(X, Y, Z)

Use /coords no jogo para pegar suas coordenadas atuais
(se tiver esse comando no servidor).

===================================================
