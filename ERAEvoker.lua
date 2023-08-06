function ERACombatFrames_EvokerSetup(cFrame)
    local devastationActive = 1
    local preservationActive = 2
    local augmentationActive = 3

    ERAOutOfCombatStatusBars:Create(cFrame, 0, -101, 128, 16, 0, true, 0.4, 0.4, 0.8, false, devastationActive, preservationActive, augmentationActive)

    local essence = ERACombatEvokerEssence:create(cFrame, -111, -98, 0, devastationActive, augmentationActive)

    local combatHealth = ERACombatHealth:Create(cFrame, -191, -16, 151, 22, devastationActive, augmentationActive)

    local enemies = ERACombatEnemies:Create(cFrame, devastationActive, augmentationActive)

    if (devastationActive) then
        ERACombatFrames_EvokerDevastationSetup(cFrame, essence, enemies, combatHealth)
    end
    if (preservationActive) then
        ERACombatFrames_EvokerPreservationSetup(cFrame)
    end
    if (augmentationActive) then
        ERACombatFrames_EvokerAugmentationSetup(cFrame, essence, enemies, combatHealth)
    end
end

------------------------------------------------------------------------------------------------------------------------
---- COMMON ------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatFrames_EvokerDPS_secondY = -1.5
ERACombatFrames_EvokerDPS_firstColumnOffset = -0.5

function ERACombatFrames_EvokerDPSSetup(cFrame, spec, firebreath_alternative_talent)
    local timers = ERACombatTimersGroup:Create(cFrame, -101, 4, 1.5, false, spec)
    timers.offsetIconsX = 16
    timers.offsetIconsY = -8

    -- hover
    timers:AddCooldownIcon(timers:AddTrackedCooldown(358267), nil, -1, ERACombatFrames_EvokerDPS_secondY, true, true)
    timers:AddAuraBar(timers:AddTrackedBuff(358267), nil, 1, 1, 1)

    local firebreath_alternative = {}
    firebreath_alternative.id = 382266
    firebreath_alternative.talent = firebreath_alternative_talent
    local fireBreathCooldown = timers:AddTrackedCooldown(357208, nil, firebreath_alternative)
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

    return timers, fireBreathCooldown, leapingBuff, firebreath_alternative
end

function ERACombatFrames_EvokerMakeUtility(cFrame, includeEmbrace, ...)
    local utility = ERACombatUtilityFrame:Create(cFrame, 0, -202, ...)

    utility:AddMissingBuffAnyCaster(4622448, 0, -1.5, ERALIBTalent:CreateLevel(60), 381748)                        -- bronze buff
    utility:AddMissingBuffOnGroupMember(4630412, 1, -1.5, ERALIBTalent:Create(115669), 369459).onlyOnHealer = true -- source

    utility:AddWarlockHealthStone(-3.5, -0.9)
    utility:AddCooldown(-3, 0, 374348, nil, true, ERALIBTalent:Create(115658)) -- renewing
    if (includeEmbrace) then
        utility:AddCooldown(-2, 0, 360995, nil, true, ERALIBTalent:Create(115655))
    end
    utility:AddCooldown(-1.5, 0.9, 358267, nil, false)                              -- hover
    utility:AddWarlockPortal(-2.5, -0.9)
    utility:AddCooldown(-1.5, -0.9, 374227, nil, true, ERALIBTalent:Create(115661)) -- zephyr
    utility:AddCooldown(-0.5, -0.9, 374968, nil, true, ERALIBTalent:Create(115666)) -- spiral
    utility:AddCooldown(-1, 0, 370665, nil, true, ERALIBTalent:Create(115596))      -- rescue
    utility:AddCooldown(0, 0, 357214, nil, true)                                    -- buffet
    utility:AddCooldown(1, 0, 368970, nil, true)                                    -- swipe
    utility:AddCooldown(2, 0, 372048, nil, true, ERALIBTalent:Create(115607))       -- oppression
    utility:AddCooldown(3, 0, 369536, nil, false)                                   -- soar
    utility:AddCooldown(1.5, 1, 358385, nil, true)                                  -- landslide
    utility:AddCooldown(2.5, 1, 360806, nil, true, ERALIBTalent:Create(115601))     -- sleep
    utility:AddCooldown(2, 2, 363916, nil, true, ERALIBTalent:Create(115613))       -- obsidian
    utility:AddDefensiveDispellCooldown(2, 3, 365585, nil, ERALIBTalent:Create(115615), "Poison")
    utility:AddDefensiveDispellCooldown(2.9, 2.5, 374251, nil, ERALIBTalent:Create(115602), "Poison", "Curse", "Disease", "Bleed")

    return utility
end

