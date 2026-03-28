-- Desativar recarga de saúde
local healthRegen = lib.load("config").healthRegen
if healthRegen then
    CreateThread(function()
        while true do
            Wait(2000)
            SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
        end
    end)
end
