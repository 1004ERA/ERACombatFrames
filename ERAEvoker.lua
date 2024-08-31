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
    local timers = ERACombatTimersGroup:Create(cFrame, -101, 4, 1.5, false, false, spec)
    timers.offsetIconsX = 16
    timers.offsetIconsY = -8

    -- hover
    timers:AddCooldownIcon(timers:AddTrackedCooldown(358267), nil, -1, ERACombatFrames_EvokerDPS_secondY, true, true)

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

local function ERACombatFrames_EvokerMakeUtility(cFrame, includeEmbrace, ...)
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
    utility:AddDefensiveDispellCooldown(2, 3, 365585, nil, ERALIBTalent:Create(115615), "poison")
    utility:AddDefensiveDispellCooldown(2.9, 2.5, 374251, nil, ERALIBTalent:Create(115602), "poison", "curse", "disease", "bleed")

    return utility
end

local function ERACombatFrames_EvokerCommonTimerSetup(timers, unravelX, unravelY)
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

    local icon = timers:AddCooldownIcon(cooldown, nil, unravelX, unravelY, true, true)
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

    timers:AddAuraBar(timers:AddTrackedBuff(358267), nil, 1, 1, 1)                                    -- hover
    timers:AddAuraBar(timers:AddTrackedBuff(363916), nil, 0.5, 0.4, 0.1, ERALIBTalent:Create(115613)) -- obsidian scales

    return icon
end

------------------------------------------------------------------------------------------------------------------------
---- PRESERVATION ------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

function ERACombatFrames_EvokerPreservationSetup(cFrame)

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

    local unravelIcon = ERACombatFrames_EvokerCommonTimerSetup(timers, ERACombatFrames_EvokerDPS_firstColumnOffset, 0)

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