function ERACombatFrames_EvokerMakeUnravel(timers, x, y)
    local cooldown = timers:AddTrackedCooldown(368432, ERALIBTalent:Create(115617))
    cooldown.absorbValue = 0
    function cooldown:preUpdate(t)
        local a = UnitGetTotalAbsorbs("target")
        if (a and a > 0) then
            self.absorbValue = a
        else
            self.absorbValue = 0
        end
        local u, nomana = IsUsableSpell(self.spellID)
        self.usable = u or nomana
    end

    local icon = timers:AddCooldownIcon(cooldown, nil, x, y, true, true)
    function icon:OverrideTimerVisibility()
        if (self.cd.usable) then
            self.icon:SetAlpha(1.0)
            return true
        else
            if (self.cd.remDuration > 0) then
                self.icon:SetAlpha(0.4)
            else
                self.icon:SetAlpha(0.1)
            end
            return false
        end
    end

    return icon
end

------------------------------------------------------------------------------------------------------------------------
---- DEVASTATION -------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_EvokerDevastationSetup(cFrame, essence, enemies, combatHealth)
    local talent_surge = ERALIBTalent:Create(115581)
    local talent_not_surge = ERALIBTalent:CreateNotTalent(115581)
    local talent_firestorm = ERALIBTalent:Create(115585)
    local talent_dragonrage = ERALIBTalent:Create(115643)
    local talent_not_dragonrage = ERALIBTalent:CreateNotTalent(115643)
    local talent_animosity = ERALIBTalent:Create(115642) -- ? change ID of Dragonrage ? : 375087 -> 375797 ou 375088 ?
    local talent_not_animosity = ERALIBTalent:CreateNotTalent(115642)
    local talent_shattering = ERALIBTalent:Create(115627)
    local talent_everburning = ERALIBTalent:Create(115622)
    local talent_not_everburning = ERALIBTalent:CreateNotTalent(115622)
    local talent_quell = ERALIBTalent:Create(115620)
    local talent_tip = ERALIBTalent:Create(115665)
    local talent_big_empower = ERALIBTalent:Create(115586)
    local talent_iridescence = ERALIBTalent:Create(115633)

    local timers, fireBreathCooldown, leapingBuff, firebreath_alternative = ERACombatFrames_EvokerDPSSetup(cFrame, 1, talent_big_empower)

    local surge_alternative = {}
    surge_alternative.id = 382411
    surge_alternative.talent = talent_big_empower

    timers:AddChannelInfo(356995, 0.75)

    -- TIMER --

    local fireBreathCooldownIcon = timers:AddCooldownIcon(fireBreathCooldown, nil, -2, 0, true, true)

    local burstTimer = timers:AddTrackedBuff(359618)

    local surgeCooldown = timers:AddTrackedCooldown(359073, talent_surge, surge_alternative)
    local surgeCooldownIcon = timers:AddCooldownIcon(surgeCooldown, nil, -3, 0, true, true)

    local shatterCooldown = timers:AddTrackedCooldown(370452, talent_shattering)
    local shatterIcons = {}
    table.insert(shatterIcons, timers:AddCooldownIcon(shatterCooldown, nil, -3, 0, true, true, talent_not_surge))
    table.insert(shatterIcons, timers:AddCooldownIcon(shatterCooldown, nil, -4, 0, true, true, talent_surge))
    local shatterTimer = timers:AddTrackedDebuff(370452, talent_shattering)
    timers:AddAuraBar(shatterTimer, nil, 1, 0.3, 1)

    local firestormCooldown = timers:AddTrackedCooldown(368847, talent_firestorm)
    local firestormIcons = {}
    for i = 0, 2 do
        table.insert(firestormIcons, timers:AddCooldownIcon(firestormCooldown, nil, -3 - i, 0, true, true, ERALIBTalent:CreateCount(i, talent_surge, talent_shattering)))
    end

    local blossomCooldown = timers:AddTrackedCooldown(355913)
    local blossomIcons = {}
    for i = 0, 3 do
        table.insert(blossomIcons, timers:AddCooldownIcon(blossomCooldown, nil, -3 - i, 0, true, true, ERALIBTalent:CreateCount(i, talent_surge, talent_shattering, talent_firestorm)))
    end

    timers:AddKick(351338, ERACombatFrames_EvokerDPS_firstColumnOffset, 3, talent_quell)

    local instaflameTimer = timers:AddTrackedBuff(375802, ERALIBTalent:Create(115624))
    local instaflameBar = timers:AddAuraBar(instaflameTimer, nil, 0, 1, 0)
    function instaflameBar:GetRemDurationOr0IfInvisible(t)
        if (instaflameTimer.remDuration <= 3 or instaflameTimer.stacks > 1) then
            return self.aura.remDuration
        else
            return 0
        end
    end
    local instaflameIcon = timers:AddProc(instaflameTimer, nil, ERACombatFrames_EvokerDPS_firstColumnOffset, 2, false, true)

    local chargedBlastTimer = timers:AddTrackedBuff(370454, ERALIBTalent:Create(115628))
    timers:AddStacksProgressIcon(chargedBlastTimer, nil, ERACombatFrames_EvokerDPS_firstColumnOffset, 0, 20)

    local burningTimer = timers:AddTrackedDebuff(357209)
    local buringBar = timers:AddAuraBar(burningTimer, nil, 1, 1, 0, talent_everburning)
    function buringBar:GetRemDurationOr0IfInvisible(t)
        if (self.aura.remDuration + 1 < fireBreathCooldown.remDuration) then -- +1 arbitraire (à théorycrafter)
            return self.aura.remDuration
        else
            return 0
        end
    end

    local deepCooldownIcon = timers:AddCooldownIcon(timers:AddTrackedCooldown(357210), 4622450, -2, ERACombatFrames_EvokerDPS_secondY, true, true)

    timers:AddCooldownIcon(timers:AddTrackedCooldown(375087, talent_dragonrage), nil, -3, ERACombatFrames_EvokerDPS_secondY, true, true)
    local rageTimer = timers:AddTrackedBuff(375087, talent_dragonrage)
    timers:AddAuraBar(rageTimer, nil, 1, 0.5, 0.1, talent_dragonrage)

    local tipCooldown = timers:AddTrackedCooldown(370553, talent_tip)
    timers:AddCooldownIcon(tipCooldown, nil, -3, ERACombatFrames_EvokerDPS_secondY, true, true, talent_not_dragonrage)
    timers:AddCooldownIcon(tipCooldown, nil, -4, ERACombatFrames_EvokerDPS_secondY, true, true, talent_dragonrage)

    local iriRedTimer = timers:AddTrackedBuff(386353, talent_iridescence)
    timers:AddAuraBar(iriRedTimer, nil, 1, 0, 0).showStacks = true
    local iriBlueTimer = timers:AddTrackedBuff(386399, talent_iridescence)
    timers:AddAuraBar(iriBlueTimer, nil, 0, 0, 1).showStacks = true

    -- UTILITY --

    local utility = ERACombatFrames_EvokerMakeUtility(cFrame, true, 1)

    utility:AddTrinket1Cooldown(-5, 1, nil)
    utility:AddTrinket2Cooldown(-5, 0, nil)

    local out_of_combat_info = ERACombatUtilityFrame:Create(cFrame, -128, 0, 1)
    out_of_combat_info:AddCooldown(0, 0, 357208, nil, false, nil, firebreath_alternative) -- fire breath
    out_of_combat_info:AddCooldown(-1, 0, 359073, nil, false, talent_surge, surge_alternative)
    out_of_combat_info:AddCooldown(-2, 0, 355913, nil, false)                             -- blossom
    out_of_combat_info:AddCooldown(0, -1, 368847, nil, false, talent_firestorm)
    out_of_combat_info:AddCooldown(-1, -1, 357210, 4622450, false)                        -- deep breath
    out_of_combat_info:AddCooldown(-2, -1, 375087, nil, false, talent_dragonrage)
    out_of_combat_info:AddCooldown(-3, -1, 370553, nil, false, talent_tip)

    -- PRE UPDATE --

    local unravelIcon = ERACombatFrames_EvokerMakeUnravel(timers, ERACombatFrames_EvokerDPS_firstColumnOffset, 1)

    function timers:PreUpdateCombat(t)
        unravelIcon.cd:preUpdate(t)
    end

    --[[

    PRIO

    1 - shatter (good spells available)
    2 - unravel
    3 - multiflame expire soon
    4 - fire breath
    5 - pyre (high essence or buffs)
    6 - disintegrate (high essence)
    7 - surge
    8 - firestorm (2+ targets)
    9 - living flame proc
    10 - firestorm (refresh flames)
    11 - pyre (refresh flames)
    12 - shatter
    13 - blossom
    14 - filler flame
    15 - filler azur
    16 - deep

    ]]

    for _, i in ipairs(shatterIcons) do
        function i:computeAvailablePriority()
            if (unravelIcon.cd.talentActive and unravelIcon.cd.remDuration <= 1 and unravelIcon.cd.usable) then
                return 1
            end
            if (fireBreathCooldown.remDuration <= 1) then
                return 1
            end
            if (essence.currentPoints >= 3) then
                return 1
            end
            if (talent_surge:PlayerHasTalent() and surgeCooldown.remDuration <= 1) then
                return 1
            end
            if (talent_firestorm:PlayerHasTalent() and firestormCooldown.remDuration <= 1 and enemies:GetCount() > 2) then
                return 1
            end
            return 12
        end
    end

    function unravelIcon:computeAvailablePriority()
        if (self.cd.usable) then
            return 2
        else
            return 0
        end
    end

    function fireBreathCooldownIcon:computeAvailablePriority()
        return 4
    end

    local pyreDump = timers:AddPriority(4622468)
    function pyreDump:computePriority(t)
        if (essence.currentPoints >= 2 or burstTimer.remDuration > timers.remGCD + 0.1) then
            if (
                    (essence.currentPoints >= essence.maxPoints - 1 and enemies:GetCount() > 1)
                    or
                    (chargedBlastTimer.stacks >= 18)
                ) then
                return 5
            elseif (talent_everburning:PlayerHasTalent() and burningTimer.remDuration > timers.remGCD + 0.2 and burningTimer.remDuration + 1 < fireBreathCooldown.remDuration) then
                return 11
            else
                return 0
            end
        else
            return 0
        end
    end

    local disinDump = timers:AddPriority(4622451)
    function disinDump:computePriority(t)
        if (essence.currentPoints >= essence.maxPoints - 1 and enemies:GetCount() <= 2) then
            return 6
        else
            return 0
        end
    end

    function surgeCooldownIcon:computeAvailablePriority()
        return 7
    end

    for _, i in ipairs(firestormIcons) do
        function i:computeAvailablePriority()
            if (enemies:GetCount() > 1) then
                return 8
            elseif (talent_everburning:PlayerHasTalent() and burningTimer.remDuration > 2 and burningTimer.remDuration + 1 < fireBreathCooldown.remDuration) then
                return 10
            else
                return 0
            end
        end
    end

    local instaflameDump = timers:AddPriority(135827)
    function instaflameDump:computePriority(t)
        if (instaflameTimer.stacks > 0) then
            return 9
        else
            return 0
        end
    end

    for _, i in ipairs(blossomIcons) do
        function i:computeAvailablePriority()
            if (combatHealth.currentHealth / combatHealth.maxHealth < 0.85) then
                return 13
            else
                return 0
            end
        end
    end

    local flameDump = timers:AddPriority(4622464)
    function flameDump:computePriority(t)
        if (enemies:GetCount() <= 1) then
            return 14
        elseif (0 < leapingBuff.remDuration and leapingBuff.remDuration < 4) then
            return 3
        else
            return 0
        end
    end

    local azurDump = timers:AddPriority(4622447)
    function azurDump:computePriority(t)
        if (enemies:GetCount() > 1) then
            return 15
        else
            return 0
        end
    end

    function deepCooldownIcon:computeAvailablePriority()
        return 16
    end
