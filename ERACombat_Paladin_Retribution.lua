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

    local holyPower = ERAHUDModulePointsUnitPower:Create(hud, 9, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, nil)

    local judgment = hud:AddTrackedCooldown(20271)
    hud:AddRotationCooldown(judgment)

    local loh = hud:AddTrackedCooldown(633)
    hud:AddUtilityCooldown(loh, hud.healGroup)

    local stunHammer = hud:AddTrackedCooldown(853)
    hud:AddUtilityCooldown(stunHammer, hud.controlGroup)

    local steed = hud:AddTrackedCooldown(190784)
    hud:AddUtilityCooldown(steed, hud.movementGroup)

    local wrath = hud:AddTrackedCooldown(31884)
    hud:AddUtilityCooldown(wrath, hud.powerUpGroup)

    local bop = hud:AddTrackedCooldown(1022)
    hud:AddUtilityCooldown(bop, hud.defenseGroup)
    local divineprotection = hud:AddTrackedCooldown(403876)
    hud:AddUtilityCooldown(divineprotection, hud.defenseGroup)
end
