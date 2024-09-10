---@param cFrame ERACombatFrame
---@param enemies ERACombatEnemiesCount
---@param paladinTalents PaladinCommonTalents
function ERACombatFrames_PaladinRetributionSetup(cFrame, enemies, paladinTalents)
    local hud = ERAHUD:Create(cFrame, 1.5, false, false, 0, 0.0, 0.0, 1.0, false, 3)
    hud.power.hideFullOutOfCombat = true
    hud.powerHeight = 10
    function hud:IsCombatPowerVisibleOverride(t)
        return self.power.currentPower / self.power.maxPower <= 0.75
    end

    local judgment = hud:AddTrackedCooldown(20271)
    hud:AddRotationCooldown(judgment)
end