end

------------------------------------------------------------------------------------------------------------------------
---- PRESERVATION ------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_EvokerPreservationSetup(cFrame)
    local grid = ERACombatGrid:Create(cFrame, -133, -8, "BOTTOMRIGHT", 2, 360823, "Magic", "Poison")

    local essence = ERACombatEvokerEssence:create(cFrame, -77, -77, 1, 2)

    local combatHealth = ERACombatHealth:Create(cFrame, -8, -121, 141, 16, 2)
    ERACombatPower:Create(cFrame, -8, -144, 141, 16, 0, true, 0.2, 0.1, 1, 2)

    local timers = ERACombatTimersGroup:Create(cFrame, -144, -88, 1.5, false, 2)
    timers.offsetIconsX = 16
    timers.offsetIconsY = 16

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
    timers:AddAuraBar(timers:AddTrackedBuff(358267), nil, 1, 1, 1)

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

    local unravelIcon = ERACombatFrames_EvokerMakeUnravel(timers, third_column, 2.5)

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
    utility:AddCooldown(-3, 2, 373861, nil, false, talent_anomaly)             -- anomaly
    utility:AddCooldown(-4, 2, 357208, nil, false)                             -- fire breath
    utility:AddCooldown(-5, 2, 355936, nil, false)                             -- dream breath
    utility:AddCooldown(-6, 2, 367226, nil, false, talent_spiritbloom)
    utility:AddCooldown(-6, 1, 357170, nil, false, talent_dilation)
    utility:AddCooldown(-4, 0, 357210, nil, false) -- deep breath
    utility:AddCooldown(-5, 0, 359816, nil, false, talent_dream_flight)
