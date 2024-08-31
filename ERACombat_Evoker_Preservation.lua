---comment
---@param cFrame ERACombatFrame
---@param talents ERACombat_EvokerCommonTalents
function ERACombatFrames_EvokerPreservationSetup(cFrame, talents)
    local essence = ERACombatEvokerEssence:create(cFrame, -88, -32, 1, 2)

    local combatHealth = ERACombatHealth:Create(cFrame, -16, -77, 141, 12, 2)
    ERACombatPower:Create(cFrame, -16, -92, 141, 12, 0, true, 0.2, 0.1, 1, 2)

    local timers = ERACombatTimersGroup:Create(cFrame, -144, -32, 1.5, false, true, 2)
    ---@cast timers ERACombatTimers_Evoker
    timers.offsetIconsX = 16
    timers.offsetIconsY = -40

    local tParams = {
        quellX = 2,
        quellY = 3,
        unravelX = 2,
        unravelY = 2,
        unravelPrio = 2
    }

    local utility = ERACombat_EvokerSetup(cFrame, timers, tParams, talents, 2)

    local grid = ERACombatGrid:Create(cFrame, -151, -8, "BOTTOMRIGHT", 2, 360823, "Magic", "Poison")
    grid:AddTrackedBuff(364343, 0, 1, 0.0, 1.0, 0.5, 0.0, 1.0, 0.5, nil) -- echo
    grid:AddTrackedBuff(366155, 1, 1, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0, nil) -- reversion
    grid:AddTrackedBuff(357170, 2, 1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, nil) -- dilation
end

---comment
---@param cFrame ERACombatFrame
---@param talents ERACombat_EvokerCommonTalents
function ERACombatFrames_EvokerPreservationSetup_OLD(cFrame, talents)
    local grid = ERACombatGrid:Create(cFrame, -141, -8, "BOTTOMRIGHT", 2, 360823, "Magic", "Poison")

    local essence = ERACombatEvokerEssence:create(cFrame, -77, -77, 1, 2)

    local combatHealth = ERACombatHealth:Create(cFrame, -8, -121, 141, 16, 2)
    ERACombatPower:Create(cFrame, -8, -144, 141, 16, 0, true, 0.2, 0.1, 1, 2)



    local talent_spiritbloom = ERALIBTalent:Create(115546)
    local talent_dilation = ERALIBTalent:Create(115650)
    local talent_anomaly = ERALIBTalent:Create(115561)
    local talent_reversion = ERALIBTalent:Create(115652)
    local talent_dream_flight = ERALIBTalent:Create(115573)
    local talent_stasis = ERALIBTalent:Create(115567)

    -- GRID --

    -- spellID, position, priority, rC, gC, bC, rB, gB, bB, talent
    grid:AddTrackedBuff(364343, 0, 1, 0.0, 1.0, 0.5, 0.0, 1.0, 0.5, nil) -- echo
    grid:AddTrackedBuff(366155, 1, 1, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0, nil) -- reversion
    grid:AddTrackedBuff(357170, 2, 1, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, nil) -- dilation

    -- TIMER --

    local first_column = -0.5
    local second_column = first_column + 0.8
    local third_column = second_column + 0.8

    -- hover
    timers:AddCooldownIcon(timers:AddTrackedCooldown(358267), nil, first_column, 0.5, true, true)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(360995), nil, first_column, 1.5, true, true) -- embrace
    timers:AddCooldownIcon(timers:AddTrackedCooldown(357170, talent_dilation), nil, first_column, 2.5, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(373861, talent_anomaly), nil, first_column, 3.5, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(366155, talent_reversion), nil, first_column, 4.5, true, true)
    timers:AddCooldownIcon(timers:AddTrackedCooldown(357210), 4622450, first_column, 2.5, true, true) -- deep breath

    local fireBreathCooldown = timers:AddTrackedCooldown(357208)
    local fireBreathCooldownIcon = timers:AddCooldownIcon(fireBreathCooldown, nil, second_column, 2, true, true)

    local dreamBreathCooldown = timers:AddTrackedCooldown(355936)
    local dreamBreathCooldownIcon = timers:AddCooldownIcon(dreamBreathCooldown, nil, second_column, 3, true, true)

    local spiritBloomCooldown = timers:AddTrackedCooldown(367226, talent_spiritbloom)
    local spiritBloomCooldownIcon = timers:AddCooldownIcon(spiritBloomCooldown, nil, second_column, 4, true, true)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(357210), nil, first_column, -0.5, true, true) -- deep breath
    timers:AddCooldownIcon(timers:AddTrackedCooldown(359816, talent_dream_flight), nil, second_column, 5, true, true)

    timers:AddKick(351338, third_column, 3.5, ERALIBTalent:Create(115620))

    -- leaping flame
    local leapingBuff = timers:AddTrackedBuff(370901, ERALIBTalent:Create(115657))
    local leapingBar = timers:AddAuraBar(leapingBuff, nil, 1, 0.7, 0)
    function leapingBar:GetRemDurationOr0IfInvisible(t)
        if (self.aura.remDuration < 5 or fireBreathCooldown.remDuration < 4) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    -- stasis
    --local stasisAccTimer = timers:AddTrackedBuff(370537, talent_stasis)
    local stasisReleaseTimer = timers:AddTrackedBuff(370562, talent_stasis)
    timers:AddAuraBar(stasisReleaseTimer, nil, 0.8, 0.7, 0.2)

    local unravelIcon = ERACombatFrames_EvokerCommonTimerSetup(timers, third_column, 2.5)

    function timers:PreUpdateCombat(t)
        unravelIcon.cd:preUpdate(t)
        self.hasteEvoker = 1 / (1 + GetHaste() / 100)
    end

    -- UTILITY --

    local utility = ERACombatFrames_EvokerMakeUtility(cFrame, false, 2)
    utility:AddTrinket1Cooldown(-6, 0, nil)
    utility:AddTrinket2Cooldown(-7, 0, nil)
    utility:AddCooldown(-1.5, 1.9, 360995, nil, false)                         -- embrace out of combat
    utility:AddCooldown(-2, 0, 370960, nil, true, ERALIBTalent:Create(115549)) -- communion
    utility:AddCooldown(-3, 1, 370553, nil, true, ERALIBTalent:Create(115665)) -- tip
    utility:AddCooldown(-4, 1, 370537, nil, true, ERALIBTalent:Create(115567)) -- stasis
    utility:AddCooldown(-5, 1, 363534, nil, true, ERALIBTalent:Create(115651)) -- rewind
    -- out of combat :
    utility:AddCooldown(-2, 3, 366155, nil, false, talent_reversion)
    utility:AddCooldown(-3, 2, 373861, nil, false, talent_anomaly) -- anomaly
    utility:AddCooldown(-4, 2, 357208, nil, false)                 -- fire breath
    utility:AddCooldown(-5, 2, 355936, nil, false)                 -- dream breath
    utility:AddCooldown(-6, 2, 367226, nil, false, talent_spiritbloom)
    utility:AddCooldown(-6, 1, 357170, nil, false, talent_dilation)
    utility:AddCooldown(-4, 0, 357210, nil, false) -- deep breath
    utility:AddCooldown(-5, 0, 359816, nil, false, talent_dream_flight)
end
