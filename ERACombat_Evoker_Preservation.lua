---comment
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

    local essence = ERACombatEvokerEssence:create(cFrame, -77, -32, 1, 2)

    local combatHealth = ERACombatHealth:Create(cFrame, -16, -77, 121, 12, 2)
    ERACombatPower:Create(cFrame, -16, -92, 121, 12, 0, true, 0.2, 0.1, 1, 2)

    local timers = ERACombatTimersGroup:Create(cFrame, -144, -32, 1.5, false, true, 2)
    ---@cast timers ERACombatTimers_Evoker
    timers.offsetIconsX = 16
    timers.offsetIconsY = -40

    local first_column_X = -0.5
    local first_column_Y = 1.5
    local second_column_X = first_column_X + 0.8
    local second_column_Y = first_column_Y + 0.5
    local third_column_X = first_column_X + 2 * 0.8
    local third_column_Y = first_column_Y

    local tParams = {
        quellX = third_column_X,
        quellY = third_column_Y + 3,
        unravelX = third_column_X,
        unravelY = third_column_Y + 2,
        unravelPrio = 2
    }

    local utility = ERACombat_EvokerSetup(cFrame, timers, tParams, talents, 2)

    local grid = ERACombatGrid:Create(cFrame, -151, -8, "BOTTOMRIGHT", 2, 360823, "Magic", "Poison")
    grid:AddTrackedBuff(364343, 0, 1, 0.0, 1.0, 0.5, 0.0, 1.0, 0.5, nil) -- echo
    grid:AddTrackedBuff(366155, 1, 1, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0, nil) -- reversion
    grid:AddTrackedBuff(357170, 2, 1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, nil) -- dilation

    -- TIMERS --

    local fireBreathCooldown = timers:AddTrackedCooldown(357208)
    local fireBreathCooldownIcon = timers:AddCooldownIcon(fireBreathCooldown, nil, second_column_X, second_column_Y + 1, true, true)
    timers.evoker_firebreathCooldown = fireBreathCooldown

    local dreamBreathCooldown = timers:AddTrackedCooldown(355936)
    local dreamBreathCooldownIcon = timers:AddCooldownIcon(dreamBreathCooldown, nil, second_column_X, second_column_Y + 2, true, true)

    local spiritBloomCooldown = timers:AddTrackedCooldown(367226, talent_spiritbloom)
    local spiritBloomCooldownIcon = timers:AddCooldownIcon(spiritBloomCooldown, nil, second_column_X, second_column_Y + 3, true, true)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(360995, talents.embrace), nil, first_column_X, first_column_Y, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(357170, talent_dilation), nil, first_column_X, first_column_Y + 1, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(373861, talent_anomaly), nil, first_column_X, first_column_Y + 2, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(366155, talent_reversion), nil, first_column_X, first_column_Y + 3, true, true)

    --local stasisAccTimer = timers:AddTrackedBuff(370537, talent_stasis)
    local stasisReleaseTimer = timers:AddTrackedBuff(370562, talent_stasis)
    timers:AddAuraBar(stasisReleaseTimer, nil, 0.8, 0.7, 0.2)

    -------------
    -- UTILITY --
    -------------

    utility:AddCooldown(-1.5, 0.9, 370553, nil, true, talents.tip)
    utility:AddCooldown(-2.5, 0.9, 370537, nil, true, talent_stasis)
    utility:AddCooldown(-3.5, 0.9, 363534, nil, true, talent_rewind)

    utility:AddCooldown(-4, 0, 357210, 4622450, true) -- deep breath
    utility:AddCooldown(-3, 0, 359816, nil, true, talent_dream_flight)
    utility:AddCooldown(-2, 0, 374348, nil, true, talents.renewing)

    utility:AddCooldown(-3.5, -0.9, 370960, nil, true, talent_comunion)

    -- out of combat

    utility:AddCooldown(-2, 1.8, 357208, nil, false) -- fire breath
    utility:AddCooldown(-3, 1.8, 355936, nil, false) -- dream breath
    utility:AddCooldown(-4, 1.8, 367226, nil, false, talent_spiritbloom)
    utility:AddCooldown(-1.5, 2.7, 360995, nil, false, talents.embrace)
    utility:AddCooldown(-2.5, 2.7, 366155, nil, false, talent_reversion)
    utility:AddCooldown(-3.5, 2.7, 373861, nil, false, talent_anomaly)
    utility:AddCooldown(-4.5, 2.7, 357170, nil, false, talent_dilation)
end