end

------------------------------------------------------------------------------------------------------------------------
---- AUGMENTATION ------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
function ERACombatFrames_EvokerAugmentation_EruptionCastTime(timers, talent_short_eruption, talent_burst_eruption, burstTimer)
    local mult
    if (talent_burst_eruption:PlayerHasTalent() and burstTimer.remDuration > timers.occupied) then
        mult = 0.6
    else
        mult = 1
    end
    if (talent_short_eruption:PlayerHasTalent()) then
        mult = mult * 0.8
    end
    return mult * 2.5 / timers.haste
end

function ERACombatFrames_EvokerAugmentationSetup(cFrame, essence, enemies, combatHealth)
    local talent_prescience = ERALIBTalent:Create(115675)
    local talent_not_prescience = ERALIBTalent:CreateNotTalent(115675)
    local talent_blistering = ERALIBTalent:Create(115508)
    local talent_quell = ERALIBTalent:Create(115620)
    local talent_tip = ERALIBTalent:Create(115665)
    local talent_skip = ERALIBTalent:CreateAnd(ERALIBTalent:Create(115533), ERALIBTalent:CreateNotTalent(115686))
    local talent_paradox = ERALIBTalent:Create(115526)
    local talent_strong_flame = ERALIBTalent:Create(115521)
    local talent_strong_azur = ERALIBTalent:Create(115680)
    local talent_more_burst = ERALIBTalent:Create(115519)
    local talent_cheap_eruption = ERALIBTalent:Create(115505)
    local talent_long_eruption = ERALIBTalent:CreateNotTalent(115621)
    local talent_short_eruption = ERALIBTalent:Create(115621)
    local talent_burst_eruption = ERALIBTalent:Create(115531)
    local talent_big_empower = ERALIBTalent:Create(115506)

    -- TIMER --

    local timers, fireBreathCooldown, leapingBuff, firebreath_alternative = ERACombatFrames_EvokerDPSSetup(cFrame, 3, talent_big_empower)

    local uph_alternative = {}
    uph_alternative.id = 408092
    uph_alternative.talent = talent_big_empower

    timers:AddKick(351338, ERACombatFrames_EvokerDPS_firstColumnOffset, 2, talent_quell)

    local mightCooldown = timers:AddTrackedCooldown(395152)
    local mightCooldownCooldownIcon = timers:AddCooldownIcon(mightCooldown, nil, -2, 0, true, true)

    local uphCooldown = timers:AddTrackedCooldown(396286, nil, uph_alternative)
    local uphCooldownIcon = timers:AddCooldownIcon(uphCooldown, nil, -3, 0, true, true)

    local fireBreathCooldownIcon = timers:AddCooldownIcon(fireBreathCooldown, nil, -4, 0, true, true)

    local blossomCooldown = timers:AddTrackedCooldown(355913)
    local blossomCooldownIcon = timers:AddCooldownIcon(blossomCooldown, nil, -5, 0, true, true)

    local deepCooldownIcon = timers:AddCooldownIcon(timers:AddTrackedCooldown(403631), 5199622, -2, ERACombatFrames_EvokerDPS_secondY, true, true)

    local prescienceCooldown = timers:AddTrackedCooldown(409311, talent_prescience)
    local prescienceCooldownIcon = timers:AddCooldownIcon(prescienceCooldown, nil, -3, ERACombatFrames_EvokerDPS_secondY, true, true)

    local blisteringCooldown = timers:AddTrackedCooldown(360827, talent_blistering)
    local blisteringIcons = {}
    table.insert(blisteringIcons, timers:AddCooldownIcon(blisteringCooldown, nil, -3, ERACombatFrames_EvokerDPS_secondY, true, true, talent_not_prescience))
    table.insert(blisteringIcons, timers:AddCooldownIcon(blisteringCooldown, nil, -4, ERACombatFrames_EvokerDPS_secondY, true, true, talent_prescience))

    local cpt = {}
    for i = 0, 2 do
        table.insert(cpt, ERALIBTalent:CreateCount(i, talent_prescience, talent_blistering))
    end
    local tipCooldown = timers:AddTrackedCooldown(370553, talent_tip)
    for i, c in ipairs(cpt) do
        timers:AddCooldownIcon(tipCooldown, nil, -2 - i, ERACombatFrames_EvokerDPS_secondY, true, true, c)
    end

    cpt = {}
    for i = 0, 3 do
        table.insert(cpt, ERALIBTalent:CreateCount(i, talent_prescience, talent_blistering, talent_tip))
    end
    local skipCooldown = timers:AddTrackedCooldown(404977, talent_skip)
    for i, c in ipairs(cpt) do
        timers:AddCooldownIcon(skipCooldown, 5201905, -2 - i, ERACombatFrames_EvokerDPS_secondY, true, true, c)
    end

    --local paradoxCooldown = timers:AddTrackedCooldown(406732, talent_paradox)
    --timers:AddCooldownIcon(paradoxCooldown, nil, 0, ERACombatFrames_EvokerDPS_secondY, true, true)
    local paradoxTimer = timers:AddTrackedBuff(406732, talent_paradox)
    timers:AddAuraBar(paradoxTimer, nil, 1, 0.9, 0.7)

    --local burstTimer = timers:AddTrackedBuff(359618)
    local burstTimer = timers:AddTrackedBuff(392268)

    local eruptionMarker = timers:AddMarker(0.9, 0.6, 0.5)
    function eruptionMarker:computeTimeOr0IfInvisible(haste)
        return ERACombatFrames_EvokerAugmentation_EruptionCastTime(timers, talent_short_eruption, talent_burst_eruption, burstTimer)
    end

    local mightTimer = timers:AddTrackedBuff(395296)
    local mightLongBar = timers:AddAuraBar(mightTimer, nil, 0.7, 0.6, 0.2)
    function mightLongBar:GetRemDurationOr0IfInvisible(t)
        if (self.aura.remDuration > 0.05 + self.group.occupied + ERACombatFrames_EvokerAugmentation_EruptionCastTime(self.group, talent_short_eruption, talent_burst_eruption, burstTimer)) then
            return self.aura.remDuration
        else
            return 0
        end
    end
    local mightShortBar = timers:AddAuraBar(mightTimer, nil, 0.4, 0.4, 0.4)
    function mightShortBar:GetRemDurationOr0IfInvisible(t)
        if (self.aura.remDuration <= 0.05 + self.group.occupied + ERACombatFrames_EvokerAugmentation_EruptionCastTime(self.group, talent_short_eruption, talent_burst_eruption, burstTimer)) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    -- UTILITY --

    local utility = ERACombatFrames_EvokerMakeUtility(cFrame, true, 3)

    utility:AddTrinket1Cooldown(-5, 0, nil)
    utility:AddTrinket2Cooldown(-6, 0, nil)
    utility:AddCooldown(-0.5, 0.9, 406732, nil, true, talent_paradox)
    utility:AddCooldown(0.5, -0.9, 408233, nil, true, ERALIBTalent:Create(115493))                  -- weyrnstone
    utility:AddMissingBuffAnyCaster(5199623, -1, -1.5, ERALIBTalent:Create(115518), 403264, 403265) -- attunement

    local out_of_combat_info = ERACombatUtilityFrame:Create(cFrame, -128, 0, 3)
    out_of_combat_info:AddCooldown(0, 0, 395152, nil, false)                               -- might
    out_of_combat_info:AddCooldown(-1, 0, 396286, nil, false, nil, uph_alternative)        -- uph
    out_of_combat_info:AddCooldown(-2, 0, 357208, nil, false, nil, firebreath_alternative) -- fire breath
    out_of_combat_info:AddCooldown(-3, 0, 355913, nil, false)                              -- blossom
    --out_of_combat_info:AddCooldown(0, 0, 406732, nil, false, talent_paradox)      -- paradox
    out_of_combat_info:AddCooldown(0, -1, 403631, 5199622, false)                          -- deep breath
    out_of_combat_info:AddCooldown(-1, -1, 409311, nil, false, talent_prescience)
    out_of_combat_info:AddCooldown(-2, -1, 360827, nil, false, talent_blistering)
    out_of_combat_info:AddCooldown(-3, -1, 370553, nil, false, talent_tip)
    out_of_combat_info:AddCooldown(-4, -1, 404977, nil, false, talent_skip)

    local unravelIcon = ERACombatFrames_EvokerMakeUnravel(timers, ERACombatFrames_EvokerDPS_firstColumnOffset, 0)

    function timers:PreUpdateCombat(t)
        unravelIcon.cd:preUpdate(t)
        self.hasteEvoker = 1 / (1 + GetHaste() / 100)
        --[[
        if (mightTimer.remDuration > 4 * self.hasteEvoker + 0.5) then
            self.canTryGetBurst = true
        else
            self.canTryGetBurst = false
        end
        ]]
    end

    --[[

    PRIO

    1 - might
    2 - eruption refresh (overflow)
    3 - uph refresh
    4 - firebreath refresh
    5 - living flame multiflame fading soon
    6 - prescience
    7 - blistering
    8 - eruption refresh
    9 - unravel
    10 - blossom
    11 - living flame (proc or 1 or 2 targets)
    12 - azur (not living flame 2 strikes)
    13 - eons

    ]]

    function mightCooldownCooldownIcon:computeAvailablePriority()
        return 1
    end

    local eruptionDump = timers:AddPriority(5199630)
    function eruptionDump:computePriority(t)
        if (mightTimer.remDuration > 2 * timers.hasteEvoker + 0.1) then
            if (
                    (burstTimer.stacks > 1 or (burstTimer.stacks == 1 and not talent_more_burst:PlayerHasTalent()))
                    or
                    (essence.currentPoints >= essence.maxPoints or (essence.currentPoints + 1 >= essence.maxPoints and essence.nextAvailable < 2))
                ) then
                return 2
            elseif (essence.currentPoints >= 3 or (essence.currentPoints >= 2 and talent_cheap_eruption:PlayerHasTalent())) then
                return 8
            else
                return 0
            end
        else
            return 0
        end
    end

    function uphCooldownIcon:computeAvailablePriority()
        if (mightTimer.remDuration > 2.5 * timers.hasteEvoker + 0.1) then
            return 3
        else
            return 0
        end
    end

    function fireBreathCooldownIcon:computeAvailablePriority()
        if (mightTimer.remDuration > 2.5 * timers.hasteEvoker + 0.1) then
            return 4
        else
            return 0
        end
    end

    function prescienceCooldownIcon:computeAvailablePriority()
        return 6
    end

    for _, i in ipairs(blisteringIcons) do
        function i:computeAvailablePriority()
            return 7
        end
    end

    function unravelIcon:computeAvailablePriority()
        if (self.cd.usable) then
            return 9
        else
            return 0
        end
    end

    function blossomCooldownIcon:computeAvailablePriority()
        if (combatHealth.currentHealth / combatHealth.maxHealth < 0.85) then
            return 10
        else
            return 0
        end
    end

    local flameDump = timers:AddPriority(4622464)
    function flameDump:computePriority(t)
        if (0 < leapingBuff.remDuration and leapingBuff.remDuration < 4) then
            return 5
        elseif (talent_strong_flame:PlayerHasTalent() or enemies:GetCount() <= 1) then
            return 11
        else
            return 0
        end
    end

    local azurDump = timers:AddPriority(4622447)
    function azurDump:computePriority(t)
        if (leapingBuff.remDuration <= 0 or leapingBuff.remDuration >= 4) then
            if (talent_strong_flame:PlayerHasTalent() or enemies:GetCount() < 2) then
                return 0
            else
                return 12
            end
        else
            return 0
        end
    end

    function deepCooldownIcon:computeAvailablePriority()
        return 13
    end
