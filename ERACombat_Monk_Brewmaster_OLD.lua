---@class ERACombatTimers_MonkBrewmaster : ERACombatTimers
---@field offsetIconsX number
---@field offsetIconsY number
---@field lastInstaVivify number
---@field healthPercent number
---@field ehSlot number

---comment
---@param cFrame any
---@param enemies any
---@param monkTalents MonkCommonTalents
function ERACombatFrames_MonkBrewmasterSetup_OLD(cFrame, enemies, monkTalents)
    local talent_rsk = ERALIBTalent:Create(124985)
    local talent_bof = ERALIBTalent:Create(124843)
    local talent_not_bof = ERALIBTalent:CreateNotTalent(124843)
    local talent_no_shuffle = ERALIBTalent:CreateNotTalent(124864)
    local talent_rjw = ERALIBTalent:Create(125007)
    local talent_chib = ERALIBTalent:Create(126501)
    local talent_celestialb = ERALIBTalent:Create(124841)
    local talent_strong_rsk = ERALIBTalent:Create(124984)
    local talent_weapons = ERALIBTalent:Create(124996)
    local talent_exploding = ERALIBTalent:Create(125001)
    local talent_zenmed = ERALIBTalent:Create(125006)
    local talent_charred = ERALIBTalent:Create(124986)
    local talent_celestial_flames = ERALIBTalent:Create(124844)

    local timers = ERACombatTimersGroup:Create(cFrame, -88, 42, 1, true, false, 1)
    ---@cast timers ERACombatTimers_MonkBrewmaster
    timers.offsetIconsX = -32
    timers.offsetIconsY = -36
    local first_column_X = 0.5

    ---@type MonkCommonTimerIconParams
    local timerParams = {
        kickX = first_column_X,
        kickY = 3,
        paraX = 5,
        paraY = 5,
        todPrio = 4,
        todX = -3.5,
        todY = -0.9
    }

    ERACombatFrames_MonkTimerBars(timers, monkTalents, timerParams)

    local kegCooldown = timers:AddTrackedCooldown(121253)
    local purifCooldown = timers:AddTrackedCooldown(119582)

    ERAOutOfCombatStatusBars:Create(cFrame, 0, -77, 144, 22, 22, 3, true, 1, 1, 0, 0, 1)

    local barWidth = 151
    local barX = -181

    local health = ERACombatHealth:Create(cFrame, barX, 26, barWidth, 22, 1)

    ERACombatStagger:Create(cFrame, barX, 3, barWidth, 11, purifCooldown)

    local nrg = ERACombatPower:Create(cFrame, barX, -6, barWidth, 16, 3, false, 1.0, 1.0, 0.0, 1)
    nrg:AddConsumer(25, 606551)
    nrg:AddConsumer(65, 606551)
    local kegConsumer = nrg:AddConsumer(40, 594274)
    function kegConsumer:ComputeVisibilityOverride(t)
        if (kegCooldown.hasCharges) then
            return kegCooldown.currentCharges > 0
        else
            return kegCooldown.remDuration <= 3
        end
    end
    function kegConsumer:ComputeIconVisibilityOverride(t)
        if (kegCooldown.hasCharges) then
            self.icon:SetDesaturated(false)
        else
            if (kegCooldown.remDuration <= 0 or kegCooldown.remDuration + 0.05 <= timers.occupied) then
                self.icon:SetDesaturated(false)
            else
                self.icon:SetDesaturated(true)
            end
        end
        return true
    end

    local purifIcon = timers:AddCooldownIcon(purifCooldown, nil, -4.5, 1, true, true)

    local bokAlternative = {}
    bokAlternative.id = 100784
    bokAlternative.talent = talent_no_shuffle
    local bokCooldown = timers:AddTrackedCooldown(205523, nil, bokAlternative) -- 100784 (basic) or 205523 (with shuffle)
    local bokIcon = timers:AddCooldownIcon(bokCooldown, nil, 0, 0, true, true)
    function bokIcon:ShouldShowMainIconOverride()
        return false
    end

    local kegIcon = timers:AddCooldownIcon(kegCooldown, nil, -1, 0, true, true)

    local ehCooldown = timers:AddTrackedCooldown(322101)
    local ehIcon = timers:AddCooldownIcon(ehCooldown, nil, -2, 0, true, true)
    function ehIcon:ShouldShowMainIconOverride()
        return false
    end

    local bofCooldown = timers:AddTrackedCooldown(115181, talent_bof)
    local bofIcon = timers:AddCooldownIcon(bofCooldown, nil, -2, 0, true, true)

    local rskCooldown = timers:AddTrackedCooldown(107428, talent_rsk)
    local rskIcons = {}
    table.insert(rskIcons, timers:AddCooldownIcon(rskCooldown, nil, -2, 0, true, true, talent_not_bof))
    table.insert(rskIcons, timers:AddCooldownIcon(rskCooldown, nil, -3, 0, true, true, talent_bof))

    local rjwBuff = timers:AddTrackedBuff(116847, talent_rjw)
    local rjwCooldown = timers:AddTrackedCooldown(116847, talent_rjw)
    local rjwIcon = timers:AddCooldownIcon(rjwCooldown, nil, 0, 0, false, true)
    function rjwIcon:ShouldShowMainIconOverride()
        return false
    end
    local rjwLongBar = timers:AddAuraBar(rjwBuff, nil, 0.0, 0.6, 0.2)
    function rjwLongBar:GetRemDurationOr0IfInvisibleOverride(t)
        if (rjwCooldown.remDuration <= self.group.remGCD) then
            return 0
        else
            return self.aura.remDuration
        end
    end
    local rjwShortBar = timers:AddAuraBar(rjwBuff, nil, 0.0, 1.0, 0.7)
    function rjwShortBar:GetRemDurationOr0IfInvisibleOverride(t)
        if (rjwCooldown.remDuration <= self.group.remGCD) then
            return self.aura.remDuration
        else
            return 0
        end
    end

    local celestialbCooldown = timers:AddTrackedCooldown(322507, talent_celestialb)
    local celestialbIcon = timers:AddCooldownIcon(celestialbCooldown, nil, -1.5, -0.9, true, true)

    local chibCooldown = timers:AddTrackedCooldown(123986, talent_chib)
    local chibIcon = timers:AddCooldownIcon(chibCooldown, nil, -2.5, -0.9, true, true)

    local zenmedBuff = timers:AddTrackedBuff(115176, talent_zenmed)
    timers:AddAuraBar(zenmedBuff, nil, 0.3, 0.6, 0.3)

    local weaponsBuff = timers:AddTrackedBuff(387184, talent_weapons)
    timers:AddAuraBar(weaponsBuff, nil, 0.0, 0.0, 1.0)

    timers:AddAuraBar(timers:AddTrackedBuff(325190, talent_celestial_flames), nil, 1.0, 0.0, 0.0)
    timers:AddAuraBar(timers:AddTrackedBuff(386963, talent_charred), nil, 0.7, 0.3, 0.0)

    local instaVivifyTimer = timers:AddTrackedBuff(392883, monkTalents.vivification)
    ERACombatFrames_MonkRecurringIcon_instaVivify(timers, monkTalents.vivification, instaVivifyTimer)

    timers.lastInstaVivify = 0
    function timers:CLEU(t)
        local _, evt, _, sourceGUY, _, _, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        if (sourceGUY == self.cFrame.playerGUID and evt == "SPELL_AURA_APPLIED" and spellID == 392883) then
            self.lastInstaVivify = t
        end
    end

    timers.ehSlot = -1
    function timers:OnResetToIdle()
        self.ehSlot = ERALIB_GetSpellSlot(322101)
        self.lastInstaVivify = 0
    end

    function timers:DataUpdatedOverride(t)
        self.healthPercent = health.currentHealth / health.maxHealth

        local healMult = GetSpellBonusHealing() * (1 + (GetCombatRatingBonus(29) + GetVersatilityBonus(29)) / 100) * (1 + 0.04 * monkTalents.healingTaken4.rank) * (1 + 0.02 * monkTalents.healingDone2.rank)

        local vivifyHeal
        if (instaVivifyTimer.remDuration > 0 and nrg.currentPower >= 30) then
            nrg.bar:SetBorderColor(0.0, 1.0, 0.0)
            vivifyHeal = 6 * 1.4 * (1 + monkTalents.vivify_30pct.rank * 0.3)
        else
            nrg.bar:SetBorderColor(1.0, 1.0, 1.0)
            vivifyHeal = 0
        end

        local ehHeal
        if (ehCooldown.remDuration <= self.occupied) then
            ehHeal = 1.3 * (1 + monkTalents.strongEH.rank * 0.05)
            if (monkTalents.scalingEH:PlayerHasTalent()) then
                ehHeal = ehHeal * (2 - self.healthPercent)
            end
            if (self.ehSlot > 0) then
                local s = GetActionCount(self.ehSlot)
                if (s and s > 0) then
                    ehHeal = ehHeal + s * 3.2
                end
            end
        else
            ehHeal = 0
        end

        if (vivifyHeal > ehHeal) then
            health:SetHealingColor(1.0, 1.0, 0.0)
            health:SetHealing(vivifyHeal * healMult)
        else
            health:SetHealingColor(0.5, 0.5, 1.0)
            health:SetHealing(ehHeal * healMult)
        end
    end

    local utility = ERACombatFrames_MonkUtility(cFrame, 1, true, monkTalents)
    utility:AddCooldown(-3.5, 0.9, 115176, nil, true, talent_zenmed)
    utility:AddCooldown(-2.5, 0.9, 132578, nil, true, ERALIBTalent:Create(124849)) -- niuzao
    utility:AddCooldown(-1.5, 0.9, 387184, nil, true, talent_weapons)
    utility:AddCooldown(-0.5, 0.9, 115399, nil, true, ERALIBTalent:Create(124991)) -- black ox brew
    utility:AddCooldown(-1, 0, 325153, nil, true, talent_exploding)
    utility:AddCooldown(0, 0, 122278, nil, true, ERALIBTalent:Create(124978))      -- dampen
    -- out of combat
    utility:AddCooldown(-2, 2, 123986, nil, false, talent_chib)
    utility:AddCooldown(-4, 2, 322507, nil, false, talent_celestialb)
    utility:AddCooldown(-2, 3, 121253, nil, false) -- keg
    utility:AddCooldown(-3, 3, 107428, nil, false, talent_rsk)
    utility:AddCooldown(-4, 3, 115181, nil, false, talent_bof)
    utility:AddCooldown(-5, 3, 322101, nil, false) -- eh

    --[[

    PRIO

    1 - expel harm low health
    2 - elixir low health
    3 - vivify low health
    4 - touch of death
    5 - keg smash
    6 - bok
    7 - bof
    8 - chib many targets
    9 - chiw
    10 - expel harm
    11 - elixir
    12 - chib few targets but healing
    13 - rjw many targets
    14 - rsk
    15 - rjw few targets
    16 - celestialb
    17 - keg smash long charge
    18 - elixir
    19 - vivify
    20 - chib

    ]]

    function ehIcon:ComputeAvailablePriorityOverride()
        if (timers.healthPercent < 0.4) then
            return 1
        elseif (timers.healthPercent < 0.8) then
            return 10
        else
            return 0
        end
    end

    local vivifyPrio = timers:AddPriority(1360980)
    function vivifyPrio:ComputePriority(t)
        if (nrg.currentPower >= 30 and instaVivifyTimer.remDuration > 0) then
            if (timers.healthPercent < 0.5) then
                return 2
            elseif (timers.healthPercent < 0.8) then
                return 19
            else
                return 0
            end
        else
            return 0
        end
    end

    function kegIcon:ComputeAvailablePriorityOverride()
        return 5
    end
    local kegchargedPrio = timers:AddPriority(594274)
    function kegchargedPrio:ComputePriority(t)
        if (kegCooldown.hasCharges and 0 < kegCooldown.currentCharges and kegCooldown.currentCharges < kegCooldown.maxCharges) then
            self.icon:SetDesaturated(kegCooldown.remDuration > 2)
            if (kegCooldown.remDuration < 3) then
                return 5
            else
                return 17
            end
        else
            return 0
        end
    end

    function bokIcon:ComputeAvailablePriorityOverride()
        return 6
    end

    function bofIcon:ComputeAvailablePriorityOverride()
        return 7
    end

    function chibIcon:ComputeAvailablePriorityOverride()
        if (enemies:GetCount() > 3) then
            return 8
        elseif (timers.healthPercent < 0.8) then
            return 12
        else
            return 20
        end
    end

    local rjwPrio = timers:AddPriority(606549)
    function rjwPrio:ComputePriority(t)
        if (talent_rjw:PlayerHasTalent() and rjwBuff.remDuration <= timers.occupied) then
            local threshold
            if (talent_strong_rsk.rank == 2) then
                threshold = 4
            elseif (talent_strong_rsk.rank == 1) then
                threshold = 3
            else
                threshold = 2
            end
            if (enemies:GetCount() >= threshold) then
                return 13
            else
                return 15
            end
        else
            return 0
        end
    end

    for _, i in ipairs(rskIcons) do
        function i:ComputeAvailablePriorityOverride()
            return 14
        end
    end

    function celestialbIcon:ComputeAvailablePriorityOverride()
        return 16
    end
