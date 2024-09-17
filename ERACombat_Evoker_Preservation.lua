---@param cFrame ERACombatFrame
---@param talents ERACombat_EvokerCommonTalents
function ERACombatFrames_EvokerPreservationSetup(cFrame, talents)
    local talent_spiritbloom = ERALIBTalent:Create(115546)
    local talent_dilation = ERALIBTalent:Create(115650)
    local talent_anomaly = ERALIBTalent:Create(115561)
    local talent_reversion = ERALIBTalent:Create(115652)
    local talent_dream_flight = ERALIBTalent:Create(115573)
    local talent_stasis = ERALIBTalent:Create(115567)
    local talent_comunion = ERALIBTalent:Create(115549)
    local talent_rewind = ERALIBTalent:Create(115651)

    local hud = ERAHUD:Create(cFrame, 1.5, false, true, 0, 0.0, 0.0, 1.0, false, 2)
    ---@cast hud ERAEvokerHUD
    hud.power.hideFullOutOfCombat = true
    hud.powerHeight = 12

    ERAEvokerCommonSetup(hud, "TO_RIGHT", 369299, 1, talents, nil, 2)

    if ERACombatOptions_IsSpecModuleActive(2, ERACombatOptions_Grid) then
        local grid = ERACombatGrid:Create(cFrame, "BOTTOMRIGHT", 2, 360823, "Magic", "Poison")
        grid:AddTrackedBuff(364343, 0, 1, 0.0, 1.0, 0.5, 0.0, 1.0, 0.5, nil) -- echo
        grid:AddTrackedBuff(366155, 1, 1, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0, nil) -- reversion
        grid:AddTrackedBuff(357170, 2, 1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, nil) -- dilation
    end

    --- rotation ---

    local dilationIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(357170, talent_dilation))
    local firebreathIcon = hud:AddRotationCooldown(hud.evoker_firebreathCooldown)
    local dreamBreathIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(355936))
    local spiritBloomIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(367226, talent_spiritbloom))
    local embraceIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(360995, talents.embrace))
    local anomalyIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(373861, talent_anomaly))
    local reversionIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(366155, talent_reversion))
    local engulfIcon = hud:AddRotationCooldown(hud:AddTrackedCooldown(443328, talents.engulf))

    --[[

    PRIO

    1 - unravel
    2 - embrace
    3 - firebreath
    4 - engulf

    ]]

    function embraceIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 2
    end

    function firebreathIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 3
    end

    function engulfIcon.onTimer:ComputeAvailablePriorityOverride(t)
        return 4
    end

    --- bars ---

    local stasisAccTimer = hud:AddTrackedBuff(370537, talent_stasis)
    hud:AddAuraBar(stasisAccTimer, nil, 1.0, 0.5, 0.0)
    local stasisReleaseTimer = hud:AddTrackedBuff(370562, talent_stasis)
    hud:AddAuraBar(stasisReleaseTimer, nil, 0.8, 0.7, 0.2)

    --- utility ---

    local statisIcon = hud:AddUtilityCooldown(hud:AddTrackedCooldown(370537, talent_stasis), hud.powerUpGroup, nil, -2)
    function statisIcon:HighlightOverride(t, combat)
        return stasisAccTimer.remDuration > 0
    end
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(357210), hud.powerUpGroup, 4622450, 1.5) -- deep breath

    hud:AddUtilityCooldown(hud:AddTrackedCooldown(359816, talent_dream_flight), hud.healGroup, nil, -3)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(363534, talent_rewind), hud.healGroup, nil, -2)
    hud:AddUtilityCooldown(hud:AddTrackedCooldown(370960, talent_comunion), hud.healGroup, nil, -1)
end