end

------------------------------------------------------------------------------------------------------------------------
---- ESSENCE -----------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

ERACombatEvokerEssence_size = 24
ERACombatEvokerEssence_margin = 4

ERACombatEvokerEssencePoint = {}
ERACombatEvokerEssencePoint.__index = ERACombatEvokerEssencePoint

function ERACombatEvokerEssencePoint:create(group, index)
    local p = {}
    setmetatable(p, ERACombatEvokerEssencePoint)

    p.index = index

    p.frame = CreateFrame("Frame", nil, group.frame, "ERAEvokerEssencePointFrame")
    p.frame:SetSize(ERACombatEvokerEssence_size, ERACombatEvokerEssence_size)
    p.size = ERACombatEvokerEssence_size
    p.point = p.frame.FULL_POINT
    p.trt = p.frame.TRT
    p.trr = p.frame.TRR
    p.tlt = p.frame.TLT
    p.tlr = p.frame.TLR
    p.blr = p.frame.BLR
    p.blt = p.frame.BLT
    p.brt = p.frame.BRT
    p.brr = p.frame.BRR
    ERAPieControl_Init(p)

    p.wasAvailable = false
    p.wasFilling = false
    p.wasEmpty = false

    return p
end

function ERACombatEvokerEssencePoint:updateTalent(frame, maxPoints, x, anchor)
    if (self.index > maxPoints) then
        self.frame:Hide()
    else
        self.frame:SetPoint("CENTER", frame, anchor, x, 0)
        self.frame:Show()
    end