end

ERACombatStagger = {}
ERACombatStagger.__index = ERACombatStagger
setmetatable(ERACombatStagger, { __index = ERACombatModule })

function ERACombatStagger:Create(cFrame, x, y, barWidth, barHeight, purifyingCooldown)
    local bar = {}
    setmetatable(bar, ERACombatStagger)
    bar.frame = CreateFrame("Frame", nil, UIParent, nil)
    bar.frame:SetPoint("TOP", UIParent, "CENTER", x, y)
    bar.frame:SetSize(barWidth, barHeight)
    bar.bar = ERACombatStatusBar:create(bar.frame, 0, 0, barWidth, barHeight, 1.0, 0.0, 0.0)
    bar.purifCooldown = purifyingCooldown
    bar:construct(cFrame, -1, 0.05, false, 1)
    return bar
end

function ERACombatStagger:EnterCombat()
    self:enter()
end
function ERACombatStagger:ExitCombat()
    self:exit()
end
function ERACombatStagger:ResetToIdle()
    self:exit()
end
function ERACombatStagger:SpecInactive(wasActive)
    if (wasActive) then
        self:exit()
    end
end
function ERACombatStagger:enter()
    self.frame:Show()
    self.bar:SetAll(UnitHealthMax("player"), UnitStagger("player"), 0, 0, 0)
end
function ERACombatStagger:exit()
    self.frame:Hide()
end

function ERACombatStagger:UpdateCombat(t)
    if (self.purifCooldown.hasCharges) then
        if (self.purifCooldown.currentCharges > 0) then
            if (self.purifCooldown.currentCharges >= self.purifCooldown.maxCharges) then
                self.bar:SetMainColor(1.0, 0.0, 1.0)
            else
                self.bar:SetMainColor(1.0, 0.0, 0.5)
            end
        else
            self.bar:SetMainColor(1.0, 0.0, 0.0)
        end
    else
        if (self.purifCooldown.remDuration > 0) then
            self.bar:SetMainColor(0.8, 0.0, 0.0)
        else
            self.bar:SetMainColor(1.0, 0.0, 0.5)
        end
    end
    self.bar:SetAll(UnitHealthMax("player"), UnitStagger("player"), 0, 0, 0)
end

function ERACombatStagger:CheckTalents()
    -- rien
end