end

function ERACombatEvokerEssencePoint:drawAvailable()
    if (not self.wasAvailable) then
        if (self.wasEmpty) then
            self.wasEmpty = false
            self.point:Show()
        end
        self.wasAvailable = true
        self.wasFilling = false
        self.point:SetVertexColor(0.5, 0.7, 0.9, 1)
    end
    ERAPieControl_SetOverlayValue(self, 0)
end

function ERACombatEvokerEssencePoint:drawFilling(part)
    if (not self.wasFilling) then
        if (self.wasEmpty) then
            self.wasEmpty = false
            self.point:Show()
        end
        self.wasAvailable = false
        self.wasFilling = true
        self.point:SetVertexColor(0.9, 0.2, 0.5, 1)
    end
    ERAPieControl_SetOverlayValue(self, 1 - part)
end

function ERACombatEvokerEssencePoint:drawEmpty()
    if (not self.wasEmpty) then
        self.wasAvailable = false
        self.wasFilling = false
        self.wasEmpty = true
        self.point:Hide()
    end
    ERAPieControl_SetOverlayValue(self, 0)
end

ERACombatEvokerEssence = {}
ERACombatEvokerEssence.__index = ERACombatEvokerEssence
setmetatable(ERACombatEvokerEssence, { __index = ERACombatModule })

function ERACombatEvokerEssence:create(cFrame, x, y, orientation, ...)
    local e = {}
    setmetatable(e, ERACombatEvokerEssence)
    e:construct(cFrame, 0.2, 0.02, false, ...)
    e.frame = CreateFrame("Frame", nil, UIParent, nil)
    if (orientation == 1) then
        e.frame:SetPoint("LEFT", UIParent, "CENTER", x, y)
    else
        e.frame:SetPoint("RIGHT", UIParent, "CENTER", x, y)
    end
    e.frame:SetSize((ERACombatEvokerEssence_size + ERACombatEvokerEssence_margin) * 6, ERACombatEvokerEssence_size)
    e.orientation = orientation
    e.currentPoints = 0
    e.maxPoints = UnitPowerMax("player", 19)
    e.nextAvailable = 0
    e.lastFull = 0
    e.points = {}
    for i = 1, 6 do
        table.insert(e.points, ERACombatEvokerEssencePoint:create(e, i))
    end
    return e
end

function ERACombatEvokerEssence:SpecInactive(wasActive)
    self.frame:Hide()
end
function ERACombatEvokerEssence:EnterCombat(fromIdle)
    self.frame:Show()
end
function ERACombatEvokerEssence:EnterVehicle(fromCombat)
    self.frame:Hide()
end
function ERACombatEvokerEssence:ExitVehicle(toCombat)
    self.frame:Show()
end
function ERACombatEvokerEssence:ResetToIdle()
    self.frame:Show()
end
function ERACombatEvokerEssence:CheckTalents()
    self:updatePoints()
    self.mustUpdatePoints = true
end
function ERACombatEvokerEssence:updatePoints()
    if (self.mustUpdatePoints) then
        self.mustUpdatePoints = false
        self.maxPoints = UnitPowerMax("player", 19)
        for i = #self.points + 1, self.maxPoints do
            table.insert(self.points, ERACombatEvokerEssencePoint:create(self, i))
        end
        local x
        local anchor
        if (self.orientation == 1) then
            x = 0.5 * (ERACombatEvokerEssence_size + ERACombatEvokerEssence_margin)
            anchor = "LEFT"
        else
            x = (0.5 - self.maxPoints) * (ERACombatEvokerEssence_size + ERACombatEvokerEssence_margin)
            anchor = "RIGHT"
        end
        for i, p in ipairs(self.points) do
            p:updateTalent(self.frame, self.maxPoints, x, anchor)
            x = x + (ERACombatEvokerEssence_size + ERACombatEvokerEssence_margin)
        end
    end
end

function ERACombatEvokerEssence:UpdateIdle(t)
    self:update(t)
    if (self.currentPoints == self.maxPoints) then
        self.frame:Hide()
    else
        self.frame:Show()
    end
end
function ERACombatEvokerEssence:UpdateCombat(t)
    self:update(t)
end

function ERACombatEvokerEssence:update(t)
    self:updatePoints()
    local points = UnitPower("player", 19)
    if (points < self.maxPoints) then
        local partial = UnitPartialPower("player", 19) / 1000
        if (self.currentPoints + 1 == points and partial < 0.1) then
            self.lastGain = t
        end
        self.currentPoints = points
        local rate = GetPowerRegenForPowerType(19)
        if ((not rate) or rate <= 0) then
            rate = 0.2
        end
        local duration = 1 / rate
        if (self.lastGain) then
            local delta = t - self.lastGain
            if (delta < 2 * duration) then
                --local partial_weight = partial * partial
                -- sigmoide : les valeurs basses de UnitPartialPower ont l'air d'être moins fiables que les hautes
                local partial_weight = 0.5 * 1 / (1 + exp(-13 * (partial - 0.5)))
                if (delta > duration) then
                    if (delta > duration * 1.1618033988749894) then
                        delta = delta - duration
                    else
                        delta = duration
                    end
                end
                local estimated = delta / duration
                partial = (partial * partial_weight + estimated) / (1 + partial_weight)
            end
            --[[
            if (delta < 3 * duration) then
                while delta > duration do
                    delta = delta - duration
                end
                local estimated = delta / duration
                if (math.abs(estimated - partial) < 0.1) then
                    partial = estimated
                end
            end
            ]]
        end
        self.nextAvailable = duration * (1 - partial)
        for i = 1, points do
            self.points[i]:drawAvailable()
        end
        self.points[points + 1]:drawFilling(partial)
        for i = points + 2, self.maxPoints do
            self.points[i]:drawEmpty()
        end
    else
        self.currentPoints = points
        self.nextAvailable = 0
        for i = 1, points do
            self.points[i]:drawAvailable()
        end
    end
end
